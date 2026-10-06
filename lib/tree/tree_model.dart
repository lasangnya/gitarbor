import 'dart:math' as math;

import '../data/models/repo_models.dart';

const tau = math.pi * 2;

/// mulberry32, the design page's seeded generator. Bit-exact on the VM and
/// on the web, so a repo grows the same tree everywhere.
class Mulberry32 {
  Mulberry32(int seed) : _a = seed & 0xFFFFFFFF;
  int _a;

  double call() {
    _a = (_a + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _a;
    t = _imul(t ^ (t >>> 15), 1 | t);
    t = ((t + _imul(t ^ (t >>> 7), 61 | t)) & 0xFFFFFFFF) ^ t;
    return ((t ^ (t >>> 14)) & 0xFFFFFFFF) / 4294967296;
  }

  static int _imul(int a, int b) {
    final lo = (a & 0xFFFF) * b;
    final hi = (((a >>> 16) * b) & 0xFFFF) << 16;
    return (lo + hi) & 0xFFFFFFFF;
  }
}

/// FNV-1a over the repo name: the tree's seed.
int seedFor(String s) {
  var h = 0x811C9DC5;
  for (final c in s.toLowerCase().codeUnits) {
    h ^= c;
    h = Mulberry32._imul(h, 0x01000193);
  }
  return h;
}

enum LimbKind { trunk, twig, branch }

class LeafSpec {
  const LeafSpec({
    required this.s,
    required this.age,
    required this.side,
    required this.len,
    required this.variant,
    required this.off,
    required this.phase,
    required this.commits,
  });

  /// Position along the limb, 0 at the fork and 1 at the tip.
  final double s;

  /// Days since the newest commit it stands for.
  final double age;
  final int side;
  final double len;
  final int variant;
  final double off;
  final double phase;

  /// The commits this leaf stands for, newest first. One per leaf unless
  /// the limb has more commits than [TreeModelBuilder.maxLeaves].
  final List<Commit> commits;
}

class BlossomSpec {
  const BlossomSpec({
    required this.s,
    required this.side,
    required this.r,
    required this.variant,
    required this.rot,
    required this.d,
  });
  final double s;
  final int side;
  final double r;
  final int variant;
  final double rot;
  final double d;
}

class LimbSpec {
  LimbSpec({
    required this.name,
    required this.kind,
    required this.parent,
    required this.at,
    required this.side,
    required this.spread,
    required this.len,
    required this.w0,
    required this.w1,
    required this.curv,
    required this.phase,
    required this.flex,
    required this.birth,
    required this.dur,
    this.branch,
    this.number = 0,
    this.authorRank = -1,
  });

  final String name;
  final LimbKind kind;
  final Branch? branch;

  /// Index of the parent limb in [TreeModel.limbs]; -1 for the trunk.
  final int parent;

  /// Where along the parent it forks, 0 to 1.
  final double at;
  final int side;
  final double spread;
  final double len;
  final double w0;
  final double w1;
  final double curv;
  final double phase;
  final double flex;

  /// Growth (0 to 1) at which this limb starts, and how long it takes.
  final double birth;
  final double dur;

  /// Key number on the print plate; 0 for the trunk and twigs.
  final int number;
  final int authorRank;
  final List<LeafSpec> leaves = [];
  final List<BlossomSpec> blossoms = [];

  BranchStatus? get status => branch?.status;
  bool get isPruned => status == BranchStatus.pruned;
  bool get isBranch => kind == LimbKind.branch;
}

class GrassBlade {
  const GrassBlade(this.x, this.h, this.lean, this.phase);
  final double x, h, lean, phase;
}

class FallenLeaf {
  const FallenLeaf(this.x, this.rot, this.len, this.variant);
  final double x, rot, len;
  final int variant;
}

class RootSpec {
  const RootSpec(this.a, this.len, this.curv);
  final double a, len, curv;
}

/// Everything about a tree that doesn't change from frame to frame.
class TreeModel {
  TreeModel({
    required this.snapshot,
    required this.now,
    required this.limbs,
    required this.grass,
    required this.fallen,
    required this.roots,
    required this.authorRanks,
    required this.historyStart,
  });

  final RepoSnapshot snapshot;
  final DateTime now;

  /// Trunk first; every limb comes after its parent.
  final List<LimbSpec> limbs;
  final List<GrassBlade> grass;
  final List<FallenLeaf> fallen;
  final List<RootSpec> roots;
  final Map<String, int> authorRanks;

  /// Date of the oldest commit drawn; the history scrubber runs from here
  /// to [now].
  final DateTime historyStart;

  LimbSpec get trunk => limbs.first;
  Iterable<LimbSpec> get branches => limbs.where((l) => l.isBranch);

