import 'dart:convert';

import 'package:annotations/src/models/models.dart';
import 'package:test/test.dart';

import 'data/ce150_version_1_annotations.dart' as ce150;
import 'data/me0_ram_annotations.dart' as ram;
import 'data/pc1500_a03_annotations.dart' as rom;

void main() {
  group('Annotations', () {
    test('should annotations successfully', () {
      _checkAnnotations(jsonDecode(ce150.json) as Map<String, dynamic>);
      _checkAnnotations(jsonDecode(ram.json) as Map<String, dynamic>);
      _checkAnnotations(jsonDecode(rom.json) as Map<String, dynamic>);
    });
  });
}

void _checkAnnotations(Map<String, dynamic> json) {
  expect(
    Annotations.fromJson(json),
    equals(const TypeMatcher<Annotations>()),
  );
}
