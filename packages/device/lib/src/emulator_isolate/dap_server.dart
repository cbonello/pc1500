import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device/src/emulator_isolate/dasm.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:lh5801/lh5801.dart';

/// Callback invoked when the DAP server needs the emulator to stop or resume.
typedef DapPauseCallback = void Function();

/// DAP (Debug Adapter Protocol) server for the PC-1500 emulator.
///
/// Speaks the DAP protocol over a TCP socket, translating VS Code debug
/// requests into emulator operations (step, continue, read registers, etc.).
///
/// The server runs inside the emulator isolate for zero-overhead CPU access.
class DapServer {
  DapServer(this._emulator, this._socket);

  final Emulator _emulator;
  final Socket _socket;
  int _seq = 1;

  /// Buffer for incomplete TCP data.
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  int? _expectedContentLength;

  /// Start listening for DAP messages.
  void start() {
    _socket.listen(_onData, onError: (_) => dispose(), onDone: dispose);
  }

  /// Clean up and resume the emulator if paused.
  void dispose() {
    if (_emulator.isPaused) {
      _emulator.resumeExecution();
    }
    try {
      _socket.close();
    } catch (_) {}
  }

  // ── TCP framing ──────────────────────────────────────────────────────────

  /// Process incoming bytes using DAP's Content-Length framing.
  void _onData(Uint8List data) {
    _buffer.add(data);
    _processBuffer();
  }

  void _processBuffer() {
    while (true) {
      final Uint8List bytes = _buffer.toBytes();
      if (_expectedContentLength == null) {
        // Look for the header terminator \r\n\r\n.
        final String str = utf8.decode(bytes, allowMalformed: true);
        final int headerEnd = str.indexOf('\r\n\r\n');
        if (headerEnd < 0) return; // Need more data.

        // Parse Content-Length from headers.
        final String headers = str.substring(0, headerEnd);
        final RegExp re = RegExp(
          r'Content-Length:\s*(\d+)',
          caseSensitive: false,
        );
        final Match? match = re.firstMatch(headers);
        if (match == null) {
          // Malformed header — discard and close.
          dispose();
          return;
        }
        _expectedContentLength = int.parse(match.group(1)!);

        // Remove consumed header bytes (including the \r\n\r\n separator).
        final int bodyStart = headerEnd + 4;
        _buffer.clear();
        if (bodyStart < bytes.length) {
          _buffer.add(bytes.sublist(bodyStart));
        }
        continue; // Check if we have enough body bytes now.
      }

      // We know the expected content length — check if we have enough bytes.
      if (bytes.length < _expectedContentLength!) return; // Need more data.

      final int contentLength = _expectedContentLength!;
      final String jsonStr = utf8.decode(bytes.sublist(0, contentLength));
      _buffer.clear();
      if (contentLength < bytes.length) {
        _buffer.add(bytes.sublist(contentLength));
      }
      _expectedContentLength = null;

      // Parse and handle the JSON message.
      try {
        final Map<String, Object?> msg =
            jsonDecode(jsonStr) as Map<String, Object?>;
        _handleMessage(msg);
      } catch (e) {
        // Ignore malformed JSON.
      }
    }
  }

  // ── Sending ──────────────────────────────────────────────────────────────

  void _send(Map<String, Object?> message) {
    message['seq'] = _seq++;
    final String json = jsonEncode(message);
    final List<int> body = utf8.encode(json);
    final String header = 'Content-Length: ${body.length}\r\n\r\n';
    try {
      _socket.add(utf8.encode(header));
      _socket.add(body);
    } catch (_) {}
  }

  void _sendResponse(
    int requestSeq,
    String command, {
    Object? body,
    bool success = true,
    String? message,
  }) {
    _send({
      'type': 'response',
      'request_seq': requestSeq,
      'success': success,
      'command': command,
      if (body != null) 'body': body,
      if (message != null) 'message': message,
    });
  }

  void _sendEvent(String event, {Object? body}) {
    _send({'type': 'event', 'event': event, if (body != null) 'body': body});
  }

  /// Notify VS Code that the emulator has stopped (breakpoint, step, pause).
  void notifyStopped(String reason, {String? description}) {
    _sendEvent(
      'stopped',
      body: {
        'reason': reason,
        'threadId': 1,
        if (description != null) 'description': description,
      },
    );
  }

  // ── Message dispatch ─────────────────────────────────────────────────────

