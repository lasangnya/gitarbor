import 'package:flutter/material.dart';

class TreeLayout {
  final Offset trunkBase;
  final Offset trunkTop;
  final List<ContributorLayout> contributors;

  TreeLayout({
    required this.trunkBase,
    required this.trunkTop,
    required this.contributors,
  });
}

class ContributorLayout {
  final String login;
  final Offset avatarPos;
  final Path spinePath;
  final List<BranchLabelLayout> branchLabels;

  ContributorLayout({
    required this.login,
    required this.avatarPos,
    required this.spinePath,
    required this.branchLabels,
  });
}

class BranchLabelLayout {
  final String name;
  final Offset position;

  BranchLabelLayout({required this.name, required this.position});
}
