import 'dart:async';
import 'dart:convert';

import 'package:dart_mcp/server.dart';
import 'package:pc1500_mcp_server/src/dap_client.dart';
import 'package:stream_channel/stream_channel.dart';

/// MCP server that bridges Claude to the PC-1500 emulator via DAP.
///
/// Exposes emulator debugging tools (read registers, memory, step, etc.)
/// through the Model Context Protocol. Communicates with the running
/// emulator over a DAP TCP connection.
final class PC1500MCPServer extends MCPServer with ToolsSupport {
  PC1500MCPServer(
    StreamChannel<String> channel, {
    this.host = 'localhost',
    this.port = 3756,
  }) : super.fromStreamChannel(
         channel,
         implementation: Implementation(
           name: 'pc1500-emulator',
           version: '0.1.0',
         ),
       );

  final String host;
  final int port;
  DapClient? _dap;

  @override
  FutureOr<InitializeResult> initialize(InitializeRequest request) {
    registerTool(_connectTool, _handleConnect);
    registerTool(_disconnectTool, _handleDisconnect);
    registerTool(_cpuStateTool, _handleCpuState);
    registerTool(_readMemoryTool, _handleReadMemory);
    registerTool(_writeMemoryTool, _handleWriteMemory);
    registerTool(_disassembleTool, _handleDisassemble);
    registerTool(_stepTool, _handleStep);
    registerTool(_continueTool, _handleContinue);
    registerTool(_pauseTool, _handlePause);
    registerTool(_setBreakpointsTool, _handleSetBreakpoints);

    return super.initialize(request);
  }

  // ── Tool definitions ────────────────────────────────────────────────────

  static final _connectTool = Tool(
    name: 'emulator_connect',
    description:
        'Connect to the running PC-1500 emulator via DAP. '
        'Must be called before any other emulator tool.',
    inputSchema: ObjectSchema(),
    annotations: ToolAnnotations(readOnlyHint: false, idempotentHint: true),
  );

  static final _disconnectTool = Tool(
    name: 'emulator_disconnect',
    description: 'Disconnect from the PC-1500 emulator.',
    inputSchema: ObjectSchema(),
    annotations: ToolAnnotations(readOnlyHint: false),
  );

  static final _cpuStateTool = Tool(
    name: 'emulator_cpu_state',
    description:
        'Read the LH5801 CPU state: registers (A, X, Y, U, S, P), '
        'flags (C, Z, V, H, IE), and system state (HLT, IRQ, timer, DISP).',
    inputSchema: ObjectSchema(),
    annotations: ToolAnnotations(readOnlyHint: true),
  );

  static final _readMemoryTool = Tool(
    name: 'emulator_read_memory',
    description:
        'Read bytes from emulator memory. Returns hex dump. '
        'Address is in the LH5801 address space (0x0000-0xFFFF for ME0, '
        '0x10000-0x1FFFF for ME1).',
    inputSchema: ObjectSchema(
      properties: {
        'address': StringSchema(
          description: 'Start address (hex, e.g. "0x4000" or "0x7860")',
        ),
        'count': IntegerSchema(
          description: 'Number of bytes to read (default 64, max 4096)',
        ),
      },
      required: ['address'],
    ),
    annotations: ToolAnnotations(readOnlyHint: true),
  );

  static final _writeMemoryTool = Tool(
    name: 'emulator_write_memory',
    description: 'Write bytes to emulator memory.',
    inputSchema: ObjectSchema(
      properties: {
        'address': StringSchema(
          description: 'Start address (hex, e.g. "0x7860")',
        ),
        'bytes': StringSchema(
          description: 'Hex bytes to write (e.g. "FF 00 40 58")',
        ),
      },
      required: ['address', 'bytes'],
    ),
    annotations: ToolAnnotations(readOnlyHint: false, destructiveHint: true),
  );

  static final _disassembleTool = Tool(
    name: 'emulator_disassemble',
    description:
        'Disassemble LH5801 instructions at the given address. '
        'Shows instruction bytes, mnemonics, and ROM annotations.',
    inputSchema: ObjectSchema(
      properties: {
        'address': StringSchema(
          description: 'Start address (hex). Defaults to current PC.',
        ),
        'count': IntegerSchema(
          description: 'Number of instructions (default 20, max 100)',
        ),
      },
    ),
    annotations: ToolAnnotations(readOnlyHint: true),
  );

  static final _stepTool = Tool(
    name: 'emulator_step',
    description: 'Execute a single CPU instruction and return the new state.',
    inputSchema: ObjectSchema(
      properties: {
        'count': IntegerSchema(
          description: 'Number of steps (default 1, max 10000)',
        ),
      },
    ),
    annotations: ToolAnnotations(readOnlyHint: false),
  );

  static final _continueTool = Tool(
    name: 'emulator_continue',
    description:
        'Resume emulator execution (run freely until breakpoint or pause).',
    inputSchema: ObjectSchema(),
    annotations: ToolAnnotations(readOnlyHint: false),
  );

