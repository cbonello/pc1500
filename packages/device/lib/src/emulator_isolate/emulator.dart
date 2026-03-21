import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:annotations/annotations.dart';
import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/clock.dart';
import 'package:device/src/emulator_isolate/dap_server.dart';
import 'package:device/src/emulator_isolate/dasm.dart';
import 'package:device/src/emulator_isolate/extension_module.dart';
import 'package:device/src/emulator_isolate/keyboard.dart';
import 'package:device/src/messages.dart';
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

// ── I/O port base addresses (ME1, accessed as 0x10000 + base from CPU) ──

const int _ce153Base = 0x8000; // CE-153 (keyboard)
const int _ce150Base = 0xB000; // CE-150 (printer)
const int _ce158Base = 0xD000; // CE-158 (RS-232C)
const int _pc1500Base = 0xF000; // PC-1500 main I/O

// ── System RAM addresses ────────────────────────────────────────────────

/// LCD symbol byte 0 (BUSY, SHIFT, SML, SMALL, I/II/III, DEF).
const int _symByte0 = 0x764E;

/// LCD symbol byte 1 (RUN, PRO, RESERVE, DEG/RAD/GRAD).
const int _symByte1 = 0x764F;

/// Start of user RAM (program area base for BASIC storage).
const int _userRamStart = 0x4000;


// ── BASINPUT entry points (from ROM annotations) ────────────────────────

