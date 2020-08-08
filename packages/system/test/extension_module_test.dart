import 'package:system/src/extension_module.dart';
import 'package:test/test.dart';

void main() {
  group('ExtensionModule', () {
    test('should create an extension module successfully', () {
      final ExtensionModule extensionModule = ExtensionModule();

      expect(extensionModule.name, isEmpty);
      expect(extensionModule.capacity, isZero);
      expect(extensionModule.isUsed, isFalse);
    });

    group('addModule()', () {
      final ExtensionModule extensionModule = ExtensionModule();

      test('should detect invalid arguments', () {
        expect(
          () => extensionModule.addModule(null, 0),
          throwsA(const TypeMatcher<AssertionError>()),
        );

        expect(
          () => extensionModule.addModule('', 0),
          throwsA(const TypeMatcher<AssertionError>()),
        );

        expect(
          () => extensionModule.addModule('abc', 0),
          throwsA(const TypeMatcher<AssertionError>()),
        );
      });

      test('should add an extension module successfully', () {
        extensionModule.addModule('CE151', 0x1000);

        expect(extensionModule.name, equals('CE151'));
        expect(extensionModule.capacity, equals(0x1000));
        expect(extensionModule.isUsed, isTrue);
      });
    });

    group('removeModule()', () {
      final ExtensionModule extensionModule = ExtensionModule();

      test('should remove an extension module successfully', () {
        extensionModule.addModule('CE151', 0x1000);
        extensionModule.removeModule();

        expect(extensionModule.name, isEmpty);
        expect(extensionModule.capacity, isZero);
        expect(extensionModule.isUsed, isFalse);
      });
    });
  });
}
