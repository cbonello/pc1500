import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc1500/src/repositories/local_storage/local_storage_repository.dart';

const int _defaultDebugPort = 3756;

final ChangeNotifierProvider<DebugPortRepository> debugPortRepositoryProvider =
    ChangeNotifierProvider<DebugPortRepository>((Ref ref) {
      final DebugPortRepository repository = DebugPortRepository(
        localStorageRepository: ref.watch(localStorageRepositoryProvider),
      );

      return repository;
    });

class DebugPortRepository with ChangeNotifier {
  DebugPortRepository({required LocalStorageRepository localStorageRepository})
    : _localStorageRepository = localStorageRepository,
      _debugPort = localStorageRepository.getDebugPort(_defaultDebugPort);

  final LocalStorageRepository _localStorageRepository;
  int _debugPort;

  void resetDebugPort() => debugPort = _defaultDebugPort;

  int get debugPort => _debugPort;

  set debugPort(int port) {
    if (port != _debugPort) {
      _localStorageRepository.setDebugPort(port);
      _debugPort = port;
      notifyListeners();
    }
  }
}
