import 'dart:isolate';
import 'dart:typed_data';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/emulator_frontend.dart';
import 'package:device/src/messages/messages.dart';
import 'package:test/test.dart';

Uint8List _startMsg({
  HardwareDeviceType type = HardwareDeviceType.pc1500A,
  int debugPort = 0,
}) => StartEmulatorMessageSerializer().serialize(
  StartEmulatorMessage(type: type, debugPort: debugPort),
);

Uint8List _keyDownMsg(String keyName) => KeyEventMessageSerializer().serialize(
  KeyEventMessage(keyName: keyName, isDown: true),
);

Uint8List _keyUpMsg(String keyName) => KeyEventMessageSerializer().serialize(
  KeyEventMessage(keyName: keyName, isDown: false),
);

Uint8List _updateTypeMsg(HardwareDeviceType type) =>
    UpdateDeviceTypeMessageSerializer().serialize(
      UpdateDeviceTypeMessage(type: type),
    );

/// Creates an [EmulatorFrontEnd] with the emulator already started.
EmulatorFrontEnd _started() {
  final ReceivePort outPort = ReceivePort();
  final EmulatorFrontEnd fe = EmulatorFrontEnd(outPort: outPort.sendPort);
  fe.handleMessageForTest(_startMsg());
  addTearDown(() {
    fe.dispose();
    outPort.close();
  });

  return fe;
}

void main() {
  group('EmulatorFrontEnd', () {
    group('lifecycle', () {
      test('should create emulator on startEmulator message', () {
        final EmulatorFrontEnd fe = _started();
        expect(fe.emulator, isNotNull);
        expect(fe.type, equals(HardwareDeviceType.pc1500A));
      });

      test('should recreate emulator on updateDeviceType', () {
        final EmulatorFrontEnd fe = _started();
        final oldEmulator = fe.emulator;
        fe.handleMessageForTest(_updateTypeMsg(HardwareDeviceType.pc1500));
        expect(fe.type, equals(HardwareDeviceType.pc1500));
        expect(fe.emulator, isNot(same(oldEmulator)));
      });

      test('dispose should stop emulator and clean up', () {
        final EmulatorFrontEnd fe = _started();
        fe.dispose();
        expect(fe.emulator, isNull);
      });
    });

    group('key handling', () {
      test('ON key should not pass through to keyboard matrix', () {
        final EmulatorFrontEnd fe = _started();
        fe.handleMessageForTest(_keyDownMsg('on'));
        expect(fe.emulator!.keyboard.debugPressedKeys, isNot(contains('on')));
      });

      test('OFF key should not pass through to keyboard matrix', () {
        final EmulatorFrontEnd fe = _started();
        fe.handleMessageForTest(_keyDownMsg('on'));
        fe.handleMessageForTest(_keyDownMsg('off'));
        expect(fe.emulator!.keyboard.debugPressedKeys, isNot(contains('off')));
      });

      test('MODE key should not pass through to keyboard matrix', () {
        final EmulatorFrontEnd fe = _started();
        fe.handleMessageForTest(_keyDownMsg('on'));
        fe.handleMessageForTest(_keyDownMsg('mode'));
        expect(fe.emulator!.keyboard.debugPressedKeys, isNot(contains('mode')));
      });

      test('SHIFT key should not pass through to keyboard matrix', () {
        final EmulatorFrontEnd fe = _started();
        fe.handleMessageForTest(_keyDownMsg('on'));
        fe.handleMessageForTest(_keyDownMsg('shift'));
        expect(
          fe.emulator!.keyboard.debugPressedKeys,
          isNot(contains('shift')),
        );
      });

      test('regular key should be added to keyboard matrix', () {
        final EmulatorFrontEnd fe = _started();
        fe.handleMessageForTest(_keyDownMsg('7'));
        expect(fe.emulator!.keyboard.debugPressedKeys, contains('7'));
      });

      test('key up should remove key from pressed set', () {
        final EmulatorFrontEnd fe = _started();
        fe.handleMessageForTest(_keyDownMsg('a'));
        expect(fe.emulator!.keyboard.debugPressedKeys, contains('a'));
        fe.handleMessageForTest(_keyUpMsg('a'));
        expect(fe.emulator!.keyboard.debugPressedKeys, isNot(contains('a')));
      });
    });

    group('error handling', () {
      test('malformed message should not crash the frontend', () {
        final EmulatorFrontEnd fe = _started();
        fe.handleMessageForTest(Uint8List.fromList([255]));
        expect(fe.emulator, isNotNull);
      });
    });

    group('debug server', () {
      test('should start with isDebugClientConnected false', () {
        final EmulatorFrontEnd fe = _started();
        expect(fe.isDebugClientConnected, isFalse);
      });

      test('stop should reset debug state', () {
        final EmulatorFrontEnd fe = _started();
        fe.dispose();
        expect(fe.isDebugClientConnected, isFalse);
        expect(fe.serverSocket, isNull);
        expect(fe.serverSocketSub, isNull);
      });
    });
  });
}
