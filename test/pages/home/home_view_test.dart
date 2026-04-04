import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/pages/home/home_view.dart';
import 'package:pc1500/src/repositories/systems/systems_repository.dart';

void main() {
  group('deviceLabel', () {
    test('returns correct label for each device type', () {
      expect(deviceLabel(DeviceType.pc1500), equals('PC-1500'));
      expect(deviceLabel(DeviceType.pc1500A), equals('PC-1500A'));
      expect(deviceLabel(DeviceType.pc2), equals('PC-2'));
    });

    test('covers all DeviceType values', () {
      for (final DeviceType type in DeviceType.values) {
        expect(deviceLabel(type), isNotEmpty);
      }
    });
  });

  group('ramLabel', () {
    test('returns 2KB for PC-1500 and PC-2', () {
      expect(ramLabel(DeviceType.pc1500), equals('2KB RAM'));
      expect(ramLabel(DeviceType.pc2), equals('2KB RAM'));
    });

    test('returns 6KB for PC-1500A', () {
      expect(ramLabel(DeviceType.pc1500A), equals('6KB RAM'));
    });

    test('covers all DeviceType values', () {
      for (final DeviceType type in DeviceType.values) {
        expect(ramLabel(type), isNotEmpty);
      }
    });
  });
}
