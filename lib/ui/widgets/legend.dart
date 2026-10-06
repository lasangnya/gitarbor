import 'package:flutter/material.dart';

import '../../data/models/repo_models.dart';
import '../format.dart';
import '../theme.dart';
import 'status_icon.dart';

/// Leaf age gradient and the three status rows.
class Legend extends StatelessWidget {
  const Legend({super.key, this.showLabel = true});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final small = TextStyle(fontSize: 12, color: t.ink2);
    Widget row(BranchStatus s, String text) => Row(
      children: [
        StatusIcon(s),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: small)),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text('LEGEND', style: TextStyles.label(t)),
          const SizedBox(height: 8),
        ],
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [t.sprout, t.moss, t.amber, t.rust],
              stops: const [0, .3, .66, 1],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final s in const ['today', '4 mo', '1 yr+'])
              Text(s, style: mono(11, color: t.ink3)),
          ],
        ),
        const SizedBox(height: 8),
        row(BranchStatus.merged, 'Blossoms: merged branch'),
        const SizedBox(height: 8),
        row(BranchStatus.stale, 'Dry, drooping: stale branch'),
        const SizedBox(height: 8),
        row(BranchStatus.pruned, 'Cut stub: closed unmerged, deleted'),
      ],
    );
  }
}
