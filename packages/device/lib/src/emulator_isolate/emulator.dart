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

    // Standard users system RAM (1.5KB).
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
        // PB7 = ON key input (active low).
        return keyboard.isOnKeyPressed ? 0x7F : 0xFF;
      },
      onInterrupt: () {
        // PC-1500 I/O interrupt → CPU IR2.
      },
    );

    _ce153IO = LH5811(
      onPortARead: () {
        // Keyboard scan: return PA input based on active strobe lines.
        return keyboard.scanPortA(
          _ce153IO.portBOutput,
          _ce153IO.portCOutput,
        );
      },
      onPortBRead: () {
        return keyboard.scanPortB(
          _ce153IO.portBOutput,
          _ce153IO.portCOutput,
        );
      },
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

    _lcd = Lcd(memRead: _csd.readAt);
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
    }
    return _csd.readByteAt(address);
  }

  /// Memory write interceptor — routes I/O port writes through LH5811.
  void _memWrite(int address, int value) {
    if (address >= 0x10000) {
      final int me1Addr = address & 0xFFFF;
      final LH5811? io = _ioForAddress(me1Addr);
      if (io != null) {
        io.write(me1Addr & 0x0F, value);
        return;
      }
    }
    _csd.writeByteAt(address, value);
  }

  bool get isRunning => _running;

  /// Executes a single CPU instruction. Returns the number of cycles consumed.
  int step() => _cpu.step();

  /// Starts the emulation loop.
  void run() {
    _clock.updateFps(_clock.fps);
    _running = true;
    _scheduleFrame();
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

    final DateTime frameStart = DateTime.now();
    final Duration frameBudget = _clock.frameDuration;

    while (_running) {
      final int cycles = _cpu.step();
      if (_clock.increment(cycles)) {
        break;
      }
    }

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
