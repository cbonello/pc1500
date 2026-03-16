import 'dart:typed_data';

import 'package:chip_select_decoder/src/memory_chip.dart';
import 'package:equatable/equatable.dart';
import 'package:roms/roms.dart';

enum ChipSelectDecoderErrorId {
  ramFit,
  romFit,
  read,
  write,
  overlap,
  address,
  config,
}

class ChipSelectDecoderError extends Error {
  ChipSelectDecoderError(this.id, [this.message = '']);

  final ChipSelectDecoderErrorId id;
  final String message;

  @override
  String toString() => 'Chip-Select Error #$id: $message';
}

const int bankSize = 0x10000; // 64 KB

enum MemoryBank { me0, me1 }

class ChipSelectDecoder extends Equatable {
  ChipSelectDecoder();

  final Map<MemoryBank, List<MemoryChipBase>> _memoryBanks =
      <MemoryBank, List<MemoryChipBase>>{
        MemoryBank.me0: <MemoryChipBase>[],
        MemoryBank.me1: <MemoryChipBase>[],
      };

  // Flat lookup tables: address → chip. O(1) reads/writes instead of O(n).
  final List<MemoryChipBase?> _lookupME0 =
      List<MemoryChipBase?>.filled(bankSize, null);
  final List<MemoryChipBase?> _lookupME1 =
      List<MemoryChipBase?>.filled(bankSize, null);

  List<MemoryChipBase> memoryChips(MemoryBank bank) =>
      List.unmodifiable(_memoryBanks[bank]!);

  void restoreState(Map<String, dynamic> state) {
    for (final MemoryBank bank in MemoryBank.values) {
      final String key = bank.toString();
      if (state.containsKey(key)) {
        final List<Map<String, dynamic>> chips = (state[key] as Iterable)
            .cast<Map<String, dynamic>>()
            .toList();
        for (final Map<String, dynamic> m in chips) {
          final MemoryChipBase mc = _findMemoryChip(
            _memoryBanks[bank]!,
            m['start'] as int,
            m['length'] as int,
          );
          mc.restoreState(m);
        }
      }
    }
  }

  Map<String, dynamic> saveState() {
    List<MemoryChipBase> filterRAM(List<MemoryChipBase> m) =>
        m.where((MemoryChipBase m) => m.isReadonly == false).toList();

    final Map<String, dynamic> state = <String, dynamic>{
      MemoryBank.me0.toString(): filterRAM(
        _memoryBanks[MemoryBank.me0]!,
      ).map<Map<String, dynamic>>((MemoryChipBase m) => m.saveState()).toList(),
      MemoryBank.me1.toString(): filterRAM(
        _memoryBanks[MemoryBank.me1]!,
      ).map<Map<String, dynamic>>((MemoryChipBase m) => m.saveState()).toList(),
    };

    return state;
  }

