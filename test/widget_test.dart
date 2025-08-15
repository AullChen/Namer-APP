// This is a basic Flutter widget test for the Name Generator app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Name Generator app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the app loads successfully with NavigationRail
    expect(find.byType(NavigationRail), findsOneWidget);
    
    // Verify navigation rail destinations exist
    expect(find.text('生成器'), findsOneWidget);
    expect(find.text('收藏夹'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('Navigation between screens works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Test navigation to favorites screen
    await tester.tap(find.text('收藏夹'));
    await tester.pumpAndSettle();

    // Test navigation to settings screen
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    // Test navigation back to generator
    await tester.tap(find.text('生成器'));
    await tester.pumpAndSettle();

    // Verify navigation rail is still present
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
