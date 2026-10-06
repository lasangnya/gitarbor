import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/print/plate_pdf.dart';
import 'package:gitarbor/print/print_screen.dart';
import 'package:gitarbor/tree/sample_tree.dart';
import 'package:gitarbor/tree/tree_model.dart';
import 'package:gitarbor/ui/theme.dart';
import 'package:pdf/pdf.dart';

void main() {
  final snap = sampleSnapshot();
  final model = TreeModelBuilder().build(snap);

  test('formatFor matches the paper', () {
    expect(formatFor(PaperSize.a3), PdfPageFormat.a3);
    expect(formatFor(PaperSize.a4), PdfPageFormat.a4);
    expect(formatFor(PaperSize.letter), PdfPageFormat.letter);
    for (final p in PaperSize.values) {
      expect(formatFor(p).height, greaterThan(formatFor(p).width));
    }
  });

  test('plateFileName', () {
    expect(plateFileName(snap, PaperSize.a3), 'gitarbor-example-lantern-a3.pdf');
    expect(
      plateFileName(snap, PaperSize.letter),
      'gitarbor-example-lantern-letter.pdf',
    );
  });

  test('plateKey lists every branch limb in limb-number order', () {
    final key = plateKey(model);
    final limbs = model.limbs.where((l) => l.isBranch).toList();
    expect(key, hasLength(10));
    expect(key.map((e) => e.number), [for (var i = 1; i <= 10; i++) i]);
    for (final e in key) {
      final l = limbs.firstWhere((l) => l.number == e.number);
      expect(e.name, l.name);
      expect(e.commits, l.branch!.commitCount);
      expect(e.status, l.branch!.status);
    }
    expect(key.map((e) => e.name).toSet(), snap.branches.map((b) => b.name).toSet());
  });

  testWidgets('buildPlatePdf makes a PDF for every paper', (tester) async {
    for (final p in PaperSize.values) {
      final bytes = (await tester.runAsync(
        () => buildPlatePdf(
          snap,
          model,
          PlateOptions(paper: p),
          collected: DateTime(2026, 10, 5),
        ),
      ))!;
      expect(bytes, isNotEmpty);
      expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');
    }
  });

  testWidgets('PrintScreen shows settings and actions at 1280x800', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(GitarborTokens.day, Brightness.light),
        home: PrintScreen(snapshot: snap),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Print settings'), findsOneWidget);
    for (final s in [
      'PAPER',
      'INK',
      'BRANCH NAMES',
      'A3',
      'A4',
      'Letter',
      'Full colour',
      'Botanical ink',
      'Line only',
      'Numbered key',
      'Tags on limbs',
      'Export PDF',
      'Print',
    ]) {
      expect(find.text(s), findsWidgets, reason: s);
    }
    expect(find.widgetWithText(FilledButton, 'Export PDF'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Print'), findsOneWidget);
    // Leave without a pending debounce timer.
    await tester.pumpWidget(const SizedBox());
  });
}
