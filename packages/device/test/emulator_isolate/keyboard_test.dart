import 'package:device/src/emulator_isolate/keyboard.dart';
import 'package:test/test.dart';

void main() {
  group(Keyboard, () {
    group('keyDown / keyUp', () {
      test('keyDown should add key to pressed set', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        expect(kb.debugPressedKeys, contains('a'));
      });

      test('keyUp should remove key from pressed set', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyUp('a');
        expect(kb.debugPressedKeys, isNot(contains('a')));
      });

      test('multiple keys can be pressed simultaneously', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyDown('b');
        expect(kb.debugPressedKeys, containsAll(<String>['a', 'b']));
      });

      test('keyUp for unpressed key is a no-op', () {
        final Keyboard kb = Keyboard();
        kb.keyUp('z');
        expect(kb.debugPressedKeys, isEmpty);
      });
    });

    group('isOnKeyPressed', () {
      test('should return false when ON is not pressed', () {
        final Keyboard kb = Keyboard();
        expect(kb.isOnKeyPressed, isFalse);
      });

      test('should return true when ON is pressed', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('on');
        expect(kb.isOnKeyPressed, isTrue);
      });

      test('should return false after ON is released', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('on');
        kb.keyUp('on');
        expect(kb.isOnKeyPressed, isFalse);
      });
    });

    group('debugPressedKeys', () {
      test('should return unmodifiable set', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        expect(
          () => kb.debugPressedKeys.add('x'),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('scanIN', () {
      test('should return 0xFF when no keys pressed', () {
        final Keyboard kb = Keyboard();
        expect(kb.scanIN(0xFF, 0x00), equals(0xFF));
      });

      test('should detect key on correct column and row', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('7'); // PA2, IN2
        final int result = kb.scanIN(0x04, 0x00);
        expect(result & 0x04, equals(0)); // IN2 low
        expect(result | 0x04, equals(0xFF)); // rest high
      });

      test('should not detect key on wrong column', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('7'); // PA2, IN2
        expect(kb.scanIN(0x01, 0x00), equals(0xFF));
      });

      test('should detect key during quick check (all columns)', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('7'); // PA2, IN2
        expect(kb.scanIN(0xFF, 0x00) & 0x04, equals(0));
      });

      test('should not detect key when OPA disables strobe', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('7'); // PA2, IN2
        expect(kb.scanIN(0x04, 0x04), equals(0xFF));
      });

      test('should detect multiple keys on same column', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('7'); // PA2, IN2
        kb.keyDown('4'); // PA2, IN1
        final int result = kb.scanIN(0x04, 0x00);
        expect(result & 0x04, equals(0)); // IN2
        expect(result & 0x02, equals(0)); // IN1
      });

      test('should detect multiple keys on different columns', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('7'); // PA2, IN2
        kb.keyDown('a'); // PA6, IN3
        expect(kb.scanIN(0x04, 0x00) & 0x04, equals(0)); // '7'
        expect(kb.scanIN(0x40, 0x00) & 0x08, equals(0)); // 'a'
      });

      test('unknown key names should be ignored', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('nonexistent');
        expect(kb.scanIN(0xFF, 0x00), equals(0xFF));
      });
    });

    // Each queued key occupies 2 ticks total:
    //   tick N:   dequeue key, add to pressed, holdFrames = 1
    //   tick N+1: holdFrames = 0 (still held)
    //   tick N+2: cleanup key (removed from pressed), dequeue next
    group('key queue', () {
      test('queued key should be re-injected after release', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyUp('a');
        kb.tickKeyQueue(); // dequeue 'a'
        expect(kb.debugPressedKeys, contains('a'));
      });

      test('queued key should be held for minHoldFrames + 1 ticks', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyUp('a');
        // Tick 1: dequeue 'a'.
        kb.tickKeyQueue();
        expect(kb.debugPressedKeys, contains('a'));
        // Tick 2: hold (holdFrames=0).
        kb.tickKeyQueue();
        expect(kb.debugPressedKeys, contains('a'));
        // Tick 3: cleanup 'a' — removed.
        kb.tickKeyQueue();
        expect(kb.debugPressedKeys, isNot(contains('a')));
      });

      test('should deduplicate consecutive identical keys', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyDown('a'); // OS auto-repeat (skipped)
        kb.keyDown('a'); // OS auto-repeat (skipped)
        kb.keyUp('a');
        // Only one 'a' queued.
        kb.tickKeyQueue(); // dequeue 'a'
        expect(kb.debugPressedKeys, contains('a'));
        kb.tickKeyQueue(); // hold
        kb.tickKeyQueue(); // hold
        kb.tickKeyQueue(); // cleanup 'a'
        // No more entries.
        kb.tickKeyQueue();
        expect(kb.debugPressedKeys, isNot(contains('a')));
      });

      test('should allow same key after different key', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyDown('b');
        kb.keyDown('a'); // not consecutive
        kb.keyUp('a');
        kb.keyUp('b');
        // Queue: ['a', 'b', 'a'].
        kb.tickKeyQueue(); // dequeue 'a'
        expect(kb.debugPressedKeys, contains('a'));
        kb.tickKeyQueue(); // hold
        kb.tickKeyQueue(); // cleanup 'a', dequeue 'b'
        expect(kb.debugPressedKeys, contains('b'));
        kb.tickKeyQueue(); // hold
        kb.tickKeyQueue(); // cleanup 'b', dequeue second 'a'
        expect(kb.debugPressedKeys, contains('a'));
      });

      test('rapid type sequence should preserve order', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyUp('a');
        kb.keyDown('b');
        kb.keyUp('b');
        kb.keyDown('c');
        kb.keyUp('c');

        // 'a': ticks 1-2
        kb.tickKeyQueue(); // dequeue 'a'
        expect(kb.scanIN(0x40, 0x00) & 0x08, equals(0)); // 'a' at PA6/IN3
        kb.tickKeyQueue(); // hold
        // 'b': ticks 3-4
        kb.tickKeyQueue(); // cleanup 'a', dequeue 'b'
        expect(kb.scanIN(0x80, 0x00) & 0x40, equals(0)); // 'b' at PA7/IN6
        kb.tickKeyQueue(); // hold
        // 'c': ticks 5-6
        kb.tickKeyQueue(); // cleanup 'b', dequeue 'c'
        expect(kb.scanIN(0x10, 0x00) & 0x40, equals(0)); // 'c' at PA4/IN6
      });

      test('keyUp should not remove key from queue', () {
        final Keyboard kb = Keyboard();
        kb.keyDown('a');
        kb.keyDown('b');
        kb.keyUp('a');
        kb.keyUp('b');
        // Both still in queue.
        kb.tickKeyQueue(); // dequeue 'a'
        expect(kb.debugPressedKeys, contains('a'));
        kb.tickKeyQueue(); // hold
        kb.tickKeyQueue(); // hold
        kb.tickKeyQueue(); // cleanup 'a', dequeue 'b'
        expect(kb.debugPressedKeys, contains('b'));
      });

      test('should cap queue size', () {
        final Keyboard kb = Keyboard();
        for (int i = 0; i < 30; i++) {
          kb.keyDown('k$i');
        }
        // Queue should be capped at 16. Drain and count injections.
        int injections = 0;
        for (int i = 0; i < 200; i++) {
          final bool wasFull = kb.debugPressedKeys.isNotEmpty;
          kb.tickKeyQueue();
          final bool isFull = kb.debugPressedKeys.isNotEmpty;
          if (!wasFull && isFull) injections++;
        }
        expect(injections, lessThanOrEqualTo(16));
      });
    });
  });
}
