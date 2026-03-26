import 'package:device/src/device.dart';
import 'package:lcd/lcd.dart';

// ── UI → Emulator messages ──────────────────────────────────────────────────

/// Sent once after the isolate starts to configure the emulator.
class StartEmulatorMsg {
  const StartEmulatorMsg({required this.type, required this.debugPort});

  final HardwareDeviceType type;
  final int debugPort;
}

/// Sent to change the emulated hardware model.
class UpdateDeviceTypeMsg {
  const UpdateDeviceTypeMsg({required this.type});

  final HardwareDeviceType type;
}

/// Sent when a key is pressed.
class KeyDownMsg {
  const KeyDownMsg(this.keyName);

  final String keyName;
}

/// Sent when a key is released.
class KeyUpMsg {
  const KeyUpMsg(this.keyName);

  final String keyName;
}

/// Sent to execute a single CPU step (debugger).
class StepMsg {
  const StepMsg();
}

// ── Emulator → UI messages ──────────────────────────────────────────────────

/// Sent when the LCD display state changes.
class LcdEventMsg {
  const LcdEventMsg(this.event);

  final LcdEvent event;
}

/// Sent when the debug client connection status changes.
class DebugClientStatusMsg {
  const DebugClientStatusMsg(this.connected);

  final bool connected;
}

/// Sent when the ROM's BEEP subroutine is called.
class BuzzerEventMsg {
  const BuzzerEventMsg({required this.frequencyHz, required this.durationMs});

  final double frequencyHz;
  final double durationMs;
}