  void _handleMessage(Map<String, Object?> msg) {
    final String type = msg['type'] as String? ?? '';
    if (type != 'request') return;

    final int seq = msg['seq'] as int? ?? 0;
    final String command = msg['command'] as String? ?? '';
    final Map<String, Object?> args =
        (msg['arguments'] as Map<String, Object?>?) ?? {};

    switch (command) {
      case 'initialize':
        _handleInitialize(seq, command);
      case 'attach':
        _handleAttach(seq, command);
      case 'configurationDone':
        _sendResponse(seq, command);
      case 'threads':
        _handleThreads(seq, command);
      case 'stackTrace':
        _handleStackTrace(seq, command);
      case 'scopes':
        _handleScopes(seq, command, args);
      case 'variables':
        _handleVariables(seq, command, args);
      case 'continue':
        _handleContinue(seq, command);
      case 'pause':
        _handlePause(seq, command);
      case 'next':
      case 'stepIn':
        _handleStep(seq, command);
      case 'stepOut':
        _handleStepOut(seq, command);
      case 'evaluate':
        _handleEvaluate(seq, command, args);
      case 'setVariable':
        _handleSetVariable(seq, command, args);
      case 'setInstructionBreakpoints':
        _handleSetInstructionBreakpoints(seq, command, args);
      case 'setBreakpoints':
        _sendResponse(seq, command, body: {'breakpoints': <Object>[]});
      case 'disassemble':
        _handleDisassemble(seq, command, args);
      case 'readMemory':
        _handleReadMemory(seq, command, args);
      case 'writeMemory':
        _handleWriteMemory(seq, command, args);
      case 'sendKeys':
        _handleSendKeys(seq, command, args);
      case 'disconnect':
        _handleDisconnect(seq, command);
      default:
        _sendResponse(
          seq,
          command,
          success: false,
          message: 'Unsupported command: $command',
        );
    }
  }

  // ── Request handlers ─────────────────────────────────────────────────────

  void _handleInitialize(int seq, String command) {
    _sendResponse(
      seq,
      command,
      body: {
        'supportsDisassembleRequest': true,
        'supportsReadMemoryRequest': true,
        'supportsWriteMemoryRequest': true,
        'supportsInstructionBreakpoints': true,
        'supportsSteppingGranularity': true,
        'supportsSingleThreadExecutionRequests': true,
        'supportsSetVariable': true,
        'supportsEvaluateForHovers': true,
        'supportsStepBack': false,
      },
    );
    _sendEvent('initialized');
  }

  void _handleAttach(int seq, String command) {
    _sendResponse(seq, command);
    // Send initial stopped event so VS Code shows the current state.
    notifyStopped('entry', description: 'Attached to PC-1500');
  }

  void _handleThreads(int seq, String command) {
    _sendResponse(
      seq,
      command,
      body: {
        'threads': [
          {'id': 1, 'name': 'LH5801'},
        ],
      },
    );
  }

  void _handleStackTrace(int seq, String command) {
    final int pc = _emulator.pc;
    final DasmDescriptor desc = _emulator.dasm(pc);
    final String name = desc is DasmCode
        ? '${desc.label.isNotEmpty ? "${desc.label}: " : ""}${desc.instruction}'
        : '\$${pc.toRadixString(16).padLeft(4, '0')}';

    _sendResponse(
      seq,
      command,
      body: {
        'stackFrames': [
          {
            'id': 1,
            'name': name,
            'instructionPointerReference': '0x${pc.toRadixString(16)}',
            'line': 0,
            'column': 0,
            'source': {'name': 'LH5801', 'sourceReference': 0},
          },
        ],
        'totalFrames': 1,
      },
    );
  }

  static const int _scopeRegisters = 1;
  static const int _scopeFlags = 2;
  static const int _scopeSystem = 3;

  void _handleScopes(int seq, String command, Map<String, Object?> args) {
    _sendResponse(
      seq,
      command,
      body: {
        'scopes': [
          {
            'name': 'Registers',
            'variablesReference': _scopeRegisters,
            'expensive': false,
          },
          {
            'name': 'Flags',
            'variablesReference': _scopeFlags,
            'expensive': false,
          },
          {
            'name': 'System',
            'variablesReference': _scopeSystem,
            'expensive': false,
          },
        ],
      },
    );
  }

