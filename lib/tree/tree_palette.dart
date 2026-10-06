import 'dart:ui';

/// The colours the tree is painted with. Day and Night follow the app
/// theme; [print] is always warm paper with ink, whatever the theme.
class TreePalette {
  const TreePalette({
    required this.id,
    required this.sprout,
    required this.moss,
    required this.amber,
    required this.rust,
    required this.bark,
    required this.bark2,
    required this.blossom,
    required this.ink,
    required this.surface,
    required this.paper,
    required this.skyTop,
    required this.skyBottom,
    required this.soil,
    required this.authors,
  });

  /// Sprite atlases are cached per palette id.
  final String id;
  final Color sprout, moss, amber, rust, bark, bark2, blossom;
  final Color ink, surface, paper, skyTop, skyBottom, soil;

  /// Author colours, assigned by author rank.
  final List<Color> authors;

  Color authorColor(int rank) => authors[rank % authors.length];

  static const day = TreePalette(
    id: 'day',
    sprout: Color(0xFF9BC23E),
    moss: Color(0xFF3D7A51),
    amber: Color(0xFFD6932B),
    rust: Color(0xFFB3502F),
    bark: Color(0xFF5B3A40),
    bark2: Color(0xFF8A5F66),
    blossom: Color(0xFFE2598F),
    ink: Color(0xFF1C2826),
    surface: Color(0xFFF9FBF5),
    paper: Color(0xFFEDF1E8),
    skyTop: Color(0xFFD7E7E3),
    skyBottom: Color(0xFFF2F4EA),
    soil: Color(0xFFC9D2BB),
    authors: [
      Color(0xFF4C5BC4),
      Color(0xFF17868A),
      Color(0xFF8B4CBE),
      Color(0xFFC0662A),
      Color(0xFF2F6FA8),
      Color(0xFF7B6A3A),
    ],
  );

  static const night = TreePalette(
    id: 'night',
    sprout: Color(0xFFBEDD5E),
    moss: Color(0xFF5BA46D),
    amber: Color(0xFFEAB04B),
    rust: Color(0xFFDD7550),
    bark: Color(0xFF8E6A70),
    bark2: Color(0xFFB9949A),
    blossom: Color(0xFFF383B0),
    ink: Color(0xFFE2ECE4),
    surface: Color(0xFF15211F),
    paper: Color(0xFF0D1615),
    skyTop: Color(0xFF0A1820),
    skyBottom: Color(0xFF13211C),
    soil: Color(0xFF1D2A23),
    authors: [
      Color(0xFF8D98F0),
      Color(0xFF4FC3C2),
      Color(0xFFC08AF0),
      Color(0xFFEE9A5E),
      Color(0xFF6FA8E0),
      Color(0xFFC9B57A),
    ],
  );

  static const print = TreePalette(
    id: 'print',
    sprout: Color(0xFF9BC23E),
    moss: Color(0xFF3D7A51),
    amber: Color(0xFFD6932B),
    rust: Color(0xFFB3502F),
    bark: Color(0xFF5B3A40),
    bark2: Color(0xFF8A5F66),
    blossom: Color(0xFFE2598F),
    ink: Color(0xFF2A2521),
    surface: Color(0xFFFBFAF3),
    paper: Color(0xFFFBFAF3),
    skyTop: Color(0xFFFBFAF3),
    skyBottom: Color(0xFFFBFAF3),
    soil: Color(0xFFFBFAF3),
    authors: [
      Color(0xFF4C5BC4),
      Color(0xFF17868A),
      Color(0xFF8B4CBE),
      Color(0xFFC0662A),
      Color(0xFF2F6FA8),
      Color(0xFF7B6A3A),
    ],
  );

  /// Leaf colour for a commit [days] old: sprout, moss, amber, rust.
  Color ageColor(double days) {
    final stops = [(0.0, sprout), (21.0, moss), (140.0, amber), (380.0, rust)];
    for (var i = 0; i < stops.length - 1; i++) {
      final (d0, c0) = stops[i];
      final (d1, c1) = stops[i + 1];
      if (days <= d1) {
        return Color.lerp(c0, c1, ((days - d0) / (d1 - d0)).clamp(0, 1))!;
      }
    }
    return rust;
  }
}

/// Leaf ages are painted in nine buckets: today, 3 weeks, 4 months, 1 year+.
const ageBuckets = 9;
const _ageStops = [0.0, 21.0, 140.0, 380.0];

int bucketForAge(double days) {
  if (days >= 380) return ageBuckets - 1;
  var i = 0;
  while (days > _ageStops[i + 1]) {
    i++;
  }
  final t = (i + (days - _ageStops[i]) / (_ageStops[i + 1] - _ageStops[i])) / 3;
  return (t * (ageBuckets - 1)).round().clamp(0, ageBuckets - 1);
}

double ageForBucket(int b) {
  final t = b / (ageBuckets - 1) * 3;
  final i = t.floor().clamp(0, 2);
  return _ageStops[i] + (_ageStops[i + 1] - _ageStops[i]) * (t - i);
}
