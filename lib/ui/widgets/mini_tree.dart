import 'package:flutter/material.dart';

import '../theme.dart';

/// The design's `#mini` symbol: a tiny tree on a rounded tile.
class MiniTree extends StatelessWidget {
  const MiniTree({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MiniPainter(t)),
    );
  }
}

class _MiniPainter extends CustomPainter {
  _MiniPainter(this.t);
  final GitarborTokens t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 40);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 40, 40),
        const Radius.circular(10),
      ),
      Paint()..color = t.paper,
    );
    canvas.drawPath(
      Path()
        ..moveTo(20, 34)
        ..lineTo(20, 14)
        ..moveTo(20, 24)
        ..lineTo(13, 18)
        ..moveTo(20, 20)
        ..lineTo(27, 13),
      Paint()
        ..color = t.tree.bark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(12, 16), 4, Paint()..color = t.moss);
    canvas.drawCircle(const Offset(28, 11), 5, Paint()..color = t.sprout);
    canvas.drawCircle(const Offset(20, 10), 4, Paint()..color = t.amber);
  }

  @override
  bool shouldRepaint(_MiniPainter old) => old.t != t;
}
