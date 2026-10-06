import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'tree_model.dart';
import 'tree_palette.dart';

/// Leaf length and blossom radius the sprites are painted at, in sprite
/// units. Leaves are drawn at any size by scaling.
const leafLength = 110.0;
const flowerRadius = 44.0;

const _leafPad = 8.0;
const _leafCellH = 96.0;
const _flowerCell = flowerRadius * 2 + 16;

/// Pixels per sprite unit, so sprites stay crisp when scaled up on HiDPI.
const _k = 2.0;

class _LeafShape {
  const _LeafShape(this.w, this.b, this.mx, this.sh);
  final double w, b, mx, sh;
}

const _leafShapes = [
  _LeafShape(.17, -.05, .5, 1),
  _LeafShape(.14, .05, .56, -1),
  _LeafShape(.2, -.09, .44, -1),
  _LeafShape(.125, .02, .6, 1),
];
const leafVariants = 4;
const flowerVariants = 3;

/// Outline of leaf [variant] at length [len], stem at the origin pointing
/// along +x.
ui.Path leafPath(double len, int variant) {
  final v = _leafShapes[variant];
  final hw = len * v.w, b = len * v.b;
  return ui.Path()
    ..moveTo(0, 0)
    ..cubicTo(len * .1, -hw * 1.1, len * v.mx, -hw * 1.25 + b * .4, len, b)
    ..cubicTo(len * v.mx, hw * 1.15 + b * .4, len * .12, hw, 0, 0)
    ..close();
}

/// One petal of radius [r], base at the origin pointing along +x.
ui.Path petalPath(double r) => ui.Path()
  ..moveTo(0, 0)
  ..cubicTo(r * .15, -r * .55, r * 1.02, -r * .5, r * .96, 0)
  ..cubicTo(r * 1.02, r * .5, r * .15, r * .55, 0, 0)
  ..close();

/// The watercolour leaves and blossoms for one palette, painted once into
/// a single image so each frame draws them all with one `drawAtlas` call.
///
/// Leaves: [leafVariants] rows by [ageBuckets] columns. Blossoms: one row
/// of [flowerVariants] below.
class SpriteAtlas {
  SpriteAtlas._(this.image, this.paper);

  final ui.Image image;

  /// Paper grain, a 220-unit tile to repeat over the sky.
  final ui.Image paper;

  static final _cache = <String, Future<SpriteAtlas>>{};

  /// The atlas for [p], painted on first use and cached by palette id.
  static Future<SpriteAtlas> load(TreePalette p) =>
      _cache.putIfAbsent(p.id, () => _paint(p));

  ui.Rect leafRect(int bucket, int variant) => ui.Rect.fromLTWH(
    bucket * (leafLength + 2 * _leafPad) * _k,
    variant * _leafCellH * _k,
    (leafLength + 2 * _leafPad) * _k,
    _leafCellH * _k,
  );

  ui.Rect flowerRect(int variant) => ui.Rect.fromLTWH(
    variant * _flowerCell * _k,
    leafVariants * _leafCellH * _k,
    _flowerCell * _k,
    _flowerCell * _k,
  );

  /// Places a leaf sprite with its stem at ([x], [y]), pointing at
  /// [angle], [len] long.
  ui.RSTransform leafTransform(double x, double y, double angle, double len) =>
      ui.RSTransform.fromComponents(
        rotation: angle,
        scale: len / leafLength / _k,
        anchorX: _leafPad * _k,
        anchorY: _leafCellH / 2 * _k,
        translateX: x,
        translateY: y,
      );

  ui.RSTransform flowerTransform(double x, double y, double rot, double r) =>
      ui.RSTransform.fromComponents(
        rotation: rot,
        scale: r / flowerRadius / _k,
        anchorX: _flowerCell / 2 * _k,
        anchorY: _flowerCell / 2 * _k,
        translateX: x,
        translateY: y,
      );