const int _basinput1 = 0xCA58; // RUN mode: input with '>' prompt.
const int _basinput3 = 0xCA80; // PRO mode: input without prompt.

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
      _csd.appendRAM(MemoryBank.me0, _userRamStart, 0x1800); // 6KB.
    } else {
      _csd.appendRAM(MemoryBank.me0, _userRamStart, 0x0800); // 2KB.
    }

    try {
      final json =
          jsonDecode(std_users_ram.me0RamAnnotationsJson)
              as Map<String, dynamic>;
      _annotations.load(json);
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('Failed to load RAM annotations: $e');

        return true;
      }());
    }

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
    _initCpuPins();

    _lcd = Lcd(memRead: _csd.readAt);
    displayRam.registerObserver(MemoryAccessType.write, _lcd);
    stdUserRam.registerObserver(MemoryAccessType.write, _lcd);
    _lcdSub = _lcd.events.listen((LcdEvent event) {
      outPort.send(LcdEventMsg(event));
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
  late StreamSubscription<LcdEvent> _lcdSub;
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
  bool _paused = false;

  final Keyboard keyboard;
  late final LH5811 _pc1500IO;
  late final LH5811 _ce153IO;


  /// Initializes CPU pins to their power-on state.
  void _initCpuPins() {
    _cpu.pins.resetPin = true;
    _cpu.pins.inputPorts = 0xFF; // No keys pressed (active low).
    // Seed the timer LFSR with a non-zero value so it can generate
    // periodic IR1 interrupts. An all-zero LFSR never advances.
    _cpu.cpu.tm.value = 1;
  }

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
    if (base == _pc1500Base) {
      return _pc1500IO;
    }
    if (base == _ce153Base) {
      return _ce153IO;
    }

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
      // ME1 $7400-$7BFF: display chips (V2/V3) respond to ME1 at
      // the same addresses as ME0.
      if (me1Addr >= 0x7400 && me1Addr < 0x7C00) {
        return _csd.readByteAt(me1Addr);
      }
      // All other ME1 addresses are unmapped (no user RAM in ME1).
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
      // ME1 $7400-$7BFF: display chips (V2/V3) respond to ME1.
      if (me1Addr >= 0x7400 && me1Addr < 0x7C00) {
        _memWrite(me1Addr, value);

        return;
      }

      // All other ME1 addresses are unmapped (no user RAM in ME1).
      return;
    }
    // Guard: silently drop writes to ROM ($C000+).
    // Writes to unmapped RAM gaps are handled by the CSD (silently ignored).
    if (address >= 0xC000) {
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

  // ── Test helpers ──────────────────────────────────────────────────────

  /// Exposes [_memRead] for unit tests.
  int memReadForTest(int address) => _memRead(address);

  /// Exposes [_memWrite] for unit tests.
  void memWriteForTest(int address, int value) => _memWrite(address, value);

  /// Simulates the cold-start-done state (ROM entered HLT for the first time).
  void simulateColdStartDone() => _coldStartDone = true;

  /// Simulates a fully booted state for tests (cold start + wake from HLT).
  void simulateWarmStartDone() {
    _coldStartDone = true;
  }

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

  // ── DAP debugger API ────────────────────────────────────────────────────

  /// Address breakpoints checked each step. Managed by [DapServer].
  final Set<int> breakpoints = <int>{};

  /// Whether the emulator is paused (by a breakpoint or DAP pause request).
  bool get isPaused => _paused;

  /// Current program counter.
  int get pc => _cpu.cpu.p.value;

  /// Snapshot of CPU register and flag state (cloned).
  LH5801State get cpuState => _cpu.state;

  /// Current CPU pin state.
  LH5801Pins get cpuPins => _cpu.pins;

  /// DAP server reference for breakpoint notifications.
  DapServer? dapServer;

  /// Pauses the emulator at the end of the current frame.
  void pause() {
    _paused = true;
  }

  /// Resumes the emulator after a pause. Reschedules the frame loop.
  void resumeExecution() {
    if (_paused) {
      _paused = false;
      if (_running) _scheduleFrame();
    }
  }

  /// Executes exactly one instruction (for DAP next/stepIn).
  int stepSingle() {
    return step();
  }

  // ── Emulation loop ─────────────────────────────────────────────────────

  /// Starts the emulation loop.
  void run() {
    _running = true;
    _scheduleFrame();
  }

  bool _coldStartDone = false;
  int _debugTraceCount = 0; // TODO: remove after debugging
  int _debugLastPC = -1; // TODO: remove after debugging

  /// Powers on the emulator: resets CPU and starts execution.
  /// First call = cold start + automatic warm start.
  /// Subsequent calls = warm start (RAM preserved).
  void powerOn() {
    if (_running) {
      // Already running — reset the CPU for a warm start.
      _resetCpu();
    } else {
      // First power-on: cold start.
      //
      // Pre-seed RAM state that the ROM expects to be preserved across
      // power cycles (battery-backed on real hardware, but zeroed in the
      // emulator on first boot).
      //
      // 1. RAM probe results at $7860-$7864: the ROM compares these with
      //    fresh probe results. A mismatch triggers "NEW0?:CHECK" which
      //    blocks initialization waiting for a key press.
      // 2. VARIABLE_POINTER at $7899: must equal RAM top so the BASIC
      //    interpreter knows where the variable area starts. CFCC does
      //    NOT set this — it's expected to survive from the previous boot.
      // 3. End-of-program marker ($FF) at $4000: marks an empty program.
      final int ramTop =
          type == HardwareDeviceType.pc1500A ? 0x58 : 0x48;
      _csd.writeByteAt(0x7860, 0xFF); // No module at $0000.
      _csd.writeByteAt(0x7861, 0xFF); // No module detected.
      _csd.writeByteAt(0x7862, 0xFF); // No module detected.
      _csd.writeByteAt(0x7863, 0x40); // RAM start high byte.
      _csd.writeByteAt(0x7864, ramTop); // RAM end high byte.
      // 0x7865-0x7866: base program area start address. INITBST (DF93)
      // reads this when no expansion module is present (0x7861 bit 7 set).
      // On real hardware this is set by the first-ever boot's "NEW0?:CHECK"
      // response and preserved by battery-backed RAM thereafter.
      // Per TRM 5-1-1 and 5-3-6: the user RAM area starts at $4000.
      // ROM information occupies 8 bytes ($4000-$4007), the reserve area
      // occupies 189 bytes ($4008-$40C4), and the BASIC program area
      // starts at $40C5 (PC-1500 only, or $38C5 with CE-155).
      //
      // INITBST (DF93) reads the program block base from $7865-$7866.
      // CFCC adds 3 to skip a 3-byte program block header, then stores
      // the result (with bit 7 set) as DATA_POINTER ($78BE-$78BF).
      // So $7865-$7866 = $40C2 → DATA_POINTER = $C0C5 (effective $40C5).
      _csd.writeByteAt(0x7865, 0x40); // Program block base high.
      _csd.writeByteAt(0x7866, 0xC2); // Program block base low.
      // 0x7867-0x7868: current program start (VEJ CA $67).
      // 0x7869-0x786A: current program block pointer (VEJ CC $69,
      // read by D2E0 during line insertion). Both point to $40C2.
      _csd.writeByteAt(0x7867, 0x40); // Current program start high.
      _csd.writeByteAt(0x7868, 0xC2); // Current program start low.
      _csd.writeByteAt(0x7869, 0x40); // Current program block high.
      _csd.writeByteAt(0x786A, 0xC2); // Current program block low.
      _csd.writeByteAt(0x7899, ramTop); // VARIABLE_POINTER high byte.
      // End-of-BASIC-program marker (0xFF) at $40C5, per TRM 5-3-5.
      _csd.writeByteAt(0x40C5, 0xFF); // End-of-program marker.
      _coldStartDone = false;
      run();
    }
  }

  /// Resets the CPU for a warm start (RAM preserved).
  void _resetCpu() {
    _cpu.pins.resetPin = true;
    step(); // Use wrapper, not _cpu.step() directly.
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
    final int flags = _csd.readByteAt(_symByte0);
    _csd.writeByteAt(_symByte0, flags ^ 0x02);
  }

  /// Cycles between RUN and PRO modes.
  /// On the real PC-1500, MODE is a physical slide switch that triggers a
  /// hardware restart of the main loop. We emulate this by updating the LCD
  /// symbol in $764F and redirecting the CPU to the correct BASINPUT entry.
  void cycleMode() {
    final int current = _csd.readByteAt(_symByte1);
    final bool isRun = (current & 0x40) != 0;
    // Toggle RUN ↔ PRO, preserving angle mode bits and other state.
    final int next = isRun
        ? (current & ~0x40) |
              0x20 // RUN → PRO
        : (current & ~0x20) | 0x40; // PRO → RUN
    _csd.writeByteAt(_symByte1, next);
    // Redirect the CPU to the correct BASINPUT entry point.
    // The main loop's BASINPUT entry determines RUN vs PRO behavior.
    _cpu.cpu.p.value = isRun ? _basinput3 : _basinput1;
    _cpu.cpu.hlt = false;
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

    // The ROM's cold start fully initialises all system variables and the
    // BASIC program area, then enters the main loop (SIE + HLT at $E2A8).
    // Undefined opcodes in unmapped memory ($FF) are treated as NOPs by
    // the LH5801, which lets the cold start recover from a corrupt RTN
    // through the CE-150 address space. The timer IRQ wakes the CPU from
    // HLT naturally since the ROM enables interrupts before halting.
    if (!_coldStartDone && _cpu.cpu.hlt) {
      _coldStartDone = true;
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

    while (_running && !_paused) {
      // DEBUG: trace cold start execution path
      if (!_coldStartDone) {
        final pc = _cpu.cpu.p.value;
        if (pc == 0xCA55 || pc == 0xCA58 || pc == 0xC9E4) {
          // ignore: avoid_print
          print('DEBUG: PC=0x${pc.toRadixString(16)}'
              ' A=0x${_cpu.cpu.a.value.toRadixString(16)}'
              ' S=0x${_cpu.cpu.s.value.toRadixString(16)}'
              ' 4000=0x${_csd.readByteAt(0x4000).toRadixString(16)}'
              ' 7899=0x${_csd.readByteAt(0x7899).toRadixString(16)}');
        }
      }
      final int cycles = step();
      // Check for DAP breakpoints (O(1) hash lookup, skipped when empty).
      if (breakpoints.isNotEmpty && breakpoints.contains(_cpu.cpu.p.value)) {
        _paused = true;
        dapServer?.notifyStopped('breakpoint');
        break;
      }
      if (_clock.increment(cycles)) {
        break;
      }
    }

    // Sync DISP flip-flop state to the LCD each frame.
    _lcd.setDisplayOn(_cpu.pins.dispFlipflop);

    // Advance the key queue AFTER the ROM has scanned the keyboard.
    // This injects one queued key per frame, holding it long enough for
    // the ROM's scan to detect it reliably.
    keyboard.tickKeyQueue();

    if (!_running || _paused) {
      return;
    }

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
      final AnnotationBase? annotation = _annotations.getAnnotationFromAddress(
        address,
      );
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
    // CE-151 adds 4KB — ME1 routing already covers up to $2000 (8KB window).
    // The ROM detects expansion RAM during its cold start memory probe.
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
    // ME1 has no user RAM — only I/O ports. The CE-155 expansion RAM
    // is in ME0 only, accessed directly by the ROM.
  }

  void dispose() {
    stop();
    _lcdSub.cancel();
    _lcd.dispose();
    _connector40Pins.removeModule();
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
    _initCpuPins();
  }

  List<Trace> get traces => (_cpu as LH5801Traced).traces;
}
