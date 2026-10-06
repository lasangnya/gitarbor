import 'package:flutter/material.dart';

import '../theme.dart';

/// The design's `.card`: surface, 1px line, radius 16, soft shadow.
class GCard extends StatelessWidget {
  const GCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.radius = 16,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: t.line),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: t.shadow,
                  offset: const Offset(0, 12),
                  blurRadius: 32,
                  spreadRadius: -16,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
