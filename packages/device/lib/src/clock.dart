import 'dart:io';

import 'package:meta/meta.dart';

const int fpsMin = 5;
const int fpsMax = 60;

class Clock {
  Clock({@required this.freq, @required int fps})
      : _fps = fps,
        _cycles = 0;

  // Number of frames per second.
  int _fps;
  // Clock frequency in Hz.
  final int freq;
  // Number of clock cycles per frame.
  int _cyclesPerFrame;

  // Number of clock cycles performed so far in current frame.
  int _cycles;
  // Frame duration.
  Duration _frameDuration;
  // Frame duration if we were executing one more frame per second.
  Duration _framePlus1Duration;
  // Expected start time of next frame.
  DateTime _startTimeNextFrame;

  int get fps => _fps;

  bool increment(int cycles) {
    _cycles += cycles;
    if (_cycles >= _cyclesPerFrame) {
      _cycles = _cycles % _cyclesPerFrame;
      return true;
    }
    return false;
  }

  void waitStartOfFrame() {
    final DateTime now = DateTime.now();
    if (now.isAfter(_startTimeNextFrame) && _fps > fpsMin) {
      // We are past the expected start of the next frame; current frame rate
      // is too high.
      updateFps(_fps - 1);
    } else {
      final Duration timeLeft = _startTimeNextFrame.difference(DateTime.now());
      sleep(timeLeft);
      if (timeLeft > _framePlus1Duration && _fps < fpsMax) {
        // Time left (unused) could allow us to execute one more frame per
        // second.
        updateFps(_fps + 1);
      }
    }
    _timeNextFrame();
  }

  void updateFps(int fps) {
    _fps = fps;
    _frameDuration = Duration(milliseconds: (1000 / _fps).round());
    _framePlus1Duration = Duration(milliseconds: (1000 / (_fps + 1)).round());
    _cyclesPerFrame = (freq / _fps).round();
  }

  void _timeNextFrame() {
    _startTimeNextFrame = DateTime.now().add(_frameDuration);
  }
}
