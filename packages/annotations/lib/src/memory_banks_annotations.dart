import 'package:meta/meta.dart';

import 'address_space.dart';
import 'annotated_area.dart';
import 'base_annotation.dart';
import 'exception.dart';

class MemoryBanksAnnotations {
  factory MemoryBanksAnnotations() {
    return MemoryBanksAnnotations._(
      areasInBanks: <int, List<AnnotatedArea>>{
        0: <AnnotatedArea>[],
        1: <AnnotatedArea>[],
      },
      banks: <Map<int, AnnotationBase>>[
        <int, AnnotationBase>{},
        <int, AnnotationBase>{},
      ],
      symbolTable: <Map<String, AnnotationBase>>[
        <String, AnnotationBase>{},
        <String, AnnotationBase>{},
      ],
    );
  }

  MemoryBanksAnnotations._({
    @required Map<int, List<AnnotatedArea>> areasInBanks,
    @required this.banks,
    @required this.symbolTable,
  }) : _areasInBanks = areasInBanks;

  void load(Map<String, dynamic> json) {
    final List<AnnotatedArea> areas = <AnnotatedArea>[];

    for (final String tag in json.keys) {
      if (json[tag] == null) {
        throw AnnotationsError(
          'MemoryBanksAnnotations: Null annotated area "$tag"',
        );
      }

      final AddressSpace addressSpace = AddressSpace.fromTag(tag);
      final AnnotatedArea area = AnnotatedArea.fromJson(
        null,
        addressSpace,
        json[tag] as Map<String, dynamic>,
      );

      areas.add(area);
    }

    if (areas.isNotEmpty) {
      for (int i = 0; i < areas.length; i++) {
        final int memoryBank = areas[i].addressSpace.memoryBank;

        for (int j = 0; j < _areasInBanks[memoryBank].length; j++) {
          if (areas[i]
              .addressSpace
              .intersectWith(_areasInBanks[memoryBank][j].addressSpace)) {
            throw AnnotationsError(
              'MemoryBanksAnnotations: ${areas[i].addressSpace}: ${_areasInBanks[memoryBank][j].addressSpace}: Areas intersect',
            );
          }
        }

        _areasInBanks[memoryBank].add(areas[i]);
      }

      _clear();
      for (final int memoryBank in <int>[0, 1]) {
        for (final AnnotationBase area in _areasInBanks[memoryBank]) {
          area.mapAddress(banks[memoryBank]);
          area.addSymbol(symbolTable[memoryBank]);
        }
      }
    }
  }

  final Map<int, List<AnnotatedArea>> _areasInBanks;
  final List<Map<int, AnnotationBase>> banks;
  final List<Map<String, AnnotationBase>> symbolTable;

  bool isAnnotated(int address) =>
      banks[_memoryBank(address)].containsKey(address & 0xFFFF);

  AnnotationBase getAnnotationFromAddress(int address) => isAnnotated(address)
      ? banks[_memoryBank(address)][address & 0xFFFF]
      : null;

  bool isSymbolDefined(int memoryBank, String symbol) =>
      symbolTable[memoryBank].containsKey(symbol);

  AnnotationBase getAnnotationFromSymbol(int memoryBank, String symbol) =>
      isSymbolDefined(memoryBank, symbol)
          ? symbolTable[memoryBank][symbol]
          : null;

  int _memoryBank(int address) => address < 0x10000 ? 0 : 1;

  void _clear() {
    for (final int memoryBank in <int>[0, 1]) {
      banks[memoryBank].clear();
      symbolTable[memoryBank].clear();
    }
  }
}
