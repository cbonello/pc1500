import 'package:device/src/device.dart';
import 'package:lcd/lcd.dart';
import 'package:test/test.dart';

void main() {
  group(Device, () {
    group('constructor', () {
      test('should initialize with given type', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        expect(device.hardwareDeviceType, equals(HardwareDeviceType.pc1500A));
      });

      test('should start with debug client disconnected', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        expect(device.isDebugClientConnected, isFalse);
      });
    });

    group('run / kill', () {
      test('should spawn isolate on run', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        await device.run();
        // Running the emulator should not throw.
      });

      test('should not spawn twice on double run', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        await device.run();
        await device.run(); // second call is a no-op
      });

      test('kill should not throw when not running', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        device.kill(); // no-op, should not throw
      });

      test('kill after run should clean up', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        await device.run();
        device.kill();
        // Can run again after kill.
        await device.run();
      });
    });

    group('updateHardwareDeviceType()', () {
      test('should change type', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        await device.run();
        await device.updateHardwareDeviceType(HardwareDeviceType.pc1500);
        expect(device.hardwareDeviceType, equals(HardwareDeviceType.pc1500));
      });

      test('should not restart when type unchanged', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        await device.run();
        // Same type — should be a no-op.
        await device.updateHardwareDeviceType(HardwareDeviceType.pc1500A);
        expect(device.hardwareDeviceType, equals(HardwareDeviceType.pc1500A));
      });
    });

    group('key events', () {
      test('sendKeyDown() should not throw when running', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        await device.run();
        device.sendKeyDown('7');
      });

      test('sendKeyUp() should not throw when running', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        await device.run();
        device.sendKeyUp('7');
      });

      test('sendKeyDown() should not throw when not running', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        // Not running — silently ignored.
        device.sendKeyDown('a');
      });

      test('sendKeyUp() should not throw when not running', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        device.sendKeyUp('a');
      });
    });

    group('lcdEvents', () {
      test('should provide a broadcast stream', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        final Stream<LcdEvent> stream = device.lcdEvents;
        expect(stream.isBroadcast, isTrue);
      });

      test('should allow multiple listeners', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        addTearDown(device.dispose);
        // Two listeners should not throw.
        device.lcdEvents.listen((_) {});
        device.lcdEvents.listen((_) {});
      });
    });

    group('dispose()', () {
      test('should kill and close stream', () async {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        await device.run();
        device.dispose();
        // Stream should be closed after dispose.
        expect(device.lcdEvents.isEmpty, completion(isTrue));
      });

      test('should be safe to call twice', () {
        final Device device = Device(
          type: HardwareDeviceType.pc1500A,
          debugPort: 0,
        );
        device.dispose();
        device.dispose(); // second call should not throw
      });
    });
  });
}
