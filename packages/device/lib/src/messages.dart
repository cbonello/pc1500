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

/// Sent to request a state snapshot from the emulator.
class SaveStateMsg {
  const SaveStateMsg();
}

/// Sent to perform a cold reset (clears RAM, shows "NEW 0 ? CHECK").
class ColdResetMsg {
  const ColdResetMsg();
}

/// Sent to restore emulator state from a previously saved snapshot.
class RestoreStateMsg {
  const RestoreStateMsg(this.state);

  final Map<String, dynamic> state;
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

/// Sent when the emulator power state changes.
class PowerStateMsg {
  const PowerStateMsg(this.isOn);

  final bool isOn;
}

/// Sent in response to [SaveStateMsg] with the emulator's state snapshot.
class SaveStateResultMsg {
  const SaveStateResultMsg(this.state);

  final Map<String, dynamic> state;
}

/// Sent in response to [RestoreStateMsg] to acknowledge completion.
class RestoreStateResultMsg {
  const RestoreStateResultMsg({required this.success, this.error});

  final bool success;
  final String? error;
}

/// Sent when the ROM's BEEP subroutine is called.
class BuzzerEventMsg {
  const BuzzerEventMsg({required this.frequencyHz, required this.durationMs});

  final double frequencyHz;
  final double durationMs;
}
