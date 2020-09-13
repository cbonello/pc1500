import 'package:flutter/material.dart';

import 'src/services/local_storage/local_storage_service.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LocalStorageService localStorageService =
      await LocalStorageService.getInstance();

  runApp(PC1500App(localStorageService: localStorageService));
}

class PC1500App extends StatelessWidget {
  const PC1500App({Key key, @required this.localStorageService})
      : assert(localStorageService != null),
        super(key: key);

  final LocalStorageService localStorageService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sharp PC-1500 Emulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sharp PC-1500'),
      ),
      body: Center(
        child: Image.asset('assets/systems/pc2.png'),
      ),
    );
  }
}