  MemoryChipBase appendRAM(MemoryBank bank, int start, int length) {
    if (0 > start || start >= bankSize) {
      throw ArgumentError.value(start, 'start');
    }
    if (length < 1) {
      throw ArgumentError.value(
        length,
        'length',
        'RAM size must be greater than zero',
      );
    }
    final int end = start + length - 1;
    if (end >= bankSize) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.ramFit,
        'RAM does not fit within a 64KB address space',
      );
    }
    _checkMemoryOverlap(start, end, _memoryBanks[bank]!);

    final MemoryChipRam memoryChip = MemoryChipRam(
      start: start,
      length: length,
    );
    _memoryBanks[bank]!.add(memoryChip);
    _populateLookup(bank, memoryChip);

    return memoryChip;
  }

  MemoryChipBase appendROM(MemoryBank bank, int start, RomBase rom) {
    if (0 > start || start >= bankSize) {
      throw ArgumentError.value(start, 'start');
    }

    final Uint8List bytes = rom.bytes;
    if (bytes.isEmpty) {
      throw ArgumentError.value(
        0,
        'content',
        'ROM size must be greater than zero',
      );
    }
    final int end = start + bytes.length - 1;
    if (end >= bankSize) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.romFit,
        'ROM does not fit within a 64KB address space',
      );
    }
    _checkMemoryOverlap(start, end, _memoryBanks[bank]!);

    final MemoryChipRom memoryChip = MemoryChipRom(start: start, rom: rom);
    _memoryBanks[bank]!.add(memoryChip);
    _populateLookup(bank, memoryChip);

    return memoryChip;
  }

  MemoryChipBase appendROMPlaceholder(
    MemoryBank bank,
    int start,
    int length,
    int value,
  ) {
    if (0 > start || start >= bankSize) {
      throw ArgumentError.value(start, 'start');
    }
    if (length < 1) {
      throw ArgumentError.value(
        length,
        'length',
        'ROM placeholder size must be greater than zero',
      );
    }
    final int end = start + length - 1;
    if (end >= bankSize) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.romFit,
        'ROM placeholder does not fit within a 64KB address space',
      );
    }
    _checkMemoryOverlap(start, end, _memoryBanks[bank]!);

    final MemoryChipRomPlaceholder memoryChip = MemoryChipRomPlaceholder(
      start: start,
      length: length,
      value: value,
    );
    _memoryBanks[bank]!.add(memoryChip);
    _populateLookup(bank, memoryChip);

    return memoryChip;
  }

  Uint8ClampedList readAt(int address, int length) {
    if (length <= 0) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.read,
        'readAt: $length: length argument must be greater than zero',
      );
    }

    final int addressWithinBank = address & 0xFFFF;
    final MemoryChipBase? mc = _lookupChip(address);

    if (mc != null &&
        mc.start <= addressWithinBank &&
        addressWithinBank + length - 1 <= mc.end) {
      return mc.readAt(addressWithinBank - mc.start, length);
    }

    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.read,
      'readAt: could not read from unmapped memory address '
      '${_meHex16(address)}',
    );
  }

  int readByteAt(int address) {
    final MemoryChipBase? mc = _lookupChip(address);
    if (mc != null) {
      return mc.readByteAt((address & 0xFFFF) - mc.start);
    }

    // Unmapped address — return 0xFF (floating bus).
    // The ROM probes unmapped ranges to detect expansion modules.
    return 0xFF;
  }

  void writeByteAt(int address, int value) {
    final MemoryChipBase? mc = _lookupChip(address);
    if (mc != null) {
      mc.writeByteAt((address & 0xFFFF) - mc.start, value);
      return;
    }

    // Unmapped address — silently ignore.
    // Writes to unmapped memory have no effect on real hardware.
  }

  /// O(1) chip lookup via flat table.
  MemoryChipBase? _lookupChip(int address) {
    if (address >= 0 && address < bankSize) {
      return _lookupME0[address];
    }
    if (address >= bankSize && address < 2 * bankSize) {
      return _lookupME1[address & 0xFFFF];
    }
    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.address,
      'invalid address ${_meHex16(address)}',
    );
  }

  void _populateLookup(MemoryBank bank, MemoryChipBase chip) {
    final List<MemoryChipBase?> lookup =
        bank == MemoryBank.me0 ? _lookupME0 : _lookupME1;
    for (int i = chip.start; i <= chip.end; i++) {
      lookup[i] = chip;
    }
  }

  void _checkMemoryOverlap(
    int start,
    int end,
    List<MemoryChipBase> memoryBank,
  ) {
    for (final MemoryChipBase mc in memoryBank) {
      if ((start >= mc.start && start <= mc.end) ||
          (end >= mc.start && end <= mc.end) ||
          (start <= mc.start && end >= mc.end)) {
        throw ChipSelectDecoderError(
          ChipSelectDecoderErrorId.overlap,
          'overlapping memory chips [${_meHex16(start)}..${_meHex16(end)}] '
          'and [${_meHex16(mc.start)}..${_meHex16(mc.end)}]',
        );
      }
    }
  }

  MemoryChipBase _findMemoryChip(
    List<MemoryChipBase> bank,
    int start,
    int length,
  ) {
    final Iterable<MemoryChipBase> result = bank.where(
      (MemoryChipBase mc) => start == mc.start && length == mc.length,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.config,
      'State saved corresponds to another hardware configuration',
    );
  }

  String _hex16(int address) =>
      address.toUnsigned(16).toRadixString(16).toUpperCase().padLeft(4, '0');

  String _meHex16(int address) {
    final String prefix = address >= 0x10000 ? '#' : '';

    return '$prefix${_hex16(address)}H';
  }

  @override
  List<Object> get props => <Object>[_memoryBanks];

  @override
  bool get stringify => true;
}
