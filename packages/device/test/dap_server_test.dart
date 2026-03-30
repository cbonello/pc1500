import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/dap_server.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:test/test.dart';

/// Encodes a DAP request as a Content-Length framed message.
List<int> _dapRequest(
  String command, {
  int seq = 1,
  Map<String, Object?>? args,
}) {
  final Map<String, Object?> msg = {
    'type': 'request',
    'seq': seq,
    'command': command,
    if (args != null) 'arguments': args,
  };
  final String json = jsonEncode(msg);
  final List<int> body = utf8.encode(json);
  final String header = 'Content-Length: ${body.length}\r\n\r\n';
  return [...utf8.encode(header), ...body];
}

/// Reads one DAP message from a socket stream.
Future<Map<String, Object?>> _readDapMessage(Socket socket) {
  final completer = Completer<Map<String, Object?>>();
  final buffer = BytesBuilder(copy: false);

  late StreamSubscription<Uint8List> sub;
  sub = socket.listen((data) {
    buffer.add(data);
    final bytes = buffer.toBytes();
    final str = utf8.decode(bytes, allowMalformed: true);
    final headerEnd = str.indexOf('\r\n\r\n');
    if (headerEnd < 0) return;

    final match = RegExp(r'Content-Length:\s*(\d+)').firstMatch(str);
    if (match == null) return;
    final contentLength = int.parse(match.group(1)!);
    final bodyStart = headerEnd + 4;
    if (bytes.length < bodyStart + contentLength) return;

    final jsonStr =
        utf8.decode(bytes.sublist(bodyStart, bodyStart + contentLength));
    sub.cancel();
    completer.complete(jsonDecode(jsonStr) as Map<String, Object?>);
  });

  return completer.future.timeout(const Duration(seconds: 5));
}

/// Reads ALL DAP messages available within a timeout.
Future<List<Map<String, Object?>>> _readAllDapMessages(
  Socket socket, {
  Duration timeout = const Duration(milliseconds: 500),
}) async {
  final messages = <Map<String, Object?>>[];
  final buffer = BytesBuilder(copy: false);

  final sub = socket.listen((data) {
    buffer.add(data);
    while (true) {
      final bytes = buffer.toBytes();
      final str = utf8.decode(bytes, allowMalformed: true);
      final headerEnd = str.indexOf('\r\n\r\n');
      if (headerEnd < 0) break;

      final match = RegExp(r'Content-Length:\s*(\d+)').firstMatch(str);
      if (match == null) break;
      final contentLength = int.parse(match.group(1)!);
      final bodyStart = headerEnd + 4;
      if (bytes.length < bodyStart + contentLength) break;

      final jsonStr =
          utf8.decode(bytes.sublist(bodyStart, bodyStart + contentLength));
      messages.add(jsonDecode(jsonStr) as Map<String, Object?>);

      buffer.clear();
      final remaining = bytes.sublist(bodyStart + contentLength);
      if (remaining.isNotEmpty) buffer.add(remaining);
    }
  });

  await Future<void>.delayed(timeout);
  await sub.cancel();
  return messages;
}

/// Creates an [Emulator] for testing (not started).
Emulator _createEmulator() {
  final outPort = ReceivePort();
  final emulator = Emulator(HardwareDeviceType.pc1500A, outPort.sendPort);
  emulator.simulateColdStartDone();
  emulator.simulateWarmStartDone();
  return emulator;
}