  void _handleVariables(int seq, String command, Map<String, Object?> args) {
    final int ref = args['variablesReference'] as int? ?? 0;
    final LH5801State state = _emulator.cpuState;

    List<Map<String, Object>> vars;
    switch (ref) {
      case _scopeRegisters:
        vars = [
          _regVar('A', state.a.value, 8),
          _regVar('X', state.x.value, 16),
          _regVar('Y', state.y.value, 16),
          _regVar('U', state.u.value, 16),
          _regVar('S', state.s.value, 16),
          _regVar('P', state.p.value, 16),
        ];
      case _scopeFlags:
        vars = [
          _boolVar('C (Carry)', state.t.c),
          _boolVar('Z (Zero)', state.t.z),
          _boolVar('V (Overflow)', state.t.v),
          _boolVar('H (Half-carry)', state.t.h),
          _boolVar('IE (Interrupt)', state.t.ie),
        ];
      case _scopeSystem:
        vars = [
          _boolVar('HLT', state.hlt),
          _boolVar('IR0 (NMI)', state.ir0),
          _boolVar('IR1 (Timer)', state.ir1),
          _boolVar('IR2 (MI)', state.ir2),
          _regVar('Timer', state.tm.value, 16),
          _boolVar('DISP', _emulator.cpuPins.dispFlipflop),
        ];
      default:
        vars = [];
    }

    _sendResponse(seq, command, body: {'variables': vars});
  }

  Map<String, Object> _regVar(String name, int value, int bits) {
    final String hex = value
        .toRadixString(16)
        .padLeft(bits ~/ 4, '0')
        .toUpperCase();
    return {'name': name, 'value': '\$$hex ($value)', 'variablesReference': 0};
  }

  Map<String, Object> _boolVar(String name, bool value) {
    return {'name': name, 'value': value ? '1' : '0', 'variablesReference': 0};
  }

  void _handleContinue(int seq, String command) {
    _sendResponse(seq, command, body: {'allThreadsContinued': true});
    _emulator.resumeExecution();
    _sendEvent('continued', body: {'threadId': 1, 'allThreadsContinued': true});
  }

  void _handlePause(int seq, String command) {
    _emulator.pause();
    _sendResponse(seq, command);
    notifyStopped('pause');
  }

  void _handleStep(int seq, String command) {
    _emulator.stepSingle();
    _sendResponse(seq, command);
    notifyStopped('step');
  }

  /// Steps out of the current subroutine by running until RTN (0x9A) or
  /// RTI (0x8A) is executed. Capped at 100 000 instructions to avoid
  /// hanging if the code never returns.
  void _handleStepOut(int seq, String command) {
    const int maxSteps = 100000;
    for (int i = 0; i < maxSteps; i++) {
      final int pc = _emulator.pc;
      final int opcode = _emulator.memReadForTest(pc);
      _emulator.stepSingle();
      // RTN = 0x9A, RTI = 0x8A — stop AFTER executing the return.
      if (opcode == 0x9A || opcode == 0x8A) break;
      // Also stop on breakpoints.
      if (_emulator.breakpoints.contains(_emulator.pc)) break;
    }
    _sendResponse(seq, command);
    notifyStopped('step');
  }

  /// Evaluates an expression in the debug console.
  ///
  /// Supports:
  /// - Register names: A, X, Y, U, S, P, C, Z, V, H, IE, HLT
  /// - Memory reads: [addr] or [addr:count] (hex, e.g. [7600] or [C000:10])
  /// - Hex literals: $FF, 0xFF
  void _handleEvaluate(int seq, String command, Map<String, Object?> args) {
    final String expr = (args['expression'] as String? ?? '').trim();

    // Register lookup.
    final LH5801State state = _emulator.cpuState;
    final String upper = expr.toUpperCase();
    String? result;

    switch (upper) {
      case 'A':
        result = _fmtReg(state.a.value, 8);
      case 'X':
        result = _fmtReg(state.x.value, 16);
      case 'Y':
        result = _fmtReg(state.y.value, 16);
      case 'U':
        result = _fmtReg(state.u.value, 16);
      case 'S':
        result = _fmtReg(state.s.value, 16);
      case 'P' || 'PC':
        result = _fmtReg(state.p.value, 16);
      case 'C':
        result = state.t.c ? '1' : '0';
      case 'Z':
        result = state.t.z ? '1' : '0';
      case 'V':
        result = state.t.v ? '1' : '0';
      case 'H':
        result = state.t.h ? '1' : '0';
      case 'IE':
        result = state.t.ie ? '1' : '0';
      case 'HLT':
        result = state.hlt ? '1' : '0';
    }
    if (result != null) {
      _sendResponse(seq, command, body: {'result': result, 'variablesReference': 0});
      return;
    }

    // Memory read: [addr] or [addr:count]
    final RegExp memRe = RegExp(r'^\[([0-9a-fA-F]+)(?::(\d+))?\]$');
    final Match? memMatch = memRe.firstMatch(expr);
    if (memMatch != null) {
      final int addr = int.parse(memMatch.group(1)!, radix: 16);
      final int count = int.parse(memMatch.group(2) ?? '1');
      final StringBuffer sb = StringBuffer();
      for (int i = 0; i < count; i++) {
        if (i > 0) sb.write(' ');
        sb.write(
          _emulator
              .memReadForTest((addr + i) & 0x1FFFF)
              .toRadixString(16)
              .padLeft(2, '0')
              .toUpperCase(),
        );
      }
      _sendResponse(seq, command, body: {'result': sb.toString(), 'variablesReference': 0});
      return;
    }

    // Hex literal: $FF or 0xFF
    final RegExp hexRe = RegExp(r'^(?:\$|0x)([0-9a-fA-F]+)$');
    final Match? hexMatch = hexRe.firstMatch(expr);
    if (hexMatch != null) {
      final int val = int.parse(hexMatch.group(1)!, radix: 16);
      _sendResponse(seq, command, body: {'result': '$val', 'variablesReference': 0});
      return;
    }

    _sendResponse(
      seq,
      command,
      success: false,
      message: 'Unknown expression: $expr',
    );
  }

