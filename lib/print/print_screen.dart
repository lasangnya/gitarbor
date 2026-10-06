import 'package:flutter/material.dart';

import '../data/models/repo_models.dart';

/// Placeholder; Phase 5 replaces it with the herbarium plate.
class PrintScreen extends StatelessWidget {
  const PrintScreen({super.key, required this.snapshot});

  final RepoSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(snapshot.fullName)),
      body: const Center(child: Text('Print plate — coming in Phase 5')),
    );
  }
}
