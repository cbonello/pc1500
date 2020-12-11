import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:roms/roms.dart';

import 'memory_chip.dart';

enum ChipSelectDecoderErrorId {
  ramFit,
  romFit,
  read,
  write,
  overlap,
  address,
  config
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

  final Map<MemoryBank, List<MemoryChipBase>> memoryBanks =
      <MemoryBank, List<MemoryChipBase>>{
    MemoryBank.me0: <MemoryChipBase>[],
    MemoryBank.me1: <MemoryChipBase>[],
  };

  void restoreState(Map<String, dynamic> state) {
    for (final MemoryBank bank in MemoryBank.values) {
      if (state.containsKey(bank.toString())) {
        (state[bank.toString()].cast<Map<String, dynamic>>()).forEach(
          (dynamic m) {
            final MemoryChipBase mc = _findMemoryChip(
              memoryBanks[bank],
              m['start'] as int,
              m['length'] as int,
            );
            mc.restoreState(m as Map<String, dynamic>);
          },
        );
      }
    }
  }

  Map<String, dynamic> saveState() {
    List<MemoryChipBase> _filterRAM(List<MemoryChipBase> m) =>
        m.where((MemoryChipBase m) => m.isReadonly == false).toList();

    final Map<String, dynamic> state = <String, dynamic>{
      MemoryBank.me0.toString(): _filterRAM(memoryBanks[MemoryBank.me0])
          .map<Map<String, dynamic>>((MemoryChipBase m) => m.saveState()),
      MemoryBank.me1.toString(): _filterRAM(memoryBanks[MemoryBank.me1])
          .map<Map<String, dynamic>>((MemoryChipBase m) => m.saveState()),
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
    _checkMemoryOverlap(start, end, memoryBanks[bank]);

    final MemoryChipRam memoryChip = MemoryChipRam(
      start: start,
      length: length,
    );
    memoryBanks[bank].add(memoryChip);
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
    _checkMemoryOverlap(start, end, memoryBanks[bank]);

    final MemoryChipRom memoryChip = MemoryChipRom(start: start, rom: rom);
    memoryBanks[bank].add(memoryChip);
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
    _checkMemoryOverlap(start, end, memoryBanks[bank]);

    final MemoryChipRomPlaceholder memoryChip = MemoryChipRomPlaceholder(
      start: start,
      length: length,
      value: value,
    );
    memoryBanks[bank].add(memoryChip);
    return memoryChip;
  }

  Uint8ClampedList readAt(int address, int length) {
    final MemoryBank bank = _findMemoryBank(address);
    final int addressWithinBank = address & 0xFFFF;

    if (length <= 0) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.read,
        'readAt: $length: length argument must be greater than zero',
      );
    }

    for (final MemoryChipBase mc in memoryBanks[bank]) {
      if (mc.start <= addressWithinBank && addressWithinBank <= mc.end) {
        if (addressWithinBank + length > mc.end) {
          throw ChipSelectDecoderError(
            ChipSelectDecoderErrorId.read,
            'readAt: ME$bank: could not read from unmapped memory address ${_meHex16(address)}',
          );
        }
        return mc.readAt(addressWithinBank - mc.start, length);
      }
    }

    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.read,
      'readAt: ME$bank: could not read from unmapped memory address ${_meHex16(address)}',
    );
  }

  int readByteAt(int address) {
    final MemoryBank bank = _findMemoryBank(address);
    final int addressWithinBank = address & 0xFFFF;

    for (final MemoryChipBase mc in memoryBanks[bank]) {
      if (mc.start <= addressWithinBank && addressWithinBank <= mc.end) {
        return mc.readByteAt(addressWithinBank - mc.start);
      }
    }

    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.read,
      'readByteAt: ME$bank: could not read from unmapped memory address ${_meHex16(address)}',
    );
  }

  void writeByteAt(int address, int value) {
    final MemoryBank bank = _findMemoryBank(address);
    final int addressWithinBank = address & 0xFFFF;

    for (final MemoryChipBase mc in memoryBanks[bank]) {
      if (mc.start <= addressWithinBank && addressWithinBank <= mc.end) {
        mc.writeByteAt(addressWithinBank - mc.start, value);
        return;
      }
    }

    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.write,
      'writeByteAt: could not write to unmapped memory address ${_meHex16(address)}',
    );
  }

  void _checkMemoryOverlap(
      int start, int end, List<MemoryChipBase> memoryBank) {
    for (final MemoryChipBase mc in memoryBank) {
      if ((start >= mc.start && start <= mc.end) ||
          (end >= mc.start && end <= mc.end)) {
        throw ChipSelectDecoderError(
          ChipSelectDecoderErrorId.overlap,
          'overlapping memory chips [${_meHex16(start)}..${_meHex16(end)}] and [${_meHex16(mc.start)}..${_meHex16(mc.end)}]',
        );
      }
    }
  }

  MemoryChipBase _findMemoryChip(
      List<MemoryChipBase> bank, int start, int length) {
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

  MemoryBank _findMemoryBank(int address) {
    if (0 <= address && address < bankSize) {
      return MemoryBank.me0;
    }
    if (bankSize <= address && address < 2 * bankSize) {
      return MemoryBank.me1;
    }
    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.address,
      'invalid address ${_meHex16(address)}',
    );
  }

  String _hex16(int address) =>
      address.toUnsigned(16).toRadixString(16).toUpperCase().padLeft(4, '0');

  String _meHex16(int address) {
    final String prefix = address >= 0x10000 ? '#' : '';
    return '$prefix${_hex16(address)}H';
  }

  @override
  List<Object> get props => <Object>[memoryBanks];

  @override
  bool get stringify => true;
}
