import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../data/models/repo_models.dart';
import 'sprite_atlas.dart';
import 'tree_geometry.dart';
import 'tree_model.dart';
import 'tree_palette.dart';

enum TreeLabels { none, compact, full, numbered }

enum TreeInk { color, ink, line }

/// Which limbs stay at full strength; the rest fade back.
sealed class TreeFocus {
  const TreeFocus();
}

class AuthorFocus extends TreeFocus {
  const AuthorFocus(this.login);
  final String login;
}

class BranchFocus extends TreeFocus {
  const BranchFocus(this.name);
  final String name;
}

class LeafHit {
  const LeafHit(this.x, this.y, this.limb, this.leaf);

  /// Leaf centre in canvas pixels.
  final double x, y;
  final int limb, leaf;
}

/// Mutable state shared by the tree widget and its painter. The widget
/// changes fields and repaints; the painter writes back [hits] and the
/// view transform for hit testing.
class TreeScene {
  TreeScene({
    required this.model,
    required this.atlas,
    required this.palette,
    this.print = false,
    this.ink = TreeInk.color,
    this.labels = TreeLabels.full,
    this.grow = 1,
    this.wind = .55,
    this.still = false,
    this.petals = true,
    this.sky = true,
    this.viewBox,
    this.zoom = 1,
    this.pan = Offset.zero,
  });

  TreeModel model;
  SpriteAtlas atlas;
  TreePalette palette;
  bool print;
  TreeInk ink;
  TreeLabels labels;
  double grow;
  double wind;
  bool still;
  bool petals;
  bool sky;

  /// Tree-unit rectangle fitted into the canvas; defaults to the tree's
  /// bounds.
  Rect? viewBox;
  double zoom;
  Offset pan;
  TreeFocus? focus;
  String? selected;
  LeafRef? hover;
  bool collectHits = false;

  /// Seconds since the scene started; drives the wind.
  double time = 0;

  // Written by the painter.
  final List<LeafHit> hits = [];
  final List<TagBox> tags = [];
  double scale = 1;
  Offset origin = Offset.zero;
  late Rect _fit = TreeGeometry.bounds(model);
  TreeModel? _fitFor;

  final _petals = <_Petal>[];
  final _rand = math.Random(7);
  double _lastTime = 0;
  final _text = <String, TextPainter>{};

  Rect get fitBox {
    if (_fitFor != model) {
      _fit = TreeGeometry.bounds(model);
      _fitFor = model;
    }
    return _fit;
  }

  double dimFor(LimbSpec l) {
    final f = focus;
    if (f == null) return 1;
    if (f is AuthorFocus) return l.branch?.author == f.login ? 1 : .2;
    if (f is BranchFocus) return l.name == f.name && l.isBranch ? 1 : .2;
    return 1;
  }

  /// Converts a canvas point to tree units.
  Offset toTree(Offset p) => (p - origin) / scale;

  /// The limb whose drawn tag or tip is nearest [p] (canvas pixels).
  int? limbAt(Offset p) {
    for (final t in tags) {
      if (t.box.inflate(4).contains(p)) return t.limb;
    }
    return null;
  }

  TextPainter text(String s, TextStyle style) {
    final key =
        '${style.fontFamily}|${style.fontSize}|${style.fontWeight}|'
        '${style.color?.toARGB32()}|$s';
    return _text.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(text: s, style: style),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  void clearTextCache() => _text.clear();
}

class _Petal {
  _Petal(this.x, this.y, this.rot);
  double x, y, rot, vx = 0, life = 0;
}

/// A drawn tag, for tap and hover hit testing.
class TagBox {
  TagBox(this.limb, this.box);
  final int limb;
  final Rect box;
}

/// Paints a [TreeScene]: sky and paper, ground, bark, leaves and blossoms
/// from the sprite atlas, grass, petals and hanging tags.
class TreePainter extends CustomPainter {
  TreePainter(this.scene, {super.repaint});

  final TreeScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = scene;
    final w = size.width, h = size.height;
    if (w <= 0 || h <= 0) return;
    final lineArt = sc.print && sc.ink != TreeInk.color;

    if (!sc.print && sc.sky) _sky(canvas, size);

    final vb = sc.viewBox ?? sc.fitBox;
    final s = math.min(w / vb.width, h / vb.height) * sc.zoom;
    final origin = Offset(
      (w - vb.width * s) / 2 - vb.left * s + sc.pan.dx,
      (h - vb.height * s) / 2 - vb.top * s + sc.pan.dy,
    );
    sc.scale = s;
    sc.origin = origin;

