import 'dart:io';

typedef SocketServerCallback = void Function(WebSocket socket);

class SocketServer {
  SocketServer({int port})
      : _port = port ?? 5600,
        _started = false;

  final int _port;
  bool _started;
  HttpServer _server;

  Future<void> start(
    SocketServerCallback onData, {
    Function onError,
    void Function() onDone,
  }) async {
    try {
      _server = await HttpServer.bind('localhost', _port);
      _server.transform(WebSocketTransformer()).listen(
            onData,
            onError: onError,
            onDone: onDone,
          );
      _started = true;
    } catch (_) {
      throw Exception('Cannot start debug server on port $_port');
    }
  }

  bool get isRunning => _started;

  Future<void> close() async {
    if (_started) {
      await _server.close();
      _started = false;
    } else {
      throw Exception('Debug server is not online');
    }
  }
}
