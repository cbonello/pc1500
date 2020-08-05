import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockWriteObserver extends Mock implements WriteObserver {}

void main() {
  group('MemoryChip', () {
    test('should raise an exception for invalid arguments', () {
      expect(
        () => MemoryChip(start: 0, end: 100, memory: null),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should create a MemoryChip successfully', () {
      expect(
        MemoryChip(start: 0, end: 99, memory: Memory.ram(100)),
        equals(const TypeMatcher<MemoryChip>()),
      );
    });

    group('clone()', () {
      test('should clone a MemoryChip', () {
        final MemoryChip memoryChip1 = MemoryChip(
          start: 0,
          end: 127,
          memory: Memory.ram(128),
        )
          ..writeByteAt(10, 10)
          ..writeByteAt(15, 15);
        final MemoryChip memoryChip2 = memoryChip1.clone();

        expect(memoryChip1, equals(memoryChip2));
      });
    });

    test('content of RAMS should be saved/restored successfully', () {
      final MemoryChip memoryChip1 = MemoryChip(
        start: 0,
        end: 127,
        memory: Memory.ram(128),
      );
      final MemoryChip memoryChip2 = memoryChip1.clone();

      memoryChip1.writeByteAt(100, 43);

      memoryChip2.restoreState(memoryChip1.saveState());
      expect(memoryChip1, equals(memoryChip2));
    });

    test('isReadonly should return false for RAMs or I/O ports and true for ROMs', () {
      final MemoryChip memoryChip1 = MemoryChip(
        start: 0,
        end: 127,
        memory: Memory.ram(128),
      );
      expect(memoryChip1.isReadonly, isFalse);

      final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
      final MemoryChip memoryChip2 = MemoryChip(
        start: 0,
        end: 127,
        memory: Memory.rom(data),
      );
      expect(memoryChip2.isReadonly, isTrue);
    });

    group('readByteAt()', () {
      test('should return the expected data', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
        final MemoryChip memoryChip = MemoryChip(
          start: 0,
          end: 127,
          memory: Memory.rom(data),
        );

        for (int i = 0; i < data.length; i++) {
          expect(memoryChip.readByteAt(i), equals(data[i]));
        }
      });
    });

    group('write()', () {
      test('should update the memory', () {
        final MemoryChip memoryChip = MemoryChip(
          start: 0,
          end: 5,
          memory: Memory.ram(6),
        );
        final List<int> data = <int>[43, 237, 7, 0, 12, 154];

        for (int i = 0; i < data.length; i++) {
          memoryChip.writeByteAt(i, data[i]);
        }

        for (int i = 0; i < data.length; i++) {
          expect(memoryChip.readByteAt(i), equals(data[i]));
        }
      });

      test('should call the observer (if any) after each write', () {
        final MockWriteObserver observer = MockWriteObserver();
        final MemoryChip memoryChip = MemoryChip(
          start: 0,
          end: 5,
          memory: Memory.ram(6),
          observer: observer,
        );

        memoryChip.writeByteAt(3, 25);
        verify(observer.checkWrite(any, any)).called(1);
        memoryChip.writeByteAt(2, 185);
        verify(observer.checkWrite(any, any)).called(1);
      });
    });
  });
}
