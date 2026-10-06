import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'sprite_atlas.dart';
import 'tree_model.dart';
import 'tree_painter.dart';
import 'tree_palette.dart';

/// Hovered leaf, with its centre in the widget's coordinates.
class LeafHover {
  const LeafHover(this.limb, this.leaf, this.position);
  final LimbSpec limb;
  final LeafSpec leaf;
  final Offset position;
}

/// A live, swaying watercolour tree.
///
/// Wind runs off a [Ticker] that only repaints the canvas. Reduced motion
/// (from [MediaQuery.disableAnimations] or [still]) freezes it.
class TreeView extends StatefulWidget {
  const TreeView({
    super.key,
    required this.model,
    required this.palette,
    this.grow = 1,
    this.wind = .55,
    this.still = false,
    this.labels = TreeLabels.full,
    this.petals = true,
    this.sky = true,
    this.viewBox,
    this.zoom = 1,
    this.pan = Offset.zero,
    this.focus,
    this.selected,
    this.onHover,
    this.onLimbTap,
    this.onPan,
  });

  final TreeModel model;
  final TreePalette palette;
  final double grow;

  /// 0 is calm, 1.25 is gusty.
  final double wind;
  final bool still;
  final TreeLabels labels;
  final bool petals;
  final bool sky;
  final Rect? viewBox;
  final double zoom;
  final Offset pan;
  final TreeFocus? focus;
  final String? selected;

  /// Called with the leaf under the pointer, or null when it leaves.
  final ValueChanged<LeafHover?>? onHover;

  /// Called when a branch tag or a leaf is tapped.
  final ValueChanged<LimbSpec>? onLimbTap;

  /// Called while dragging, with the drag delta in pixels.
  final ValueChanged<Offset>? onPan;

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _clock = ValueNotifier<double>(0);
  SpriteAtlas? _atlas;
  TreeScene? _scene;
  LeafHit? _hover;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _clock.value = elapsed.inMicroseconds / 1e6;
    });
    _loadAtlas();
  }

  Future<void> _loadAtlas() async {
    final palette = widget.palette;
    final ready = SpriteAtlas.cached(palette);
    if (ready != null) {
      // Called from initState or didUpdateWidget; a build follows.
      _atlas = ready;
      return;
    }
    final atlas = await SpriteAtlas.load(palette);
    if (!mounted || palette != widget.palette) return;
    setState(() => _atlas = atlas);
  }

  @override
  void didUpdateWidget(TreeView old) {
    super.didUpdateWidget(old);
    if (old.palette != widget.palette) {
      _scene?.clearTextCache();
      _loadAtlas();
    }
  }

  bool get _still =>
      widget.still || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  void _syncTicker() {
    final run =
        !_still && _atlas != null && TickerMode.valuesOf(context).enabled;
    if (run && !_ticker.isActive) {
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  TreeScene _sceneFor(SpriteAtlas atlas) {
    final s = _scene ??= TreeScene(
      model: widget.model,
      atlas: atlas,
      palette: widget.palette,
    );
    s
      ..model = widget.model
      ..atlas = atlas
      ..palette = widget.palette
      ..grow = widget.grow
      ..wind = widget.wind
      ..still = _still
      ..labels = widget.labels
      ..petals = widget.petals
      ..sky = widget.sky
      ..viewBox = widget.viewBox
      ..zoom = widget.zoom
      ..pan = widget.pan
      ..focus = widget.focus
      ..selected = widget.selected
      ..collectHits = widget.onHover != null || widget.onLimbTap != null
      ..hover = _hover == null
          ? null
          : (limb: _hover!.limb, leaf: _hover!.leaf);
    return s;
  }

  LeafHit? _nearest(Offset p) {
    final s = _scene;
    if (s == null) return null;
    LeafHit? best;
    var bd = 196.0; // 14 px
    for (final h in s.hits) {
      final d = (h.x - p.dx) * (h.x - p.dx) + (h.y - p.dy) * (h.y - p.dy);
      if (d < bd) {
        bd = d;
        best = h;
      }
    }
    return best;
  }

  void _onHover(Offset p) {
    final hit = _nearest(p);
    if (hit?.limb == _hover?.limb && hit?.leaf == _hover?.leaf) return;
    setState(() => _hover = hit);
    final m = widget.model;
    widget.onHover?.call(
      hit == null
          ? null
          : LeafHover(
              m.limbs[hit.limb],
              m.limbs[hit.limb].leaves[hit.leaf],
              Offset(hit.x, hit.y),
            ),
    );
  }

  void _onExit() {
    if (_hover == null) return;
    setState(() => _hover = null);
    widget.onHover?.call(null);
  }

  void _onTap(Offset p) {
    final s = _scene;
    if (s == null || widget.onLimbTap == null) return;
    final m = widget.model;
    final tag = s.limbAt(p);
    if (tag != null && tag > 0) {
      widget.onLimbTap!(m.limbs[tag]);
      return;
    }
    final hit = _nearest(p);
    if (hit != null && m.limbs[hit.limb].isBranch) {
      widget.onLimbTap!(m.limbs[hit.limb]);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final atlas = _atlas;
    _syncTicker();
    if (atlas == null) {
      return ColoredBox(color: widget.palette.skyBottom);
    }
    final scene = _sceneFor(atlas);
    Widget canvas = RepaintBoundary(
      child: CustomPaint(
        painter: _ClockedPainter(scene, _clock),
        size: Size.infinite,
      ),
    );
    if (widget.onHover != null) {
      canvas = MouseRegion(
        onHover: (e) => _onHover(e.localPosition),
        onExit: (_) => _onExit(),
        child: canvas,
      );
    }
    if (widget.onLimbTap != null || widget.onPan != null) {
      canvas = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => _onTap(d.localPosition),
        onPanUpdate: widget.onPan == null
            ? null
            : (d) => widget.onPan!(d.delta),
        child: canvas,
      );
    }
    return canvas;
  }
}

/// Copies the ticker time into the scene before each paint.
class _ClockedPainter extends TreePainter {
  _ClockedPainter(super.scene, this.clock) : super(repaint: clock);
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    scene.time = clock.value;
    super.paint(canvas, size);
  }

  @override
  bool shouldRepaint(TreePainter old) => true;
}