  static final _pauseTool = Tool(
    name: 'emulator_pause',
    description: 'Pause emulator execution.',
    inputSchema: ObjectSchema(),
    annotations: ToolAnnotations(readOnlyHint: false),
  );

  static final _setBreakpointsTool = Tool(
    name: 'emulator_set_breakpoints',
    description:
        'Set instruction breakpoints. Replaces all existing breakpoints. '
        'Pass empty list to clear.',
    inputSchema: ObjectSchema(
      properties: {
        'addresses': ListSchema(
          description: 'List of hex addresses (e.g. ["0xE967", "0xCD89"])',
          items: StringSchema(description: 'Hex address'),
        ),
      },
      required: ['addresses'],
    ),
    annotations: ToolAnnotations(readOnlyHint: false),
  );

  // ── Tool handlers ───────────────────────────────────────────────────────

  Future<CallToolResult> _handleConnect(CallToolRequest request) async {
    if (_dap != null && _dap!.isConnected) {
      return _text('Already connected to emulator.');
    }
    DapClient? client;
    try {
      client = await DapClient.connect(host, port);
      await client.initialize();
      _dap = client;

      return _text('Connected to PC-1500 emulator at $host:$port.');
    } catch (e) {
      await client?.close();
      _dap = null;

      return _error('Failed to connect: $e');
    }
  }

  Future<CallToolResult> _handleDisconnect(CallToolRequest request) async {
    final dap = _dap;
    if (dap == null) {
      return _text('Not connected.');
    }
    _dap = null;
    try {
      await dap.close();
    } catch (_) {}
    return _text('Disconnected.');
  }

  Future<CallToolResult> _handleCpuState(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    try {
      final results = await Future.wait([
        dap.request('variables', {'variablesReference': 1}),
        dap.request('variables', {'variablesReference': 2}),
        dap.request('variables', {'variablesReference': 3}),
        dap.request('stackTrace', {
          'threadId': 1,
          'startFrame': 0,
          'levels': 1,
        }),
      ]);
      final regs = results[0];
      final flags = results[1];
      final sys = results[2];
      final stack = results[3];

      final buf = StringBuffer();
      buf.writeln('=== PC-1500 CPU State ===');

      // Current instruction.
      final frames = stack['stackFrames'] as List?;
      if (frames != null && frames.isNotEmpty) {
        final frame = frames.first as Map<String, Object?>;
        buf.writeln(
          'PC: ${frame['instructionPointerReference']}  ${frame['name']}',
        );
      }

      buf.writeln();
      buf.writeln('Registers:');
      for (final v in (regs['variables'] as List? ?? [])) {
        final m = v as Map<String, Object?>;
        buf.writeln('  ${m['name']}: ${m['value']}');
      }

      buf.writeln();
      buf.writeln('Flags:');
      for (final v in (flags['variables'] as List? ?? [])) {
        final m = v as Map<String, Object?>;
        buf.writeln('  ${m['name']}: ${m['value']}');
      }

      buf.writeln();
      buf.writeln('System:');
      for (final v in (sys['variables'] as List? ?? [])) {
        final m = v as Map<String, Object?>;
        buf.writeln('  ${m['name']}: ${m['value']}');
      }

      return _text(buf.toString());
    } on Object catch (e) {
      return _error('Failed to read CPU state: $e');
    }
  }

