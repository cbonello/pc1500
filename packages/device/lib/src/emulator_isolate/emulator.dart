import 'dart:isolate';

void emulatorMain(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  mainToIsolateStream.listen((data) {
    print('[mainToIsolateStream] $data');
    // exit(0);
  });
  isolateToMainStream.send('This is from myIsolate()');
}
