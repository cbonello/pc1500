import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Exception thrown when a DAP request fails.
class DapRequestException implements Exception {
  DapRequestException(this.command, this.message, [this.body]);

  final String command;
  final String message;
  final Map<String, Object?>? body;

  @override
  String toString() => 'DapRequestException($command): $message';
}

/// Lightweight DAP client that speaks the Debug Adapter Protocol over TCP.
///
/// Sends DAP requests and returns decoded JSON response bodies.
class DapClient {
  DapClient._(this._socket);

  final Socket _socket;
  int _seq = 1;
  final Map<int, Completer<Map<String, Object?>>> _pending = {};
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  int? _expectedContentLength;

  /// The separator between DAP header and body.
  static const _headerTerminator = [0x0D, 0x0A, 0x0D, 0x0A]; // \r\n\r\n
  static final _contentLengthPattern = RegExp(
    r'Content-Length:\s*(\d+)',
    caseSensitive: false,
  );

  /// Maximum allowed Content-Length (10 MB). Prevents a malicious server from
  /// causing unbounded memory allocation.
  static const _maxContentLength = 10 * 1024 * 1024;

  /// Maximum receive buffer size (12 MB — enough for max content + headers).
  static const _maxBufferSize = 12 * 1024 * 1024;

  /// Maximum header block size (64 KB). If no \r\n\r\n is found within this
  /// many bytes, the stream is considered malformed.
  static const _maxHeaderSize = 64 * 1024;

