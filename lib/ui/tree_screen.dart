import 'package:flutter/material.dart';
import '../models/repo_models.dart';
import '../painters/tree_painter.dart';
import '../services/layout_engine.dart';
import 'components/branch_label.dart';
import 'components/contributor_node.dart';

class TreeScreen extends StatelessWidget {
  final RepoTree tree;

  const TreeScreen({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tree.repo.name),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 1. Calculate the layout based on the available screen size
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final layout = LayoutEngine.calculate(tree, size);
          return InteractiveViewer(
            constrained:
                false, // Allows the canvas to be larger than the screen
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  // Layer 1: The Skeleton Lines
                  CustomPaint(
                    size: size,
                    painter: TreeSkeletonPainter(layout: layout),
                  ),

                  // Layer 2: The Contributor Nodes (Avatars + Names)
                  ...layout.contributors.map(
                    (c) => Positioned(
                      left: c.avatarPos.dx - 40,
                      // Adjust to center the 60px wide node
                      top: c.avatarPos.dy - 30,
                      child: ContributorNode(
                        login: c.login,
                        // avatarUrl: ... fetch from tree if available
                      ),
                    ),
                  ),

                  // Layer 3: The Branch Labels (The black rectangles)
                  ...layout.contributors
                      .expand((c) => c.branchLabels)
                      .map(
                        (b) => Positioned(
                          left: b.position.dx,
                          top: b.position.dy,
                          child: BranchLabel(name: b.name),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
