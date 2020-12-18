import 'dart:io';

import 'dart:typed_data';

class SocketServer {
  SocketServer({InternetAddress host, int port = 3756})
      : _host = host ?? InternetAddress.loopbackIPv6,
        _port = port;

  final InternetAddress _host;
  final int _port;
  ServerSocket _serverSocket;
  Socket _clientSocket;

  Future<void> start() async {
    _serverSocket = await ServerSocket.bind(_host, _port);
    _serverSocket.listen(_handleClient);
  }

  void send(Object message) => _clientSocket?.writeln(message);

  void stop() {
    _disconnectClient();
    _serverSocket?.close();
  }

  void _handleClient(Socket client) {
    // Only one client!
    if (_clientSocket == null) {
      _clientSocket = client;
      _clientSocket.listen(
        (Uint8List onData) {
          print(String.fromCharCodes(onData).trim());
          send('Received: ${String.fromCharCodes(onData)}');
        },
        onError: (Object _) {
          _disconnectClient();
        },
        onDone: () {
          _disconnectClient();
        },
      );
    }
  }

  void _disconnectClient() {
    _clientSocket?.close();
    _clientSocket?.destroy();
    _clientSocket = null;
  }
}
