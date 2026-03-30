import 'dart:async';
import 'dart:convert';
import 'dart:io' show ZLibCodec;
import 'dart:typed_data';

import 'package:basic_compiler/basic_compiler.dart';
import 'package:dart_mcp/server.dart';
import 'package:pc1500_mcp_server/src/dap_client.dart';

/// MCP server that bridges Claude to the PC-1500 emulator via DAP.
///
/// Exposes emulator debugging tools (read registers, memory, step, etc.)
/// through the Model Context Protocol. Communicates with the running
/// emulator over a DAP TCP connection.
final class PC1500MCPServer extends MCPServer with ToolsSupport {
  PC1500MCPServer(
    super.channel, {
    this.host = 'localhost',
    this.port = 3756,
  }) : super.fromStreamChannel(
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
    registerTool(_screenshotTool, _handleScreenshot);
    registerTool(_uploadBasicTool, _handleUploadBasic);

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
    description:
        'Execute one or more CPU instructions and return the new state. '
        'Each step is a DAP round-trip, so large counts (>100) will be slow.',
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

  static final _screenshotTool = Tool(
    name: 'emulator_screenshot',
    description:
        'Capture the PC-1500 LCD screen as a PNG image (156×7 LCD pixels '
        'scaled 10× to 1560×70). Also returns active status symbols '
        '(DEF, SHIFT, RUN, PRO, etc.) as text.',
    inputSchema: ObjectSchema(),
    annotations: ToolAnnotations(readOnlyHint: true),
  );

  static final _uploadBasicTool = Tool(
    name: 'emulator_upload_basic',
    description:
        'Compile and upload a BASIC program to emulator memory. '
        'Tokenizes keywords into internal codes and writes the binary '
        'program at \$40C2. Updates STATUS pointers so LIST and RUN work.',
    inputSchema: ObjectSchema(
      properties: {
        'program': StringSchema(
          description:
              'BASIC source code (one line per line, e.g. "10 PRINT \\"HELLO\\"\\n20 END")',
        ),
        'run': BooleanSchema(
          description: 'Auto-run the program after upload (default false)',
        ),
      },
      required: ['program'],
    ),
    annotations: ToolAnnotations(readOnlyHint: false, destructiveHint: true),
  );

  // ── Tool handlers ───────────────────────────────────────────────────────

  Future<CallToolResult> _handleConnect(CallToolRequest request) async {
    if (_dap != null && _dap!.isConnected) {
      return _text('Already connected to emulator.');
    }
    // Close stale client if the connection was lost.
    final stale = _dap;
    _dap = null;
    if (stale != null) {
      try {
        await stale.close();
      } catch (_) {}
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
      final addr = _tryParseHex(addrStr) ?? 0;
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
      if (_tryParseHex(a) == null) {
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

  Future<CallToolResult> _handleScreenshot(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) {
      return _notConnected();
    }

    try {
      // Read both display halves and symbol bytes.
      final results = await Future.wait([
        dap.request('readMemory', {'memoryReference': '0x7600', 'count': 78}),
        dap.request('readMemory', {'memoryReference': '0x7700', 'count': 78}),
        dap.request('readMemory', {'memoryReference': '0x764E', 'count': 2}),
      ]);

      final left = base64Decode(results[0]['data'] as String? ?? '');
      final right = base64Decode(results[1]['data'] as String? ?? '');
      final symData = base64Decode(results[2]['data'] as String? ?? '');

      // Decode status symbols.
      final syms = <String>[];
      if (symData.length >= 2) {
        if (symData[0] & 0x80 != 0) syms.add('DEF');
        if (symData[0] & 0x40 != 0) syms.add('I');
        if (symData[0] & 0x20 != 0) syms.add('II');
        if (symData[0] & 0x10 != 0) syms.add('III');
        if (symData[0] & 0x08 != 0) syms.add('SMALL');
        if (symData[0] & 0x04 != 0) syms.add('SML');
        if (symData[0] & 0x02 != 0) syms.add('SHIFT');
        if (symData[0] & 0x01 != 0) syms.add('BUSY');
        if (symData[1] & 0x40 != 0) syms.add('RUN');
        if (symData[1] & 0x20 != 0) syms.add('PRO');
        if (symData[1] & 0x10 != 0) syms.add('RESERVE');
        if (symData[1] & 0x04 != 0) syms.add('RAD');
        if (symData[1] & 0x02 != 0) syms.add('G');
        if (symData[1] & 0x01 != 0) syms.add('DE');
      }

      // Decode interleaved 2-byte-per-column-pair format into a pixel grid.
      // Each buffer has 78 bytes = 39 pairs, each pair encodes 2 columns:
      //   Even byte: bits 4-7 → x1 rows 0-3, bits 0-3 → x2 rows 0-3
      //   Odd byte:  bits 4-6 → x1 rows 4-6, bits 0-2 → x2 rows 4-6
      // Buffer 1: x1 starts at col 78, x2 starts at col 0.
      // Buffer 2: x1 starts at col 117, x2 starts at col 39.
      const lcdW = 156;
      const lcdH = 7;
      const scale = 10;
      const imgW = lcdW * scale;
      const imgH = lcdH * scale;
      final pixels = List.generate(lcdW, (_) => List.filled(lcdH, false));

      void decodeBuffer(Uint8List buf, int xStart1, int xStart2) {
        int x1 = xStart1;
        int x2 = xStart2;
        for (
          int i = 0;
          i <= buf.length - 2 && x1 < lcdW && x2 < lcdW;
          i += 2, x1++, x2++
        ) {
          final lo = buf[i];
          final hi = buf[i + 1];
          // x1 column.
          pixels[x1][0] = lo & 0x10 != 0;
          pixels[x1][1] = lo & 0x20 != 0;
          pixels[x1][2] = lo & 0x40 != 0;
          pixels[x1][3] = lo & 0x80 != 0;
          pixels[x1][4] = hi & 0x10 != 0;
          pixels[x1][5] = hi & 0x20 != 0;
          pixels[x1][6] = hi & 0x40 != 0;
          // x2 column.
          pixels[x2][0] = lo & 0x01 != 0;
          pixels[x2][1] = lo & 0x02 != 0;
          pixels[x2][2] = lo & 0x04 != 0;
          pixels[x2][3] = lo & 0x08 != 0;
          pixels[x2][4] = hi & 0x01 != 0;
          pixels[x2][5] = hi & 0x02 != 0;
          pixels[x2][6] = hi & 0x04 != 0;
        }
      }

      decodeBuffer(left, 78, 0);
      decodeBuffer(right, 117, 39);

      final png = _buildPng(imgW, imgH, (int x, int y) {
        return pixels[x ~/ scale][y ~/ scale];
      });

      final content = <Content>[
        ImageContent(data: base64Encode(png), mimeType: 'image/png'),
        TextContent(
          text: 'Symbols: ${syms.isEmpty ? "(none)" : syms.join(" ")}',
        ),
      ];

      return CallToolResult(content: content);
    } on Object catch (e) {
      return _error('Failed to capture screen: $e');
    }
  }

  /// Build a PNG with LCD-green colors.
  static Uint8List _buildPng(
    int w,
    int h,
    bool Function(int x, int y) pixelOn,
  ) {
    // LCD colors: dark green background, bright green foreground.
    const onR = 0x2A;
    const onG = 0x3A;
    const onB = 0x14;
    const offR = 0x9E;
    const offG = 0xA8;
    const offB = 0x85;

    // Build raw scanlines: filter byte (0 = None) + RGB per pixel.
    final raw = BytesBuilder(copy: false);
    for (int y = 0; y < h; y++) {
      raw.addByte(0); // filter: None
      for (int x = 0; x < w; x++) {
        final on = pixelOn(x, y);
        raw.addByte(on ? onR : offR);
        raw.addByte(on ? onG : offG);
        raw.addByte(on ? onB : offB);
      }
    }

    final compressed = ZLibCodec().encode(raw.takeBytes());

    // Assemble PNG file.
    final out = BytesBuilder();

    // Signature.
    out.add(const [137, 80, 78, 71, 13, 10, 26, 10]);

    // IHDR.
    final ihdr = ByteData(13);
    ihdr.setUint32(0, w);
    ihdr.setUint32(4, h);
    ihdr.setUint8(8, 8); // bit depth
    ihdr.setUint8(9, 2); // color type: RGB
    _pngChunk(out, 'IHDR', ihdr.buffer.asUint8List());

    // IDAT.
    _pngChunk(out, 'IDAT', Uint8List.fromList(compressed));

    // IEND.
    _pngChunk(out, 'IEND', Uint8List(0));

    return out.toBytes();
  }

  /// Write a PNG chunk: length + type + data + CRC.
  static void _pngChunk(BytesBuilder out, String type, Uint8List data) {
    final typeBytes = Uint8List.fromList(type.codeUnits);
    final len = ByteData(4)..setUint32(0, data.length);
    out.add(len.buffer.asUint8List());
    out.add(typeBytes);
    out.add(data);

    // CRC-32 over type + data.
    final crc = _crc32([...typeBytes, ...data]);
    final crcBytes = ByteData(4)..setUint32(0, crc);
    out.add(crcBytes.buffer.asUint8List());
  }

  /// Standard CRC-32 as used by PNG.
  static int _crc32(List<int> data) {
    // Build table on first use.
    _crc32Table ??= List<int>.generate(256, (n) {
      int c = n;
      for (int k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
      }
      return c;
    });

    int crc = 0xFFFFFFFF;
    for (final b in data) {
      crc = _crc32Table![(crc ^ b) & 0xFF] ^ (crc >>> 8);
    }
    return crc ^ 0xFFFFFFFF;
  }

  static List<int>? _crc32Table;

  Future<CallToolResult> _handleUploadBasic(CallToolRequest request) async {
    final dap = _requireDap();
    if (dap == null) return _notConnected();

    final args = request.arguments ?? {};
    final program = args['program'] as String? ?? '';

    if (program.trim().isEmpty) {
      return _error('No program source provided.');
    }

    // Compile BASIC source to binary.
    final CompilerResult compiled;
    try {
      compiled = compile(program);
    } on CompilerError catch (e) {
      return _error('Compilation error: $e');
    }

    // Program base address.
    const int base = 0x40C2;
    final int endAddr = base + compiled.bytes.length - 1; // address of 0xFF

    try {
      // Write compiled program bytes at $40C2.
      await dap.request('writeMemory', {
        'memoryReference': '0x${base.toRadixString(16)}',
        'data': base64Encode(compiled.bytes),
      });

      // Update end-of-program pointer ($7867-$7868) to point to the 0xFF byte.
      await dap.request('writeMemory', {
        'memoryReference': '0x7867',
        'data': base64Encode([
          (endAddr >> 8) & 0xFF,
          endAddr & 0xFF,
        ]),
      });

      final bool autoRun = args['run'] == true;
      if (autoRun) {
        // Resume emulator if paused, then type RUN + ENTER.
        try {
          await dap.request('continue', {'threadId': 1});
        } catch (_) {} // Ignore if already running.
        await dap.request('sendKeys', {
          'keys': ['r', 'u', 'n', 'enter'],
        });
      }

      final String status = autoRun ? ' Running.' : '';
      return _text(
        'Uploaded ${compiled.lineCount} lines '
        '(${compiled.bytes.length} bytes) at '
        '\$${base.toRadixString(16).toUpperCase()}-'
        '\$${endAddr.toRadixString(16).toUpperCase()}.$status',
      );
    } on Object catch (e) {
      return _error('Upload failed: $e');
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
  /// Returns `null` if the string is not valid hex.
  static int? _tryParseHex(String s) {
    final stripped = s.startsWith('0x') || s.startsWith('0X')
        ? s.substring(2)
        : s;
    return int.tryParse(stripped, radix: 16);
  }

  /// Extract an integer argument, handling [int], [double], and [String] values.
  static int _intArg(Map<String, Object?> args, String key, int defaultValue) {
    final v = args[key];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }
}
