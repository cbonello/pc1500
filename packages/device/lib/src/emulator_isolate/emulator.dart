import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:annotations/annotations.dart';
import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/clock.dart';
import 'package:device/src/emulator_isolate/dasm.dart';
import 'package:device/src/emulator_isolate/extension_module.dart';
import 'package:device/src/emulator_isolate/keyboard.dart';
import 'package:device/src/messages/messages.dart';
import 'package:lcd/lcd.dart';
import 'package:lh5801/lh5801.dart';
import 'package:lh5811/lh5811.dart';
import 'package:roms/annotations.dart' as std_users_ram;
import 'package:roms/roms.dart';

class EmulatorError extends Error {
  EmulatorError(this.message);

  final String message;

  @override
  String toString() => 'Device: $message';
}

// I/O port base addresses in ME1 (accessed as 0x10000 + base from CPU).
const int _ce153Base = 0x8000; // CE-153 (keyboard)
const int _ce150Base = 0xB000; // CE-150 (printer)
const int _ce158Base = 0xD000; // CE-158 (RS-232C)
const int _pc1500Base = 0xF000; // PC-1500 main I/O

class Emulator {
  Emulator(
    this.type,
    this.outPort, [
    this.ir0Enter,
    this.ir1Enter,
    this.ir2Enter,
    this.irExit,
    this.subroutineEnter,
    this.subroutineExit,
  ]) : _csd = ChipSelectDecoder(),
       _connector40Pins = ExtensionModule(),
       _annotations = MemoryBanksAnnotations(),
       keyboard = Keyboard() {
    _clock = Clock(freq: 1300000, fps: 50);

    // Display chip RAM (SC-882G chips 3 & 4 use 9-bit addresses,
    // responding at 0x7400-0x75FF in addition to 0x7600-0x77FF).
    final MemoryChipBase displayRam = _csd.appendRAM(
      MemoryBank.me0,
      0x7400,
      0x0200,
    );

    // Standard users system RAM and display chip area (0x7600-0x7BFF).
    final MemoryChipBase stdUserRam = _csd.appendRAM(
      MemoryBank.me0,
      0x7600,
      0x0600,
    );

    // ROM (16KB).
    final PC1500Rom pc1500Rom = PC1500Rom(PC1500RomType.a03);
    _csd.appendROM(MemoryBank.me0, 0xC000, pc1500Rom);
    _annotations.load(pc1500Rom.annotations);

    // Standard users RAM.
    if (type == HardwareDeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x4000, 0x1800); // 6KB.
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4000, 0x0800); // 2KB.
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(std_users_ram.me0RamAnnotationsJson)
              as Map<String, dynamic>;
      _annotations.load(json);
    } catch (_) {}

    // I/O ports — mapped as RAM placeholders covering the full chip-select
    // decoded range. Each LH5811 only uses 16 registers (AD0-AD3), but the
    // chip select circuit activates over 4KB blocks. Reads/writes are
    // intercepted by _memRead/_memWrite for LH5811-backed ports.
    _csd.appendROMPlaceholder(MemoryBank.me1, _ce153Base, 0x1000, 0xFF);
    _csd.appendROMPlaceholder(MemoryBank.me1, _ce150Base, 0x1000, 0xFF);
    _csd.appendROMPlaceholder(MemoryBank.me1, _ce158Base, 0x1000, 0xFF);
    _csd.appendROMPlaceholder(MemoryBank.me1, _pc1500Base, 0x1000, 0xFF);

    // LH5811 I/O port controllers.
    _pc1500IO = LH5811(
      onPortBRead: () {
        // PB3 = VCC (export model) or GND (domestic). Always 1 for export.
        // PB7 = ON key input (active low).
        return keyboard.isOnKeyPressed ? 0x7F : 0xFF;
      },
      onInterrupt: () {
        // PC-1500 I/O interrupt → CPU IR2 (maskable interrupt).
        _cpu.pins.miPin = true;
        // Workaround: LH5801 emulator only clears HLT on IR2,
        // but all interrupts should clear HLT per the datasheet.
        _cpu.cpu.hlt = false;
      },
    );

    _ce153IO = LH5811(
      onInterrupt: () {
        // CE-153 interrupt → CPU IR0.
      },
    );

    _cpu = LH5801(
      clockFrequency: 1300000,
      memRead: _memRead,
      memWrite: _memWrite,
      ir0Enter: ir0Enter,
      ir1Enter: ir1Enter,
      ir2Enter: ir2Enter,
      irExit: irExit,
      subroutineEnter: subroutineEnter,
      subroutineExit: subroutineExit,
    )..reset();
    _cpu.pins.resetPin = true;
    _cpu.pins.inputPorts = 0xFF; // No keys pressed (active low).
    // Seed the timer LFSR with a non-zero value so it can generate
    // periodic IR1 interrupts. An all-zero LFSR never advances.
    _cpu.cpu.tm.value = 1;

    _lcd = Lcd(memRead: _csd.readAt);
    displayRam.registerObserver(MemoryAccessType.write, _lcd);
    stdUserRam.registerObserver(MemoryAccessType.write, _lcd);
    _lcd.events.listen((LcdEvent event) {
      outPort.send(LcdEventSerializer().serialize(event));
    });
    _lcd.emitInitialState();

    _dasm = LH5801DASM(memRead: _memRead);
  }

  final HardwareDeviceType type;
  final SendPort outPort;
  late final Clock _clock;
  late LH5801 _cpu;
  final ChipSelectDecoder _csd;
  late Lcd _lcd;
  final ExtensionModule _connector40Pins;
  late final LH5801DASM _dasm;
  final MemoryBanksAnnotations _annotations;
  final LH5801Command? ir0Enter;
  final LH5801Command? ir1Enter;
  final LH5801Command? ir2Enter;
  final LH5801Command? irExit;
  final LH5801Command? subroutineEnter;
  final LH5801Command? subroutineExit;
  bool _running = false;

  final Keyboard keyboard;
  late final LH5811 _pc1500IO;
  late final LH5811 _ce153IO;

  /// Updates CPU IN0-IN7 based on current keyboard and strobe state.
  void updateKeyboardInput() {
    final int dda = _pc1500IO.read(0x0C);
    final int opa = _pc1500IO.read(0x0E);
    final int result = keyboard.scanIN(dda, opa);
    _cpu.pins.inputPorts = result;
    // Wake the CPU from HLT when a key is pressed.
    if (result != 0xFF) {
      _pc1500IO.triggerIRQ();
    }
    // ON key: connected to PB7 of PC-1500 I/O.
    // Sets IF1 (PB7 flag) and triggers IRQ to wake CPU via IR2.
    // The IR2 handler at E171 checks IF1 to detect the ON key.
    if (keyboard.isOnKeyPressed) {
      _pc1500IO.triggerPB7();
      _pc1500IO.triggerIRQ();
    }
  }

  /// Returns the LH5811 for a given ME1 address, or null if not I/O mapped.
  /// The chip select circuit decodes 4KB blocks, so we mask to the base.
  LH5811? _ioForAddress(int address) {
    final int base = address & 0xF000;
    if (base == _pc1500Base) return _pc1500IO;
    if (base == _ce153Base) return _ce153IO;
    // CE-150 and CE-158 not yet implemented as LH5811 — fall through to
    // the ROM placeholder which returns 0xFF.
    return null;
  }

  /// Memory read interceptor — routes I/O port reads through LH5811.
  int _memRead(int address) {
    if (address >= 0x10000) {
      final int me1Addr = address & 0xFFFF;
      final LH5811? io = _ioForAddress(me1Addr);
      if (io != null) {
        return io.read(me1Addr & 0x0F);
      }
      // ME1 reads from RAM/display addresses: route to ME0.
      // ME1 $0000-$1FFF → ME0 $4000-$5FFF (user RAM, offset by $4000).
      if (me1Addr < 0x2000) {
        return _csd.readByteAt(me1Addr + 0x4000);
      }
      // ME1 $7400-$7BFF → ME0 same address (display + system RAM).
      if (me1Addr >= 0x7400 && me1Addr < 0x7C00) {
        return _csd.readByteAt(me1Addr);
      }
      // Unhandled ME1 addresses: return 0xFF (open bus).
      return 0xFF;
    }
    return _csd.readByteAt(address);
  }

  /// Memory write interceptor — routes I/O port writes through LH5811.
  void _memWrite(int address, int value) {
    if (address >= 0x10000) {
      final int me1Addr = address & 0xFFFF;
      final LH5811? io = _ioForAddress(me1Addr);
      if (io != null) {
        final int reg = me1Addr & 0x0F;
        io.write(reg, value);
        // Update CPU IN0-IN7 when PC-1500 I/O strobe state changes.
        // DDA (0x0C) or OPA (0x0E) affect keyboard column strobes.
        if (io == _pc1500IO && (reg == 0x0C || reg == 0x0E)) {
          final int dda = _pc1500IO.read(0x0C);
          final int opa = _pc1500IO.read(0x0E);
          final int scanResult = keyboard.scanIN(dda, opa);
          _cpu.pins.inputPorts = scanResult;
        }
        return;
      }
      // ME1 writes to RAM/display addresses: route to ME0.
      // On real hardware, RAM chips respond to both ME0 and ME1. The chip
      // select circuit maps ME1 addresses differently:
      //   ME1 $0000-$1FFF → ME0 $4000-$5FFF (user RAM, offset by $4000)
      //   ME1 $7400-$7BFF → ME0 $7400-$7BFF (display + system RAM, same addr)
      if (me1Addr < 0x2000) {
        _memWrite(me1Addr + 0x4000, value);
        return;
      }
      if (me1Addr >= 0x7400 && me1Addr < 0x7C00) {
        _memWrite(me1Addr, value);
        return;
      }
      // Unhandled ME1 addresses: silently drop (no hardware responds).
      return;
    }
    _csd.writeByteAt(address, value);
    // Mirror display chip writes: chips 3 & 4 (9-bit addr, 0x7400/0x7500)
    // share the same physical RAM as chips 1 & 2 (8-bit addr, 0x7600/0x7700).
    // Writes to either range must appear in both.
    if (address >= 0x7400 && address < 0x7600) {
      _csd.writeByteAt(address + 0x0200, value);
    } else if (address >= 0x7600 && address < 0x7800) {
      _csd.writeByteAt(address - 0x0200, value);
    }
  }

  bool get isRunning => _running;




  /// Executes a single CPU instruction. Returns the number of cycles consumed.
  int step() {
    // Workaround: the LH5801 emulator only clears HLT on IR2, but
    // per the datasheet all interrupts (IR0, IR1, IR2) should clear HLT.
    // Check if the timer interrupt (IR1) is pending and clear HLT.
    if (_cpu.cpu.hlt && _cpu.cpu.t.ie && _cpu.cpu.tm.isInterruptRaised) {
      _cpu.cpu.hlt = false;
    }
    return _cpu.step();
  }

  /// Starts the emulation loop.
  void run() {
    _clock.updateFps(_clock.fps);
    _running = true;
    _scheduleFrame();
  }

  bool _coldStartDone = false;
  bool _warmStartDone = false;

  /// Powers on the emulator: resets CPU and starts execution.
  /// First call = cold start + automatic warm start.
  /// Subsequent calls = warm start (RAM preserved).
  void powerOn() {
    if (_running) {
      // Already running — reset the CPU for a warm start.
      _resetCpu();
    } else {
      // First power-on: run cold start, then schedule a warm start
      // after the cold start completes (enters HLT).
      // On real hardware: battery → cold start → standby → ON → warm start.
      _coldStartDone = false;
      _warmStartDone = false;
      run();
    }
  }

  /// Resets the CPU for a warm start (RAM preserved).
  void _resetCpu() {
    _cpu.pins.resetPin = true;
    _cpu.step();
    _cpu.pins.resetPin = false;
    _cpu.cpu.hlt = false;
    _cpu.pins.inputPorts = 0xFF;
    _cpu.cpu.tm.value = 1;
  }

  /// Toggles SHIFT mode (bit 1 of $764E).
  /// The ROM's SHIFT handler (code 0x01) toggles this bit and restarts
  /// the scan, which would re-detect the held key and toggle it back.
  /// We bypass the matrix and toggle directly to avoid the rapid loop.
  void toggleShift() {
    final int flags = _csd.readByteAt(0x764E);
    _csd.writeByteAt(0x764E, flags ^ 0x02);
  }

  /// Cycles between RUN and PRO modes.
  /// On the real PC-1500, MODE is a physical slide switch.
  /// $764F bits 6:4 = LCD symbols (bit 6=RUN, bit 5=PRO)
  /// $764F bits 2:0 = angle mode (preserved across mode changes)
  void cycleMode() {
    final int current = _csd.readByteAt(0x764F);
    final bool isRun = (current & 0x40) != 0;
    // Toggle RUN ↔ PRO, preserving angle mode bits and other state.
    final int next = isRun
        ? (current & ~0x40) | 0x20 // RUN → PRO
        : (current & ~0x20) | 0x40; // PRO → RUN
    _csd.writeByteAt(0x764F, next);
  }

  /// Powers off the emulator: stops CPU, turns display off.
  void powerOff() {
    stop();
    _lcd.setDisplayOn(false);
  }

  /// Stops the emulation loop.
  void stop() {
    _running = false;
    _frameTimer?.cancel();
    _frameTimer = null;
  }

  Timer? _frameTimer;

  void _scheduleFrame() {
    if (!_running) return;
    _frameTimer = Timer(Duration.zero, _executeFrame);
  }

  void _executeFrame() {
    if (!_running) return;

    // After cold start completes (ROM enters HLT), trigger a warm start.
    // On real hardware: battery → cold start → standby → ON press → warm start.
    // The cold start initializes RAM signatures but not all BASIC pointers.
    // The warm start (reset with RAM preserved) completes initialization.
    if (!_coldStartDone && _cpu.cpu.hlt) {
      _coldStartDone = true;
      _resetCpu();
    }
    // After warm start completes (second HLT), initialize BASIC pointers.
    // The ROM's warm start NEW0?:CHECK doesn't fully complete in the emulator,
    // leaving $786A-$786B (program area base) at $0000. Set it to $4000
    // (start of user RAM) so NEW and BASIC line storage work correctly.
    if (_coldStartDone && !_warmStartDone && _cpu.cpu.hlt) {
      _warmStartDone = true;
      _csd.writeByteAt(0x786A, 0x40); // high byte
      _csd.writeByteAt(0x786B, 0x00); // low byte → $4000
    }


    // Simulate LH5811 timer: generate a periodic IRQ each frame (~50Hz)
    // to drive the ROM's main loop (keyboard scan, display refresh).
    _pc1500IO.triggerIRQ();
    // Keep IF1 (PB7) set while ON is held, matching real hardware behavior.
    if (keyboard.isOnKeyPressed) {
      _pc1500IO.triggerPB7();
    }

    final DateTime frameStart = DateTime.now();
    final Duration frameBudget = _clock.frameDuration;

    while (_running) {
      final int cycles = step();
      if (_clock.increment(cycles)) {
        break;
      }
    }

    // Sync DISP flip-flop state to the LCD each frame.
    _lcd.setDisplayOn(_cpu.pins.dispFlipflop);

    if (!_running) return;

    final Duration elapsed = DateTime.now().difference(frameStart);
    final Duration remaining = frameBudget - elapsed;

    if (remaining > Duration.zero) {
      if (remaining > frameBudget ~/ 4 && _clock.fps < fpsMax) {
        _clock.updateFps(_clock.fps + 1);
      }
      _frameTimer = Timer(remaining, _executeFrame);
    } else {
      if (_clock.fps > fpsMin) {
        _clock.updateFps(_clock.fps - 1);
      }
      _scheduleFrame();
    }
  }

  Stream<LcdEvent> get lcdEvents => _lcd.events;

  DasmDescriptor dasm(int address) {
    final Instruction instruction = _dasm.dump(address);
    String label = '';
    String comment = '';

    if (_annotations.isAnnotated(address)) {
      final AnnotationBase? annotation =
          _annotations.getAnnotationFromAddress(address);
      label = annotation?.label ?? '';
      comment = annotation?.comment ?? '';
    }

    return DasmCode(label: label, instruction: instruction, comment: comment);
  }

  void addCE151() {
    if (_connector40Pins.isUsed) {
      throw EmulatorError(
        '40-pin connector used by ${_connector40Pins.name} module',
      );
    }
    _connector40Pins.addModule('CE151', 0x1000);

    if (type == HardwareDeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x5800, 0x1000);
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1000);
    }
  }

  void addCE155() {
    if (_connector40Pins.isUsed) {
      throw EmulatorError(
        '40-pin connector used by ${_connector40Pins.name} module',
      );
    }
    _connector40Pins.addModule('CE155', 0x2000);

    _csd.appendRAM(MemoryBank.me0, 0x3800, 0x0800);

    if (type == HardwareDeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x5800, 0x1800);
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1800);
    }
  }

  void dispose() {
    stop();
    _lcd.dispose();
  }
}

class PC1500Traced extends Emulator {
  PC1500Traced(
    super.device,
    super.outPort, [
    super.ir0Enter,
    super.ir1Enter,
    super.ir2Enter,
    super.irExit,
    super.subroutineEnter,
    super.subroutineExit,
  ]) {
    _cpu = LH5801Traced(
      clockFrequency: 1300000,
      memRead: _memRead,
      memWrite: _memWrite,
    )..reset();

    _cpu.pins.resetPin = true;
  }

  List<Trace> get traces => (_cpu as LH5801Traced).traces;
}
