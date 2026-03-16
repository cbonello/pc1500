const int fpsMin = 5;
const int fpsMax = 60;

class Clock {
  Clock({required this.freq, required int fps})
    : _fps = fps,
      _cycles = 0,
      _cyclesPerFrame = 0;

  // Clock frequency in Hz.
  final int freq;
  // Number of frames per second.
  int _fps;
  // Number of clock cycles per frame.
  int _cyclesPerFrame;
  // Number of clock cycles performed so far in current frame.
  int _cycles;

  int get fps => _fps;

  /// Returns the frame duration for the current fps.
  Duration get frameDuration =>
      Duration(microseconds: (1000000 / _fps).round());

  /// Increments the cycle counter. Returns true when a full frame's worth
  /// of cycles has been consumed.
  bool increment(int cycles) {
    _cycles += cycles;
    if (_cycles >= _cyclesPerFrame) {
      _cycles = _cycles % _cyclesPerFrame;
      return true;
    }
    return false;
  }

  void updateFps(int fps) {
    _fps = fps.clamp(fpsMin, fpsMax);
    _cyclesPerFrame = (freq / _fps).round();
  }
}
