import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/data/models/repo_models.dart';
import 'package:gitarbor/tree/sample_tree.dart';
import 'package:gitarbor/tree/tree_model.dart';

TreeModel _build([RepoSnapshot? s]) =>
    TreeModelBuilder().build(s ?? sampleSnapshot());

void main() {
  test('the same snapshot builds an identical model', () {
    final a = _build(), b = _build();
    expect(a.limbs.map((l) => l.name), b.limbs.map((l) => l.name));
    expect(a.limbs.map((l) => l.at), b.limbs.map((l) => l.at));
    expect(
      a.limbs.map((l) => l.leaves.length),
      b.limbs.map((l) => l.leaves.length),
    );
    expect(
      [
        for (final l in a.limbs)
          for (final f in l.leaves) f.age,
      ],
      [
        for (final l in b.limbs)
          for (final f in l.leaves) f.age,
      ],
    );
  });

  test('different repo names give different seeds', () {
    expect(seedFor('example/lantern'), isNot(seedFor('example/other')));
    final s = sampleSnapshot();
    final a = _build(s);
    final b = _build(s.copyWith(name: 'other'));
    expect([
      for (final l in a.limbs) l.phase,
    ], isNot([for (final l in b.limbs) l.phase]));
  });

  test('leaves are capped and cluster commits', () {
    final m = _build();
    for (final l in m.limbs) {
      expect(l.leaves.length, lessThanOrEqualTo(TreeModelBuilder.maxLeaves));
    }
    final plugin = m.limbs.firstWhere((l) => l.name == 'feature/plugin-api');
    expect(plugin.branch!.commits.length, 34);
    expect(plugin.leaves.length, lessThan(34));
    expect(plugin.leaves.any((f) => f.commits.length > 1), isTrue);
    expect(plugin.leaves.fold<int>(0, (n, f) => n + f.commits.length), 34);
    final stress = _build(stressSnapshot());
    for (final l in stress.limbs) {
      expect(l.leaves.length, lessThanOrEqualTo(TreeModelBuilder.maxLeaves));
    }
  });

  test('stale limbs have fewer leaves than commits', () {
    final stale = _build().limbs.firstWhere(
      (l) => l.name == 'experiment/wasm-build',
    );
    expect(stale.leaves.length, lessThan(stale.branch!.commits.length));
    expect(stale.leaves, isNotEmpty);
  });

  test('pruned limbs have no leaves', () {
    final pruned = _build().limbs.firstWhere((l) => l.isPruned);
    expect(pruned.leaves, isEmpty);
  });

  test('merged limbs have five blossoms', () {
    final merged = _build().limbs.where((l) => l.status == BranchStatus.merged);
    expect(merged, isNotEmpty);
    for (final l in merged) {
      expect(l.blossoms.length, 5);
    }
  });

  test('sub-branch points at its parent', () {
    final m = _build();
    final rtl = m.limbs.firstWhere((l) => l.name == 'feature/i18n-rtl');
    expect(m.limbs[rtl.parent].name, 'feature/i18n');
  });

  test('every limb comes after its parent', () {
    for (final m in [_build(), _build(stressSnapshot())]) {
      for (var i = 1; i < m.limbs.length; i++) {
        expect(m.limbs[i].parent, lessThan(i));
      }
    }
  });

  test('older fork dates sit lower on the trunk', () {
    final m = _build();
    double at(String n) => m.limbs.firstWhere((l) => l.name == n).at;
    expect(at('experiment/wasm-build'), lessThan(at('release/2.0')));
    expect(at('release/2.0'), lessThan(at('docs/getting-started')));
    expect(at('refactor/router'), lessThan(at('experiment/wasm-build')));
    expect(at('feature/plugin-api'), closeTo(.77, .02));
  });

  test('dateAtGrowth(1) is now', () {
    final m = _build();
    expect(m.dateAtGrowth(1), m.now);
    expect(m.dateAtGrowth(0), m.historyStart);
  });
}
