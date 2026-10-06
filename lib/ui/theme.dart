import 'package:flutter/material.dart';

import '../tree/tree_palette.dart';

/// Design tokens from the Gitarbor design page, as a theme extension.
/// Read them with `context.tokens`.
@immutable
class GitarborTokens extends ThemeExtension<GitarborTokens> {
  const GitarborTokens({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.line2,
    required this.cta,
    required this.onCta,
    required this.ctaSoft,
    required this.ctaLine,
    required this.shadow,
    required this.sprout,
    required this.moss,
    required this.amber,
    required this.rust,
    required this.blossom,
    required this.tree,
  });

  final Color paper, surface, ink, ink2, ink3, line, line2;
  final Color cta, onCta, ctaSoft, ctaLine, shadow;
  final Color sprout, moss, amber, rust, blossom;

  /// The palette the live tree is painted with in this theme.
  final TreePalette tree;

  Color author(int rank) => tree.authorColor(rank);

  static const day = GitarborTokens(
    paper: Color(0xFFEDF1E8),
    surface: Color(0xFFF9FBF5),
    ink: Color(0xFF1C2826),
    ink2: Color(0xBD1C2826),
    ink3: Color(0xA81C2826),
    line: Color(0x211C2826),
    line2: Color(0x121C2826),
    cta: Color(0xFFBF3C72),
    onCta: Color(0xFFFFFFFF),
    ctaSoft: Color(0x14BF3C72),
    ctaLine: Color(0x38BF3C72),
    shadow: Color(0x4724463A),
    sprout: Color(0xFF9BC23E),
    moss: Color(0xFF3D7A51),
    amber: Color(0xFFD6932B),
    rust: Color(0xFFB3502F),
    blossom: Color(0xFFE2598F),
    tree: TreePalette.day,
  );

  static const night = GitarborTokens(
    paper: Color(0xFF0D1615),
    surface: Color(0xFF15211F),
    ink: Color(0xFFE2ECE4),
    ink2: Color(0xC2E2ECE4),
    ink3: Color(0x8CE2ECE4),
    line: Color(0x24E2ECE4),
    line2: Color(0x0FE2ECE4),
    cta: Color(0xFFF28DB6),
    onCta: Color(0xFF2B0D1A),
    ctaSoft: Color(0x1AF28DB6),
    ctaLine: Color(0x47F28DB6),
    shadow: Color(0x99000000),
    sprout: Color(0xFFBEDD5E),
    moss: Color(0xFF5BA46D),
    amber: Color(0xFFEAB04B),
    rust: Color(0xFFDD7550),
    blossom: Color(0xFFF383B0),
    tree: TreePalette.night,
  );

  @override
  GitarborTokens copyWith() => this;

  @override
  GitarborTokens lerp(GitarborTokens? other, double t) =>
      other == null || t < .5 ? this : other;
}

/// Font families bundled in assets/fonts.
abstract final class Fonts {
  static const display = 'Young Serif';
  static const ui = 'Bricolage Grotesque';
  static const mono = 'IBM Plex Mono';
}

extension TokensX on BuildContext {
  GitarborTokens get tokens => Theme.of(this).extension<GitarborTokens>()!;
}

/// Text styles used across screens, from the design page.
abstract final class TextStyles {
  static const display = TextStyle(fontFamily: Fonts.display, height: 1.08);
  static const mono = TextStyle(fontFamily: Fonts.mono);

  /// Small uppercase label ("RECENTLY PLANTED").
  static TextStyle label(GitarborTokens t) => TextStyle(
    fontFamily: Fonts.mono,
    fontSize: 11,
    letterSpacing: .88,
    color: t.ink3,
  );
}

ThemeData buildTheme(GitarborTokens t, Brightness b) {
  final scheme = ColorScheme.fromSeed(seedColor: t.cta, brightness: b).copyWith(
    primary: t.cta,
    onPrimary: t.onCta,
    surface: t.surface,
    onSurface: t.ink,
    outline: t.line,
    outlineVariant: t.line2,
    error: t.rust,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  // 2 px cta outline on keyboard focus, like the design's :focus-visible.
  WidgetStateProperty<BorderSide?> ring(BorderSide? rest) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? BorderSide(color: t.cta, width: 2)
            : rest,
      );
  return ThemeData(
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.paper,
    fontFamily: Fonts.ui,
    extensions: [t],
    dividerColor: t.line,
    textTheme: ThemeData(brightness: b).textTheme.apply(
      fontFamily: Fonts.ui,
      bodyColor: t.ink,
      displayColor: t.ink,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.cta,
        foregroundColor: t.onCta,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: Fonts.ui,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: shape,
      ).copyWith(side: ring(null)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.ink,
        backgroundColor: t.surface,
        minimumSize: const Size(40, 40),
        textStyle: const TextStyle(
          fontFamily: Fonts.ui,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: shape,
      ).copyWith(side: ring(BorderSide(color: t.line))),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.ink,
        minimumSize: const Size(40, 40),
        textStyle: const TextStyle(
          fontFamily: Fonts.ui,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: shape,
      ).copyWith(side: ring(null)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: shape).copyWith(side: ring(null)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: t.surface,
      selectedColor: t.ctaSoft,
      side: BorderSide(color: t.line),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(fontFamily: Fonts.ui, fontSize: 13, color: t.ink2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.cta, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.rust, width: 2),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: t.cta,
      thumbColor: t.cta,
      inactiveTrackColor: t.line,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: t.line),
      ),
      textStyle: TextStyle(fontFamily: Fonts.ui, fontSize: 12, color: t.ink),
    ),
    focusColor: t.ctaSoft,
  );
}
