import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'memory.dart';
import 'memory_chip.dart';

enum ChipSelectErrorId { ramFit, romFit, read, write, overlap, address, config }

class ChipSelectError extends Error {
  ChipSelectError(this.id, [this.message = '']);

  final ChipSelectErrorId id;
  final String message;

  @override
  String toString() => 'Chip-Select Error #$id: $message';
}

const int kBankLengthMax = 0x10000; // 64 KB

enum MemoryBank { me0, me1 }

class ChipSelect extends Equatable {
  ChipSelect();

  final Map<MemoryBank, List<MemoryChip>> memoryBanks = <MemoryBank, List<MemoryChip>>{
    MemoryBank.me0: <MemoryChip>[],
    MemoryBank.me1: <MemoryChip>[],
  };

  void restoreState(Map<String, dynamic> json) {
    for (final MemoryBank bank in MemoryBank.values) {
      if (json.containsKey(bank.toString())) {
        (json[bank.toString()].cast<Map<String, dynamic>>()).forEach((dynamic m) {
          final MemoryChip mc = _findMemoryChip(
            memoryBanks[bank],
            m['start'] as int,
            m['end'] as int,
          );
          mc.restoreState(m as Map<String, dynamic>);
        });
      }
    }
  }

  Map<String, dynamic> saveState() {
    List<MemoryChip> _filterRAM(List<MemoryChip> m) =>
        m.where((MemoryChip m) => m.isReadonly == false).toList();

    return <String, dynamic>{
      MemoryBank.me0.toString(): _filterRAM(memoryBanks[MemoryBank.me0])
          .map<Map<String, dynamic>>((MemoryChip m) => m.saveState()),
      MemoryBank.me1.toString(): _filterRAM(memoryBanks[MemoryBank.me1])
          .map<Map<String, dynamic>>((MemoryChip m) => m.saveState()),
    };
  }

  void appendRAM(MemoryBank bank, int start, int length, [WriteObserver observer]) {
    if (0 > start || start >= kBankLengthMax) {
      throw ArgumentError.value(start, 'start');
    }
    if (length < 1) {
      throw ArgumentError.value(length, 'length', 'RAM size must be greater than zero');
    }

    final int end = start + length - 1;
    if (end >= kBankLengthMax) {
      throw ChipSelectError(
        ChipSelectErrorId.ramFit,
        'RAM does not fit within a 64KB address space',
      );
    }

    _checkMemoryOverlap(start, end, memoryBanks[bank]);

    memoryBanks[bank].add(MemoryChip(
      start: start,
      end: end,
      memory: Memory.ram(end - start + 1),
      observer: observer,
    ));
  }

  void appendROM(
    MemoryBank bank,
    int start,
    Uint8List content, [
    WriteObserver observer,
  ]) {
    final int end = start + content.length - 1;
    if (end >= kBankLengthMax) {
      throw ChipSelectError(
        ChipSelectErrorId.romFit,
        'ROM does not fit within a 64KB address space',
      );
    }

    _checkMemoryOverlap(start, end, memoryBanks[bank]);

    memoryBanks[bank].add(
      MemoryChip(start: start, end: end, memory: Memory.rom(content), observer: observer),
    );
  }

  int readByteAt(int address) {
    final MemoryBank bank = _findMemoryBank(address);
    final int addressWithinBank = address & 0xFFFF;

    for (final MemoryChip mc in memoryBanks[bank]) {
      if (mc.start <= addressWithinBank && addressWithinBank <= mc.end) {
        return mc.readByteAt(addressWithinBank - mc.start);
      }
    }

    throw ChipSelectError(
      ChipSelectErrorId.read,
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

    throw ChipSelectError(
      ChipSelectErrorId.write,
      'writeByteAt: could not write to unmapped memory address ${_meHex16(address)}',
    );
  }

  void _checkMemoryOverlap(int start, int end, List<MemoryChip> memoryBank) {
    for (final MemoryChip mc in memoryBank) {
      if ((start >= mc.start && start <= mc.end) || (end >= mc.start && end <= mc.end)) {
        throw ChipSelectError(
          ChipSelectErrorId.overlap,
          'overlapping memory chips [${_meHex16(start)}..${_meHex16(end)}] and [${_meHex16(mc.start)}..${_meHex16(mc.end)}]',
        );
      }
    }
  }

  MemoryChip _findMemoryChip(List<MemoryChip> bank, int start, int end) {
    final Iterable<MemoryChip> result = bank.where(
      (MemoryChip mc) => start == mc.start && end == mc.end,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    throw ChipSelectError(
      ChipSelectErrorId.config,
      'State saved corresponds to another hardware configuration',
    );
  }

  MemoryBank _findMemoryBank(int address) {
    if (0 <= address && address < kBankLengthMax) {
      return MemoryBank.me0;
    }
    if (kBankLengthMax <= address && address < 2 * kBankLengthMax) {
      return MemoryBank.me1;
    }
    throw ChipSelectError(
      ChipSelectErrorId.address,
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
