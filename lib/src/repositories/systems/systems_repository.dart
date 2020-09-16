import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:system/system.dart';

import 'models/models.dart';

class SystemsRepository {
  SystemsRepository._({
    @required Map<DeviceType, SkinModel> skins,
  })  : assert(skins != null),
        _skins = skins;

  static SystemsRepository _instance;
  static Future<SystemsRepository> getInstance() async {
    if (_instance == null) {
      final Map<DeviceType, SkinModel> skins = <DeviceType, SkinModel>{};
      skins[DeviceType.pc2] = await _readSkin('assets/systems/pc2.json');

      _instance = SystemsRepository._(skins: skins);
    }

    return _instance;
  }

  final Map<DeviceType, SkinModel> _skins;

  SkinModel getSkin(DeviceType type) => _skins[type];

  bool skinExistsForDevice(DeviceType type) => _skins.containsKey(type);

  static Future<SkinModel> _readSkin(String asset) async {
    final String jsonStr = await rootBundle.loadString(asset);
    final Map<String, dynamic> json =
        jsonDecode(jsonStr) as Map<String, dynamic>;
    final SkinModel skin = SkinModel.fromJson(json);
    return skin;
  }
}
