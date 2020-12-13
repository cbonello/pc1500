import 'package:bitsdojo_window/bitsdojo_window.dart' as windows;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pc1500/src/repositories/local_storage/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/application.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: <Override>[
      localStorageRepositoryProvider.overrideWithValue(
        LocalStorageRepository(sharedPreferences: sharedPreferences),
      ),
    ],
    child: const PC1500App(),
  ));

  windows.doWhenWindowReady(() {
    final Size initialSize = Size(
      1355,
      windows.appWindow.titleBarHeight + 590 + 15,
    );
    windows.appWindow.minSize = initialSize;
    windows.appWindow.maxSize = initialSize;
    windows.appWindow.size = initialSize;
    windows.appWindow.alignment = Alignment.center;
    windows.appWindow.show();
  });
}