  /// Connect to a DAP server at [host]:[port].
  static Future<DapClient> connect(String host, int port) async {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 5),
    );
    final client = DapClient._(socket);
    socket.listen(client._onData, onError: client._onError, onDone: client._onDone);
    return client;
  }

  bool get isConnected => !_closed;
  bool _closed = false;

  /// Send a DAP request and wait for the response body.
  Future<Map<String, Object?>> request(
    String command, [
    Map<String, Object?>? arguments,
  ]) {
    if (_closed) throw StateError('DAP client is closed');
    final seq = _seq++;
    final completer = Completer<Map<String, Object?>>();
    _pending[seq] = completer;

    final sent = _send({
      'type': 'request',
      'seq': seq,
      'command': command,
      if (arguments != null) 'arguments': arguments,
    });
    if (!sent) {
      _pending.remove(seq);
      throw StateError('DAP: failed to send "$command" — socket broken');
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _pending.remove(seq);
        throw TimeoutException('DAP request "$command" timed out');
      },
    );
  }

  /// Send the initialize + attach handshake.
  Future<void> initialize() async {
    await request('initialize', {
      'clientID': 'pc1500-mcp',
      'adapterID': 'pc1500',
      'supportsInstructionBreakpoints': true,
      'supportsReadMemoryRequest': true,
      'supportsWriteMemoryRequest': true,
      'supportsDisassembleRequest': true,
    });
    await request('attach');
    await request('configurationDone');
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    // Try to send a disconnect and wait briefly for acknowledgement.
    final seq = _seq++;
    final completer = Completer<Map<String, Object?>>();
    _pending[seq] = completer;
    if (_send({'type': 'request', 'seq': seq, 'command': 'disconnect'})) {
      try {
        await completer.future.timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
    _failPending(StateError('DAP client closed'));
    await _closeSocket();
  }

  // ── TCP framing (mirrors DapServer._onData) ─────────────────────────────

  /// Send a DAP message. Returns `false` if the write failed.
  bool _send(Map<String, Object?> message) {
    try {
      final json = jsonEncode(message);
      final body = utf8.encode(json);
      final header = utf8.encode('Content-Length: ${body.length}\r\n\r\n');
      _socket.add(header + body);
      return true;
    } on Object {
      return false;
    }
  }

  void _onData(Uint8List data) {
    _buffer.add(data);
    if (_buffer.length > _maxBufferSize) {
      _abort('receive buffer exceeded $_maxBufferSize bytes');
      return;
    }
    _processBuffer();
  }

  void _onError(Object error) {
    _abort('socket error: $error');
  }

  void _onDone() {
    _closed = true;
    _failPending(StateError('DAP connection lost'));
    _closeSocket();
  }

  /// Gracefully close the socket, ignoring and logging any errors.
  Future<void> _closeSocket() async {
    try {
      await _socket.close();
    } on Object catch (e) {
      stderr.writeln('DAP: error closing socket: $e');
    }
  }

  /// Terminate the connection due to a protocol violation or resource limit.
  void _abort(String reason) {
    stderr.writeln('DAP: aborting connection: $reason');
    _closed = true;
    _buffer.clear();
    _expectedContentLength = null;
    _failPending(StateError('DAP connection aborted: $reason'));
    try {
      _socket.destroy();
    } catch (_) {}
  }

  void _failPending(Object error) {
    final pending = Map.of(_pending);
    _pending.clear();
    for (final c in pending.values) {
      c.completeError(error);
    }
  }

  void _processBuffer() {
    // Take bytes once per call; only re-take if we consumed part of it.
    var bytes = _buffer.toBytes();
    _buffer.clear();

    while (!_closed) {
      if (_expectedContentLength == null) {
        final headerEnd = _indexOfHeaderTerminator(bytes);
        if (headerEnd < 0) {
          // No complete header yet — put remaining bytes back.
          if (bytes.length > _maxHeaderSize) {
            _abort('header block exceeded $_maxHeaderSize bytes');
            return;
          }
          _buffer.add(bytes);
          return;
        }

        // Headers are always ASCII — safe to decode only the header portion.
        final headers = ascii.decode(bytes.sublist(0, headerEnd));
        final match = _contentLengthPattern.firstMatch(headers);
        if (match == null) {
          _abort('missing Content-Length header');
          return;
        }
        _expectedContentLength = int.parse(match.group(1)!);

        if (_expectedContentLength! > _maxContentLength) {
          _abort(
            'Content-Length $_expectedContentLength exceeds '
            'maximum $_maxContentLength',
          );
          return;
        }

        final bodyStart = headerEnd + 4;
        bytes = bodyStart < bytes.length
            ? bytes.sublist(bodyStart)
            : Uint8List(0);
        continue;
      }

      if (bytes.length < _expectedContentLength!) {
        // Incomplete body — put remaining bytes back.
        _buffer.add(bytes);
        return;
      }

      final contentLength = _expectedContentLength!;
      final jsonStr = utf8.decode(bytes.sublist(0, contentLength));
      bytes = contentLength < bytes.length
          ? bytes.sublist(contentLength)
          : Uint8List(0);
      _expectedContentLength = null;

      try {
        final msg = jsonDecode(jsonStr) as Map<String, Object?>;
        _handleMessage(msg);
      } on FormatException catch (e) {
        _abort('failed to decode message: $e');
        return;
      }
    }
  }

  /// Scan [bytes] for the \r\n\r\n sequence, returning the index of the first
  /// byte of the match, or -1 if not found.
  static int _indexOfHeaderTerminator(Uint8List bytes) {
    for (var i = 0; i <= bytes.length - 4; i++) {
      if (bytes[i] == _headerTerminator[0] &&
          bytes[i + 1] == _headerTerminator[1] &&
          bytes[i + 2] == _headerTerminator[2] &&
          bytes[i + 3] == _headerTerminator[3]) {
        return i;
      }
    }
    return -1;
  }

  void _handleMessage(Map<String, Object?> msg) {
    final type = msg['type'] as String? ?? '';
    if (type == 'response') {
      final rawSeq = msg['request_seq'];
      if (rawSeq is! num) {
        stderr.writeln(
          'DAP: response has non-numeric request_seq: '
          '${rawSeq.runtimeType}',
        );
        return;
      }
      final requestSeq = rawSeq.toInt();
      final command = msg['command'] as String? ?? '';
      final completer = _pending.remove(requestSeq);
      if (completer != null) {
        final success = msg['success'] as bool? ?? false;
        if (success) {
          completer.complete((msg['body'] as Map<String, Object?>?) ?? {});
        } else {
          final body = msg['body'] as Map<String, Object?>?;
          completer.completeError(
            DapRequestException(
              command,
              msg['message'] as String? ?? 'DAP request failed',
              body,
            ),
          );
        }
      }
    }
    // Ignore events for now.
  }
}
