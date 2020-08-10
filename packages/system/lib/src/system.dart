import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lh5801/lh5801.dart';
import 'package:roms/roms.dart';

import 'clock.dart';
import 'extension_module.dart';

part 'system.freezed.dart';

class SystemError extends Error {
  SystemError(this.message);

  final String message;

  @override
  String toString() => 'System: $message';
}

@freezed
abstract class DeviceType with _$DeviceType {
  // Sharp PC-1500.
  const factory DeviceType.pc1500() = _PC1500;
  // Tandy PC-2 (same as PC-1500).
  const factory DeviceType.pc2() = PC2;
  // Sharp PC-1500A
  const factory DeviceType.pc1500A() = _PC1500A;
}

class System {
  System(this.device)
      : _csd = ChipSelectDecoder(),
        _connector40Pins = ExtensionModule() {
    _clock = Clock(freq: 1300000, fps: 50);

    // Standard users system RAM (1.5KB).
    _csd.appendRAM(MemoryBank.me0, 0x7600, 0x0600);
    _csd.appendROM(MemoryBank.me0, 0xC000, Roms.pc1500);

    // Standard users RAM.
    device.maybeWhen<void>(
      pc1500A: () {
        // 6KB.
        _csd.appendRAM(MemoryBank.me0, 0x4000, 0x1800);
      },
      orElse: () {
        // 2KB.
        _csd.appendRAM(MemoryBank.me0, 0x4000, 0x0800);
      },
    );

    // _updateROMStatusInformation();

    _emulator = LH5801Emulator(
      clockFrequency: 1300000,
      memRead: _csd.readByteAt,
      memWrite: _csd.writeByteAt,
    )..reset();

    _emulator.resetPin = true;
  }

  final DeviceType device;
  Clock _clock;
  LH5801Emulator _emulator;
  final ChipSelectDecoder _csd;
  final ExtensionModule _connector40Pins;

  void step() {
    _emulator.step();
  }

  void addCE151() {
    // 4KB RAM card.
    if (_connector40Pins.isUsed) {
      throw SystemError('40-pin connector used by ${_connector40Pins.name} module');
    }

    // Come standard with the PC-1500A.
    if (device != const DeviceType.pc1500A()) {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1000);
      _connector40Pins.addModule('CE151', 0x1000);
    }
  }

  void addCE155() {
    // 8KB RAM card.
    if (_connector40Pins.isUsed) {
      throw SystemError('40-pin connector used by ${_connector40Pins.name} module');
    }

    _csd.appendRAM(MemoryBank.me0, 0x3800, 0x0800);

    // Come standard with the PC-1500A.
    if (device != const DeviceType.pc1500A()) {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1000);
      _connector40Pins.addModule('CE155', 0x2000);
    }
  }

  void addCE159() {
    // 8KB RAM card (lithium battery saved).
    if (_connector40Pins.isUsed) {
      throw SystemError('40-pin connector used by ${_connector40Pins.name} module');
    }

    _csd.appendRAM(MemoryBank.me0, 0x02000, 0x02000);
    _connector40Pins.addModule('CE159', 0x2000);
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
