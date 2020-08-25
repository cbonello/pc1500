import 'dart:convert';

import 'package:meta/meta.dart';

import 'models.dart';

@immutable
class MemoryBanksAnnotations {
  const MemoryBanksAnnotations._({
    @required this.banks,
    @required this.symbolTable,
  });

  factory MemoryBanksAnnotations.fromAnnotations(
    List<String> annotations,
  ) {
    final List<AnnotatedArea> areas = <AnnotatedArea>[];

    for (final String str in annotations) {
      final Map<String, dynamic> json = jsonDecode(str) as Map<String, dynamic>;

      for (final String tag in json.keys) {
        assert(json[tag] != null);

        final AddressSpace addressSpace = AddressSpace.fromTag(tag);
        final AnnotatedArea area = AnnotatedArea.fromJson(
          null,
          addressSpace,
          json[tag] as Map<String, dynamic>,
        );

        areas.add(area);
      }
    }

    final List<Map<int, AnnotationBase>> banks = <Map<int, AnnotationBase>>[
      <int, AnnotationBase>{},
      <int, AnnotationBase>{},
    ];
    final List<Map<String, AnnotationBase>> symbolTable =
        <Map<String, AnnotationBase>>[
      <String, AnnotationBase>{},
      <String, AnnotationBase>{},
    ];

    if (areas.isNotEmpty) {
      for (int i = 1; i < areas.length; i++) {
        assert(
          areas[i - 1].addressSpace.memoryBank ==
              areas[i].addressSpace.memoryBank,
        );
        assert(
          !areas[i - 1].addressSpace.intersectWith(areas[i].addressSpace),
        );
      }

      for (final AnnotationBase area in areas) {
        final int memoryBank = area.addressSpace.memoryBank;

        area.mapAddress(banks[memoryBank]);
        area.addSymbol(symbolTable[memoryBank]);
      }
    }

    return MemoryBanksAnnotations._(banks: banks, symbolTable: symbolTable);
  }

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
}
