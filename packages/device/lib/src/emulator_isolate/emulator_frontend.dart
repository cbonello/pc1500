import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/dap_server.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:device/src/messages.dart';
import 'package:meta/meta.dart';

EmulatorFrontEnd? _frontEnd;

void runEmulator(SendPort outPort) {
  _frontEnd ??= EmulatorFrontEnd(outPort: outPort);
}

void killEmulator() {
  _frontEnd?.dispose();
  _frontEnd = null;
}

class EmulatorFrontEnd {
  EmulatorFrontEnd({required this.outPort}) {
    final ReceivePort inStream = ReceivePort();
    outPort.send(inStream.sendPort);

    inStreamSub = inStream.listen((dynamic data) {
      _messageHandler(data);
    });

    isDebugClientConnected = false;
  }

  final SendPort outPort;
  late StreamSubscription<dynamic> inStreamSub;
  late HardwareDeviceType type;
  late int debugPort;
  Emulator? emulator;

  ServerSocket? serverSocket;
  StreamSubscription<Socket>? serverSocketSub;
  DapServer? _dapServer;
  bool isDebugClientConnected = false;

  void dispose() {
    emulator?.stop();
    emulator?.dispose();
    emulator = null;
    inStreamSub.cancel();
    _stopDebuggerServer();
  }

  /// Exposed for unit tests — processes an emulator message.
  @visibleForTesting
  void handleMessageForTest(dynamic data) => _messageHandler(data);

  void _messageHandler(dynamic data) {
    try {
      switch (data) {
        case StartEmulatorMsg(:final type, :final debugPort):
          assert(emulator == null);
          this.type = type;
          emulator = Emulator(type, outPort);
          this.debugPort = debugPort;
          _startDebugServer(debugPort);
        // Don't start the CPU yet — the real PC-1500 stays powered off
        // until the ON key is pressed. run() is called on first ON key.
        case UpdateDeviceTypeMsg(:final type):
          if (type != this.type) {
            this.type = type;
            // Recreate the emulator with the new hardware type.
            // This changes RAM size, memory layout, etc.
            emulator?.stop();
            emulator = Emulator(type, outPort);
          }
        case KeyDownMsg(:final keyName):
          // Keys handled outside the keyboard matrix.
          if (keyName == 'on') {
            emulator?.powerOn();
            break;
          }
          if (keyName == 'off') {
            emulator?.powerOff();
            break;
          }
          if (keyName == 'mode') {
            emulator?.cycleMode();
            break;
          }
          if (keyName == 'shift') {
            emulator?.toggleShift();
            break;
          }
          if (keyName == 'def') {
            emulator?.toggleDef();
            break;
          }
          if (keyName == 'up-down') {
            emulator?.cycleReserveBank();
            break;
          }
          // Arrow keys must be single-pulse (enqueue, not keyDown) to
          // prevent re-entry into the ROM handler which corrupts state.
          // ↑ navigation: patch $78A6 to the line before the target,
          // then send ↓ instead of ↑. The ROM's ↓ handler uses $78A6
          // and updates ALL state variables (including PROGDISP state),
          // so the display shows the correct previous line.
          if (keyName == 'up') {
            emulator?.prepareNavigateUp();
            emulator?.keyboard.keyDown('down');
            emulator?.updateKeyboardInput();
            break;
          }
          emulator?.keyboard.keyDown(keyName);
          emulator?.updateKeyboardInput();
        case KeyUpMsg(:final keyName):
          // Release 'down' when 'up' is released (since we substituted).
          final releaseKey = keyName == 'up' ? 'down' : keyName;
          emulator?.keyboard.keyUp(releaseKey);
        // No updateKeyboardInput() — the release is deferred until the
        // next frame via the keyboard queue to avoid lost keystrokes.
        case StepMsg():
          emulator?.step();
        default:
          break;
      }
    } catch (e, st) {
      // Log but don't crash — the emulator isolate must stay alive.
      assert(() {
        // ignore: avoid_print
        print('Emulator message error: $e\n$st');
        return true;
      }());
    }
  }

  Future<void> _startDebugServer(int debugPort) async {
    if (serverSocket != null) {
      _stopDebuggerServer();
    }

    try {
      serverSocket = await ServerSocket.bind('localhost', debugPort);
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('Debug server bind failed on port $debugPort: $e');
        return true;
      }());
      return;
    }

    serverSocketSub = serverSocket!.listen(
      (Socket client) {
        if (isDebugClientConnected) {
          client.close(); // Only one debug client at a time.
          return;
        }
        _updateDebuggerStatus(true);
        // Create a DAP server for this client connection.
        _dapServer = DapServer(emulator!, client);
        emulator!.dapServer = _dapServer;
        _dapServer!.start();
        client.done
            .then((_) {
              _dapServer = null;
              if (emulator != null) emulator!.dapServer = null;
              _updateDebuggerStatus(false);
            })
            .catchError((_) {
              _dapServer = null;
              if (emulator != null) emulator!.dapServer = null;
              _updateDebuggerStatus(false);
            });
      },
      onError: (Object _) {},
      onDone: () => _updateDebuggerStatus(false),
    );
  }

  void _updateDebuggerStatus(bool debugClientStatus) {
    isDebugClientConnected = debugClientStatus;
    outPort.send(DebugClientStatusMsg(isDebugClientConnected));
  }

  void _stopDebuggerServer() {
    serverSocketSub?.cancel();
    serverSocketSub = null;
    serverSocket?.close();
    serverSocket = null;
    isDebugClientConnected = false;
  }
}
