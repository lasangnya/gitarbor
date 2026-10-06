import 'package:flutter/material.dart';

import '../format.dart';
import '../theme.dart';

/// "/ owner / repo" in mono with muted separators, optionally followed by
/// the star count.
class RepoCrumb extends StatelessWidget {
  const RepoCrumb({
    super.key,
    required this.owner,
    required this.repo,
    this.leadingSlash = true,
    this.stars,
    this.center = false,
  });

  final String owner, repo;
  final bool leadingSlash;
  final int? stars;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final base = mono(14, color: t.ink);
    final sep = base.copyWith(color: t.ink3);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (leadingSlash) TextSpan(text: '/ ', style: sep),
          TextSpan(text: owner),
          TextSpan(text: ' / ', style: sep),
          TextSpan(
            text: repo,
            style: base.copyWith(fontWeight: FontWeight.w500),
          ),
          if (stars != null)
            TextSpan(
              text: '   ★ ${formatCompact(stars!)}',
              style: base.copyWith(color: t.ink3),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: center ? TextAlign.center : TextAlign.start,
    );
  }
}
