import 'package:flutter/painting.dart';

import '../data/models/repo_models.dart';
import 'theme.dart';

/// Age text like the design page's `fmtAge`.
String formatAge(double d) => d < 1
    ? 'today'
    : d < 2
    ? 'yesterday'
    : d < 14
    ? '${d.round()} days ago'
    : d < 60
    ? '${(d / 7).round()} weeks ago'
    : d < 365
    ? '${(d / 30).round()} months ago'
    : 'over a year ago';

/// Days from [earlier] to [later], fractional.
double daysBetween(DateTime later, DateTime earlier) =>
    later.difference(earlier).inMinutes / 1440;

/// 1,284
String formatNumber(int n) {
  final s = n.abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// 2.4k
String formatCompact(int n) {
  if (n < 1000) return '$n';
  if (n < 10000) {
    final v = (n / 1000).toStringAsFixed(1);
    return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}k';
  }
  if (n < 1000000) return '${(n / 1000).round()}k';
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Oct 2026
String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

/// "today", "2 days ago", "last week", "3 months ago".
String formatRelative(DateTime then, DateTime now) {
  final d = daysBetween(now, then);
  if (d < 1) return 'today';
  if (d < 2) return 'yesterday';
  if (d < 7) return '${d.floor()} days ago';
  if (d < 14) return 'last week';
  if (d < 60) return '${(d / 7).floor()} weeks ago';
  if (d < 365) return '${(d / 30).floor()} months ago';
  return 'over a year ago';
}

/// Where "Open on GitHub" goes: the branch, or the pull request for a
/// branch that no longer exists.
Uri branchUrl(RepoSnapshot s, Branch b) {
  final base = 'https://github.com/${s.owner}/${s.name}';
  if ((b.deleted || b.status == BranchStatus.pruned) && b.prNumber != null) {
    return Uri.parse('$base/pull/${b.prNumber}');
  }
  return Uri.parse('$base/tree/${Uri.encodeFull(b.name)}');
}

/// Levenshtein distance, for "Did you mean".
int editDistance(String a, String b) {
  if (a == b) return 0;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = [
        prev[j] + 1,
        cur[j - 1] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return prev[b.length];
}

/// IBM Plex Mono at [size].
TextStyle mono(
  double size, {
  Color? color,
  FontWeight weight = FontWeight.w400,
  double? height,
  double? letterSpacing,
}) => TextStyle(
  fontFamily: Fonts.mono,
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
  fontFeatures: const [FontFeature.tabularFigures()],
);
