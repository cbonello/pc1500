import 'dart:collection';

import 'package:annotations/src/address_space.dart';
import 'package:annotations/src/annotated_area.dart';
import 'package:annotations/src/base_annotation.dart';
import 'package:annotations/src/exception.dart';

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
    required Map<int, List<AnnotatedArea>> areasInBanks,
    required List<Map<int, AnnotationBase>> banks,
    required List<Map<String, AnnotationBase>> symbolTable,
  }) : _areasInBanks = areasInBanks,
       _banks = banks,
       _symbolTable = symbolTable;

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
        final memoryBank = areas[i].addressSpace.memoryBank;

        for (int j = 0; j < (_areasInBanks[memoryBank]?.length ?? 0); j++) {
          if (areas[i].addressSpace.intersectWith(
            _areasInBanks[memoryBank]![j].addressSpace,
          )) {
            throw AnnotationsError(
              'MemoryBanksAnnotations: ${areas[i].addressSpace}: '
              '${_areasInBanks[memoryBank]![j].addressSpace}: Areas intersect',
            );
          }
        }

        _areasInBanks[memoryBank]!.add(areas[i]);
      }

      // Build into temporary maps so existing state is preserved on failure.
      final tempBanks = <Map<int, AnnotationBase>>[
        <int, AnnotationBase>{},
        <int, AnnotationBase>{},
      ];
      final tempSymbolTable = <Map<String, AnnotationBase>>[
        <String, AnnotationBase>{},
        <String, AnnotationBase>{},
      ];

      for (final int memoryBank in <int>[0, 1]) {
        for (final AnnotationBase area in _areasInBanks[memoryBank]!) {
          area.mapAddress(tempBanks[memoryBank]);
          area.addSymbol(tempSymbolTable[memoryBank]);
        }
      }

      // Success — swap in the new maps.
      for (final int memoryBank in <int>[0, 1]) {
        _banks[memoryBank]
          ..clear()
          ..addAll(tempBanks[memoryBank]);
        _symbolTable[memoryBank]
          ..clear()
          ..addAll(tempSymbolTable[memoryBank]);
      }
    }
  }

  final Map<int, List<AnnotatedArea>> _areasInBanks;
  final List<Map<int, AnnotationBase>> _banks;
  final List<Map<String, AnnotationBase>> _symbolTable;

  Map<int, AnnotationBase> bank(int index) =>
      UnmodifiableMapView(_banks[index]);

  Map<String, AnnotationBase> symbols(int index) =>
      UnmodifiableMapView(_symbolTable[index]);

  bool isAnnotated(int address) =>
      _banks[_memoryBank(address)].containsKey(address & 0xFFFF);

  AnnotationBase? getAnnotationFromAddress(int address) => isAnnotated(address)
      ? _banks[_memoryBank(address)][address & 0xFFFF]
      : null;

  bool isSymbolDefined(int memoryBank, String symbol) =>
      _symbolTable[memoryBank].containsKey(symbol);

  AnnotationBase? getAnnotationFromSymbol(int memoryBank, String symbol) =>
      isSymbolDefined(memoryBank, symbol)
      ? _symbolTable[memoryBank][symbol]
      : null;

  int _memoryBank(int address) => address < 0x10000 ? 0 : 1;
}
