import 'package:flutter/material.dart';

import '../theme.dart';

/// A circle in the author's rank colour with their initial.
class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({
    super.key,
    required this.login,
    required this.rank,
    this.size = 28,
  });

  final String login;
  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rank < 0 ? t.ink3 : t.author(rank),
      ),
      child: Text(
        login.isEmpty ? '?' : login.characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: size * .43,
          fontWeight: FontWeight.w600,
          color: t.surface,
          height: 1,
        ),
      ),
    );
  }
}
