import 'dart:typed_data';

import 'package:equatable/equatable.dart';

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

  final Map<MemoryBank, List<MemoryChip>> memoryBanks =
      <MemoryBank, List<MemoryChip>>{
    MemoryBank.me0: <MemoryChip>[],
    MemoryBank.me1: <MemoryChip>[],
  };

  void restoreState(Map<String, dynamic> state) {
    for (final MemoryBank bank in MemoryBank.values) {
      if (state.containsKey(bank.toString())) {
        (state[bank.toString()].cast<Map<String, dynamic>>()).forEach(
          (dynamic m) {
            final MemoryChip mc = _findMemoryChip(
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
    List<MemoryChip> _filterRAM(List<MemoryChip> m) =>
        m.where((MemoryChip m) => m.isReadonly == false).toList();

    final Map<String, dynamic> state = <String, dynamic>{
      MemoryBank.me0.toString(): _filterRAM(memoryBanks[MemoryBank.me0])
          .map<Map<String, dynamic>>((MemoryChip m) => m.saveState()),
      MemoryBank.me1.toString(): _filterRAM(memoryBanks[MemoryBank.me1])
          .map<Map<String, dynamic>>((MemoryChip m) => m.saveState()),
    };
    return state;
  }

  MemoryChip appendRAM(MemoryBank bank, int start, int length) {
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

    final MemoryChip memoryChip = MemoryChip.ram(start: start, length: length);
    memoryBanks[bank].add(memoryChip);
    return memoryChip;
  }

  MemoryChip appendROM(MemoryBank bank, int start, Uint8List content) {
    if (0 > start || start >= bankSize) {
      throw ArgumentError.value(start, 'start');
    }
    if (content.isEmpty) {
      throw ArgumentError.value(
        content.length,
        'content',
        'ROM size must be greater than zero',
      );
    }
    final int end = start + content.length - 1;
    if (end >= bankSize) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.romFit,
        'ROM does not fit within a 64KB address space',
      );
    }
    _checkMemoryOverlap(start, end, memoryBanks[bank]);

    final MemoryChip memoryChip = MemoryChip.rom(
      start: start,
      content: content,
    );
    memoryBanks[bank].add(memoryChip);
    return memoryChip;
  }

  int readByteAt(int address) {
    final MemoryBank bank = _findMemoryBank(address);
    final int addressWithinBank = address & 0xFFFF;

    for (final MemoryChip mc in memoryBanks[bank]) {
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

    for (final MemoryChip mc in memoryBanks[bank]) {
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

  void _checkMemoryOverlap(int start, int end, List<MemoryChip> memoryBank) {
    for (final MemoryChip mc in memoryBank) {
      if ((start >= mc.start && start <= mc.end) ||
          (end >= mc.start && end <= mc.end)) {
        throw ChipSelectDecoderError(
          ChipSelectDecoderErrorId.overlap,
          'overlapping memory chips [${_meHex16(start)}..${_meHex16(end)}] and [${_meHex16(mc.start)}..${_meHex16(mc.end)}]',
        );
      }
    }
  }

  MemoryChip _findMemoryChip(List<MemoryChip> bank, int start, int length) {
    final Iterable<MemoryChip> result = bank.where(
      (MemoryChip mc) => start == mc.start && length == mc.length,
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