  /// The date shown for a growth value on the scrubber.
  DateTime dateAtGrowth(double g) {
    final span = now.difference(historyStart).inSeconds;
    final t = ((g - .04) / .96).clamp(0.0, 1.0);
    return historyStart.add(Duration(seconds: (span * t).round()));
  }
}

/// The ground line the tree stands on, in tree units.
double hillY(double x) => 742 + 0.00009 * (x - 500) * (x - 500);

/// Trunk base, in tree units. The design's view boxes are relative to it.
const trunkBaseX = 500.0, trunkBaseY = 742.0;

/// Turns a [RepoSnapshot] into limbs, leaves and blossoms. The seed comes
/// from the repo name, so a repo always grows the same tree.
class TreeModelBuilder {
  /// Leaves per limb. Limbs with more commits get one leaf per several.
  static const maxLeaves = 24;

  /// Crown leaves, shared between the trunk's twigs.
  static const maxCrownLeaves = 60;
  static const twigCount = 6;

  /// Leaves are drawn larger than in the first design so the painted
  /// detail shows.
  static const leafScale = 1.35;

  TreeModel build(RepoSnapshot snap, {DateTime? now}) {
    final today = now ?? snap.fetchedAt;
    final r = Mulberry32(seedFor(snap.fullName));
    final ranks = {
      for (var i = 0; i < snap.authors.length; i++) snap.authors[i].login: i,
    };
    double ageOf(DateTime d) =>
        math.max(0, today.difference(d).inMinutes / 1440);

    final trunk = LimbSpec(
      name: snap.defaultBranch,
      kind: LimbKind.trunk,
      parent: -1,
      at: 0,
      side: 1,
      spread: 0,
      len: 440,
      w0: 38,
      w1: 13,
      curv: .06,
      phase: 0,
      flex: 0,
      birth: 0,
      dur: .3,
    );
    final limbs = <LimbSpec>[trunk];

    // Crown twigs carry the trunk's own commits.
    final trunkCommits = snap.trunkCommits.reversed.toList(); // oldest first
    final crownGroups = _group(trunkCommits, maxCrownLeaves);
    for (var i = 0; i < twigCount; i++) {
      final side = i.isOdd ? 1 : -1;
      final twig = LimbSpec(
        name: snap.defaultBranch,
        kind: LimbKind.twig,
        parent: 0,
        at: .86 + i * .026,
        side: side,
        spread: .18 + r() * .55,
        len: 78 + r() * 52,
        w0: 7,
        w1: 1.2,
        curv: -side * (.1 + r() * .2),
        phase: r() * tau,
        flex: .7,
        birth: trunk.dur * (.86 + i * .026) + .02,
        dur: .2,
      );
      // Twig i takes every sixth group, so each twig mixes old and new.
      final mine = [
        for (var k = i; k < crownGroups.length; k += twigCount) crownGroups[k],
      ];
      for (var j = 0; j < mine.length; j++) {
        final t = mine.length > 1 ? j / (mine.length - 1) : 1.0;
        twig.leaves.add(
          LeafSpec(
            s: .25 + .75 * t,
            age: ageOf(mine[j].first.date),
            side: j.isOdd ? 1 : -1,
            len: (17 + r() * 8) * leafScale,
            variant: (r() * 4).floor(),
            off: .45 + r() * .5,
            phase: r() * tau,
            commits: mine[j],
          ),
        );
      }
      limbs.add(twig);
    }

    // Branch limbs. Forks are placed on the trunk's timeline, so older
    // forks sit lower.
    final trunkStart = trunkCommits.isEmpty ? null : trunkCommits.first.date;
    final trunkEnd = trunkCommits.isEmpty ? today : trunkCommits.last.date;
    final byName = {for (final b in snap.branches) b.name: b};
    final mains = snap.branches.where((b) => b.parent == null).toList()
      ..sort(_byFork);
    final index = <String, int>{};
    var number = 0;

    void addBranch(Branch b, int parentIdx, double at, int side) {
      final par = limbs[parentIdx];
      final sub = par.isBranch;
      final commits = b.commits.reversed.toList(); // oldest first
      final count = math.max(b.commitCount, commits.length);
      final lg = math.log(count + 1) / math.ln2;
      final pruned = b.status == BranchStatus.pruned;
      final stale = b.status == BranchStatus.stale;
      final limb = LimbSpec(
        name: b.name,
        kind: LimbKind.branch,
        branch: b,
        parent: parentIdx,
        at: at,
        side: side,
        spread: sub ? .55 : 1.32 - .62 * at,
        len: pruned ? 36 + 5 * lg : (sub ? .72 : 1) * (72 + 30 * lg),
        w0: (sub ? 4.5 : math.min(15.0, 4 + 2.2 * lg)) * (pruned ? .85 : 1),
        w1: 1.3,
        curv: pruned
            ? -side * .08
            : stale
            ? side * .42
            : -side * (.32 + .14 * r()),
        phase: r() * tau,
        flex: pruned ? .2 : .6 + .35 * r(),
        birth: par.birth + par.dur * at + (sub ? .03 : .02),
        dur: .24,
        number: ++number,
        authorRank: ranks[b.author] ?? -1,
      );
      index[b.name] = limbs.length;
      limbs.add(limb);
      if (pruned) return;

      var groups = _group(commits, maxLeaves);
      if (groups.isEmpty && b.lastActivity != null) {
        // No commit list (rare): one leaf dated by the last activity.
        groups = [
          [
            Commit(
              sha: '',
              message: b.name,
              author: b.author ?? '',
              date: b.lastActivity!,
            ),
          ],
        ];
      }
      if (stale) {
        // Half the dry leaves have fallen.
        groups = [
          for (var i = 0; i < groups.length; i++)
            if (i.isEven || i == groups.length - 1) groups[i],
        ];
      }
      for (var i = 0; i < groups.length; i++) {
        final t = groups.length > 1 ? i / (groups.length - 1) : 1.0;
        limb.leaves.add(
          LeafSpec(
            s: (.16 + .82 * t + (r() - .5) * .04).clamp(.1, 1),
            age: ageOf(groups[i].first.date),
            side: i.isOdd ? 1 : -1,
            len: (19 + r() * 10) * leafScale,
            variant: (r() * 4).floor(),
            off: (stale ? 1.2 : .42) + r() * .42,
            phase: r() * tau,
            commits: groups[i],
          ),
        );
      }
      if (b.status == BranchStatus.merged) {
        for (var k = 0; k < 5; k++) {
          limb.blossoms.add(
            BlossomSpec(
              s: .78 + k * .055,
              side: k.isOdd ? 1 : -1,
              r: (7 + r() * 3) * 1.25,
              variant: k % 3,
              rot: r() * tau,
              d: 5 + r() * 7,
            ),
          );
        }
      }
    }

    for (var i = 0; i < mains.length; i++) {
      final b = mains[i];
      double at;
      final f = b.forkDate;
      if (f == null || trunkStart == null || f.isBefore(trunkStart)) {
        // Older than the trunk window: bottom tenth of the fork range.
        at = .2 + r() * .067;
      } else {
        final span = trunkEnd.difference(trunkStart).inSeconds;
        final t = span <= 0 ? 1.0 : f.difference(trunkStart).inSeconds / span;
        at = .267 + .6 * t.clamp(0, 1);
      }
      addBranch(b, 0, at, i.isEven ? -1 : 1);
    }

    // Sub-branches, parents first. Each forks along its parent's commits.
    var pending = snap.branches.where((b) => b.parent != null).toList()
      ..sort(_byFork);
    while (pending.isNotEmpty) {
      final next = <Branch>[];
      for (final b in pending) {
        final pi = index[b.parent];
        if (pi == null) {
          if (byName.containsKey(b.parent)) {
            next.add(b);
          } else {
            addBranch(b, 0, .5, 1);
          }
          continue;
        }
        final par = limbs[pi];
        final pc = par.branch!.commits;
        var at = .55;
        if (b.forkDate != null && pc.length > 1) {
          final a = pc.last.date, z = pc.first.date;
          final span = z.difference(a).inSeconds;
          if (span > 0) {
            at =
                .3 +
                .5 * (b.forkDate!.difference(a).inSeconds / span).clamp(0, 1);
          }
        }
        addBranch(b, pi, at, par.side);
      }
      if (next.length == pending.length) {
        // Unresolvable parents: hang them off the trunk.
        for (final b in next) {
          addBranch(b, 0, .5, 1);
        }
        break;
      }
      pending = next;
    }

    final grass = [
      for (var i = 0; i < 70; i++)
        GrassBlade(220 + r() * 560, 7 + r() * 12, (r() - .5) * .5, r() * tau),
    ];
    final hasStale = snap.branches.any((b) => b.status == BranchStatus.stale);
    final fallen = [
      for (var i = 0; i < (hasStale ? 7 : 3); i++)
        FallenLeaf(
          670 + r() * 150,
          r() * tau,
          (15 + r() * 5) * leafScale,
          (r() * 4).floor(),
        ),
    ];
    const roots = [
      RootSpec(.12, 90, .25),
      RootSpec(math.pi - .12, 96, -.25),
      RootSpec(.5, 52, .3),
      RootSpec(math.pi - .55, 58, -.3),
    ];

    final dates = [
      for (final c in snap.trunkCommits) c.date,
      for (final b in snap.branches)
        for (final c in b.commits) c.date,
    ];
    final start = dates.isEmpty
        ? today.subtract(const Duration(days: 365))
        : dates.reduce((a, b) => a.isBefore(b) ? a : b);

    return TreeModel(
      snapshot: snap,
      now: today,
      limbs: limbs,
      grass: grass,
      fallen: fallen,
      roots: roots,
      authorRanks: ranks,
      historyStart: start,
    );
  }

  static int _byFork(Branch a, Branch b) {
    final fa = a.forkDate, fb = b.forkDate;
    if (fa == null && fb == null) return a.name.compareTo(b.name);
    if (fa == null) return -1;
    if (fb == null) return 1;
    final c = fa.compareTo(fb);
    return c != 0 ? c : a.name.compareTo(b.name);
  }

  /// Splits oldest-first [commits] into at most [max] groups, each newest
  /// first, in oldest-first order.
  static List<List<Commit>> _group(List<Commit> commits, int max) {
    if (commits.isEmpty) return const [];
    final per = (commits.length / max).ceil();
    return [
      for (var i = 0; i < commits.length; i += per)
        commits.sublist(i, math.min(commits.length, i + per)).reversed.toList(),
    ];
  }
}
