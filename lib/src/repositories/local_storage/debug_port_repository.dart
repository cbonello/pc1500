import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/all.dart';

import 'local_storage_repository.dart';

const int _defaultDebugPort = 3756;

final ChangeNotifierProvider<DebugPortRepository> DebugPortRepositoryProvider =
    ChangeNotifierProvider<DebugPortRepository>(
  (ProviderReference ref) {
    final DebugPortRepository repository = DebugPortRepository(
      localStorageRepository: ref.watch(localStorageRepositoryProvider),
    );
    return repository;
  },
);

class DebugPortRepository with ChangeNotifier {
  DebugPortRepository({
    @required LocalStorageRepository localStorageRepository,
  })  : assert(localStorageRepository != null),
        _localStorageRepository = localStorageRepository,
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
