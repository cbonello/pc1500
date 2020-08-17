import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockMemoryObserver extends Mock implements MemoryObserver {}

void main() {
  group('MemoryChip', () {
    group('MemoryChip.ram', () {
      test('should create a RAM successfully', () {
        expect(
          MemoryChip.ram(start: 0, length: 100),
          equals(const TypeMatcher<MemoryChip>()),
        );
      });
    });

    group('MemoryChip.rom', () {
      test('should create a ROM successfully', () {
        expect(
          MemoryChip.rom(start: 0, content: Uint8List(100)),
          equals(const TypeMatcher<MemoryChip>()),
        );
      });
    });

    group('end getter', () {
      test('should return the last valid relative index', () {
        final MemoryChip rom = MemoryChip.rom(
          start: 0,
          content: Uint8List(100),
        );

        expect(rom.end, equals(99));
      });
    });

    group('clone()', () {
      test('should clone a MemoryChip successfully', () {
        final MemoryChip memoryChip1 = MemoryChip.ram(start: 0, length: 128)
          ..writeByteAt(10, 10)
          ..writeByteAt(15, 15);
        final MemoryChip memoryChip2 = memoryChip1.clone();

        expect(memoryChip1, equals(memoryChip2));
      });
    });

    test('content of RAMS should be saved/restored successfully', () {
      final MemoryChip memoryChip1 = MemoryChip.ram(start: 0, length: 128);
      final MemoryChip memoryChip2 = memoryChip1.clone();

      memoryChip1.writeByteAt(100, 43);

      memoryChip2.restoreState(memoryChip1.saveState());
      expect(memoryChip1, equals(memoryChip2));
    });

    test(
      'isReadonly should return false for RAMs or I/O ports and true for ROMs',
      () {
        final MemoryChip memoryChip1 = MemoryChip.ram(start: 0, length: 128);
        expect(memoryChip1.isReadonly, isFalse);

        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
        final MemoryChip memoryChip2 = MemoryChip.rom(start: 0, content: data);
        expect(memoryChip2.isReadonly, isTrue);
      },
    );

    group('readByteAt()', () {
      test('should return the expected data', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
        final MemoryChip memoryChip = MemoryChip.rom(start: 0, content: data);

        for (int i = 0; i < data.length; i++) {
          expect(memoryChip.readByteAt(i), equals(data[i]));
        }
      });

      test('should call the registered observers after each read', () {
        final MockMemoryObserver observer = MockMemoryObserver();
        final MemoryChip memoryChip = MemoryChip.ram(start: 0, length: 128);
        memoryChip.registerObserver(MemoryAccessType.read, observer);

        memoryChip.readByteAt(3);
        verify(observer.update(MemoryAccessType.read, any, any)).called(1);
        memoryChip.readByteAt(2);
        verify(observer.update(MemoryAccessType.read, any, any)).called(1);
      });
    });

    group('write()', () {
      test('should update a RAM successfully', () {
        final MemoryChip memoryChip = MemoryChip.ram(start: 0, length: 6);
        final List<int> data = <int>[43, 237, 7, 0, 12, 154];

        for (int i = 0; i < data.length; i++) {
          memoryChip.writeByteAt(i, data[i]);
        }

        for (int i = 0; i < data.length; i++) {
          expect(memoryChip.readByteAt(i), equals(data[i]));
        }
      });

      test('should call the registered observers after each write', () {
        final MockMemoryObserver observer = MockMemoryObserver();
        final MemoryChip memoryChip = MemoryChip.ram(start: 0, length: 128);
        memoryChip.registerObserver(MemoryAccessType.write, observer);

        memoryChip.writeByteAt(3, 25);
        verify(observer.update(MemoryAccessType.write, any, any)).called(1);
        memoryChip.writeByteAt(2, 185);
        verify(observer.update(MemoryAccessType.write, any, any)).called(1);
      });
    });
  });
}
