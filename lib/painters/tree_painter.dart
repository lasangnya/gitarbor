import 'package:flutter/material.dart';
import '../models/layout_models.dart';
import '../models/repo_models.dart';
import 'dart:math' as math;

class TreeSkeletonPainter extends CustomPainter {
  final TreeLayout layout;
  final math.Random _random = math.Random(42);

  TreeSkeletonPainter({required this.layout});

  @override
  void paint(Canvas canvas, Size size) {
    const trunkColor = Color(0xFF5C4033);
    const branchColor = Color(0xFF8B7355);

    // 1. Draw Trunk
    _drawArtisticLine(canvas, layout.trunkBase, layout.trunkTop, 10.0, trunkColor);

    // 2. Draw Limbs, Spines and Leaves
    for (var contributor in layout.contributors) {
      _drawArtisticLine(canvas, layout.trunkTop, contributor.avatarPos, 5.0, trunkColor);
      _drawArtisticPath(canvas, contributor.spinePath, 2.5, branchColor);

      for (var label in contributor.branchLabels) {
        _drawLeafCluster(canvas, label.position, label.status);
      }
    }
  }

  void _drawArtisticLine(Canvas canvas, Offset start, Offset end, double width, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    final texturePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = width * 0.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(start.dx + 1.5, start.dy), 
      Offset(end.dx + 1.5, end.dy), 
      texturePaint
    );
  }

  void _drawArtisticPath(Canvas canvas, Path path, double width, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
    
    final texturePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = width * 0.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, texturePaint);
  }

  void _drawLeafCluster(Canvas canvas, Offset position, BranchStatus status) {
    final leafPaint = Paint()..style = PaintingStyle.fill;

    switch (status) {
      case BranchStatus.active:
        leafPaint.color = const Color(0xFF6B8E4E);
        break;
      case BranchStatus.merged:
        leafPaint.color = const Color(0xFFC4956A);
        break;
      case BranchStatus.stale:
        leafPaint.color = const Color(0xFFB8AFA6);
        break;
    }

    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        _random.nextDouble() * 12 - 6,
        _random.nextDouble() * 12 - 6,
      );
      _drawSingleLeaf(canvas, position + offset, _random.nextDouble() * math.pi * 2, leafPaint);
    }
  }

  void _drawSingleLeaf(Canvas canvas, Offset position, double rotation, Paint paint) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(-3, -5, 0, -10);
    path.quadraticBezierTo(3, -5, 0, 0);
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
