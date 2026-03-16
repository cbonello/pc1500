import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc1500/src/repositories/systems/models/models.dart';

enum DeviceType { pc1500, pc2, pc1500A }

final FutureProvider<SystemsRepository> systemsRepositoryProvider =
    FutureProvider<SystemsRepository>(
      (Ref ref) => SystemsRepository.getInstance(),
    );

class SystemsRepository {
  SystemsRepository._({required Map<DeviceType, SkinModel> skins})
    : _skins = skins;

  static Future<SystemsRepository>? _instanceFuture;
  static Future<SystemsRepository> getInstance() {
    return _instanceFuture ??= _create();
  }

  static Future<SystemsRepository> _create() async {
    final Map<DeviceType, SkinModel> skins = <DeviceType, SkinModel>{};
    skins[DeviceType.pc2] = await _readSkin('assets/systems/pc2.json');
    skins[DeviceType.pc1500] = await _readSkin('assets/systems/pc1500.json');
    skins[DeviceType.pc1500A] = await _readSkin('assets/systems/pc1500a.json');

    return SystemsRepository._(skins: skins);
  }

  final Map<DeviceType, SkinModel> _skins;

  SkinModel getSkin(DeviceType type) => _skins[type]!;

  bool skinExistsForDevice(DeviceType type) => _skins.containsKey(type);

  static Future<SkinModel> _readSkin(String asset) async {
    final String jsonStr = await rootBundle.loadString(asset);
    final Map<String, dynamic> json =
        jsonDecode(jsonStr) as Map<String, dynamic>;
    final SkinModel skin = SkinModel.fromJson(json);
    return skin;
  }
}
