import 'dart:typed_data';
import 'dart:ui' as ui;

import '../tree/sprite_atlas.dart';
import '../tree/tree_model.dart';
import '../tree/tree_painter.dart';
import '../tree/tree_palette.dart';

/// Paints the frozen tree for the print plate into a PNG.
///
/// [widthPx] by [heightPx] pixels; at 200 dpi an A3 tree area of about
/// 25 by 26 cm is roughly 2000 by 2050 pixels. The tree is fitted to its own
/// bounds with no sky, so the plate's paper shows through.
Future<Uint8List> renderPlateTree(
  TreeModel model, {
  required int widthPx,
  required int heightPx,
  TreeInk ink = TreeInk.ink,
  TreeLabels labels = TreeLabels.numbered,
}) async {
  final atlas = await SpriteAtlas.load(TreePalette.print);
  final scene = TreeScene(
    model: model,
    atlas: atlas,
    palette: TreePalette.print,
    print: true,
    ink: ink,
    labels: labels,
    still: true,
    petals: false,
    sky: false,
  );
  final rec = ui.PictureRecorder();
  final canvas = ui.Canvas(rec);
  TreePainter(
    scene,
  ).paint(canvas, ui.Size(widthPx.toDouble(), heightPx.toDouble()));
  final image = await rec.endRecording().toImage(widthPx, heightPx);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}
