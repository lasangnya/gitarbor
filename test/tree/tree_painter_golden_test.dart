import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/tree/sample_tree.dart';
import 'package:gitarbor/tree/sprite_atlas.dart';
import 'package:gitarbor/tree/tree_model.dart';
import 'package:gitarbor/tree/tree_painter.dart';
import 'package:gitarbor/tree/tree_palette.dart';

void main() {
  final model = TreeModelBuilder().build(sampleSnapshot());

  Future<void> golden(
    WidgetTester tester,
    String file,
    TreePalette palette, {
    bool print = false,
    TreeInk ink = TreeInk.color,
    TreeLabels labels = TreeLabels.full,
  }) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final atlas = (await tester.runAsync(() => SpriteAtlas.load(palette)))!;
    final scene = TreeScene(
      model: model,
      atlas: atlas,
      palette: palette,
      print: print,
      ink: ink,
      labels: labels,
      still: true,
    )..time = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: TreePainter(scene),
            size: const Size(1280, 800),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/$file.png'),
    );
  }

  testWidgets('day', (t) => golden(t, 'tree_day', TreePalette.day));
  testWidgets('night', (t) => golden(t, 'tree_night', TreePalette.night));
  testWidgets(
    'print',
    (t) => golden(
      t,
      'tree_print',
      TreePalette.print,
      print: true,
      ink: TreeInk.ink,
      labels: TreeLabels.numbered,
    ),
  );

  testWidgets('sprite atlas', (tester) async {
    final atlas = (await tester.runAsync(
      () => SpriteAtlas.load(TreePalette.day),
    ))!;
    final img = atlas.image;
    tester.view.physicalSize = Size(
      img.width.toDouble(),
      img.height.toDouble(),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepaintBoundary(
        child: ColoredBox(
          color: const Color(0xFF808080),
          child: RawImage(image: img),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/sprite_atlas.png'),
    );
  });
}
