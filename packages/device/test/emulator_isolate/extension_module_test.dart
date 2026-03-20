import 'package:device/device.dart';
import 'package:test/test.dart';

void main() {
  group(ExtensionModule, () {
    test('should create an extension module successfully', () {
      final ExtensionModule extensionModule = ExtensionModule();

      expect(extensionModule.name, isEmpty);
      expect(extensionModule.capacity, isZero);
      expect(extensionModule.isUsed, isFalse);
    });

    group('addModule()', () {
      test('should reject empty name', () {
        final ExtensionModule extensionModule = ExtensionModule();
        expect(
          () => extensionModule.addModule('', 0x1000),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject capacity below 2KB', () {
        final ExtensionModule extensionModule = ExtensionModule();
        expect(
          () => extensionModule.addModule('CE151', 0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject capacity above 16KB', () {
        final ExtensionModule extensionModule = ExtensionModule();
        expect(
          () => extensionModule.addModule('CE151', 32 * 1024),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should add an extension module successfully', () {
        final ExtensionModule extensionModule = ExtensionModule();
        extensionModule.addModule('CE151', 0x1000);

        expect(extensionModule.name, equals('CE151'));
        expect(extensionModule.capacity, equals(0x1000));
        expect(extensionModule.isUsed, isTrue);
      });
    });

    group('removeModule()', () {
      test('should remove an extension module successfully', () {
        final ExtensionModule extensionModule = ExtensionModule();
        extensionModule.addModule('CE151', 0x1000);
        extensionModule.removeModule();

        expect(extensionModule.name, isEmpty);
        expect(extensionModule.capacity, isZero);
        expect(extensionModule.isUsed, isFalse);
      });
    });
  });
}
