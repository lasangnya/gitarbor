import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/tree/sample_tree.dart';
import 'package:gitarbor/tree/tree_painter.dart';
import 'package:gitarbor/tree/tree_view.dart';
import 'package:gitarbor/ui/live_screen.dart';

import 'test_app.dart';

void main() {
  Future<void> open(WidgetTester tester, double w, double h) async {
    setSize(tester, w, h);
    await tester.pumpWidget(testApp(LiveScreen(snapshot: sampleSnapshot())));
    await tester.pump(const Duration(milliseconds: 100));
  }

  TreeView tree(WidgetTester t) => t.widget<TreeView>(find.byType(TreeView));
  double grow(WidgetTester t) =>
      t.widget<Slider>(find.byType(Slider).last).value;

  Future<void> key(WidgetTester t, LogicalKeyboardKey k) async {
    await t.sendKeyEvent(k);
    await t.pump(const Duration(milliseconds: 50));
  }

  testWidgets('zoom, fit and labels', (tester) async {
    await open(tester, 1280, 800);
    expect(tree(tester).zoom, 1);
    await key(tester, LogicalKeyboardKey.numpadAdd);
    expect(tree(tester).zoom, greaterThan(1));
    await key(tester, LogicalKeyboardKey.numpadAdd);
    await key(tester, LogicalKeyboardKey.minus);
    final z = tree(tester).zoom;
    expect(z, greaterThan(1));
    await key(tester, LogicalKeyboardKey.digit0);
    expect(tree(tester).zoom, 1);
    expect(tree(tester).labels, TreeLabels.full);
    await key(tester, LogicalKeyboardKey.keyL);
    expect(tree(tester).labels, TreeLabels.none);
    await key(tester, LogicalKeyboardKey.keyL);
    expect(tree(tester).labels, TreeLabels.full);
  });

  testWidgets('arrows scrub and space replays', (tester) async {
    await open(tester, 1280, 800);
    expect(grow(tester), 1);
    await key(tester, LogicalKeyboardKey.arrowLeft);
    expect(grow(tester), closeTo(.95, .001));
    await key(tester, LogicalKeyboardKey.arrowLeft);
    expect(grow(tester), closeTo(.90, .001));
    await key(tester, LogicalKeyboardKey.arrowRight);
    expect(grow(tester), closeTo(.95, .001));
    await key(tester, LogicalKeyboardKey.space);
    expect(grow(tester), lessThan(.5));
    await pumpFor(tester, const Duration(seconds: 8));
    expect(grow(tester), 1);
  });

  testWidgets('Escape clears the author focus', (tester) async {
    await open(tester, 1280, 800);
    // Tap the first author tile in the rail.
    final tile = find.descendant(
      of: find.byKey(const Key('rail')),
      matching: find.byType(InkWell),
    );
    await tester.tap(tile.first);
    await tester.pump();
    expect(tree(tester).focus, isNotNull);
    await key(tester, LogicalKeyboardKey.escape);
    expect(tree(tester).focus, isNull);
  });

  testWidgets('phone starts without tags and Tags toggles them', (
    tester,
  ) async {
    await open(tester, 390, 844);
    expect(tree(tester).labels, TreeLabels.none);
    await tester.tap(find.text('Tags'));
    await tester.pump();
    expect(tree(tester).labels, TreeLabels.compact);
    await tester.tap(find.text('Tags'));
    await tester.pump();
    expect(tree(tester).labels, TreeLabels.none);
  });

  testWidgets('the tree has a semantics label', (tester) async {
    await open(tester, 1280, 800);
    expect(
      find.bySemanticsLabel(RegExp(r'^Tree of .+: \d+ branches')),
      findsOneWidget,
    );
  });
}
