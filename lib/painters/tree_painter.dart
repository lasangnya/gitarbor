import 'package:flutter/material.dart';
import '../models/layout_models.dart';

class TreeSkeletonPainter extends CustomPainter {
  final TreeLayout layout;

  TreeSkeletonPainter({required this.layout});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 1. Draw Trunk
    canvas.drawLine(layout.trunkBase, layout.trunkTop, paint);

    // 2. Draw Limbs and Spines
    for (var contributor in layout.contributors) {
      // Line from trunk to avatar
      canvas.drawLine(layout.trunkTop, contributor.avatarPos, paint);
      
      // Drawing the path directly is safer than measuring it here
      canvas.drawPath(contributor.spinePath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
