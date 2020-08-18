import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:lcd/lcd.dart';
import 'package:lh5801/lh5801.dart';
import 'package:roms/roms.dart';

import 'clock.dart';
import 'extension_module.dart';

class SystemError extends Error {
  SystemError(this.message);

  final String message;

  @override
  String toString() => 'System: $message';
}

enum DeviceType { pc1500, pc2, pc1500A }

class PC1500 {
  PC1500(this.device, [LH5801DebugEvents debugCallback])
      : _csd = ChipSelectDecoder(),
        _connector40Pins = ExtensionModule() {
    _clock = Clock(freq: 1300000, fps: 50);

    // Standard users system RAM (1.5KB).
    final MemoryChip stdUserRam = _csd.appendRAM(
      MemoryBank.me0,
      0x7600,
      0x0600,
    );

    // ROM (16KB).
    _csd.appendROM(MemoryBank.me0, 0xC000, PC1500Rom(PC1500RomType.a03).bytes);

    // Standard users RAM.
    if (device == DeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x4000, 0x1800); // 6KB.
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4000, 0x0800); // 2KB.
    }

    // I/O ports
    final MemoryChip ce153IO = _csd.appendRAM(MemoryBank.me1, 0x8000, 0x10);
    final MemoryChip ce150IO = _csd.appendRAM(MemoryBank.me1, 0xB000, 0x10);
    final MemoryChip io1 = _csd.appendRAM(MemoryBank.me1, 0xD000, 0x400);
    final MemoryChip pc1500IO = _csd.appendRAM(MemoryBank.me1, 0xF000, 0x10);

    // _updateROMStatusInformation();

    _cpu = LH5801(
      clockFrequency: 1300000,
      memRead: _csd.readByteAt,
      memWrite: _csd.writeByteAt,
      debugCallback: debugCallback,
    )..reset();
    _cpu.resetPin = true;

    _lcd = Lcd(memRead: _csd.readByteAt);
    stdUserRam.registerObserver(MemoryAccessType.write, _lcd);

    _dasm = LH5801DASM(memRead: _csd.readByteAt);
  }

  final DeviceType device;
  Clock _clock;
  LH5801 _cpu;
  Lcd _lcd;
  final ChipSelectDecoder _csd;
  final ExtensionModule _connector40Pins;
  LH5801DASM _dasm;

  int step() => _cpu.step();

  Instruction dasm(int address) => _dasm.dump(address);

  void addCE151() {
    // 4KB RAM card.
    if (_connector40Pins.isUsed) {
      throw SystemError(
        '40-pin connector used by ${_connector40Pins.name} module',
      );
    }
    _connector40Pins.addModule('CE151', 0x1000);

    if (device == DeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x5800, 0x1000);
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1000);
    }
  }

  void addCE155() {
    // 8KB RAM card.
    if (_connector40Pins.isUsed) {
      throw SystemError(
        '40-pin connector used by ${_connector40Pins.name} module',
      );
    }
    _connector40Pins.addModule('CE155', 0x2000);

    _csd.appendRAM(MemoryBank.me0, 0x3800, 0x0800);

    if (device == DeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x5800, 0x1800);
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1800);
    }
  }

  void _updateROMStatusInformation() {
    _csd.writeByteAt(0x4000, 0x55);
    // High order one byte of the ROM top address.
    _csd.writeByteAt(0x4001, 0x55);
    // High order one byte of the top address of the BASIC program.
    _csd.writeByteAt(0x4002, 0x55);
    // Low order one byte of the top address of the BASIC program.
    _csd.writeByteAt(0x4003, 0x55);
    // 16KB ROM
    _csd.writeByteAt(0x4004, 0x40);
    // Non-confidential program.
    _csd.writeByteAt(0x4007, 0xFF);
  }
}

class PC1500Traced extends PC1500 {
  PC1500Traced(DeviceType device, [LH5801DebugEvents debugCallback])
      : super(device, debugCallback) {
    _cpu = LH5801Traced(
      clockFrequency: 1300000,
      memRead: _csd.readByteAt,
      memWrite: _csd.writeByteAt,
    )..reset();

    _cpu.resetPin = true;
  }

  List<Trace> get traces => (_cpu as LH5801Traced).traces;
}
