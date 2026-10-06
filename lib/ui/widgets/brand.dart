import 'package:flutter/material.dart';

import '../theme.dart';

/// The Gitarbor mark (the design's `#mark` symbol) and word.
class Brand extends StatelessWidget {
  const Brand({super.key, this.showWord = true, this.size = 28});

  final bool showWord;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _MarkPainter(t.tree.bark, t.moss, t.sprout, t.blossom),
          ),
        ),
        if (showWord) ...[
          const SizedBox(width: 8),
          Text(
            'Gitarbor',
            style: TextStyle(
              fontFamily: Fonts.display,
              fontSize: 20,
              color: t.ink,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.bark, this.moss, this.sprout, this.blossom);
  final Color bark, moss, sprout, blossom;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);
    canvas.drawLine(
      const Offset(16, 29),
      const Offset(16, 15),
      Paint()
        ..color = bark
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(16, 20)
        ..cubicTo(13, 19, 10, 16, 9, 12)
        ..cubicTo(13, 12, 16, 15, 16, 20)
        ..close(),
      Paint()..color = moss,
    );
    canvas.drawPath(
      Path()
        ..moveTo(16, 16)
        ..cubicTo(18, 11, 22, 8, 27, 8)
        ..cubicTo(26, 13, 22, 17, 16, 16)
        ..close(),
      Paint()..color = sprout,
    );
    canvas.drawCircle(const Offset(12, 7), 3.2, Paint()..color = blossom);
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.bark != bark ||
      old.moss != moss ||
      old.sprout != sprout ||
      old.blossom != blossom;
}
