import 'dart:async';
import 'dart:typed_data';

import 'package:device/device.dart';
import 'package:just_audio/just_audio.dart';

/// Plays buzzer tones from [BuzzerEventMsg]s using in-memory WAV buffers.
///
/// The PC-1500 buzzer is a piezo element driven by a square wave. This class
/// generates a square-wave WAV in memory and plays it via [AudioPlayer].
class Buzzer {
  final AudioPlayer _player = AudioPlayer();
  final List<BuzzerEventMsg> _queue = <BuzzerEventMsg>[];
  bool _playing = false;

  /// Subscribes to a [BuzzerEventMsg] stream and plays each tone.
  StreamSubscription<BuzzerEventMsg> listen(Stream<BuzzerEventMsg> events) {
    return events.listen(_enqueue);
  }

  void _enqueue(BuzzerEventMsg event) {
    if (event.frequencyHz <= 0 || event.durationMs <= 0) return;
    _queue.add(event);
    if (!_playing) _processQueue();
  }

  Future<void> _processQueue() async {
    _playing = true;
    while (_queue.isNotEmpty) {
      final BuzzerEventMsg event = _queue.removeAt(0);
      final Uint8List wav = _generateSquareWav(
        event.frequencyHz,
        event.durationMs,
      );
      try {
        await _player.setAudioSource(_BytesAudioSource(wav));
        await _player.play();
        // Wait for playback to finish before playing the next tone.
        await Future<void>.delayed(
          Duration(milliseconds: event.durationMs.round()),
        );
      } on Object catch (_) {
        // Audio errors are non-fatal.
      }
    }
    _playing = false;
  }

  void dispose() {
    _queue.clear();
    _player.dispose();
  }

  /// Generates a 16-bit mono PCM WAV at 44100 Hz with a square wave.
  static Uint8List _generateSquareWav(double freqHz, double durationMs) {
    const int sampleRate = 44100;
    const int bitsPerSample = 16;
    const int numChannels = 1;

    const int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    const int blockAlign = numChannels * bitsPerSample ~/ 8;
    final int numSamples = (sampleRate * durationMs / 1000).round();
    final int dataSize = numSamples * blockAlign;

    // Square wave amplitude (lower than max to avoid harshness).
    const int amplitude = 8000;
    final double samplesPerPeriod = sampleRate / freqHz;

    final ByteData data = ByteData(44 + dataSize);

    // RIFF header.
    data.setUint8(0, 0x52); // 'R'
    data.setUint8(1, 0x49); // 'I'
    data.setUint8(2, 0x46); // 'F'
    data.setUint8(3, 0x46); // 'F'
    data.setUint32(4, 36 + dataSize, Endian.little);
    data.setUint8(8, 0x57); // 'W'
    data.setUint8(9, 0x41); // 'A'
    data.setUint8(10, 0x56); // 'V'
    data.setUint8(11, 0x45); // 'E'

    // fmt chunk.
    data.setUint8(12, 0x66); // 'f'
    data.setUint8(13, 0x6D); // 'm'
    data.setUint8(14, 0x74); // 't'
    data.setUint8(15, 0x20); // ' '
    data.setUint32(16, 16, Endian.little); // chunk size
    data.setUint16(20, 1, Endian.little); // PCM format
    data.setUint16(22, numChannels, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, byteRate, Endian.little);
    data.setUint16(32, blockAlign, Endian.little);
    data.setUint16(34, bitsPerSample, Endian.little);

    // data chunk.
    data.setUint8(36, 0x64); // 'd'
    data.setUint8(37, 0x61); // 'a'
    data.setUint8(38, 0x74); // 't'
    data.setUint8(39, 0x61); // 'a'
    data.setUint32(40, dataSize, Endian.little);

    // Square wave samples.
    for (int i = 0; i < numSamples; i++) {
      final double pos = (i % samplesPerPeriod) / samplesPerPeriod;
      final int sample = pos < 0.5 ? amplitude : -amplitude;
      data.setInt16(44 + i * 2, sample, Endian.little);
    }

    return data.buffer.asUint8List();
  }
}

/// An [AudioSource] that reads from an in-memory byte buffer.
// ignore: experimental_member_use
class _BytesAudioSource extends StreamAudioSource {
  _BytesAudioSource(this._bytes);

  final Uint8List _bytes;

  @override
  // ignore: experimental_member_use
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;

    // ignore: experimental_member_use
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}
