import 'dart:io';

typedef SocketServerCallback = void Function(WebSocket socket);

class SocketServer {
  SocketServer({int port})
      : _port = port ?? 5600,
        started = false;

  final int _port;
  bool started;

  Future<void> start(SocketServerCallback onData) async {
    try {
      final HttpServer server = await HttpServer.bind('localhost', _port);
      server.transform(WebSocketTransformer()).listen(onData);
    } catch (e) {
      throw Exception('Cannot start webserver on port $_port');
    }
  }
}