    final f = TreeGeometry.compute(
      sc.model,
      grow: sc.grow,
      t: sc.time,
      wind: sc.wind,
      still: sc.still,
      hover: sc.hover,
    );
    final dt = (sc.time - sc._lastTime).clamp(0.0, .05);
    sc._lastTime = sc.time;

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(s);

    _ground(canvas, lineArt);
    final m = sc.model;
    for (final r in f.roots) {
      _limb(canvas, r, lineArt, trunk: false, cut: false, opacity: 1);
    }
    for (var i = m.limbs.length - 1; i >= 1; i--) {
      final lf = f.limbs[i];
      if (lf == null) continue;
      final l = m.limbs[i];
      _limb(
        canvas,
        lf,
        lineArt,
        trunk: false,
        cut: l.isPruned,
        opacity: sc.dimFor(l),
      );
    }
    _limb(
      canvas,
      f.limbs[0]!,
      lineArt,
      trunk: true,
      cut: false,
      opacity: sc.focus != null ? .55 : 1,
    );

    _leaves(canvas, f);
    _blossoms(canvas, f);
    if (!sc.print) _grass(canvas, f);
    if (sc.petals && !sc.still && !sc.print) _updatePetals(canvas, f, dt);
    canvas.restore();

    if (sc.collectHits) {
      sc.hits
        ..clear()
        ..addAll([
          for (final l in f.leaves)
            if (l.limb >= 0)
              LeafHit(
                origin.dx + l.cx * s,
                origin.dy + l.cy * s,
                l.limb,
                l.leaf,
              ),
        ]);
    }
    sc.tags.clear();
    if (sc.labels != TreeLabels.none && sc.grow > .55) {
      _labels(canvas, size, f);
    }
  }

