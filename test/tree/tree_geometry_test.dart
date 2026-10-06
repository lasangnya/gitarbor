import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/tree/sample_tree.dart';
import 'package:gitarbor/tree/tree_geometry.dart';
import 'package:gitarbor/tree/tree_model.dart';
import 'package:gitarbor/tree/tree_palette.dart';

void main() {
  final m = TreeModelBuilder().build(sampleSnapshot());

  test('grow 0.01 draws only the trunk', () {
    final f = TreeGeometry.compute(m, grow: .01, t: 0);
    expect(f.limbs.first, isNotNull);
    expect(f.limbs.skip(1).every((l) => l == null), isTrue);
  });

  test('grow 1 draws every limb', () {
    final f = TreeGeometry.compute(m, grow: 1, t: 0);
    expect(f.limbs.every((l) => l != null), isTrue);
    expect(f.leaves, isNotEmpty);
    expect(f.blossoms, isNotEmpty);
  });

  test('still ignores time', () {
    final a = TreeGeometry.compute(m, grow: 1, t: 0, still: true);
    final b = TreeGeometry.compute(m, grow: 1, t: 12.5, still: true);
    expect(a.leaves.length, b.leaves.length);
    for (var i = 0; i < a.leaves.length; i++) {
      expect(a.leaves[i].x, b.leaves[i].x);
      expect(a.leaves[i].y, b.leaves[i].y);
      expect(a.leaves[i].angle, b.leaves[i].angle);
    }
  });

  test('age buckets are monotonic and anchored', () {
    expect(bucketForAge(0), 0);
    expect(bucketForAge(1000), 8);
    var prev = -1;
    for (var d = 0.0; d <= 500; d += 1) {
      final b = bucketForAge(d);
      expect(b, greaterThanOrEqualTo(prev));
      prev = b;
    }
    var prevAge = -1.0;
    for (var b = 0; b < ageBuckets; b++) {
      final a = ageForBucket(b);
      expect(a, greaterThan(prevAge));
      prevAge = a;
    }
  });

  test('bounds contain the trunk base', () {
    final r = TreeGeometry.bounds(m);
    expect(r.contains(const Offset(trunkBaseX, trunkBaseY)), isTrue);
  });
}
