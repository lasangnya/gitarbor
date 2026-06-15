import 'dart:math';
import 'package:flutter/material.dart';
import '../models/repo_models.dart';
import '../models/layout_models.dart';

class LayoutEngine {
  static TreeLayout calculate(RepoTree tree, Size size) {
    final bottomCenter = Offset(size.width / 2, size.height * 0.9);
    final trunkTop = Offset(size.width / 2, size.height * 0.7);

    final List<ContributorLayout> contributorLayouts = [];
    final contributors = tree.contributors;

    for (int i = 0; i < contributors.length; i++) {
      // 1. Calculate limb position
      final double angle = (pi / (contributors.length + 1)) * (i + 1) + pi;
      const double limbLength = 150.0;

      final avatarPos = Offset(
        trunkTop.dx + cos(angle) * limbLength,
        trunkTop.dy + sin(angle) * limbLength,
      );

      // 2. Create spine path
      final spinePath = Path();
      spinePath.moveTo(avatarPos.dx, avatarPos.dy - 30);
      spinePath.quadraticBezierTo(
        avatarPos.dx,
        avatarPos.dy - 150,
        avatarPos.dx - 50,
        avatarPos.dy - 300,
      );

      // 3. Calculate branch labels
      final List<BranchLabelLayout> labels = [];
      final branches = contributors[i].branches;

      if (branches.isNotEmpty) {
        final metrics = spinePath.computeMetrics();
        // Use a loop instead of .first to be ultra safe
        for (final metric in metrics) {
          for (int j = 0; j < branches.length; j++) {
            final double percent = 0.1 +
                (0.8 * (j / (branches.length > 1 ? branches.length - 1 : 1)));
            final tangent = metric.getTangentForOffset(metric.length * percent);

            if (tangent != null) {
              final double xOffset = (j % 2 == 0) ? -60.0 : 10.0;
              labels.add(BranchLabelLayout(
                name: branches[j].name,
                position: Offset(
                  tangent.position.dx + xOffset,
                  tangent.position.dy,
                ),
              ));
            }
          }
          break; // We only need the first metric (the main spine)
        }
      }

      contributorLayouts.add(ContributorLayout(
        login: contributors[i].login,
        avatarPos: avatarPos,
        spinePath: spinePath,
        branchLabels: labels,
      ));
    }

    return TreeLayout(
      trunkBase: bottomCenter,
      trunkTop: trunkTop,
      contributors: contributorLayouts,
    );
  }
}
