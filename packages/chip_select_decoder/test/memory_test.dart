import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('Memory', () {
    group('RAM', () {
      test('should raise an exception for invalid arguments', () {
        expect(() => Memory.ram(-1), throwsArgumentError);
        expect(() => Memory.ram(0), throwsArgumentError);
      });

      test('should create a RAM successfully', () {
        final Memory ram = Memory.ram(1024);

        expect(ram, equals(const TypeMatcher<Memory>()));
        expect(ram.isReadonly, isFalse);
        expect(ram.length, equals(1024));
      });
    });

    group('ROM', () {
      test('should raise an exception for invalid arguments', () {
        expect(
          () => Memory.rom(null),
          throwsArgumentError,
        );
        expect(
          () => Memory.rom(Uint8List(0)),
          throwsArgumentError,
        );
      });

      test('should create a ROM successfully', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);

        final Memory rom = Memory.rom(data);

        expect(rom, equals(const TypeMatcher<Memory>()));
        expect(rom.isReadonly, isTrue);
        expect(rom.length, equals(data.length));
      });
    });

    test('content of RAMS should be saved/restored successfully', () {
      final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
      final Memory ram1 = Memory.ram(data.length)..write(0, data);
      final Memory ram2 = Memory.ram(data.length);

      ram2.restoreState(ram1.saveState());
      expect(ram1, equals(ram2));
    });

    group('getters', () {
      test('length should return a valid value', () {
        final Memory m = Memory.ram(1024);

        expect(m.length, equals(1024));
      });

      test('isReadonly should return false for RAMs', () {
        final Memory ram = Memory.ram(1024);

        expect(ram.isReadonly, isFalse);
      });

      test('isReadonly should return true for ROMs', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
        final Memory rom = Memory.rom(data);

        expect(rom.isReadonly, isTrue);
      });
    });

    group('read()', () {
      test('should raise an exception for invalid arguments', () {
        final Memory m = Memory.ram(256);

        expect(() => m.read(-1), throwsArgumentError);
        expect(() => m.read(0, -1), throwsArgumentError);
        expect(() => m.read(128, 256), throwsArgumentError);
      });

      test('should return the expected data', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.rom(data);

        expect(m.read(), equals(const TypeMatcher<UnmodifiableUint8ClampedListView>()));

        final UnmodifiableUint8ClampedListView view = m.read();
        expect(view.length, equals(data.length));
        for (int i = 0; i < data.length; i++) {
          expect(view[i], equals(data[i]));
        }
      });
    });

    group('readByteAt()', () {
      test('should raise an exception for invalid arguments', () {
        final Memory m = Memory.ram(256);

        expect(() => m.readByteAt(-1), throwsArgumentError);
        expect(() => m.readByteAt(512), throwsArgumentError);
      });

      test('should return the expected data', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.rom(data);

        expect(m.readByteAt(0), equals(const TypeMatcher<int>()));

        for (int i = 0; i < data.length; i++) {
          expect(m.readByteAt(i), equals(data[i]));
        }
      });
    });

    group('write()', () {
      test('should raise an exception for ROMs', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.rom(data);

        expect(() => m.write(0, data), throwsA(const TypeMatcher<MemoryError>()));
      });

      test('should raise an exception for invalid arguments', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.ram(data.length);

        expect(() => m.write(-1, data), throwsArgumentError);
        expect(() => m.write(10, data), throwsArgumentError);
      });

      test('should update the memory', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.ram(data.length)..write(0, data);

        final UnmodifiableUint8ClampedListView view = m.read();
        expect(view.length, equals(data.length));
        for (int i = 0; i < data.length; i++) {
          expect(view[i], equals(data[i]));
        }
      });
    });

    group('writeByteAt()', () {
      test('should raise an exception for ROMs', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.rom(data);

        expect(() => m.writeByteAt(0, 45), throwsA(const TypeMatcher<MemoryError>()));
      });

      test('should raise an exception for invalid arguments', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.ram(data.length);

        expect(() => m.writeByteAt(-1, 73), throwsArgumentError);
        expect(() => m.writeByteAt(10, 5), throwsArgumentError);
      });

      test('should update the memory', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory m = Memory.ram(data.length)..writeByteAt(2, 67);

        expect(m.readByteAt(2), equals(67));
      });
    });

    group('clone()', () {
      test('should clone a Memory', () {
        final Memory ram1 = Memory.ram(50)..writeByteAt(2, 67);
        final Memory ram2 = ram1.clone();

        expect(ram1, equals(ram2));

        // Make sure memories are backed by distinct byte buffers.
        ram2.writeByteAt(10, 92);
        expect(ram1, isNot(equals(ram2)));

        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
        final Memory rom1 = Memory.rom(data);
        final Memory rom2 = rom1.clone();

        expect(rom1, equals(rom2));
      });
    });
  });
}
