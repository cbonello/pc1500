import 'package:bitsdojo_window/bitsdojo_window.dart' as windows;
import 'package:flutter/material.dart';

const Color borderColor = Color(0xFF805306);

class HomeView extends StatelessWidget {
  const HomeView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
