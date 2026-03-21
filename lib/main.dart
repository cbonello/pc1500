import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc1500/src/application.dart';
import 'package:pc1500/src/repositories/local_storage/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        localStorageRepositoryProvider.overrideWithValue(
          LocalStorageRepository(sharedPreferences: sharedPreferences),
        ),
      ],
      child: const PC1500App(),
    ),
  );
}