  void _sky(Canvas c, Size size) {
    final p = scene.palette;
    final rect = Offset.zero & size;
    c.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
          p.skyTop,
          p.skyBottom,
        ]),
    );
    final glow = Offset(size.width * .8, size.height * .16);
    c.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          glow,
          math.min(size.width, size.height) * .4,
          [p.surface.withValues(alpha: .7), p.surface.withValues(alpha: 0)],
        ),
    );
    c.drawRect(
      rect,
      Paint()
        ..shader = ImageShader(
          scene.atlas.paper,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        ),
    );
  }

  void _ground(Canvas c, bool lineArt) {
    final p = scene.palette;
    if (scene.print) {
      final line = Path()..moveTo(200, hillY(200));
      for (var x = 210.0; x <= 800; x += 10) {
        line.lineTo(x, hillY(x));
      }
      c.drawPath(line, _stroke(p.ink.withValues(alpha: .85), 1.3));
      final hatch = Path();
      for (var x = 230.0; x <= 770; x += 8) {
        final y = hillY(x);
        hatch
          ..moveTo(x, y + 4)
          ..lineTo(x - 6, y + 11);
      }
      c.drawPath(hatch, _stroke(p.ink.withValues(alpha: .4), .7));
      return;
    }
    Path hill(double dy) {
      final path = Path()..moveTo(-1200, hillY(-1200) + dy);
      for (var x = -1200.0; x <= 2200; x += 20) {
        path.lineTo(x, math.min(hillY(x), 830) + dy + math.sin(x * .05) * 1.5);
      }
      return path
        ..lineTo(2200, 2000)
        ..lineTo(-1200, 2000)
        ..close();
    }

    final h0 = hill(0);
    c.drawPath(h0, Paint()..color = p.soil.withValues(alpha: .8));
    c.drawPath(
      hill(8),
      Paint()..color = Color.lerp(p.soil, p.moss, .3)!.withValues(alpha: .3),
    );
    c.drawPath(
      h0,
      _stroke(Color.lerp(p.soil, p.moss, .45)!.withValues(alpha: .4), 2.5),
    );
  }

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Port of the design page's `limb`: layered bark washes, a light ridge,
  /// a dark edge and, on the trunk, grain lines. Line art for print.
  void _limb(
    Canvas c,
    LimbFrame f,
    bool lineArt, {
    required bool trunk,
    required bool cut,
    required double opacity,
  }) {
    final p = scene.palette;
    final n = f.length;
    final seed = f.x[0] * .37 + f.y[0] * .11;
    Color o(Color col, [double a = 1]) =>
        col.withValues(alpha: col.a * a * opacity);

    Path outline(double wk, double sh) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final hw = f.w[i] * wk * (1 + .08 * math.sin(i * 2.1 + seed)) / 2;
        final nx = -math.sin(f.a[i]), ny = math.cos(f.a[i]);
        final x = f.x[i] + nx * (hw + sh), y = f.y[i] + ny * (hw + sh);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      final ex = f.x[n - 1], ey = f.y[n - 1], ea = f.a[n - 1];
      if (!cut) {
        final r = math.max(.1, f.w[n - 1] * wk / 2);
        path.arcTo(
          Rect.fromCircle(
            center: Offset(ex - math.sin(ea) * sh, ey + math.cos(ea) * sh),
            radius: r,
          ),
          ea + math.pi / 2,
          -math.pi,
          false,
        );
      }
      for (var i = n - 1; i >= 0; i--) {
        final hw = f.w[i] * wk * (1 + .08 * math.sin(i * 2.1 + seed + 1.3)) / 2;
        final nx = -math.sin(f.a[i]), ny = math.cos(f.a[i]);
        path.lineTo(f.x[i] - nx * (hw - sh), f.y[i] - ny * (hw - sh));
      }
      return path..close();
    }

    final darkB = Color.lerp(p.bark, p.ink, .35)!;
    final lightB = Color.lerp(p.bark, p.paper, .5)!;
    final base = outline(1, 0);
    if (lineArt) {
      c.drawPath(
        base,
        Paint()
          ..color = o(
            scene.ink == TreeInk.ink
                ? Color.lerp(p.bark, p.paper, .78)!
                : p.paper,
          ),
      );
      c.drawPath(base, _stroke(o(p.ink, .9), 1.1));
      final hatch = Path();
      for (var i = 1; i < n - 1; i++) {
        final nx = -math.sin(f.a[i]), ny = math.cos(f.a[i]), hw = f.w[i] / 2;
        if (hw < 2) continue;
        hatch
          ..moveTo(f.x[i] + nx * hw * .9, f.y[i] + ny * hw * .9)
          ..lineTo(
            f.x[i] + nx * hw * .2 + math.cos(f.a[i]) * 3,
            f.y[i] + ny * hw * .2 + math.sin(f.a[i]) * 3,
          );
      }
      c.drawPath(hatch, _stroke(o(p.ink, .45), .6));
    } else {
      c.drawPath(
        base,
        Paint()
          ..color = o(
            Color.lerp(p.bark, scene.print ? p.paper : p.skyBottom, .35)!,
          ),
      );
      c.drawPath(outline(.88, .8), Paint()..color = o(p.bark, .3));
      final shadow = Path()..moveTo(f.x[0], f.y[0]);
      for (var i = 1; i < n; i++) {
        shadow.lineTo(f.x[i], f.y[i]);
      }
      for (var i = n - 1; i >= 0; i--) {
        shadow.lineTo(
          f.x[i] - math.sin(f.a[i]) * f.w[i] * .48,
          f.y[i] + math.cos(f.a[i]) * f.w[i] * .48,
        );
      }
      c.drawPath(shadow..close(), Paint()..color = o(darkB, .3));
      final ridge = Path();
      for (var i = 0; i < n; i++) {
        final k = f.w[i] * .24;
        final x = f.x[i] + math.sin(f.a[i]) * k;
        final y = f.y[i] - math.cos(f.a[i]) * k;
        i == 0 ? ridge.moveTo(x, y) : ridge.lineTo(x, y);
      }
      c.drawPath(ridge, _stroke(o(lightB, .5), math.max(.8, f.w[0] * .13)));
      c.drawPath(base, _stroke(o(darkB, .4), .9));
      if (trunk) {
        final grain = _stroke(o(darkB, .32), 1.1);
        for (final off in const [-.3, -.05, .12, .32]) {
          final g = Path();
          for (var i = 1; i < math.min(10, n); i++) {
            final x =
                f.x[i] -
                math.sin(f.a[i]) * f.w[i] * off +
                math.sin(i * 1.7 + off * 9) * 1.4;
            final y = f.y[i] + math.cos(f.a[i]) * f.w[i] * off;
            i == 1 ? g.moveTo(x, y) : g.lineTo(x, y);
          }
          c.drawPath(g, grain);
        }
      }
    }
    if (cut) {
      final ew = f.w[n - 1];
      c.save();
      c.translate(f.x[n - 1], f.y[n - 1]);
      c.rotate(f.a[n - 1]);
      final ring = Rect.fromCenter(
        center: Offset.zero,
        width: ew * .44,
        height: ew * 1.04,
      );
      c.drawOval(ring, Paint()..color = o(Color.lerp(p.amber, p.paper, .55)!));
      c.drawOval(ring, _stroke(o(darkB, .85), 1));
      c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: ew * .22, height: ew * .56),
        _stroke(o(darkB, .45), .7),
      );
      c.restore();
    }
  }

  void _leaves(Canvas c, TreeFrame f) {
    final sc = scene;
    final m = sc.model;
    if (sc.print && sc.ink == TreeInk.line) {
      for (final l in f.leaves) {
        if (l.len < .5) continue;
        final op = l.limb > 0 ? sc.dimFor(m.limbs[l.limb]) : 1.0;
        c.save();
        c.translate(l.x, l.y);
        c.rotate(l.angle);
        c.drawPath(
          leafPath(l.len, l.variant),
          _stroke(sc.palette.ink.withValues(alpha: .85 * op), .6),
        );
        c.restore();
      }
      return;
    }
    final full = <RSTransform>[], fullRects = <Rect>[];
    final dim = <RSTransform>[], dimRects = <Rect>[];
    for (final l in f.leaves) {
      if (l.len < .5) continue;
      final faded = l.limb > 0 && sc.dimFor(m.limbs[l.limb]) < 1;
      (faded ? dim : full).add(
        sc.atlas.leafTransform(l.x, l.y, l.angle, l.len),
      );
      (faded ? dimRects : fullRects).add(
        sc.atlas.leafRect(l.bucket, l.variant),
      );
    }
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (full.isNotEmpty) {
      c.drawAtlas(sc.atlas.image, full, fullRects, null, null, null, paint);
    }
    if (dim.isNotEmpty) {
      c.drawAtlas(
        sc.atlas.image,
        dim,
        dimRects,
        null,
        null,
        null,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = const Color(0x33000000),
      );
    }
    if (sc.print && sc.ink == TreeInk.ink) {
      final edge = _stroke(sc.palette.ink.withValues(alpha: .7), .5);
      for (final l in f.leaves) {
        if (l.len < .5) continue;
        c.save();
        c.translate(l.x, l.y);
        c.rotate(l.angle);
        c.drawPath(leafPath(l.len, l.variant), edge);
        c.restore();
      }
    }
  }

  void _blossoms(Canvas c, TreeFrame f) {
    final sc = scene;
    if (f.blossoms.isEmpty) return;
    if (sc.print && sc.ink == TreeInk.line) {
      final edge = _stroke(sc.palette.ink.withValues(alpha: .85), .6);
      for (final b in f.blossoms) {
        if (b.r < .3) continue;
        for (var k = 0; k < 5; k++) {
          c.save();
          c.translate(b.x, b.y);
          c.rotate(b.rot + k * tau / 5);
          c.drawPath(petalPath(b.r), edge);
          c.restore();
        }
      }
      return;
    }
    final full = <RSTransform>[], fullRects = <Rect>[];
    final dim = <RSTransform>[], dimRects = <Rect>[];
    for (final b in f.blossoms) {
      if (b.r < .3) continue;
      final faded = sc.dimFor(sc.model.limbs[b.limb]) < 1;
      (faded ? dim : full).add(sc.atlas.flowerTransform(b.x, b.y, b.rot, b.r));
      (faded ? dimRects : fullRects).add(sc.atlas.flowerRect(b.variant));
    }
    if (full.isNotEmpty) {
      c.drawAtlas(
        sc.atlas.image,
        full,
        fullRects,
        null,
        null,
        null,
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    if (dim.isNotEmpty) {
      c.drawAtlas(
        sc.atlas.image,
        dim,
        dimRects,
        null,
        null,
        null,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = const Color(0x33000000),
      );
    }
  }

  void _grass(Canvas c, TreeFrame f) {
    final p = scene.palette;
    final path = Path();
    for (final b in scene.model.grass) {
      final y = hillY(b.x) + 2;
      final a =
          -math.pi / 2 + b.lean + f.wind * .25 * math.sin(f.t * 2.2 + b.phase);
      path
        ..moveTo(b.x, y)
        ..quadraticBezierTo(
          b.x + math.cos(a) * b.h * .3,
          y - b.h * .6,
          b.x + math.cos(a) * b.h,
          y + math.sin(a) * b.h,
        );
    }
    c.drawPath(
      path,
      _stroke(Color.lerp(p.moss, p.soil, .25)!.withValues(alpha: .9), 1.4),
    );
  }

  void _updatePetals(Canvas c, TreeFrame f, double dt) {
    final sc = scene;
    final petals = sc._petals;
    if (f.blossoms.isNotEmpty &&
        sc._rand.nextDouble() < dt * 1.6 &&
        petals.length < 24) {
      final b = f.blossoms[sc._rand.nextInt(f.blossoms.length)];
      petals.add(_Petal(b.x, b.y, sc._rand.nextDouble() * tau));
    }
    final paint = Paint()..color = sc.palette.blossom.withValues(alpha: .85);
    petals.removeWhere((pt) {
      pt.vx += ((f.gust * 50 + 14) - pt.vx) * dt;
      pt.x += pt.vx * dt;
      pt.y += (16 + 8 * math.sin(pt.life * 3)) * dt;
      pt.rot += dt * 2.4;
      pt.life += dt;
      c.save();
      c.translate(pt.x, pt.y);
      c.rotate(pt.rot * .5);
      c.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 6.8,
          height: (2 * math.cos(pt.rot).abs() + .4) * 2,
        ),
        paint,
      );
      c.restore();
      return pt.y >= hillY(pt.x) - 1 || pt.life >= 12;
    });
  }

  /// Hanging tags: the branch name and author on a card tied to the limb
  /// tip by a string. Tags on the same side are nudged apart so they don't
  /// overlap.
  void _labels(Canvas c, Size size, TreeFrame f) {
    final sc = scene;
    final p = sc.palette;
    final m = sc.model;
    final s = sc.scale, o = sc.origin;
    final numbered = sc.labels == TreeLabels.numbered;
    final compact = sc.labels == TreeLabels.compact;
    final fs = numbered
        ? math.max(8.0, size.width / 64)
        : compact
        ? 11.0
        : 12.0;
    final mono = TextStyle(
      fontFamily: 'IBM Plex Mono',
      fontWeight: FontWeight.w500,
      fontSize: fs,
      color: p.ink,
    );
    final ui2 = TextStyle(
      fontFamily: 'Bricolage Grotesque',
      fontSize: fs - 1,
      color: p.ink.withValues(alpha: .66),
    );

    final items =
        <
          ({int limb, Offset at, int side, String name, String sub, int rank})
        >[];
    final trunk = f.limbs[0]!;
    if (trunk.g >= 1) {
      final pt = trunk.at(.14);
      final n = m.snapshot.trunkCommits.length;
      items.add((
        limb: 0,
        at: Offset(o.dx + (pt.x + pt.w / 2) * s, o.dy + pt.y * s),
        side: 1,
        name: m.trunk.name,
        sub: '${n >= 300 ? '300+' : n} commits',
        rank: -1,
      ));
    }
    for (var i = 1; i < m.limbs.length; i++) {
      final l = m.limbs[i];
      final lf = f.limbs[i];
      if (!l.isBranch || lf == null || lf.g < .98) continue;
      final b = l.branch!;
      final author = b.author ?? 'unknown';
      items.add((
        limb: i,
        at: Offset(
          o.dx + lf.x[lf.length - 1] * s,
          o.dy + lf.y[lf.length - 1] * s,
        ),
        side: l.side,
        name: b.name,
        sub: b.status == BranchStatus.pruned
            ? '$author · closed, deleted'
            : '$author · ${b.commitCount}${b.deleted ? ' · deleted' : ''}',
        rank: l.authorRank,
      ));
    }

    if (numbered) {
      for (final it in items) {
        final r = fs * .95;
        final x = it.at.dx + it.side * r * 1.6, y = it.at.dy - r * .6;
        c.drawLine(
          it.at,
          Offset(x - it.side * r, y),
          _stroke(p.ink.withValues(alpha: .6), .8),
        );
        if (it.limb == 0) {
          final tp = sc.text(it.name, mono);
          tp.paint(c, Offset(it.at.dx + 6, it.at.dy - tp.height / 2));
          continue;
        }
        c.drawCircle(Offset(x, y), r, Paint()..color = p.paper);
        c.drawCircle(Offset(x, y), r, _stroke(p.ink, 1));
        final tp = sc.text('${m.limbs[it.limb].number}', mono);
        tp.paint(c, Offset(x - tp.width / 2, y - tp.height / 2 + .5));
      }
      return;
    }

    // Lay out boxes, then nudge each side's boxes apart top to bottom.
    final boxes = <({int idx, Rect box})>[];
    for (var k = 0; k < items.length; k++) {
      final it = items[k];
      final name = sc.text(it.name, mono);
      final sub = compact ? null : sc.text(it.sub, ui2);
      final dotW = it.rank >= 0 ? 14.0 : 0.0;
      final double bw =
          math.max(
            name.width + (compact ? dotW : 0),
            sub == null ? 0.0 : sub.width + dotW,
          ) +
          16;
      final bh = compact ? fs + 12 : fs * 2 + 18;
      final ax = it.at.dx + it.side * 18;
      final ay = it.at.dy - (compact ? 6 : 10);
      var bx = it.side > 0 ? ax : ax - bw;
      bx = bx.clamp(6.0, math.max(6.0, size.width - bw - 6)).toDouble();
      final by = (ay - bh / 2)
          .clamp(6.0, math.max(6.0, size.height - bh - 6))
          .toDouble();
      boxes.add((idx: k, box: Rect.fromLTWH(bx, by, bw, bh)));
    }
    boxes.sort((a, b) => a.box.top.compareTo(b.box.top));
    final placed = <Rect>[];
    final fixed = <int, Rect>{};
    for (final b in boxes) {
      var r = b.box;
      for (var guard = 0; guard < 40; guard++) {
        final hit = placed.where((q) => q.overlaps(r.inflate(2)));
        if (hit.isEmpty) break;
        final below = hit.map((q) => q.bottom).reduce(math.max) + 4;
        r = r.translate(0, below - r.top);
      }
      placed.add(r);
      fixed[b.idx] = r;
    }

    for (var k = 0; k < items.length; k++) {
      final it = items[k];
      final r = fixed[k]!;
      final op = it.limb == 0
          ? (sc.focus != null ? .4 : 1.0)
          : sc.dimFor(m.limbs[it.limb]);
      Color a(Color col, [double x = 1]) =>
          col.withValues(alpha: col.a * x * op);
      final sx = it.side > 0 ? r.left : r.right;
      final string = Path()
        ..moveTo(it.at.dx, it.at.dy)
        ..quadraticBezierTo(
          (it.at.dx + sx) / 2,
          math.max(it.at.dy, r.center.dy) + 6,
          sx,
          r.center.dy,
        );
      c.drawPath(string, _stroke(a(p.ink, .4), 1));
      c.drawCircle(it.at, 2, Paint()..color = a(p.ink, .55));
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(6));
      c.drawRRect(rr, Paint()..color = a(sc.print ? p.paper : p.surface, .95));
      final sel = sc.selected == it.name && it.limb != 0;
      c.drawRRect(
        rr,
        _stroke(
          sel ? a(p.blossom) : a(p.ink, sc.print ? .8 : .16),
          sel ? 2 : 1,
        ),
      );
      var tx = r.left + 8;
      final name = sc.text(it.name, mono.copyWith(color: a(p.ink)));
      if (compact) {
        if (it.rank >= 0) {
          c.drawCircle(
            Offset(tx + 4, r.center.dy),
            4,
            Paint()..color = a(p.authorColor(it.rank)),
          );
          tx += 14;
        }
        name.paint(c, Offset(tx, r.center.dy - name.height / 2));
      } else {
        name.paint(c, Offset(tx, r.top + 5));
        final yy = r.top + fs + 10;
        var sx2 = r.left + 8;
        if (it.rank >= 0) {
          c.drawCircle(
            Offset(r.left + 12, yy + (fs - 1) * .6),
            4,
            Paint()..color = a(p.authorColor(it.rank)),
          );
          sx2 = r.left + 22;
        }
        final sub = sc.text(it.sub, ui2.copyWith(color: a(p.ink, .66)));
        sub.paint(c, Offset(sx2, yy));
      }
      sc.tags.add(TagBox(it.limb, r));
    }
  }

  @override
  bool shouldRepaint(TreePainter old) => old.scene != scene;
}
