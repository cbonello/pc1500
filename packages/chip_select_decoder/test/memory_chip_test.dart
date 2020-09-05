import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:crypto/crypto.dart';
import 'package:mockito/mockito.dart';
import 'package:roms/roms.dart';
import 'package:test/test.dart';

class MockMemoryObserver extends Mock implements MemoryObserver {}

class MockRom extends Mock implements RomBase {}

MockRom createMockRom(int length) {
  assert(length <= 16 * 1024);

  final Uint8List bytes = Uint8List(length);
  for (int i = 0; i < length; i++) {
    bytes[i] = i;
  }

  final MockRom rom = MockRom();
  when(rom.bytes).thenReturn(bytes);
  when(rom.hash).thenReturn(sha1.convert(bytes));

  return rom;
}

void main() {
  group('MemoryChip', () {
    group('MemoryChipRam', () {
      test('should create a RAM successfully', () {
        expect(
          MemoryChipRam(start: 0, length: 100),
          equals(const TypeMatcher<MemoryChipRam>()),
        );
      });

      test('isReadonly getter should return false', () {
        final MemoryChipRam ram = MemoryChipRam(start: 0, length: 100);
        expect(ram.isReadonly, isFalse);
      });

      test('end getter should return the expected value', () {
        final MemoryChipRam ram = MemoryChipRam(start: 0, length: 100);
        expect(ram.end, 99);
      });

      group('readByteAt()', () {
        test('should read successfully', () {
          final MemoryChipRam ram = MemoryChipRam(start: 0, length: 100);
          expect(ram.readByteAt(0), equals(0));
        });

        test('should call the registered observers after each read', () {
          final MockMemoryObserver observer = MockMemoryObserver();
          final MemoryChipRam ram = MemoryChipRam(start: 0, length: 128);
          ram.registerObserver(MemoryAccessType.read, observer);

          ram.readByteAt(3);
          verify(observer.update(MemoryAccessType.read, any, any)).called(1);
          ram.readByteAt(2);
          verify(observer.update(MemoryAccessType.read, any, any)).called(1);
        });
      });

      group('writeByteAt()', () {
        test('should write successfully', () {
          final MemoryChipRam ram = MemoryChipRam(start: 0, length: 100);
          expect(ram.readByteAt(10), equals(0));
          ram.writeByteAt(10, 89);
          expect(ram.readByteAt(10), equals(89));
        });

        test('should call the registered observers after each write', () {
          final MockMemoryObserver observer = MockMemoryObserver();
          final MemoryChipRam ram = MemoryChipRam(start: 0, length: 128);
          ram.registerObserver(MemoryAccessType.write, observer);

          ram.writeByteAt(10, 89);
          verify(observer.update(MemoryAccessType.write, any, any)).called(1);
          ram.writeByteAt(99, 12);
          verify(observer.update(MemoryAccessType.write, any, any)).called(1);
        });
      });

      test('clone() should clone a RAM successfully', () {
        final MemoryChipRam ram1 = MemoryChipRam(start: 0, length: 128)
          ..writeByteAt(10, 10)
          ..writeByteAt(15, 15);
        final MemoryChipRam ram2 = ram1.clone() as MemoryChipRam;

        expect(ram1, equals(ram2));
      });

      test('content of RAMs should be saved/restored successfully', () {
        final MemoryChipRam ram1 = MemoryChipRam(start: 0, length: 128);
        final MemoryChipRam ram2 = ram1.clone() as MemoryChipRam;

        ram1.writeByteAt(100, 43);

        ram2.restoreState(ram1.saveState());
        expect(ram1, equals(ram2));
      });
    });

    group('MemoryChipRom', () {
      test('should create a ROM successfully', () {
        final MockRom mockRom = createMockRom(256);
        expect(
          MemoryChipRom(start: 0, rom: mockRom),
          equals(const TypeMatcher<MemoryChipRom>()),
        );
      });

      test('isReadonly getter should return true', () {
        final MockRom mockRom = createMockRom(256);
        final MemoryChipRom rom = MemoryChipRom(start: 0, rom: mockRom);
        expect(rom.isReadonly, isTrue);
      });

      test('end getter should return the expected value', () {
        final MockRom mockRom = createMockRom(256);
        final MemoryChipRom rom = MemoryChipRom(start: 0, rom: mockRom);
        expect(rom.end, 255);
      });

      group('readByteAt()', () {
        test('should read successfully', () {
          final MockRom mockRom = createMockRom(256);
          final MemoryChipRom rom = MemoryChipRom(start: 100, rom: mockRom);
          expect(rom.readByteAt(121), equals(121));
        });

        test('should call the registered observers after each read', () {
          final MockRom mockRom = createMockRom(256);
          final MockMemoryObserver observer = MockMemoryObserver();
          final MemoryChipRom rom = MemoryChipRom(start: 0, rom: mockRom);
          rom.registerObserver(MemoryAccessType.read, observer);

          rom.readByteAt(3);
          verify(observer.update(MemoryAccessType.read, any, any)).called(1);
          rom.readByteAt(2);
          verify(observer.update(MemoryAccessType.read, any, any)).called(1);
        });
      });

      test('writeByteAt() should throw an exception', () {
        final MockRom mockRom = createMockRom(256);
        final MemoryChipRom rom = MemoryChipRom(start: 100, rom: mockRom);
        expect(
          () => rom.writeByteAt(10, 89),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('clone() should clone a rom successfully', () {
        final MockRom mockRom = createMockRom(256);
        final MemoryChipRom rom1 = MemoryChipRom(start: 100, rom: mockRom);
        final MemoryChipRom rom2 = rom1.clone() as MemoryChipRom;
        expect(rom1, equals(rom2));
      });

      test('content of roms should be saved/restored successfully', () {
        final MockRom mockRom = createMockRom(256);
        final MemoryChipRom rom1 = MemoryChipRom(start: 100, rom: mockRom);
        final MemoryChipRom rom2 = rom1.clone() as MemoryChipRom;
        rom2.restoreState(rom1.saveState());
        expect(rom1, equals(rom2));
      });
    });

    group('MemoryChipRomPlaceholder', () {
      test('should create a I/O ports area successfully', () {
        MemoryChipRomPlaceholder rpArea;

        expect(
          rpArea = MemoryChipRomPlaceholder(start: 0, length: 10, value: 16),
          equals(const TypeMatcher<MemoryChipRomPlaceholder>()),
        );

        for (int i = 0; i < rpArea.length; i++) {
          expect(rpArea.readByteAt(1), equals(16));
        }
      });

      test('isReadonly getter should return false', () {
        final MemoryChipRomPlaceholder rpArea = MemoryChipRomPlaceholder(
          start: 0,
          length: 100,
          value: 16,
        );
        expect(rpArea.isReadonly, isFalse);
      });

      test('end getter should return the expected value', () {
        final MemoryChipRomPlaceholder rpArea = MemoryChipRomPlaceholder(
          start: 0,
          length: 100,
          value: 16,
        );
        expect(rpArea.end, 99);
      });

      group('readByteAt()', () {
        test('should read successfully', () {
          final MemoryChipRomPlaceholder rpArea = MemoryChipRomPlaceholder(
            start: 0,
            length: 100,
            value: 16,
          );
          expect(rpArea.readByteAt(0), equals(16));
        });

        test('should call the registered observers after each read', () {
          final MockMemoryObserver observer = MockMemoryObserver();
          final MemoryChipRomPlaceholder rpArea = MemoryChipRomPlaceholder(
            start: 0,
            length: 128,
            value: 16,
          );
          rpArea.registerObserver(MemoryAccessType.read, observer);

          rpArea.readByteAt(3);
          verify(observer.update(MemoryAccessType.read, any, any)).called(1);
          rpArea.readByteAt(2);
          verify(observer.update(MemoryAccessType.read, any, any)).called(1);
        });
      });

      group('writeByteAt()', () {
        test('should write successfully', () {
          final MemoryChipRomPlaceholder rpArea = MemoryChipRomPlaceholder(
            start: 0,
            length: 100,
            value: 16,
          );
          rpArea.writeByteAt(10, 89);
          expect(rpArea.readByteAt(10), equals(16));
        });

        test('should call the registered observers after each write', () {
          final MockMemoryObserver observer = MockMemoryObserver();
          final MemoryChipRomPlaceholder rpArea = MemoryChipRomPlaceholder(
            start: 0,
            length: 128,
            value: 16,
          );
          rpArea.registerObserver(MemoryAccessType.write, observer);

          rpArea.writeByteAt(10, 89);
          verify(observer.update(MemoryAccessType.write, any, any)).called(1);
          rpArea.writeByteAt(99, 12);
          verify(observer.update(MemoryAccessType.write, any, any)).called(1);
        });
      });

      test('clone() should clone a RAM successfully', () {
        final MemoryChipRomPlaceholder ioArea1 = MemoryChipRomPlaceholder(
          start: 0,
          length: 128,
          value: 16,
        )
          ..writeByteAt(10, 10)
          ..writeByteAt(15, 15);
        final MemoryChipRomPlaceholder ioAre2 =
            ioArea1.clone() as MemoryChipRomPlaceholder;

        expect(ioArea1, equals(ioAre2));
      });

      test('content of RAMs should be saved/restored successfully', () {
        final MemoryChipRomPlaceholder ioArea1 = MemoryChipRomPlaceholder(
          start: 0,
          length: 128,
          value: 16,
        );
        final MemoryChipRomPlaceholder ioArea2 =
            ioArea1.clone() as MemoryChipRomPlaceholder;

        ioArea1.writeByteAt(100, 43);

        ioArea2.restoreState(ioArea1.saveState());
        expect(ioArea1, equals(ioArea2));
      });
    });

    // group('MemoryChip.rom', () {
    //   test('should create a ROM successfully', () {
    //     expect(
    //       MemoryChipRom(start: 0, content: Uint8List(100)),
    //       equals(const TypeMatcher<MemoryChipBase>()),
    //     );
    //   });
    // });

    // group('end getter', () {
    //   test('should return the last valid relative index', () {
    //     final MemoryChipBase rom = MemoryChipRom(
    //       start: 0,
    //       content: Uint8List(100),
    //     );

    //     expect(rom.end, equals(99));
    //   });
    // });
    // test('content of RAMS should be saved/restored successfully', () {
    //   // final MemoryChipBase memoryChip1 = MemoryChipRam(start: 0, length: 128);
    //   // final MemoryChipBase memoryChip2 = memoryChip1.clone();

    //   // memoryChip1.writeByteAt(100, 43);

    //   // memoryChip2.restoreState(memoryChip1.saveState());
    //   // expect(memoryChip1, equals(memoryChip2));
    // });

    // test(
    //   'isReadOnly should return false for RAMs or I/O ports and true for ROMs',
    //   () {
    //     final MemoryChipBase memoryChip1 = MemoryChipRam(start: 0, length: 128);
    //     expect(memoryChip1.isReadonly, isFalse);

    //     final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
    //     final MemoryChipBase memoryChip2 =
    //         MemoryChipRom(start: 0, content: data);
    //     expect(memoryChip2.isReadonly, isTrue);
    //   },
    // );

    // group('readByteAt()', () {
    //   test('should return the expected data', () {
    //     final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
    //     final MemoryChipBase memoryChip =
    //         MemoryChipRom(start: 0, content: data);

    //     for (int i = 0; i < data.length; i++) {
    //       expect(memoryChip.readByteAt(i), equals(data[i]));
    //     }
    //   });

    //   test('should call the registered observers after each read', () {
    //     final MockMemoryObserver observer = MockMemoryObserver();
    //     final MemoryChipBase memoryChip = MemoryChipRam(start: 0, length: 128);
    //     memoryChip.registerObserver(MemoryAccessType.read, observer);

    //     memoryChip.readByteAt(3);
    //     verify(observer.update(MemoryAccessType.read, any, any)).called(1);
    //     memoryChip.readByteAt(2);
    //     verify(observer.update(MemoryAccessType.read, any, any)).called(1);
    //   });
    // });

    // group('write()', () {
    //   test('should update a RAM successfully', () {
    //     final MemoryChipBase memoryChip = MemoryChipRam(start: 0, length: 6);
    //     final List<int> data = <int>[43, 237, 7, 0, 12, 154];

    //     for (int i = 0; i < data.length; i++) {
    //       memoryChip.writeByteAt(i, data[i]);
    //     }

    //     for (int i = 0; i < data.length; i++) {
    //       expect(memoryChip.readByteAt(i), equals(data[i]));
    //     }
    //   });

    //   test('should call the registered observers after each write', () {
    //     final MockMemoryObserver observer = MockMemoryObserver();
    //     final MemoryChipBase memoryChip = MemoryChipRam(start: 0, length: 128);
    //     memoryChip.registerObserver(MemoryAccessType.write, observer);

    //     memoryChip.writeByteAt(3, 25);
    //     verify(observer.update(MemoryAccessType.write, any, any)).called(1);
    //     memoryChip.writeByteAt(2, 185);
    //     verify(observer.update(MemoryAccessType.write, any, any)).called(1);
    //   });
    // });
  });
}