  static Future<SpriteAtlas> _paint(TreePalette p) async {
    final w =
        (math.max(
                  ageBuckets * (leafLength + 2 * _leafPad),
                  flowerVariants * _flowerCell,
                ) *
                _k)
            .ceil();
    final h = ((leafVariants * _leafCellH + _flowerCell) * _k).ceil();
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    c.scale(_k);
    for (var v = 0; v < leafVariants; v++) {
      for (var b = 0; b < ageBuckets; b++) {
        c.save();
        c.translate(
          b * (leafLength + 2 * _leafPad) + _leafPad,
          v * _leafCellH + _leafCellH / 2,
        );
        _paintLeaf(
          c,
          p.ageColor(ageForBucket(b)),
          v,
          Mulberry32(b * 31 + v * 7 + 3),
        );
        c.restore();
      }
    }
    for (var f = 0; f < flowerVariants; f++) {
      c.save();
      c.translate(
        f * _flowerCell + _flowerCell / 2,
        leafVariants * _leafCellH + _flowerCell / 2,
      );
      _paintFlower(c, p, Mulberry32(f * 13 + 5));
      c.restore();
    }
    final image = await rec.endRecording().toImage(w, h);
    return SpriteAtlas._(image, await _paintPaper());
  }

  static Future<ui.Image> _paintPaper() {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final r = Mulberry32(99);
    final paint = ui.Paint();
    for (var i = 0; i < 2600; i++) {
      final g = r() < .5 ? 0 : 255;
      paint.color = ui.Color.fromARGB(
        ((.02 + r() * .05) * 255).round(),
        g,
        g,
        g,
      );
      c.drawRect(
        ui.Rect.fromLTWH(r() * 220, r() * 220, 1 + r() * 2, 1 + r() * 2),
        paint,
      );
    }
    return rec.endRecording().toImage(220, 220);
  }
}

ui.Color _mix(ui.Color a, ui.Color b, double t) => ui.Color.lerp(a, b, t)!;
ui.Color _a(ui.Color c, double alpha) => c.withValues(alpha: alpha);

ui.Paint _fill(ui.Color c, [double blur = 0]) {
  final p = ui.Paint()..color = c;
  if (blur > 0) p.maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blur);
  return p;
}

ui.Paint _stroke(ui.Color c, double width, [double blur = 0]) => _fill(c, blur)
  ..style = ui.PaintingStyle.stroke
  ..strokeWidth = width;

void _oval(
  ui.Canvas c,
  double x,
  double y,
  double rx,
  double ry,
  double rot,
  ui.Paint p,
) {
  c.save();
  c.translate(x, y);
  c.rotate(rot);
  c.drawOval(
    ui.Rect.fromCenter(center: ui.Offset.zero, width: rx * 2, height: ry * 2),
    p,
  );
  c.restore();
}

