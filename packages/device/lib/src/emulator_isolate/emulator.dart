import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:annotations/annotations.dart';
import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:lcd/lcd.dart';
import 'package:lh5801/lh5801.dart';
import 'package:roms/roms.dart';

import '../device.dart';
import '../messages/messages_base.dart';
import '../messages/messages.dart';
import 'clock.dart';
import 'dasm.dart';
import 'extension_module.dart';
import 'me0_ram_annotations.dart' as std_users_ram;

SendPort _isolateToMainStream;
Emulator _emulator;
DeviceType type;
int debugPort;

void emulatorMain(SendPort isolateToMainStream) {
  _isolateToMainStream = isolateToMainStream;
  final ReceivePort mainToIsolateStream = ReceivePort();
  _isolateToMainStream.send(mainToIsolateStream.sendPort);
  mainToIsolateStream.listen((dynamic data) {
    _messageHandler(data as Uint8List);
  });
}

void _messageHandler(Uint8List data) {
  final EmulatorMessageId emulatorMessageId = EmulatorMessageId.values[data[0]];

  switch (emulatorMessageId) {
    case EmulatorMessageId.startEmulator:
      final StartEmulatorMessage message =
          StartEmulatorMessageSerializer().deserialize(data);
      type = message.type;
      debugPort = message.debugPort;
      print('${type.index} $debugPort');
      _emulator ??= Emulator(type, debugPort);
      _isolateToMainStream.send(message);
      break;
    case EmulatorMessageId.updateDeviceType:
      final SetDeviceTypeMessage message =
          SetDeviceTypeMessageSerializer().deserialize(data);
      type = message.type;
      break;
    case EmulatorMessageId.setDebutPort:
      final SetDebugPortMessage message =
          SetDebugPortMessageSerializer().deserialize(data);
      debugPort = message.port;
      break;
    default:
      throw Exception();
  }
}

class EmulatorError extends Error {
  EmulatorError(this.message);

  final String message;

  @override
  String toString() => 'Device: $message';
}

class Emulator {
  Emulator(
    this.type,
    this.debugPort, [
    this.ir0Enter,
    this.ir1Enter,
    this.ir2Enter,
    this.irExit,
    this.subroutineEnter,
    this.subroutineExit,
  ])  : _csd = ChipSelectDecoder(),
        _connector40Pins = ExtensionModule(),
        _annotations = MemoryBanksAnnotations() {
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
    if (type == DeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x4000, 0x1800); // 6KB.
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4000, 0x0800); // 2KB.
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(std_users_ram.json) as Map<String, dynamic>;
      _annotations.load(json);
    } catch (_) {}

    // I/O ports
    _csd.appendRAM(MemoryBank.me1, 0x8000, 0x10);
    _csd.appendRAM(MemoryBank.me1, 0xB000, 0x10);
    _csd.appendRAM(MemoryBank.me1, 0xD000, 0x400);
    _csd.appendRAM(MemoryBank.me1, 0xF000, 0x10);

    // _updateROMStatusInformation();

    _cpu = LH5801(
      clockFrequency: 1300000,
      memRead: _csd.readByteAt,
      memWrite: _csd.writeByteAt,
      ir0Enter: ir0Enter,
      ir1Enter: ir1Enter,
      ir2Enter: ir2Enter,
      irExit: irExit,
      subroutineEnter: subroutineEnter,
      subroutineExit: subroutineExit,
    )..reset();
    _cpu.resetPin = true;

    _lcd = Lcd(memRead: _csd.readAt);
    stdUserRam.registerObserver(MemoryAccessType.write, _lcd);

    _dasm = LH5801DASM(memRead: _csd.readByteAt);
  }

  final DeviceType type;
  final int debugPort;
  Clock _clock;
  LH5801 _cpu;
  final ChipSelectDecoder _csd;
  Lcd _lcd;
  final ExtensionModule _connector40Pins;
  LH5801DASM _dasm;
  final MemoryBanksAnnotations _annotations;
  final LH5801Command ir0Enter;
  final LH5801Command ir1Enter;
  final LH5801Command ir2Enter;
  final LH5801Command irExit;
  final LH5801Command subroutineEnter;
  final LH5801Command subroutineExit;

  int step() => _cpu.step();

  Stream<LcdEvent> get lcdEvents => _lcd.events;

  DasmDescriptor dasm(int address) {
    final Instruction instruction = _dasm.dump(address);
    String label = '', comment = '';

    if (_annotations.isAnnotated(address)) {
      final AnnotationBase annotation = _annotations.getAnnotationFromAddress(
        address,
      );
      label = annotation.label;
      comment = annotation.comment;
    }

    return DasmCode(label: label, instruction: instruction, comment: comment);
  }

  void addCE151() {
    // 4KB RAM card.
    if (_connector40Pins.isUsed) {
      throw EmulatorError(
        '40-pin connector used by ${_connector40Pins.name} module',
      );
    }
    _connector40Pins.addModule('CE151', 0x1000);

    if (type == DeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x5800, 0x1000);
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1000);
    }
  }

  void addCE155() {
    // 8KB RAM card.
    if (_connector40Pins.isUsed) {
      throw EmulatorError(
        '40-pin connector used by ${_connector40Pins.name} module',
      );
    }
    _connector40Pins.addModule('CE155', 0x2000);

    _csd.appendRAM(MemoryBank.me0, 0x3800, 0x0800);

    if (type == DeviceType.pc1500A) {
      _csd.appendRAM(MemoryBank.me0, 0x5800, 0x1800);
    } else {
      _csd.appendRAM(MemoryBank.me0, 0x4800, 0x1800);
    }
  }

  void dispose() {
    _lcd?.dispose();
  }

  // void _updateROMStatusInformation() {
  //   _csd.writeByteAt(0x4000, 0x55);
  //   // High order one byte of the ROM top address.
  //   _csd.writeByteAt(0x4001, 0x55);
  //   // High order one byte of the top address of the BASIC program.
  //   _csd.writeByteAt(0x4002, 0x55);
  //   // Low order one byte of the top address of the BASIC program.
  //   _csd.writeByteAt(0x4003, 0x55);
  //   // 16KB ROM
  //   _csd.writeByteAt(0x4004, 0x40);
  //   // Non-confidential program.
  //   _csd.writeByteAt(0x4007, 0xFF);
  // }
}

class PC1500Traced extends Emulator {
  PC1500Traced(
    DeviceType device,
    int debugPort, [
    LH5801Command ir0Enter,
    LH5801Command ir1Enter,
    LH5801Command ir2Enter,
    LH5801Command irExit,
    LH5801Command subroutineEnter,
    LH5801Command subroutineExit,
  ]) : super(
          device,
          debugPort,
          ir0Enter,
          ir1Enter,
          ir2Enter,
          irExit,
          subroutineEnter,
          subroutineExit,
        ) {
    _cpu = LH5801Traced(
      clockFrequency: 1300000,
      memRead: _csd.readByteAt,
      memWrite: _csd.writeByteAt,
    )..reset();

    _cpu.resetPin = true;
  }

  List<Trace> get traces => (_cpu as LH5801Traced).traces;
}
