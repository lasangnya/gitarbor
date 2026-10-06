import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/ui/theme.dart';

/// Composites [fg] over the opaque [bg].
Color over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

double _lin(double c) =>
    c <= .03928 ? c / 12.92 : math.pow((c + .055) / 1.055, 2.4).toDouble();

double luminance(Color c) =>
    .2126 * _lin(c.r) + .7152 * _lin(c.g) + .0722 * _lin(c.b);

/// WCAG contrast ratio of [fg] on [bg] (alpha composited over [bg]).
double contrast(Color fg, Color bg) {
  final a = luminance(over(fg, bg)), b = luminance(bg);
  final hi = math.max(a, b), lo = math.min(a, b);
  return (hi + .05) / (lo + .05);
}

void main() {
  final themes = {'day': GitarborTokens.day, 'night': GitarborTokens.night};
  for (final e in themes.entries) {
    final t = e.value;
    group('${e.key} contrast', () {
      void check(String name, Color fg, Color bg, double min) {
        test(name, () {
          final r = contrast(fg, bg);
          expect(r, greaterThanOrEqualTo(min), reason: '$name = $r');
        });
      }

      check('ink on paper', t.ink, t.paper, 7);
      check('ink on surface', t.ink, t.surface, 7);
      check('ink2 on surface', t.ink2, t.surface, 4.5);
      check('ink3 on surface', t.ink3, t.surface, 4.5);
      check('ink3 on paper', t.ink3, t.paper, 4.5);
      check('onCta on cta', t.onCta, t.cta, 4.5);
    });
  }
}
