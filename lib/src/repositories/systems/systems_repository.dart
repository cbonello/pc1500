import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:system/system.dart';

import 'models/models.dart';

class SystemRepository {
  SystemRepository._({
    @required Map<DeviceType, SkinModel> skins,
  })  : assert(skins != null),
        _skins = skins;

  final Map<DeviceType, SkinModel> _skins;

  SkinModel getSkin(DeviceType type) => _skins[type];

  static SystemRepository _instance;
  static Future<SystemRepository> getInstance() async {
    if (_instance == null) {
      Map<DeviceType, SkinModel> skins;
      skins[DeviceType.pc2] = await _readSkin('assets/systems/pc2.json');

      _instance = SystemRepository._(skins: skins);
    }

    return _instance;
  }

  static Future<SkinModel> _readSkin(String asset) async {
    final String jsonStr = await rootBundle.loadString(asset);
    final Map<String, dynamic> json =
        jsonDecode(jsonStr) as Map<String, dynamic>;
    final SkinModel skin = SkinModel.fromJson(json);
    return skin;
  }
}
