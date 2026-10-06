import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/github_api.dart';
import '../data/models/repo_models.dart';
import '../state/app_state.dart';
import '../tree/tree_model.dart';
import '../tree/tree_painter.dart';
import '../tree/tree_view.dart';
import 'connect_github_sheet.dart';
import 'format.dart';
import 'live_screen.dart';
import 'theme.dart';
import 'widgets/brand.dart';
import 'widgets/gcard.dart';
import 'widgets/repo_crumb.dart';

/// Shown while a repository is fetched: the tree grows with the progress.
/// Pops with a [RepoNotFoundException] so the Plant screen can show it.
class GrowingScreen extends ConsumerStatefulWidget {
  const GrowingScreen({super.key});

  @override
  ConsumerState<GrowingScreen> createState() => _GrowingScreenState();
}

class _GrowingScreenState extends ConsumerState<GrowingScreen>
    with SingleTickerProviderStateMixin {
  /// Its value is the tree's growth, 0 to 1.
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  TreeModel? _placeholder;
  String? _placeholderKey;
  TreeModel? _real;
  bool _finishing = false;
  bool _leaving = false;

  bool get _reduce =>
      ref.read(settingsProvider).reduceMotion ||
      MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onState(ref.read(plantProvider));
    });
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  TreeModel _placeholderFor(PlantState s) {
    final branch = s.found?.defaultBranch ?? 'main';
    final key = '${s.owner}/${s.repo}@$branch';
    if (_placeholderKey != key) {
      _placeholderKey = key;
      _placeholder = TreeModelBuilder().build(
        RepoSnapshot(
          owner: s.found?.owner ?? s.owner,
          name: s.found?.name ?? s.repo,
          defaultBranch: branch,
          fetchedAt: DateTime.now(),
        ),
      );
    }
    return _placeholder!;
  }

  void _onState(PlantState? s) {
    if (s == null || !mounted) return;
    if (s.error is RepoNotFoundException) {
      if (!_leaving) {
        _leaving = true;
        Navigator.of(context).pop(s.error);
      }
      return;
    }
    if (s.error != null) return;
    final snap = s.snapshot;
    if (snap != null) {
      _finish(snap);
      return;
    }
    _finishing = false;
    final target = (s.progress * .3).clamp(0.0, .3);
    if (_reduce) {
      _grow.value = target;
    } else {
      _grow.animateTo(
        target,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
      );
    }
  }

  void _finish(RepoSnapshot snap) {
    if (_finishing) return;
    _finishing = true;
    setState(() => _real = TreeModelBuilder().build(snap));
    void go() {
      if (!mounted || _leaving) return;
      _leaving = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => LiveScreen(snapshot: snap)),
      );
    }

    if (_reduce) {
      _grow.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => go());
      return;
    }
    if (_grow.value < .3) _grow.value = .3;
    _grow
        .animateTo(
          1,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOut,
        )
        .whenComplete(go);
  }

  void _cancel() {
    ref.read(plantProvider.notifier).cancel();
    Navigator.of(context).pop();
  }

  void _retry(PlantState s) {
    _finishing = false;
    ref.read(plantProvider.notifier).start(s.owner, s.repo);
  }

  Future<void> _connect(PlantState s) async {
    await showConnectGitHubSheet(context);
    if (!mounted) return;
    if (ref.read(tokenProvider).value != null) _retry(s);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    ref.listen(plantProvider, (_, next) => _onState(next));
    final s = ref.watch(plantProvider);
    final reduce = ref.watch(settingsProvider.select((x) => x.reduceMotion));
    final narrow = MediaQuery.sizeOf(context).width < 700;
    if (s == null) return const Scaffold();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_leaving) {
          ref.read(plantProvider.notifier).cancel();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: t.surface,
                border: Border(bottom: BorderSide(color: t.line)),
              ),
              child: Row(
                children: [
                  const Brand(),
                  const SizedBox(width: 16),
                  Flexible(
                    child: RepoCrumb(owner: s.owner, repo: s.repo),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _cancel, child: const Text('Cancel')),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _grow,
                      builder: (_, _) => TreeView(
                        model: _real ?? _placeholderFor(s),
                        palette: t.tree,
                        grow: _grow.value,
                        wind: .35,
                        labels: TreeLabels.none,
                        still: reduce,
                      ),
                    ),
                  ),
                  Positioned(
                    left: narrow ? 16 : 40,
                    top: narrow ? 16 : 40,
                    child: SizedBox(
                      width: narrow
                          ? MediaQuery.sizeOf(context).width - 32
                          : 360,
                      child: GCard(
                        padding: const EdgeInsets.all(24),
                        child: s.error != null
                            ? _errorBody(t, s)
                            : _progressBody(t, s, reduce),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- content

  Widget _header(GitarborTokens t, PlantState s, String title) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('PLANTING', style: TextStyles.label(t)),
      const SizedBox(height: 6),
      Text(
        title,
        style: TextStyles.display.copyWith(
          fontSize: 26,
          height: 1.15,
          color: t.ink,
        ),
      ),
    ],
  );

  Widget _progressBody(GitarborTokens t, PlantState s, bool reduce) {
    final found = s.found;
    final mapped = s.mapped;
    final counted = s.counted;
    final since = counted?.since;

    String mappedSub() {
      if (mapped == null) {
        return s.toFetch > 0
            ? 'reading ${s.fetched} of ${s.toFetch} branches'
            : 'looking at branches and pull requests';
      }
      final c = mapped.counts;
      final parts = [
        '${c[BranchStatus.active] ?? 0} active',
        '${c[BranchStatus.merged] ?? 0} merged',
        '${c[BranchStatus.stale] ?? 0} stale',
        '${c[BranchStatus.pruned] ?? 0} pruned',
        if (mapped.omitted > 0) '${mapped.omitted} left out',
      ];
      return parts.join(' · ');
    }

    final foundSub = found == null
        ? 'asking GitHub'
        : [
            if ((found.description ?? '').isNotEmpty) found.description!,
            '★ ${formatCompact(found.stars)}',
          ].join(' · ');

    final steps = [
      _Step(done: found != null, title: 'Found the repository', sub: foundSub),
      _Step(
        done: mapped != null,
        title: mapped == null
            ? 'Mapping the branches'
            : 'Mapped ${mapped.total} branches',
        sub: mappedSub(),
      ),
      _Step(
        done: counted != null,
        title: counted == null
            ? 'Counting the commits'
            : 'Counted ${formatNumber(counted.commits)} commits',
        sub: counted == null
            ? 'one branch at a time'
            : 'from ${counted.authors} authors'
                  '${since == null ? '' : ' since ${monthYear(since)}'}',
      ),
      _Step(
        done: s.snapshot != null,
        title: 'Opening the leaves',
        sub: 'one leaf per commit',
      ),
    ];
    final nowIdx = steps.indexWhere((e) => !e.done);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(t, s, 'Growing ${s.owner}/${s.repo}'),
        const SizedBox(height: 20),
        TweenAnimationBuilder<double>(
          tween: Tween(end: s.progress),
          duration: reduce ? Duration.zero : const Duration(milliseconds: 500),
          builder: (_, v, _) => Container(
            height: 6,
            decoration: BoxDecoration(
              color: t.line2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: t.line),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: t.moss,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _StepRow(
            step: steps[i],
            state: steps[i].done
                ? _StepState.done
                : i == nowIdx
                ? _StepState.now
                : _StepState.pending,
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.ctaSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Blossoms mark branches that were merged. Dry, drooping limbs '
            'have had no commits for months.',
            style: TextStyle(fontSize: 13, color: t.ink2, height: 1.45),
          ),
        ),
      ],
    );
  }

  Widget _errorBody(GitarborTokens t, PlantState s) {
    final e = s.error;
    final String message;
    final List<Widget> actions;
    Widget back() =>
        OutlinedButton(onPressed: _cancel, child: const Text('Back'));
    Widget connect(String label) =>
        FilledButton(onPressed: () => _connect(s), child: Text(label));
    switch (e) {
      case UnauthorizedException():
        message = 'This repository is private or your token can\'t see it.';
        actions = [connect('Connect GitHub'), back()];
      case RateLimitException():
        final at = e.resetAt.toLocal();
        final mins = at.difference(DateTime.now()).inMinutes;
        final hh = at.hour.toString().padLeft(2, '0');
        final mm = at.minute.toString().padLeft(2, '0');
        message =
            'GitHub\'s hourly limit is used up. It resets at $hh:$mm '
            '(in ${mins < 1 ? 1 : mins} min).';
        actions = [connect('Connect GitHub to lift the limit'), back()];
      case NetworkException():
        message = 'Couldn\'t reach GitHub.';
        actions = [
          FilledButton(onPressed: () => _retry(s), child: const Text('Retry')),
          back(),
        ];
      default:
        message = 'Something went wrong while planting.';
        actions = [
          FilledButton(onPressed: () => _retry(s), child: const Text('Retry')),
          back(),
        ];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(t, s, '${s.owner}/${s.repo}'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 1),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: t.rust, shape: BoxShape.circle),
              child: Text(
                '!',
                style: TextStyle(
                  color: t.surface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14, color: t.ink, height: 1.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          actions[i],
        ],
      ],
    );
  }
}

class _Step {
  const _Step({required this.done, required this.title, required this.sub});
  final bool done;
  final String title, sub;
}

enum _StepState { done, now, pending }

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.state});

  final _Step step;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final done = state == _StepState.done;
    final lit = state != _StepState.pending;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(right: 12, top: 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? t.moss : Colors.transparent,
            border: Border.all(
              color: done
                  ? t.moss
                  : state == _StepState.now
                  ? t.cta
                  : t.line,
              width: state == _StepState.now ? 2 : 1.5,
            ),
          ),
          child: done ? Icon(Icons.check, size: 14, color: t.surface) : null,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 14,
                  color: lit ? t.ink : t.ink3,
                  height: 1.45,
                ),
              ),
              Text(step.sub, style: mono(12, color: t.ink3, height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}
