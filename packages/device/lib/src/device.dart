import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device/src/emulator_isolate/emulator_frontend.dart';
import 'package:device/src/messages/messages.dart';
import 'package:device/src/messages/messages_base.dart';
import 'package:lcd/lcd.dart';

/// Hardware model variants.
enum HardwareDeviceType { pc1500, pc1500A }

/// Main-isolate handle to the PC-1500 emulator.
///
/// Manages the emulator isolate lifecycle, forwards key events, and
/// exposes an LCD event stream for the UI to render.
class Device {
  Device({required HardwareDeviceType type, required int debugPort})
    : _type = type,
      _debugPort = debugPort,
      _outEventCtrl = StreamController<LcdEvent>.broadcast(),
      isDebugClientConnected = false;

  bool isDebugClientConnected;

  HardwareDeviceType _type;
  final int _debugPort;
  final StreamController<LcdEvent> _outEventCtrl;
  Isolate? _isolate;
  SendPort? _toEmulatorPort;
  StreamSubscription<dynamic>? _fromEmulatorSub;

  /// The current hardware model.
  HardwareDeviceType get hardwareDeviceType => _type;

  /// Changes the hardware model, restarting the emulator if needed.
  ///
  /// Returns a [Future] that completes when the new emulator is ready.
  Future<void> updateHardwareDeviceType(HardwareDeviceType newType) async {
    if (newType != _type) {
      _type = newType;
      kill();
      await run();
    }
  }

  /// Stream of LCD display events from the emulator.
  Stream<LcdEvent> get lcdEvents => _outEventCtrl.stream;

  bool get _isEmulatorRunning => _isolate != null;

  /// Spawns the emulator isolate and sends the start configuration.
  ///
  /// Does nothing if the emulator is already running.
  Future<void> run() async {
    if (!_isEmulatorRunning) {
      _toEmulatorPort = await _initIsolate();
      _send(
        StartEmulatorMessage(type: _type, debugPort: _debugPort),
        _startSerializer,
      );
    }
  }

  /// Terminates the emulator isolate and cleans up resources.
  void kill() {
    if (_isEmulatorRunning) {
      _fromEmulatorSub?.cancel();
      _fromEmulatorSub = null;
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
      _toEmulatorPort = null;
    }
  }

  /// Releases all resources. Call when the [Device] is no longer needed.
  void dispose() {
    kill();
    _outEventCtrl.close();
  }

  Future<SendPort> _initIsolate() async {
    final Completer<SendPort> completer = Completer<SendPort>();
    final ReceivePort fromEmulatorPort = ReceivePort();

    _fromEmulatorSub = fromEmulatorPort.listen((dynamic data) {
      if (data is SendPort) {
        completer.complete(data);
      } else {
        assert(data is Uint8List);
        _messageHandler(data as Uint8List);
      }
    });

    _isolate = await Isolate.spawn(
      runEmulator,
      fromEmulatorPort.sendPort,
      debugName: 'Emulator',
    );

    return completer.future;
  }

  void _send<T>(T message, EmulatorMessageSerializer<T> serializer) {
    if (_isEmulatorRunning) {
      _toEmulatorPort!.send(serializer.serialize(message));
    }
  }

  /// Sends a key-down event to the emulator.
  void sendKeyDown(String keyName) {
    _send(
      KeyEventMessage(keyName: keyName, isDown: true),
      _keySerializer,
    );
  }

  /// Sends a key-up event to the emulator.
  void sendKeyUp(String keyName) {
    _send(
      KeyEventMessage(keyName: keyName, isDown: false),
      _keySerializer,
    );
  }

  void _messageHandler(Uint8List data) {
    if (data.isEmpty) return;

    final int id = data[0];
    if (id < 0 || id >= EmulatorMessageId.values.length) return;

    final EmulatorMessageId messageId = EmulatorMessageId.values[id];

    switch (messageId) {
      case EmulatorMessageId.isDebugClientConnected:
        final IsDebugClientConnectedMessage message =
            _debugSerializer.deserialize(data);
        isDebugClientConnected = message.status;
      case EmulatorMessageId.lcdEvent:
        final LcdEvent event = _lcdSerializer.deserialize(data);
        _outEventCtrl.add(event);
      default:
        assert(() {
          // ignore: avoid_print
          print('Device: unexpected message $messageId');
          return true;
        }());
    }
  }
}

// Reusable stateless serializer instances.
final _startSerializer = StartEmulatorMessageSerializer();
final _keySerializer = KeyEventMessageSerializer();
final _lcdSerializer = LcdEventSerializer();
final _debugSerializer = IsDebugClientConnectedMessageSerializer();
