import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc1500/src/repositories/local_storage/local_storage_repository.dart';

/// Default TCP port for the debug server.
const int _defaultDebugPort = 3756;

/// Provides the persisted debug server port.
final ChangeNotifierProvider<DebugPortRepository> debugPortRepositoryProvider =
    ChangeNotifierProvider<DebugPortRepository>((Ref ref) {
      return DebugPortRepository(
        localStorageRepository: ref.watch(localStorageRepositoryProvider),
      );
    });

/// Repository for the debug server TCP port setting.
class DebugPortRepository with ChangeNotifier {
  DebugPortRepository({required LocalStorageRepository localStorageRepository})
    : _localStorageRepository = localStorageRepository,
      _debugPort = localStorageRepository.getDebugPort(_defaultDebugPort);

  final LocalStorageRepository _localStorageRepository;
  int _debugPort;

  /// Restores the debug port to its default value.
  void resetDebugPort() => debugPort = _defaultDebugPort;

  /// The current debug server port.
  int get debugPort => _debugPort;

  /// Updates the debug port. Values outside 0–65535 are ignored.
  set debugPort(int port) {
    if (port != _debugPort && port >= 0 && port <= 65535) {
      _localStorageRepository.setDebugPort(port);
      _debugPort = port;
      notifyListeners();
    }
  }
}
