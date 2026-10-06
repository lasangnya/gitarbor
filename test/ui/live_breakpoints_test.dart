import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/tree/sample_tree.dart';
import 'package:gitarbor/ui/live_screen.dart';

import 'test_app.dart';

void main() {
  Future<void> open(WidgetTester tester, double w, double h) async {
    setSize(tester, w, h);
    await tester.pumpWidget(testApp(LiveScreen(snapshot: sampleSnapshot())));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('1280x800 shows the rail', (tester) async {
    await open(tester, 1280, 800);
    expect(find.byKey(const Key('rail')), findsOneWidget);
    expect(find.text('Authors · 6'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('1180x820 floats the Authors button, no rail', (tester) async {
    await open(tester, 1180, 820);
    expect(find.byKey(const Key('rail')), findsNothing);
    expect(find.textContaining('Authors ·'), findsOneWidget);
    expect(find.text('Print'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('390x844 shows the sheet tabs', (tester) async {
    await open(tester, 390, 844);
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Authors'), findsOneWidget);
    expect(find.text('Legend'), findsOneWidget);
    expect(find.byKey(const Key('rail')), findsNothing);
    await tester.tap(find.text('Legend'));
    await tester.pump();
    expect(find.text('Blossoms: merged branch'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
