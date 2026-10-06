import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'tree_model.dart';
import 'tree_palette.dart';

/// Points along a limb: 13 samples of position, angle and width.
class LimbFrame {
  LimbFrame(this.x, this.y, this.a, this.w, this.g);

  static const samples = 12;
  final Float64List x, y, a, w;

  /// Growth of this limb, 0 to 1.
  final double g;

  int get length => x.length;

  /// Interpolated point at [s] (0 to 1) along the drawn length.
  ({double x, double y, double a, double w}) at(double s) {
    final f = s.clamp(0.0, 1.0) * (length - 1);
    final i = math.min(length - 2, f.floor());
    final t = f - i;
    double l(Float64List v) => v[i] + (v[i + 1] - v[i]) * t;
    return (x: l(x), y: l(y), a: l(a), w: l(w));
  }

  /// Port of the design page's `polyline`.
  factory LimbFrame.grow(
    double x,
    double y,
    double a0,
    double len,
    double w0,
    double w1,
    double curv,
    double grow,
    double sway,
  ) {
    const n = samples;
    final xs = Float64List(n + 1),
        ys = Float64List(n + 1),
        as = Float64List(n + 1),
        ws = Float64List(n + 1);
    final step = len * grow / n;
    for (var i = 0; i <= n; i++) {
      final s = i / n;
      final a = a0 + curv * s * grow + sway * s * s;
      xs[i] = x;
      ys[i] = y;
      as[i] = a;
      ws[i] = (w0 + (w1 - w0) * s) * (.45 + .55 * grow);
      x += math.cos(a) * step;
      y += math.sin(a) * step;
    }
    return LimbFrame(xs, ys, as, ws, grow);
  }
}

class LeafInstance {
  LeafInstance(
    this.x,
    this.y,
    this.angle,
    this.len,
    this.bucket,
    this.variant,
    this.limb,
    this.leaf,
  );

  /// Stem position and pointing angle, in tree units.
  final double x, y, angle, len;
  final int bucket, variant;

  /// Indices into [TreeModel.limbs] and that limb's leaves; -1 for leaves
  /// lying on the ground.
  final int limb, leaf;

  double get cx => x + math.cos(angle) * len * .5;
  double get cy => y + math.sin(angle) * len * .5;
}

class BlossomInstance {
  BlossomInstance(this.x, this.y, this.r, this.rot, this.variant, this.limb);
  final double x, y, r, rot;
  final int variant, limb;
}

/// One frame of the tree: every limb, leaf and blossom placed for a given
/// growth, time and wind.
class TreeFrame {
  TreeFrame({
    required this.limbs,
    required this.roots,
    required this.leaves,
    required this.blossoms,
    required this.gust,
    required this.grow,
    required this.t,
    required this.wind,
  });

  /// Indexed like [TreeModel.limbs]; null for limbs not yet grown.
  final List<LimbFrame?> limbs;
  final List<LimbFrame> roots;
  final List<LeafInstance> leaves;
  final List<BlossomInstance> blossoms;

  /// Overall wind offset this frame; drives petals and grass.
  final double gust;
  final double grow, t, wind;
}

/// Identifies one leaf, for hover.
typedef LeafRef = ({int limb, int leaf});

