import 'dart:io';

import 'package:pc1500_mcp_server/server.dart';

void main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? 3756 : 3756;
  final host = args.length > 1 ? args[1] : 'localhost';

  final channel = stdioChannel(input: stdin, output: stdout);
  final server = PC1500MCPServer(channel, host: host, port: port);
  await server.done;
}
