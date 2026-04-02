import 'package:device/device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/device/device_repository.dart';
import 'package:pc1500/src/repositories/systems/systems_repository.dart';

void main() {
  group(getHardwareDevice, () {
    test('maps pc1500 to HardwareDeviceType.pc1500', () {
      expect(
        getHardwareDevice(DeviceType.pc1500),
        equals(HardwareDeviceType.pc1500),
      );
    });

    test('maps pc1500A to HardwareDeviceType.pc1500A', () {
      expect(
        getHardwareDevice(DeviceType.pc1500A),
        equals(HardwareDeviceType.pc1500A),
      );
    });

    test('maps pc2 to HardwareDeviceType.pc1500 (fallback)', () {
      expect(
        getHardwareDevice(DeviceType.pc2),
        equals(HardwareDeviceType.pc1500),
      );
    });

    test('covers all DeviceType values', () {
      // Ensures the switch is exhaustive — if a new DeviceType is added
      // without updating getHardwareDevice, this test will fail.
      for (final DeviceType type in DeviceType.values) {
        expect(() => getHardwareDevice(type), returnsNormally);
      }
    });
  });

  group('canSafelySwitchDevices', () {
    test('pc1500 to pc2 is safe', () {
      expect(canSafelySwitchDevices(DeviceType.pc1500, DeviceType.pc2), isTrue);
    });

    test('pc2 to pc1500 is safe', () {
      expect(canSafelySwitchDevices(DeviceType.pc2, DeviceType.pc1500), isTrue);
    });

    test('pc1500 to pc1500A is unsafe (RAM size differs)', () {
      expect(
        canSafelySwitchDevices(DeviceType.pc1500, DeviceType.pc1500A),
        isFalse,
      );
    });

    test('pc1500A to pc1500 is unsafe (RAM size differs)', () {
      expect(
        canSafelySwitchDevices(DeviceType.pc1500A, DeviceType.pc1500),
        isFalse,
      );
    });

    test('pc1500A to pc2 is unsafe', () {
      expect(
        canSafelySwitchDevices(DeviceType.pc1500A, DeviceType.pc2),
        isFalse,
      );
    });

    test('pc2 to pc1500A is unsafe', () {
      expect(
        canSafelySwitchDevices(DeviceType.pc2, DeviceType.pc1500A),
        isFalse,
      );
    });

    test('same type to same type is safe', () {
      expect(
        canSafelySwitchDevices(DeviceType.pc1500, DeviceType.pc1500),
        isTrue,
      );
      expect(canSafelySwitchDevices(DeviceType.pc2, DeviceType.pc2), isTrue);
    });

    test('pc1500A to pc1500A is unsafe (still involves pc1500A)', () {
      expect(
        canSafelySwitchDevices(DeviceType.pc1500A, DeviceType.pc1500A),
        isFalse,
      );
    });
  });
}