  Future<CallToolResult> _handleReadMemory(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    final args = request.arguments ?? {};
    final addrStr = args['address'] as String? ?? '0';
    final count = _intArg(args, 'count', 64).clamp(1, 4096);

    try {
      final result = await dap.request('readMemory', {
        'memoryReference': addrStr,
        'count': count,
      });

      final data = base64Decode(result['data'] as String? ?? '');
      final addr = _parseHex(addrStr);
      final buf = StringBuffer();
      buf.writeln('Memory at $addrStr ($count bytes):');

      for (int i = 0; i < data.length; i += 16) {
        final lineAddr = addr + i;
        buf.write('  \$${lineAddr.toRadixString(16).padLeft(4, '0')}: ');
        final end = (i + 16).clamp(0, data.length);
        final hex = data
            .sublist(i, end)
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' ');
        final ascii = data
            .sublist(i, end)
            .map((b) => b >= 0x20 && b < 0x7F ? String.fromCharCode(b) : '.')
            .join();
        buf.writeln('$hex  $ascii');
      }

      return _text(buf.toString());
    } on Object catch (e) {
      return _error('Failed to read memory: $e');
    }
  }

  Future<CallToolResult> _handleWriteMemory(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    final args = request.arguments ?? {};
    final addrStr = args['address'] as String? ?? '0';
    final bytesStr = args['bytes'] as String? ?? '';

    // Parse hex bytes like "FF 00 40 58".
    final List<int> hexBytes;
    try {
      hexBytes = bytesStr
          .split(RegExp(r'[\s,]+'))
          .where((s) => s.isNotEmpty)
          .map((s) {
            final v = int.tryParse(s, radix: 16);
            if (v == null || v < 0 || v > 255) {
              throw FormatException('Invalid hex byte: "$s"');
            }

            return v;
          })
          .toList();
    } on FormatException catch (e) {
      return _error('$e');
    }

    if (hexBytes.isEmpty) {
      return _error('No bytes to write.');
    }
    try {
      final result = await dap.request('writeMemory', {
        'memoryReference': addrStr,
        'data': base64Encode(hexBytes),
      });

      return _text('Wrote ${result['bytesWritten']} bytes at $addrStr.');
    } on Object catch (e) {
      return _error('Failed to write memory: $e');
    }
  }

  Future<CallToolResult> _handleDisassemble(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    final args = request.arguments ?? {};
    final addrStr = args['address'] as String?;
    final count = _intArg(args, 'count', 20).clamp(1, 100);

    try {
      // If no address given, use current PC from stack trace.
      String memRef;
      if (addrStr != null) {
        memRef = addrStr;
      } else {
        final stack = await dap.request('stackTrace', {
          'threadId': 1,
          'startFrame': 0,
          'levels': 1,
        });
        final frames = stack['stackFrames'] as List? ?? [];
        memRef = frames.isNotEmpty
            ? (frames.first as Map)['instructionPointerReference'] as String
            : '0x0';
      }

      final result = await dap.request('disassemble', {
        'memoryReference': memRef,
        'instructionCount': count,
      });

      final instructions = result['instructions'] as List? ?? [];
      final buf = StringBuffer();
      buf.writeln('Disassembly at $memRef ($count instructions):');
      for (final instr in instructions) {
        final m = instr as Map<String, Object?>;
        final addr = m['address'] as String? ?? '';
        final bytes = m['instructionBytes'] as String? ?? '';
        final text = m['instruction'] as String? ?? '';
        buf.writeln('  $addr: ${bytes.padRight(12)} $text');
      }

      return _text(buf.toString());
    } on Object catch (e) {
      return _error('Failed to disassemble: $e');
    }
  }

  Future<CallToolResult> _handleStep(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }
    final args = request.arguments ?? {};
    final count = _intArg(args, 'count', 1).clamp(1, 10000);

    try {
      for (int i = 0; i < count; i++) {
        await dap.request('next', {'threadId': 1});
      }

      // Return CPU state after stepping.
      return _handleCpuState(request);
    } on Object catch (e) {
      return _error('Failed to step: $e');
    }
  }

  Future<CallToolResult> _handleContinue(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    try {
      await dap.request('continue', {'threadId': 1});

      return _text('Emulator resumed. Use emulator_pause to stop.');
    } on Object catch (e) {
      return _error('Failed to continue: $e');
    }
  }

  Future<CallToolResult> _handlePause(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    try {
      await dap.request('pause', {'threadId': 1});

      return _handleCpuState(request);
    } on Object catch (e) {
      return _error('Failed to pause: $e');
    }
  }

  Future<CallToolResult> _handleSetBreakpoints(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    final args = request.arguments ?? {};
    final addrs = args['addresses'];
    if (addrs is! List) {
      return _error(
        '"addresses" must be a list of hex strings. '
        'Example: ["0xE967", "0xCD89"]',
      );
    }
    final addrList = <String>[];
    for (final a in addrs) {
      if (a is! String) {
        return _error(
          'Each address must be a hex string, got ${a.runtimeType}. '
          'Example: ["0xE967", "0xCD89"]',
        );
      }
      if (_parseHex(a) == 0 && a != '0' && a != '0x0' && a != '0x0000') {
        return _error('Invalid hex address: "$a"');
      }
      addrList.add(a);
    }

    try {
      final bps = addrList.map((a) => {'instructionReference': a}).toList();
      await dap.request('setInstructionBreakpoints', {'breakpoints': bps});

      return _text(
        addrList.isEmpty
            ? 'All breakpoints cleared.'
            : 'Set ${addrList.length} breakpoint(s): ${addrList.join(', ')}',
      );
    } on Object catch (e) {
      return _error('Failed to set breakpoints: $e');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  DapClient? _requireDap() => (_dap != null && _dap!.isConnected) ? _dap : null;

  static CallToolResult _notConnected() =>
      _error('Not connected to emulator. Call emulator_connect first.');

  static CallToolResult _text(String text) =>
      CallToolResult(content: [TextContent(text: text)]);

  static CallToolResult _error(String text) =>
      CallToolResult(content: [TextContent(text: text)], isError: true);

  /// Parse a hex address string like "0x7860" or "7860".
  /// Addresses are always hexadecimal in this context.
  static int _parseHex(String s) {
    final stripped = s.startsWith('0x') || s.startsWith('0X')
        ? s.substring(2)
        : s;
    return int.tryParse(stripped, radix: 16) ?? 0;
  }

  /// Extract an integer argument, handling both [int] and [double] from JSON.
  static int _intArg(Map<String, Object?> args, String key, int defaultValue) {
    final v = args[key];
    if (v is int) {
      return v;
    }
    if (v is double) {
      return v.toInt();
    }

    return defaultValue;
  }
}
