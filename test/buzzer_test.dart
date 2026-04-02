import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/buzzer.dart';

void main() {
  group('Buzzer.generateSquareWav', () {
    test('generates valid RIFF/WAVE header', () {
      final wav = Buzzer.generateSquareWav(440, 100);

      // RIFF header.
      expect(String.fromCharCodes(wav.sublist(0, 4)), equals('RIFF'));
      expect(String.fromCharCodes(wav.sublist(8, 12)), equals('WAVE'));
    });

    test('generates valid fmt chunk', () {
      final wav = Buzzer.generateSquareWav(440, 100);
      final data = ByteData.sublistView(wav);

      expect(String.fromCharCodes(wav.sublist(12, 16)), equals('fmt '));
      expect(data.getUint32(16, Endian.little), equals(16)); // chunk size
      expect(data.getUint16(20, Endian.little), equals(1)); // PCM format
      expect(data.getUint16(22, Endian.little), equals(1)); // mono
      expect(data.getUint32(24, Endian.little), equals(44100)); // sample rate
      expect(data.getUint16(34, Endian.little), equals(16)); // bits per sample
    });

    test('generates valid data chunk', () {
      final wav = Buzzer.generateSquareWav(440, 100);
      final data = ByteData.sublistView(wav);

      expect(String.fromCharCodes(wav.sublist(36, 40)), equals('data'));

      final dataSize = data.getUint32(40, Endian.little);
      // 100ms at 44100Hz = 4410 samples * 2 bytes = 8820.
      expect(dataSize, equals(4410 * 2));
      expect(wav.length, equals(44 + dataSize));
    });

    test('RIFF file size field is consistent', () {
      final wav = Buzzer.generateSquareWav(1000, 50);
      final data = ByteData.sublistView(wav);

      final riffSize = data.getUint32(4, Endian.little);
      expect(riffSize, equals(wav.length - 8));
    });

    test('square wave alternates between positive and negative amplitude', () {
      // Use a low frequency so each half-period spans many samples.
      // At 100Hz / 44100Hz, one period = 441 samples, half = 220.5.
      final wav = Buzzer.generateSquareWav(100, 50);
      final data = ByteData.sublistView(wav);

      // First sample is in the positive half.
      final sample0 = data.getInt16(44, Endian.little);
      expect(sample0, equals(8000));

      // Sample 250 is well into the negative half (past the 220.5 midpoint).
      final sampleNeg = data.getInt16(44 + 250 * 2, Endian.little);
      expect(sampleNeg, equals(-8000));
    });

    test('duration affects output size', () {
      final short = Buzzer.generateSquareWav(440, 50);
      final long = Buzzer.generateSquareWav(440, 200);

      expect(long.length, greaterThan(short.length));
    });

    test('frequency does not affect output size', () {
      final low = Buzzer.generateSquareWav(200, 100);
      final high = Buzzer.generateSquareWav(2000, 100);

      expect(low.length, equals(high.length));
    });
  });
}
