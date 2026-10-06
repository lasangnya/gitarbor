import '../data/branch_classifier.dart';
import '../data/models/repo_models.dart';
import 'tree_model.dart';

/// The design page's sample branches.
class _Spec {
  const _Spec(
    this.name,
    this.author,
    this.status,
    this.commits,
    this.at,
    this.oldest,
    this.newest,
    this.msgs, {
    this.deleted = false,
    this.parent,
  });
  final String name, author;
  final BranchStatus status;
  final int commits;
  final double at;
  final double oldest, newest;
  final List<String> msgs;
  final bool deleted;
  final String? parent;
}

const _authors = ['aiko-t', 'mira', 'tomasz', 'rahul-dev', 'junpark', 'lena'];

const _mainMsgs = [
  'Fix broken link check',
  'Update dependencies',
  'Faster incremental builds',
  'Tidy CLI help text',
  'Cache parsed front matter',
  'Release 1.9.3',
];

const _specs = [
  _Spec(
    'refactor/router',
    'rahul-dev',
    BranchStatus.merged,
    21,
    .20,
    230,
    170,
    [
      'Split router into matchers',
      'Drop legacy hash routes',
      'Add route priority tests',
      'Merge router v2',
    ],
    deleted: true,
  ),
  _Spec(
    'experiment/wasm-build',
    'rahul-dev',
    BranchStatus.stale,
    12,
    .30,
    470,
    380,
    [
      'Try wasm-pack target',
      'Stub fs for wasm',
      'Benchmark wasm build',
      'WIP: wasm loader',
    ],
  ),
  _Spec('feature/old-editor', 'lena', BranchStatus.pruned, 14, .40, 300, 260, [
    'Old editor',
  ], deleted: true),
  _Spec('fix/rss-dates', 'mira', BranchStatus.merged, 6, .40, 130, 110, [
    'Use RFC 822 dates in RSS',
    'Test timezone offsets',
    'Fix pubDate for drafts',
  ], deleted: true),
  _Spec('feature/i18n', 'aiko-t', BranchStatus.active, 15, .50, 70, 4, [
    'Add locale loader',
    'Translate nav strings',
    'Fallback to default locale',
    'Pluralise counts',
  ]),
  _Spec('feature/dark-mode', 'tomasz', BranchStatus.merged, 18, .58, 95, 55, [
    'Add theme tokens',
    'Respect prefers-color-scheme',
    'Dark syntax theme',
    'Persist theme choice',
  ]),
  _Spec('release/2.0', 'mira', BranchStatus.active, 27, .68, 50, 1, [
    'Bump to 2.0.0-rc.1',
    'Update changelog',
    'Migrate config format',
    'Freeze plugin API',
  ]),
  _Spec('feature/plugin-api', 'aiko-t', BranchStatus.active, 34, .77, 42, 0, [
    'Define plugin manifest',
    'Add lifecycle hooks',
    'Sandbox plugin fs',
    'Load plugins in parallel',
  ]),
  _Spec('docs/getting-started', 'junpark', BranchStatus.active, 9, .87, 16, 2, [
    'Write install guide',
    'Add first-site tutorial',
    'Screenshots for quickstart',
  ]),
  _Spec('feature/i18n-rtl', 'tomasz', BranchStatus.active, 7, .55, 22, 6, [
    'Mirror layout for RTL',
    'Arabic sample site',
    'Fix bidi in code blocks',
  ], parent: 'feature/i18n'),
];

String _sha(String key, int i) {
  var h = seedFor('$key#$i');
  final b = StringBuffer();
  for (var k = 0; k < 5; k++) {
    b.write(h.toRadixString(16).padLeft(8, '0'));
    h = seedFor('$h$k');
  }
  return b.toString().substring(0, 40);
}

DateTime _ago(DateTime now, double days) =>
    now.subtract(Duration(minutes: (days * 1440).round()));

/// Newest-first commits spread between [oldest] and [newest] days ago.
List<Commit> _spread({
  required String key,
  required DateTime now,
  required int n,
  required double oldest,
  required double newest,
  required List<String> msgs,
  required String Function(int) author,
}) => [
  for (var i = 0; i < n; i++)
    Commit(
      sha: _sha(key, i),
      message: msgs[i % msgs.length],
      author: author(i),
      date: _ago(now, newest + (oldest - newest) * (n > 1 ? i / (n - 1) : 0)),
    ),
];

