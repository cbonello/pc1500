import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/pages/home/home_page.dart';

void main() {
  group('HomePage', () {
    test('routeName is /home', () {
      expect(HomePage.routeName, equals('/home'));
    });
  });
}