void main() {
  group('DapServer', () {
    late ServerSocket server;
    late Emulator emulator;

    setUp(() async {
      emulator = _createEmulator();
      server = await ServerSocket.bind('localhost', 0);
    });

    tearDown(() async {
      emulator.stop();
      emulator.dispose();
      await server.close();
    });

    /// Connects a client, wires up a DapServer, returns the client socket.
    Future<Socket> connectClient() async {
      final clientFuture = Socket.connect('localhost', server.port);
      final serverSocket = await server.first;
      final client = await clientFuture;

      final dap = DapServer(emulator, serverSocket);
      emulator.dapServer = dap;
      dap.start();

      addTearDown(() {
        dap.dispose();
        client.close();
      });

      return client;
    }

    test('initialize returns capabilities and initialized event', () async {
      final client = await connectClient();
      client.add(_dapRequest('initialize'));

      final messages = await _readAllDapMessages(client);

      final response = messages.firstWhere((m) => m['type'] == 'response');
      expect(response['command'], 'initialize');
      expect(response['success'], isTrue);
      final body = response['body']! as Map<String, Object?>;
      expect(body['supportsDisassembleRequest'], isTrue);
      expect(body['supportsReadMemoryRequest'], isTrue);
      expect(body['supportsInstructionBreakpoints'], isTrue);

      final event = messages.firstWhere((m) => m['type'] == 'event');
      expect(event['event'], 'initialized');
    });

    test('threads returns single LH5801 thread', () async {
      final client = await connectClient();
      client.add(_dapRequest('threads'));

      final msg = await _readDapMessage(client);
      expect(msg['success'], isTrue);
      final threads = (msg['body']! as Map)['threads']! as List;
      expect(threads, hasLength(1));
      expect((threads[0] as Map)['name'], 'LH5801');
    });

    test('scopes returns Registers, Flags, and System', () async {
      final client = await connectClient();
      client.add(_dapRequest('scopes', args: {'frameId': 1}));

      final msg = await _readDapMessage(client);
      expect(msg['success'], isTrue);
      final scopes = (msg['body']! as Map)['scopes']! as List;
      expect(scopes, hasLength(3));
      final names = scopes.map((s) => (s as Map)['name']).toList();
      expect(names, ['Registers', 'Flags', 'System']);
    });

    test('variables returns register values', () async {
      final client = await connectClient();
      client.add(_dapRequest('variables', args: {'variablesReference': 1}));

      final msg = await _readDapMessage(client);
      expect(msg['success'], isTrue);
      final vars = (msg['body']! as Map)['variables']! as List;
      final names = vars.map((v) => (v as Map)['name']).toSet();
      expect(names, containsAll(['A', 'X', 'Y', 'U', 'S', 'P']));
    });

    test('variables returns flag values', () async {
      final client = await connectClient();
      client.add(_dapRequest('variables', args: {'variablesReference': 2}));

      final msg = await _readDapMessage(client);
      final vars = (msg['body']! as Map)['variables']! as List;
      final names = vars.map((v) => (v as Map)['name']).toSet();
      expect(
        names,
        containsAll([
          'C (Carry)',
          'Z (Zero)',
          'V (Overflow)',
          'H (Half-carry)',
          'IE (Interrupt)',
        ]),
      );
    });

    test('setInstructionBreakpoints updates emulator breakpoints', () async {
      final client = await connectClient();
      client.add(
        _dapRequest('setInstructionBreakpoints', args: {
          'breakpoints': [
            {'instructionReference': '0xE243'},
            {'instructionReference': '0xC000', 'offset': 5},
          ],
        }),
      );

      final msg = await _readDapMessage(client);
      expect(msg['success'], isTrue);
      final bps = (msg['body']! as Map)['breakpoints']! as List;
      expect(bps, hasLength(2));
      expect(emulator.breakpoints, contains(0xE243));
      expect(emulator.breakpoints, contains(0xC005));
    });

    test('readMemory returns base64-encoded bytes', () async {
      final client = await connectClient();
      emulator.memWriteForTest(0x4000, 0xAB);
      emulator.memWriteForTest(0x4001, 0xCD);

      client.add(_dapRequest('readMemory', args: {
        'memoryReference': '0x4000',
        'count': 2,
      }));

      final msg = await _readDapMessage(client);
      expect(msg['success'], isTrue);
      final data =
          base64Decode((msg['body']! as Map)['data']! as String);
      expect(data, [0xAB, 0xCD]);
    });

    test('writeMemory modifies emulator RAM', () async {
      final client = await connectClient();
      client.add(_dapRequest('writeMemory', args: {
        'memoryReference': '0x4000',
        'data': base64Encode([0x12, 0x34]),
      }));

      final msg = await _readDapMessage(client);
      expect(msg['success'], isTrue);
      expect(emulator.memReadForTest(0x4000), 0x12);
      expect(emulator.memReadForTest(0x4001), 0x34);
    });

    test('pause sets emulator paused flag', () async {
      final client = await connectClient();
      client.add(_dapRequest('pause', args: {'threadId': 1}));

      final messages = await _readAllDapMessages(client);
      final response = messages.firstWhere((m) => m['type'] == 'response');
      expect(response['success'], isTrue);
      expect(emulator.isPaused, isTrue);

      final stopped = messages.firstWhere(
        (m) => m['type'] == 'event' && m['event'] == 'stopped',
      );
      expect((stopped['body']! as Map)['reason'], 'pause');
    });

    test('step executes one instruction', () async {
      final client = await connectClient();
      final pcBefore = emulator.pc;
      client.add(_dapRequest('next', args: {'threadId': 1}));

      final messages = await _readAllDapMessages(client);
      final response = messages.firstWhere((m) => m['type'] == 'response');
      expect(response['success'], isTrue);
      expect(emulator.pc, isNot(equals(pcBefore)));
    });

    test('unsupported command returns error response', () async {
      final client = await connectClient();
      client.add(_dapRequest('bogusCommand'));

      final msg = await _readDapMessage(client);
      expect(msg['success'], isFalse);
      expect(msg['message']! as String, contains('Unsupported'));
    });

    test('multiple messages in one TCP chunk are parsed', () async {
      final client = await connectClient();
      final bytes1 = _dapRequest('threads');
      final bytes2 = _dapRequest('threads', seq: 2);
      client.add([...bytes1, ...bytes2]);

      final messages = await _readAllDapMessages(client);
      final responses = messages
          .where(
            (m) => m['type'] == 'response' && m['command'] == 'threads',
          )
          .toList();
      expect(responses, hasLength(2));
    });
  });
}
