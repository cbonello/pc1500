import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/application.dart';
import 'package:pc1500/src/pages/home/home_page.dart';

void main() {
  group(PC1500App, () {
    test('is a const StatelessWidget', () {
      const app = PC1500App();
      expect(app, isA<StatelessWidget>());
    });

    testWidgets('builds a MaterialApp with correct configuration', (
      WidgetTester tester,
    ) async {
      // Build inside a Builder to inspect the MaterialApp without navigating
      // to HomePage (which requires ProviderScope from main.dart).
      late MaterialApp app;
      await tester.pumpWidget(
        Builder(
          builder: (BuildContext context) {
            // Build PC1500App and extract the MaterialApp it produces.
            const PC1500App pc1500App = PC1500App();
            final Widget result = pc1500App.build(context);
            app = result as MaterialApp;
            // Return a minimal placeholder to satisfy the test framework.
            return const SizedBox.shrink();
          },
        ),
      );

      expect(app.title, equals('Sharp PC-1500'));
      expect(app.debugShowCheckedModeBanner, isFalse);
      expect(app.initialRoute, equals(HomePage.routeName));
      expect(app.routes, contains(HomePage.routeName));
      expect(app.theme, isNotNull);
    });
  });
}
