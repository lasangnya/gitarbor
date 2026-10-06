import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/state/app_state.dart';
import 'package:gitarbor/ui/widgets/settings_menu.dart';

import 'test_app.dart';

void main() {
  Future<ProviderContainer> open(WidgetTester tester) async {
    setSize(tester, 800, 900);
    await tester.pumpWidget(
      testApp(const Scaffold(body: Center(child: SettingsMenu()))),
    );
    await tester.tap(find.byTooltip('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 500));
    return ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
  }

  testWidgets('sheet lists theme, motion, GitHub and debug', (tester) async {
    await open(tester);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Day garden'), findsOneWidget);
    expect(find.text('Match system'), findsOneWidget);
    expect(find.text('Night garden'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(
      find.text('Stops the wind and the growing animation.'),
      findsOneWidget,
    );
    expect(find.text('Connect GitHub'), findsOneWidget);
    expect(find.text('Renderer debug'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing a theme updates settingsProvider', (tester) async {
    final c = await open(tester);
    expect(c.read(settingsProvider).theme, ThemeChoice.system);
    await tester.tap(find.text('Night garden'));
    await tester.pump();
    expect(c.read(settingsProvider).theme, ThemeChoice.night);
    await tester.tap(find.text('Day garden'));
    await tester.pump();
    expect(c.read(settingsProvider).theme, ThemeChoice.day);
  });

  testWidgets('reduce motion switch toggles the setting', (tester) async {
    final c = await open(tester);
    expect(c.read(settingsProvider).reduceMotion, isFalse);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(c.read(settingsProvider).reduceMotion, isTrue);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(c.read(settingsProvider).reduceMotion, isFalse);
  });

  testWidgets('Connect GitHub opens the connect sheet', (tester) async {
    await open(tester);
    await tester.tap(find.text('Connect GitHub'));
    await pumpFor(tester, const Duration(milliseconds: 600));
    expect(find.text('Settings'), findsNothing);
    expect(find.textContaining('Connect'), findsWidgets);
  });
}
