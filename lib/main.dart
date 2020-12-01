import 'package:bitsdojo_window/bitsdojo_window.dart' as windows;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/application.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: PC1500App()));

  windows.doWhenWindowReady(() {
    final Size initialSize = Size(1506, windows.getTitleBarHeight() + 628 + 15);
    windows.appWindow.minSize = initialSize;
    windows.appWindow.maxSize = initialSize;
    windows.appWindow.size = initialSize;
    windows.appWindow.alignment = Alignment.center;
    windows.appWindow.show();
  });
}