  String _fmtReg(int value, int bits) {
    final String hex =
        value.toRadixString(16).padLeft(bits ~/ 4, '0').toUpperCase();
    return '\$$hex ($value)';
  }

  /// Sets a register or flag variable from the Variables pane.
  void _handleSetVariable(int seq, String command, Map<String, Object?> args) {
    final String name = (args['name'] as String? ?? '').trim();
    final String valueStr = (args['value'] as String? ?? '').trim();

    // Parse value: accept hex ($FF, 0xFF, FFh) or decimal.
    final int? newValue = _parseValue(valueStr);
    if (newValue == null) {
      _sendResponse(
        seq,
        command,
        success: false,
        message: 'Invalid value: $valueStr',
      );
      return;
    }

    final cpu = _emulator.cpuDirect;
    String? displayValue;

    switch (name) {
      case 'A':
        cpu.a.value = newValue;
        displayValue = _fmtReg(cpu.a.value, 8);
      case 'X':
        cpu.x.value = newValue;
        displayValue = _fmtReg(cpu.x.value, 16);
      case 'Y':
        cpu.y.value = newValue;
        displayValue = _fmtReg(cpu.y.value, 16);
      case 'U':
        cpu.u.value = newValue;
        displayValue = _fmtReg(cpu.u.value, 16);
      case 'S':
        cpu.s.value = newValue;
        displayValue = _fmtReg(cpu.s.value, 16);
      case 'P':
        cpu.p.value = newValue;
        displayValue = _fmtReg(cpu.p.value, 16);
      case 'C (Carry)':
        cpu.t.c = newValue != 0;
        displayValue = cpu.t.c ? '1' : '0';
      case 'Z (Zero)':
        cpu.t.z = newValue != 0;
        displayValue = cpu.t.z ? '1' : '0';
      case 'V (Overflow)':
        cpu.t.v = newValue != 0;
        displayValue = cpu.t.v ? '1' : '0';
      case 'H (Half-carry)':
        cpu.t.h = newValue != 0;
        displayValue = cpu.t.h ? '1' : '0';
      case 'IE (Interrupt)':
        cpu.t.ie = newValue != 0;
        displayValue = cpu.t.ie ? '1' : '0';
      default:
        _sendResponse(
          seq,
          command,
          success: false,
          message: 'Cannot set variable: $name',
        );
        return;
    }

    _sendResponse(seq, command, body: {'value': displayValue, 'variablesReference': 0});
  }

  int? _parseValue(String s) {
    // $FF or 0xFF
    final RegExp hexRe = RegExp(r'^(?:\$|0x)([0-9a-fA-F]+)$');
    final Match? hexMatch = hexRe.firstMatch(s);
    if (hexMatch != null) return int.tryParse(hexMatch.group(1)!, radix: 16);
    // FFh
    if (s.endsWith('h') || s.endsWith('H')) {
      return int.tryParse(s.substring(0, s.length - 1), radix: 16);
    }
    // Plain decimal or hex without prefix
    return int.tryParse(s) ?? int.tryParse(s, radix: 16);
  }

  void _handleSetInstructionBreakpoints(
    int seq,
    String command,
    Map<String, Object?> args,
  ) {
    final List<Object?> bps = args['breakpoints'] as List<Object?>? ?? [];
    _emulator.breakpoints.clear();

    final List<Map<String, Object>> verified = [];
    for (final Object? bp in bps) {
      if (bp is Map<String, Object?>) {
        final String ref = bp['instructionReference'] as String? ?? '0';
        final int addr =
            int.tryParse(ref) ??
            int.tryParse(ref.replaceFirst('0x', ''), radix: 16) ??
            0;
        final int offset = bp['offset'] as int? ?? 0;
        final int finalAddr = addr + offset;
        _emulator.breakpoints.add(finalAddr);
        verified.add({
          'verified': true,
          'instructionReference': '0x${finalAddr.toRadixString(16)}',
        });
      }
    }

    _sendResponse(seq, command, body: {'breakpoints': verified});
  }

