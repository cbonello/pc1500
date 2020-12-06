import 'package:bitsdojo_window/bitsdojo_window.dart' as windows;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:system/system.dart';

import '../../repositories/systems/systems_repository.dart';
import 'skin.dart';

const Color borderColor = Color(0xFF805306);

class HomeView extends ConsumerWidget {
  const HomeView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final AsyncValue<SystemsRepository> systemsRepository =
        watch(systemsRepositoryProvider);

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
              child: systemsRepository.when<Widget>(
                data: (SystemsRepository repository) {
                  return Skin(skin: repository.getSkin(DeviceType.pc2));
                },
                loading: () => const CircularProgressIndicator(),
                error: (Object err, StackTrace _) => Text('Error: $err'),
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
