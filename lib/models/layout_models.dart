import 'package:flutter/material.dart';

import '../models/repo_models.dart';

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
  final BranchStatus status;

  BranchLabelLayout({
    required this.name,
    required this.position,
    required this.status,
  });
}
