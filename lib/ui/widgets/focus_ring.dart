import 'package:flutter/material.dart';

import '../theme.dart';

/// Draws a 2 px cta outline around [child] while something inside it has
/// keyboard focus, like the design's :focus-visible. Pointer focus does not
/// show it.
class FocusRing extends StatefulWidget {
  const FocusRing({super.key, required this.child, this.radius = 12});

  final Widget child;
  final double radius;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final show =
        _focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (f) => setState(() => _focused = f),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: show ? Border.all(color: t.cta, width: 2) : null,
        ),
        child: widget.child,
      ),
    );
  }
}

/// The design's `.seg` control: a paper track with one raised option.
class Seg<T> extends StatelessWidget {
  const Seg({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.height = 40,
  });

  /// Value to label, in display order.
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.line),
      ),
      child: Row(
        children: [
          for (final e in options.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: e.key == value,
                label: e.value,
                excludeSemantics: true,
                onTap: () => onChanged(e.key),
                child: FocusRing(
                  radius: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: e.key == value ? t.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: e.key == value
                          ? [
                              BoxShadow(
                                color: t.line,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onChanged(e.key),
                      child: Container(
                        height: height - 8,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          e.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: e.key == value
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: e.key == value ? t.ink : t.ink2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