class TreeGeometry {
  /// Port of the design page's frame setup. [wind] is 0 (calm) to about
  /// 1.25 (gusty); [still] freezes motion (reduced motion, print).
  static TreeFrame compute(
    TreeModel m, {
    required double grow,
    required double t,
    double wind = .55,
    bool still = false,
    LeafRef? hover,
  }) {
    final w = still ? 0.0 : wind;
    final gust = .5 + .5 * math.sin(t * .37) * math.sin(t * .13 + 1);
    final w0 =
        w *
        (.5 * math.sin(t * 1.05) + .25 * math.sin(t * 2.3 + .7) + .5 * gust);
    final g = grow;

    final limbs = List<LimbFrame?>.filled(m.limbs.length, null);
    final tr = m.trunk;
    final tg = (g / tr.dur).clamp(0.0, 1.0);
    limbs[0] = LimbFrame.grow(
      trunkBaseX,
      trunkBaseY,
      -math.pi / 2,
      tr.len,
      tr.w0,
      tr.w1,
      tr.curv,
      math.max(tg, .02),
      w0 * .03,
    );

    for (var i = 1; i < m.limbs.length; i++) {
      final l = m.limbs[i];
      final par = limbs[l.parent];
      if (par == null || par.g < l.at) continue;
      final lg = ((g - l.birth) / l.dur).clamp(0.0, 1.0);
      if (lg <= 0) continue;
      final p = par.at(l.at / par.g);
      final sway =
          w0 * .14 * l.flex +
          (still ? 0 : .045 * w * math.sin(t * 1.6 + l.phase));
      limbs[i] = LimbFrame.grow(
        p.x,
        p.y,
        p.a + l.side * l.spread,
        l.len,
        l.w0,
        l.w1,
        l.curv,
        lg,
        sway,
      );
    }

    final roots = <LimbFrame>[
      if (tg > .2)
        for (final r in m.roots)
          LimbFrame.grow(
            trunkBaseX,
            trunkBaseY - 2,
            r.a,
            r.len,
            16,
            1,
            r.curv,
            ((tg - .2) / .5).clamp(0.0, 1.0),
            0,
          ),
    ];

    final leaves = <LeafInstance>[];
    final blossoms = <BlossomInstance>[];
    if (g > .7) {
      for (final f in m.fallen) {
        leaves.add(
          LeafInstance(
            f.x,
            hillY(f.x) - 1,
            f.rot,
            f.len,
            ageBuckets - 1,
            f.variant,
            -1,
            -1,
          ),
        );
      }
    }
    for (var i = 1; i < m.limbs.length; i++) {
      final lf = limbs[i];
      if (lf == null) continue;
      final l = m.limbs[i];
      for (var j = 0; j < l.leaves.length; j++) {
        final leaf = l.leaves[j];
        if (leaf.s > lf.g) continue;
        final pop = ((lf.g - leaf.s) / .08).clamp(0.0, 1.0);
        final p = lf.at(leaf.s / lf.g);
        final pa =
            p.a +
            leaf.side * leaf.off +
            (still ? 0 : .32 * w * math.sin(t * 3.1 + leaf.phase)) +
            w0 * .22;
        final na = p.a + leaf.side * math.pi / 2;
        final big = hover != null && hover.limb == i && hover.leaf == j
            ? 1.7
            : 1.0;
        leaves.add(
          LeafInstance(
            p.x + math.cos(na) * p.w * .35,
            p.y + math.sin(na) * p.w * .35,
            pa,
            leaf.len * pop * big,
            bucketForAge(leaf.age),
            leaf.variant,
            i,
            j,
          ),
        );
      }
      if (l.blossoms.isNotEmpty && lf.g >= 1) {
        final bloom = ((g - l.birth - l.dur) / .06).clamp(0.0, 1.0);
        for (final b in l.blossoms) {
          final p = lf.at(b.s);
          final na = p.a + b.side * math.pi / 2;
          blossoms.add(
            BlossomInstance(
              p.x + math.cos(na) * b.d,
              p.y + math.sin(na) * b.d,
              b.r * bloom,
              b.rot + (still ? 0 : .2 * math.sin(t * 2 + b.rot)),
              b.variant,
              i,
            ),
          );
        }
      }
    }

    return TreeFrame(
      limbs: limbs,
      roots: roots,
      leaves: leaves,
      blossoms: blossoms,
      gust: w0,
      grow: g,
      t: t,
      wind: w,
    );
  }

  /// Bounds of the fully grown, windless tree in tree units, with the
  /// ground below it. Used to fit the view.
  static Rect bounds(TreeModel m) {
    final f = compute(m, grow: 1, t: 0, still: true);
    var l = trunkBaseX - 260.0, r = trunkBaseX + 260.0;
    var top = trunkBaseY - 300.0;
    const bottom = trunkBaseY + 40.0;
    void add(double x, double y, double pad) {
      l = math.min(l, x - pad);
      r = math.max(r, x + pad);
      top = math.min(top, y - pad);
    }

    for (final lf in f.limbs) {
      if (lf == null) continue;
      for (var i = 0; i < lf.length; i++) {
        add(lf.x[i], lf.y[i], lf.w[i]);
      }
    }
    for (final leaf in f.leaves) {
      add(
        leaf.x + math.cos(leaf.angle) * leaf.len,
        leaf.y + math.sin(leaf.angle) * leaf.len,
        4,
      );
    }
    // Room for hanging tags beside the outermost limbs.
    return Rect.fromLTRB(l - 40, top - 30, r + 40, bottom);
  }
}
