/// CLI tool: compile a .bas file and upload it to the running PC-1500 emulator.
///
/// Usage:
///   dart run bin/upload.dart program.bas [--run] [--port 3756]
import 'dart:convert';
import 'dart:io';

import 'package:basic_compiler/basic_compiler.dart';
import 'package:pc1500_mcp_server/src/dap_client.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first == '--help' || args.first == '-h') {
    stderr.writeln('Usage: dart run bin/upload.dart <file.bas> [--run] '
        '[--port PORT]');
    stderr.writeln();
    stderr.writeln('Options:');
    stderr.writeln('  --run     Auto-run the program after upload');
    stderr.writeln('  --port N  DAP server port (default 3756)');
    exit(1);
  }

  final String filePath = args.first;
  final bool autoRun = args.contains('--run');
  final int port = _parsePort(args);

  // Read source file.
  final File file = File(filePath);
  if (!file.existsSync()) {
    stderr.writeln('File not found: $filePath');
    exit(1);
  }
  final String source = file.readAsStringSync();

  // Compile.
  final CompilerResult compiled;
  try {
    compiled = compile(source);
  } on CompilerError catch (e) {
    stderr.writeln('Compilation error: $e');
    exit(1);
  }

  stdout.writeln('Compiled ${compiled.lineCount} lines '
      '(${compiled.bytes.length} bytes).');

  // Connect to emulator.
  final DapClient dap;
  try {
    dap = await DapClient.connect('localhost', port);
    await dap.request('initialize', {
      'clientID': 'upload-cli',
      'adapterID': 'pc1500',
    });
    await dap.request('attach', {});
  } on Object catch (e) {
    stderr.writeln('Failed to connect to emulator on port $port: $e');
    exit(1);
  }

  try {
    // Write program at $40C2.
    const int base = 0x40C2;
    final int endAddr = base + compiled.bytes.length - 1;

    await dap.request('writeMemory', {
      'memoryReference': '0x${base.toRadixString(16)}',
      'data': base64Encode(compiled.bytes),
    });

    // Update end-of-program pointer ($7867-$7868).
    await dap.request('writeMemory', {
      'memoryReference': '0x7867',
      'data': base64Encode([
        (endAddr >> 8) & 0xFF,
        endAddr & 0xFF,
      ]),
    });

    stdout.writeln('Uploaded to \$${base.toRadixString(16).toUpperCase()}-'
        '\$${endAddr.toRadixString(16).toUpperCase()}.');

    if (autoRun) {
      try {
        await dap.request('continue', {'threadId': 1});
      } catch (_) {}
      await dap.request('sendKeys', {
        'keys': ['r', 'u', 'n', 'enter'],
      });
      stdout.writeln('Running.');
    }
  } on Object catch (e) {
    stderr.writeln('Upload failed: $e');
    exit(1);
  } finally {
    await dap.close();
  }
}

int _parsePort(List<String> args) {
  final int idx = args.indexOf('--port');
  if (idx >= 0 && idx + 1 < args.length) {
    return int.tryParse(args[idx + 1]) ?? 3756;
  }
  return 3756;
}
