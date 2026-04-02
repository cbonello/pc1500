/// Minimum allowed frames per second.
const int fpsMin = 5;

/// Maximum allowed frames per second.
const int fpsMax = 60;

/// Tracks CPU cycle budgets per frame to pace emulation.
///
/// The emulator runs the CPU in a tight loop until enough cycles have been
/// consumed to fill one frame, then yields so the Flutter UI can repaint.
/// [Clock] converts between wall-clock time (fps) and CPU time (cycles).
class Clock {
  /// Creates a clock for the given CPU [freq]uency (Hz) and target [fps].
  ///
  /// [fps] is clamped to [[fpsMin], [fpsMax]].
  Clock({required this.freq, required int fps})
    : _fps = fps.clamp(fpsMin, fpsMax),
      _cycles = 0,
      _cyclesPerFrame = (freq / fps.clamp(fpsMin, fpsMax)).round();

  /// CPU clock frequency in Hz (e.g. 1 300 000 for the LH5801 at 1.3 MHz).
  final int freq;

  int _fps;
  int _cyclesPerFrame;
  int _cycles;

  /// Current frames-per-second target.
  int get fps => _fps;

  /// CPU cycles allocated per frame at the current [fps].
  int get cyclesPerFrame => _cyclesPerFrame;

  /// Wall-clock duration of one frame at the current [fps].
  Duration get frameDuration =>
      Duration(microseconds: (1000000 / _fps).round());

  /// Adds [cycles] to the running total for the current frame.
  ///
  /// Returns `true` when the frame budget has been reached or exceeded,
  /// signalling that the emulator should yield. Excess cycles carry over
  /// into the next frame so that long instructions do not drift timing.
  bool increment(int cycles) {
    _cycles += cycles;
    if (_cycles >= _cyclesPerFrame) {
      _cycles = _cycles % _cyclesPerFrame;
      return true;
    }

    return false;
  }

  /// Changes the target frame rate and recomputes the per-frame cycle budget.
  ///
  /// [fps] is clamped to [[fpsMin], [fpsMax]].
  void updateFps(int fps) {
    _fps = fps.clamp(fpsMin, fpsMax);
    _cyclesPerFrame = (freq / _fps).round();
  }
}
