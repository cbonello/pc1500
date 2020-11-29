import 'package:bitsdojo_window/bitsdojo_window.dart' as windows;
import 'package:flutter/material.dart';

// import 'src/services/local_storage/local_storage_service.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final LocalStorageService localStorageService =
  //     await LocalStorageService.getInstance();

  runApp(const MyApp());

  windows.doWhenWindowReady(() {
    final Size initialSize = Size(1506, windows.getTitleBarHeight() + 628 + 15);
    windows.appWindow.minSize = initialSize;
    windows.appWindow.maxSize = initialSize;
    windows.appWindow.size = initialSize;
    windows.appWindow.alignment = Alignment.center;
    windows.appWindow.show();
  });
}

const Color borderColor = Color(0xFF805306);

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFBABEC1),
        body: windows.WindowBorder(
          color: borderColor,
          width: 1,
          child: Column(
            children: <Widget>[
              windows.WindowTitleBarBox(
                child: Row(
                  children: <Widget>[
                    Expanded(child: windows.MoveWindow()),
                    const WindowButtons()
                  ],
                ),
              ),
              Center(
                child: Stack(
                  children: <Widget>[
                    Image.asset('assets/systems/pc2.png'),
                    Positioned(
                      left: 370.0,
                      top: 81.0,
                      child: Container(
                        height: 90,
                        width: 903,
                        color: Colors.yellow[100],
                      ),
                    ),
                    Positioned(
                      left: 92.0,
                      top: 256.0,
                      child: Container(
                        height: 26,
                        width: 54,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            'OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ), //const Color(0xFF181319),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Color backgroundStartColor = Color(0xFFFFD500);
const Color backgroundEndColor = Color(0xFFF6A00C);

const windows.WindowButtonColors buttonColors = windows.WindowButtonColors(
    iconNormal: Color(0xFF805306),
    mouseOver: Color(0xFFF6A00C),
    mouseDown: Color(0xFF805306),
    iconMouseOver: Color(0xFF805306),
    iconMouseDown: Color(0xFFFFD500));

final windows.WindowButtonColors closeButtonColors = windows.WindowButtonColors(
    mouseOver: Colors.red[700],
    mouseDown: Colors.red[900],
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        windows.MinimizeWindowButton(colors: buttonColors),
        windows.MaximizeWindowButton(colors: buttonColors),
        windows.CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

class PC1500App extends StatelessWidget {
  // const PC1500App({Key key, @required this.localStorageService})
  //     : assert(localStorageService != null),
  //       super(key: key);

  // final LocalStorageService localStorageService;

  const PC1500App({Key key}) : super(key: key);

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
        child: Image.asset('assets/systems/pc2.png', fit: BoxFit.cover),
      ),
    );
  }
}
