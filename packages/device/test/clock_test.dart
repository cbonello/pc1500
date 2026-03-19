import 'package:device/src/emulator_isolate/clock.dart';
import 'package:test/test.dart';

void main() {
  group('Clock', () {
    group('constructor', () {
      test('should initialize cyclesPerFrame from freq and fps', () {
        final Clock clock = Clock(freq: 1300000, fps: 50);
        // 1300000 / 50 = 26000 cycles per frame.
        // increment() should return true after exactly 26000 cycles.
        expect(clock.increment(25999), isFalse);
        expect(clock.increment(1), isTrue);
      });

      test('should clamp fps to minimum', () {
        final Clock clock = Clock(freq: 1300000, fps: 1);
        expect(clock.fps, equals(fpsMin));
      });

      test('should clamp fps to maximum', () {
        final Clock clock = Clock(freq: 1300000, fps: 100);
        expect(clock.fps, equals(fpsMax));
      });
    });

    group('increment()', () {
      test('should return false when frame budget not exhausted', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        // 1000 / 10 = 100 cycles per frame.
        expect(clock.increment(50), isFalse);
        expect(clock.increment(49), isFalse);
      });

      test('should return true when frame budget reached', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        // 100 cycles per frame.
        expect(clock.increment(100), isTrue);
      });

      test('should return true when frame budget exceeded', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        expect(clock.increment(150), isTrue);
      });

      test('should carry over excess cycles to next frame', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        // 100 cycles per frame. Add 90, then 20 (10 over).
        expect(clock.increment(90), isFalse);
        expect(clock.increment(20), isTrue);
        // 10 cycles carried over → need 90 more to complete next frame.
        expect(clock.increment(89), isFalse);
        expect(clock.increment(1), isTrue);
      });

      test('should handle multiple frames in sequence', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        for (int i = 0; i < 5; i++) {
          expect(clock.increment(100), isTrue);
        }
      });

      test('should accumulate small increments', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        // 100 cycles per frame, add 1 at a time.
        for (int i = 0; i < 99; i++) {
          expect(clock.increment(1), isFalse);
        }
        expect(clock.increment(1), isTrue);
      });
    });

    group('updateFps()', () {
      test('should change cycles per frame', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        // Initially 100 cycles/frame.
        clock.updateFps(20);
        // Now 1000 / 20 = 50 cycles/frame.
        expect(clock.fps, equals(20));
        expect(clock.increment(49), isFalse);
        expect(clock.increment(1), isTrue);
      });

      test('should clamp fps to valid range', () {
        final Clock clock = Clock(freq: 1000, fps: 10);
        clock.updateFps(1);
        expect(clock.fps, equals(fpsMin));
        clock.updateFps(1000);
        expect(clock.fps, equals(fpsMax));
      });
    });

    group('frameDuration', () {
      test('should return correct duration for 50 fps', () {
        final Clock clock = Clock(freq: 1300000, fps: 50);
        expect(
          clock.frameDuration,
          equals(const Duration(microseconds: 20000)),
        );
      });

      test('should return correct duration for 60 fps', () {
        final Clock clock = Clock(freq: 1300000, fps: 60);
        // 1000000 / 60 ≈ 16667 microseconds.
        expect(
          clock.frameDuration,
          equals(Duration(microseconds: (1000000 / 60).round())),
        );
      });
    });
  });
}