  void _handleDisassemble(int seq, String command, Map<String, Object?> args) {
    final String memRef = args['memoryReference'] as String? ?? '0';
    int addr =
        int.tryParse(memRef) ??
        int.tryParse(memRef.replaceFirst('0x', ''), radix: 16) ??
        0;
    final int offset = args['offset'] as int? ?? 0;
    final int count = args['instructionCount'] as int? ?? 10;
    addr += offset;

    final List<Map<String, Object>> instructions = [];
    for (int i = 0; i < count; i++) {
      final DasmDescriptor desc = _emulator.dasm(addr);
      int instrLen = 1; // default
      String instrText = '\$${addr.toRadixString(16).padLeft(4, '0')}';
      if (desc is DasmCode) {
        instrText = desc.instruction.toString();
        instrLen = desc.instruction.descriptor.bytes.length;
        if (desc.label.isNotEmpty) {
          instrText = '${desc.label}: $instrText';
        }
        if (desc.comment.isNotEmpty) {
          instrText = '$instrText ; ${desc.comment}';
        }
      }

      instructions.add({
        'address': '0x${addr.toRadixString(16)}',
        'instructionBytes': List.generate(
          instrLen,
          (j) => _emulator
              .memReadForTest(addr + j)
              .toRadixString(16)
              .padLeft(2, '0'),
        ).join(' '),
        'instruction': instrText,
      });

      addr += instrLen;
    }

    _sendResponse(seq, command, body: {'instructions': instructions});
  }

  void _handleReadMemory(int seq, String command, Map<String, Object?> args) {
    final String memRef = args['memoryReference'] as String? ?? '0';
    int addr =
        int.tryParse(memRef) ??
        int.tryParse(memRef.replaceFirst('0x', ''), radix: 16) ??
        0;
    final int offset = args['offset'] as int? ?? 0;
    final int count = args['count'] as int? ?? 0;
    addr += offset;

    final Uint8List bytes = Uint8List(count);
    for (int i = 0; i < count; i++) {
      bytes[i] = _emulator.memReadForTest((addr + i) & 0x1FFFF);
    }

    _sendResponse(
      seq,
      command,
      body: {
        'address': '0x${addr.toRadixString(16)}',
        'data': base64Encode(bytes),
      },
    );
  }

  void _handleWriteMemory(int seq, String command, Map<String, Object?> args) {
    final String memRef = args['memoryReference'] as String? ?? '0';
    int addr =
        int.tryParse(memRef) ??
        int.tryParse(memRef.replaceFirst('0x', ''), radix: 16) ??
        0;
    final int offset = args['offset'] as int? ?? 0;
    addr += offset;

    final String data64 = args['data'] as String? ?? '';
    final Uint8List bytes = base64Decode(data64);
    for (int i = 0; i < bytes.length; i++) {
      _emulator.memWriteForTest((addr + i) & 0x1FFFF, bytes[i]);
    }

    _sendResponse(seq, command, body: {'bytesWritten': bytes.length});
  }

  /// Sends key-down/key-up pairs to the emulator keyboard with a small delay.
  ///
  /// Accepts `keys`: a list of key name strings (e.g. ["r","u","n","enter"]).
  /// Each key is pressed and released with a brief hold time to let the ROM
  /// scan and process it.
  void _handleSendKeys(int seq, String command, Map<String, Object?> args) {
    final keys = (args['keys'] as List?)?.cast<String>() ?? <String>[];
    if (keys.isEmpty) {
      _sendResponse(seq, command, body: {'sent': 0});
      return;
    }

    // Send keys one at a time with frame delays so the ROM processes each.
    // Guard against emulator being stopped mid-sequence.
    int i = 0;
    void sendNext() {
      if (!_emulator.isRunning || i >= keys.length) {
        _sendResponse(seq, command, body: {'sent': i});
        return;
      }
      final key = keys[i];
      i++;
      _emulator.keyboard.keyDown(key);
      _emulator.updateKeyboardInput();
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!_emulator.isRunning) return;
        _emulator.keyboard.keyUp(key);
        Future<void>.delayed(const Duration(milliseconds: 40), sendNext);
      });
    }

    sendNext();
  }

  void _handleDisconnect(int seq, String command) {
    _sendResponse(seq, command);
    dispose();
  }
}