/// A deterministic snapshot of "example/lantern", built from the design
/// page's sample data.
RepoSnapshot sampleSnapshot({DateTime? now}) {
  final today = now ?? DateTime.utc(2026, 10, 5, 12);
  final trunk = [
    for (var i = 0; i < 120; i++)
      Commit(
        sha: _sha('main', i),
        message: _mainMsgs[i % _mainMsgs.length],
        author: _authors[i % _authors.length],
        date: today.subtract(Duration(days: 4 * i)),
      ),
  ];
  final start = trunk.last.date;
  final span = trunk.first.date.difference(start);

  final branches = <Branch>[];
  final byName = <String, Branch>{};
  for (final s in _specs) {
    final pruned = s.status == BranchStatus.pruned;
    final commits = pruned
        ? <Commit>[]
        : _spread(
            key: s.name,
            now: today,
            n: s.commits,
            oldest: s.oldest,
            newest: s.newest,
            msgs: s.msgs,
            author: (_) => s.author,
          );
    DateTime? fork;
    if (s.parent != null) {
      final pc = byName[s.parent]!.commits;
      final a = pc.last.date, z = pc.first.date;
      fork = a.add(z.difference(a) ~/ 2);
    } else {
      final t = ((s.at - .267) / .6).clamp(0.0, 1.0);
      fork = s.at < .267
          ? start.subtract(const Duration(days: 20))
          : start.add(Duration(seconds: (span.inSeconds * t).round()));
    }
    final b = Branch(
      name: s.name,
      status: s.status,
      deleted: s.deleted,
      commits: commits,
      commitCount: s.commits,
      parent: s.parent,
      forkSha: _sha('${s.name}-fork', 0),
      forkDate: fork,
      lastActivity: pruned
          ? _ago(today, 300)
          : commits.isEmpty
          ? null
          : commits.first.date,
      author: s.author,
      prNumber: s.deleted ? 100 + branches.length : null,
    );
    branches.add(b);
    byName[b.name] = b;
  }
  // Most recently active first.
  branches.sort((a, b) => b.lastActivity!.compareTo(a.lastActivity!));

  return RepoSnapshot(
    owner: 'example',
    name: 'lantern',
    description: 'A small static-site generator',
    stars: 2400,
    defaultBranch: 'main',
    trunkCommits: trunk,
    branches: branches,
    authors: aggregateAuthors(trunk, branches),
    fetchedAt: today,
  );
}

/// A large seeded snapshot for performance checks.
RepoSnapshot stressSnapshot({int branches = 40, int commitsPerBranch = 40}) {
  final now = DateTime.utc(2026, 10, 5, 12);
  final r = Mulberry32(2024);
  final trunk = [
    for (var i = 0; i < 120; i++)
      Commit(
        sha: _sha('stress-main', i),
        message: _mainMsgs[i % _mainMsgs.length],
        author: _authors[i % _authors.length],
        date: now.subtract(Duration(days: 4 * i)),
      ),
  ];
  final list = <Branch>[];
  for (var i = 0; i < branches; i++) {
    final x = r();
    final status = x < .5
        ? BranchStatus.active
        : x < .7
        ? BranchStatus.merged
        : x < .9
        ? BranchStatus.stale
        : BranchStatus.pruned;
    final pruned = status == BranchStatus.pruned;
    final newest = status == BranchStatus.stale
        ? 380 + r() * 100
        : r() * (status == BranchStatus.merged ? 200 : 40);
    final oldest = newest + 10 + r() * 150;
    final author = _authors[(r() * _authors.length).floor()];
    final name = 'topic/branch-${i.toString().padLeft(2, '0')}';
    final commits = pruned
        ? <Commit>[]
        : _spread(
            key: name,
            now: now,
            n: commitsPerBranch,
            oldest: oldest,
            newest: newest,
            msgs: const ['Work in progress', 'Review feedback', 'Add tests'],
            author: (_) => author,
          );
    // About a fifth hang off an earlier branch.
    final sub = i > 3 && r() < .2;
    final parent = sub ? list[(r() * i).floor()] : null;
    DateTime fork;
    if (parent != null && parent.commits.length > 1) {
      final a = parent.commits.last.date, z = parent.commits.first.date;
      fork = a.add(z.difference(a) * r());
    } else {
      fork = now.subtract(Duration(days: (r() * 470).round()));
    }
    list.add(
      Branch(
        name: name,
        status: status,
        deleted: pruned || status == BranchStatus.merged,
        commits: commits,
        commitCount: commitsPerBranch,
        parent: parent != null && parent.status != BranchStatus.pruned
            ? parent.name
            : null,
        forkSha: _sha('$name-fork', 0),
        forkDate: fork,
        lastActivity: pruned ? _ago(now, 300) : commits.first.date,
        author: author,
      ),
    );
  }
  list.sort((a, b) => b.lastActivity!.compareTo(a.lastActivity!));
  return RepoSnapshot(
    owner: 'example',
    name: 'stress',
    description: 'Generated for performance checks',
    stars: 1,
    defaultBranch: 'main',
    trunkCommits: trunk,
    branches: list,
    authors: aggregateAuthors(trunk, list),
    fetchedAt: now,
  );
}