/// Port of the design page's `paintLeaf`: a wash, pooled pigment, a pale
/// highlight, speckles, veins, a soft edge and a midrib.
void _paintLeaf(ui.Canvas c, ui.Color col, int variant, Mulberry32 r) {
  const ls = leafLength;
  final v = _leafShapes[variant];
  final dark = _mix(col, const ui.Color(0xFF1C2C16), .42);
  final deep = _mix(col, const ui.Color(0xFF121E0C), .62);
  final light = _mix(col, const ui.Color(0xFFF8F6D2), .5);
  final hw = ls * v.w;
  double my(double x) {
    final t = x / ls;
    return 2 * t * (1 - t) * ls * v.b * .4 + t * t * ls * v.b;
  }

  final outline = leafPath(ls, variant);
  c.drawPath(outline, _fill(_a(col, .72), .8));

  c.save();
  c.clipPath(outline);
  final shade = ui.Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(ls * .5, ls * v.b * .4, ls, ls * v.b)
    ..lineTo(ls, v.sh * hw * 2)
    ..lineTo(0, v.sh * hw * 2)
    ..close();
  c.drawPath(shade, _fill(_a(dark, .38), 2));
  for (var i = 0; i < 6; i++) {
    final x = ls * (.15 + r() * .7);
    final y = (r() - .5) * hw * 1.4;
    final rx = ls * (.05 + r() * .08);
    final ry = hw * (.25 + r() * .3);
    final rot = (r() - .5) * .4;
    final tone = r() < .55 ? dark : light;
    _oval(c, x, y, rx, ry, rot, _fill(_a(tone, .14 + r() * .14), 2));
  }
  _oval(
    c,
    ls * .5,
    -v.sh * hw * .42,
    ls * .28,
    hw * .3,
    v.b * .4,
    _fill(_a(light, .6), 3),
  );
  final speck = ui.Paint();
  for (var i = 0; i < 90; i++) {
    speck.color = _a(deep, .04 + r() * .09);
    c.drawRect(
      ui.Rect.fromLTWH(
        r() * ls,
        (r() - .5) * hw * 2.4,
        .8 + r() * 1.4,
        .8 + r() * 1.4,
      ),
      speck,
    );
  }
  final vein = _stroke(_a(light, .4), .9);
  for (var i = 1; i < 7; i++) {
    final x = ls * (.06 + i * .11), y = my(x);
    for (final sg in const [-1, 1]) {
      c.drawPath(
        ui.Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(
            x + ls * .05,
            y + sg * hw * .45,
            x + ls * .12,
            y + sg * hw * .75,
          ),
        vein,
      );
    }
  }
  c.restore();

  c.drawPath(outline, _stroke(_a(dark, .5), 1.4, .6));
  final rib = ui.Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(ls * .45, my(ls * .45) * .9, ls * .9, my(ls * .9));
  c.drawPath(rib, _stroke(_a(light, .8), 1.8));
  c.drawPath(rib, _stroke(_a(dark, .3), .6));
}

/// Port of the design page's `paintFlower`: five washed petals and a
/// stamen centre.
void _paintFlower(ui.Canvas c, TreePalette p, Mulberry32 r) {
  const fr = flowerRadius;
  final col = p.blossom;
  final light = _mix(col, const ui.Color(0xFFFFF6F8), .6);
  final dark = _mix(col, const ui.Color(0xFF601234), .35);
  final a0 = r() * tau;
  for (var k = 0; k < 5; k++) {
    c.save();
    c.rotate(a0 + k * tau / 5 + (r() - .5) * .25);
    final rr = fr * (.85 + r() * .15);
    final petal = petalPath(rr);
    c.drawPath(
      petal,
      _fill(col, .8)
        ..shader = ui.Gradient.linear(
          ui.Offset.zero,
          ui.Offset(rr, 0),
          [_a(col, .78), _a(col, .45), _a(light, .5)],
          [0, .6, 1],
        ),
    );
    _oval(
      c,
      rr * .58,
      -rr * .12,
      rr * .24,
      rr * .13,
      0,
      _fill(_a(light, .5), 2),
    );
    c.drawPath(petal, _stroke(_a(dark, .42), 1.2, .5));
    c.drawLine(
      ui.Offset(rr * .15, 0),
      ui.Offset(rr * .62, (r() - .5) * 3),
      _stroke(_a(dark, .25), .8),
    );
    c.restore();
  }
  c.drawCircle(
    ui.Offset.zero,
    fr * .2,
    _fill(_a(_mix(p.amber, col, .3), .8), 1),
  );
  final stamen = _stroke(_a(dark, .45), .8);
  final tip = _fill(_a(p.amber, .95));
  for (var i = 0; i < 12; i++) {
    final a = r() * tau, l = fr * (.22 + r() * .14);
    final end = ui.Offset(math.cos(a) * l, math.sin(a) * l);
    c.drawLine(ui.Offset.zero, end, stamen);
    c.drawCircle(end, 1.7, tip);
  }
}
