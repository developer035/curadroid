// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:curadroid/app.dart';
import 'package:curadroid/core/theme/app_theme.dart';
import 'package:curadroid/data/repositories/settings_repo.dart';
import 'package:curadroid/features/settings/settings_screen.dart';

void main() {
  testWidgets('CuraTrailApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await SettingsRepository.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepoProvider.overrideWith((ref) => settings),
        ],
        child: const CuraTrailApp(),
      ),
    );
  });

  testWidgets('SettingsScreen renders without layout or paint errors', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'use_ai_coach': true,
    });
    final settings = await SettingsRepository.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepoProvider.overrideWith((ref) => settings),
        ],
        child: MaterialApp(
          theme: AppTheme.light(null),
          home: const SettingsScreen(),
        ),
      ),
    );

    // Pump and settle to ensure all slivers, cards, and buttons lay out and paint
    await tester.pumpAndSettle();

    // Verify visible sections render properly without any layout or paint exceptions
    expect(find.text('DATA & INTEGRATIONS'), findsOneWidget);
    expect(find.text('AI COACH (BETA PROXY)'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);

    // Drag ListView down to ensure all remaining slivers build, layout, and paint smoothly
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('DATA MANAGEMENT'), findsOneWidget);
    expect(find.text('SAFETY & DISCLAIMER'), findsOneWidget);
  });

  testWidgets('Bottom navigation bar switches to Settings screen without error', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'use_ai_coach': true,
    });
    final settings = await SettingsRepository.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepoProvider.overrideWith((ref) => settings),
        ],
        child: const CuraTrailApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Tap Settings destination in NavigationBar
    final settingsTab = find.text('Settings');
    expect(settingsTab, findsOneWidget);
    await tester.tap(settingsTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify SettingsScreen content is now visible
    expect(find.text('DATA & INTEGRATIONS'), findsOneWidget);
    expect(find.text('AI COACH (BETA PROXY)'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });
}
