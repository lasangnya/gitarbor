import 'package:flutter/material.dart';

import '../../data/models/repo_models.dart';
import '../theme.dart';

/// Sprig (active), flower (merged), dry leaf (stale) and cut stub (pruned),
/// from the design's `#i-*` symbols.
class StatusIcon extends StatelessWidget {
  const StatusIcon(this.status, {super.key, this.size = 18});

  final BranchStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StatusPainter(status, t)),
    );
  }
}

class _StatusPainter extends CustomPainter {
  _StatusPainter(this.status, this.t);
  final BranchStatus status;
  final GitarborTokens t;

  Path _leaf() => Path()
    ..moveTo(5, 19)
    ..cubicTo(6, 11, 11, 6, 19, 5)
    ..cubicTo(18, 13, 13, 18, 5, 19)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    switch (status) {
      case BranchStatus.active:
        canvas.drawPath(_leaf(), Paint()..color = t.sprout);
        canvas.drawLine(
          const Offset(5, 19),
          const Offset(13, 11),
          Paint()
            ..color = t.moss
            ..strokeWidth = 1.5,
        );
      case BranchStatus.stale:
        canvas.drawPath(
          _leaf(),
          Paint()..color = t.rust.withValues(alpha: .75),
        );
        canvas.drawLine(
          const Offset(5, 19),
          const Offset(13, 11),
          Paint()
            ..color = t.tree.bark
            ..strokeWidth = 1.5,
        );
      case BranchStatus.merged:
        final p = Paint()..color = t.blossom;
        for (final c in const [
          Offset(12, 6.5),
          Offset(17.2, 10.3),
          Offset(15.2, 16.4),
          Offset(8.8, 16.4),
          Offset(6.8, 10.3),
        ]) {
          canvas.drawCircle(c, 3.6, p);
        }
        canvas.drawCircle(const Offset(12, 12), 2.4, Paint()..color = t.amber);
      case BranchStatus.pruned:
        canvas.drawPath(
          Path()
            ..moveTo(3, 15)
            ..lineTo(14, 9)
            ..lineTo(16, 13)
            ..lineTo(5, 19)
            ..close(),
          Paint()..color = t.tree.bark.withValues(alpha: .8),
        );
        canvas.save();
        canvas.translate(15, 11);
        canvas.rotate(-28 * 3.14159265 / 180);
        final oval = Rect.fromCenter(
          center: Offset.zero,
          width: 3.6,
          height: 5.2,
        );
        canvas.drawOval(oval, Paint()..color = t.amber);
        canvas.drawOval(
          oval,
          Paint()
            ..color = t.tree.bark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_StatusPainter old) => old.status != status || old.t != t;
}
