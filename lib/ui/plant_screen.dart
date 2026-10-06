import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/github_api.dart';
import '../data/repo_link.dart';
import '../state/app_state.dart';
import '../tree/sample_tree.dart';
import '../tree/tree_model.dart';
import '../tree/tree_painter.dart';
import '../tree/tree_view.dart';
import 'connect_github_sheet.dart';
import 'format.dart';
import 'growing_screen.dart';
import 'theme.dart';
import 'widgets/brand.dart';
import 'widgets/gcard.dart';
import 'widgets/mini_tree.dart';
import 'widgets/settings_menu.dart';

/// Recent trees whose repo name equals or is within edit distance 2 of
/// [repo], other than [owner]/[repo] itself.
List<String> suggestRepos(String owner, String repo, List<RecentTree> recent) {
  final typed = '$owner/$repo'.toLowerCase();
  return [
    for (final r in recent)
      if (r.fullName.toLowerCase() != typed &&
          editDistance(
                r.fullName.split('/').last.toLowerCase(),
                repo.toLowerCase(),
              ) <=
              2)
        r.fullName,
  ];
}

enum _ProblemKind { invalid, notFound }

class _Problem {
  const _Problem(this.kind, [this.repo = '']);
  final _ProblemKind kind;
  final String repo;
}

class PlantScreen extends ConsumerStatefulWidget {
  const PlantScreen({super.key});

  @override
  ConsumerState<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends ConsumerState<PlantScreen> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  late final TreeModel _sample;
  late final int _sampleBranches;
  _Problem? _problem;

  @override
  void initState() {
    super.initState();
    final snap = sampleSnapshot();
    _sampleBranches = snap.branches.length;
    _sample = TreeModelBuilder().build(snap);
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final link = parseRepoLink(_text.text);
    if (link == null) {
      setState(() => _problem = const _Problem(_ProblemKind.invalid));
      return;
    }
    _plant(link.owner, link.repo);
  }

  Future<void> _plant(String owner, String repo) async {
    setState(() {
      _problem = null;
      _text.text = '$owner/$repo';
    });
    ref.read(plantProvider.notifier).start(owner, repo);
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(builder: (_) => const GrowingScreen()),
    );
    if (!mounted) return;
    if (result is RepoNotFoundException) {
      setState(
        () => _problem = _Problem(_ProblemKind.notFound, '$owner/$repo'),
      );
    }
  }

  void _plantFull(String fullName) {
    final link = parseRepoLink(fullName);
    if (link != null) _plant(link.owner, link.repo);
  }

  Widget? _errorMessage(GitarborTokens t) {
    final p = _problem;
    if (p == null) return null;
    final base = TextStyle(fontSize: 13, color: t.ink2, height: 1.45);
    final span = switch (p.kind) {
      _ProblemKind.invalid => TextSpan(
        text:
            'That doesn\'t look like a GitHub repository. Try owner/repo or '
            'paste a link.',
      ),
      _ProblemKind.notFound => TextSpan(
        children: [
          const TextSpan(text: 'We couldn\'t find '),
          TextSpan(
            text: p.repo,
            style: mono(13, color: t.ink2),
          ),
          const TextSpan(
            text: '. Check the owner name, or connect GitHub if it is private.',
          ),
        ],
      ),
    };
    return Row(
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
          child: Text.rich(span, style: base, key: const Key('plant-error')),
        ),
      ],
    );
  }

  List<String> _suggestions(List<RecentTree> recent) {
    final p = _problem;
    if (p == null || p.kind != _ProblemKind.notFound) return const [];
    final link = parseRepoLink(p.repo);
    if (link == null) return const [];
    return suggestRepos(link.owner, link.repo, recent);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(body: w >= 700 ? _desktop(context, w) : _phone(context));
  }

  // ----------------------------------------------------------- shared bits

  Widget _field(GitarborTokens t) => _RepoField(
    controller: _text,
    focusNode: _focus,
    error: _problem != null,
    onSubmit: _submit,
  );

  Widget _chips(GitarborTokens t) => Wrap(
    spacing: 8,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text('Try', style: TextStyle(fontSize: 13, color: t.ink3)),
      ),
      for (final r in const [
        'flutter/flutter',
        'vercel/next.js',
        'rust-lang/rust',
      ])
        RepoChip(label: r, onTap: () => _plantFull(r)),
    ],
  );

  Widget _didYouMean(GitarborTokens t, List<String> names) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('DID YOU MEAN', style: TextStyles.label(t)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final n in names)
            RepoChip(label: n, selected: true, onTap: () => _plantFull(n)),
        ],
      ),
    ],
  );

  Widget _recent(GitarborTokens t, List<RecentTree> recent, int max) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('RECENTLY PLANTED', style: TextStyles.label(t)),
        const SizedBox(height: 8),
        for (final r in recent.take(max)) ...[
          _RecentRow(tree: r, now: now, onTap: () => _plantFull(r.fullName)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _connectFooter(GitarborTokens t) {
    final signedIn = ref.watch(tokenProvider).value != null;
    final small = TextStyle(fontSize: 12, color: t.ink3, height: 1.5);
    if (signedIn) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Connected to GitHub · ', style: small),
          _LinkText(
            'Sign out',
            onTap: () => ref.read(tokenProvider.notifier).signOut(),
          ),
        ],
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Public repositories work without signing in. ', style: small),
        _LinkText(
          'Connect GitHub',
          onTap: () => showConnectGitHubSheet(context),
        ),
        Text(' to plant private ones and lift rate limits.', style: small),
      ],
    );
  }

  // --------------------------------------------------------------- desktop

  Widget _desktop(BuildContext context, double w) {
    final t = context.tokens;
    final recent = ref.watch(recentTreesProvider);
    final reduce = ref.watch(settingsProvider.select((s) => s.reduceMotion));
    final left = w >= 1120 ? 560.0 : w * .5;
    final hPad = left < 480 ? 32.0 : 56.0;
    final stacked = left - hPad * 2 < 420;
    final err = _errorMessage(t);
    final names = _suggestions(recent);

    final plantButton = SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: _submit,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text('Plant tree'),
      ),
    );

    return Row(
      children: [
        SizedBox(
          width: left,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Brand(),
                      ),
                      const SizedBox(height: 64),
                      Text(
                        'Grow a living tree from any Git repository.',
                        style: TextStyles.display.copyWith(
                          fontSize: left < 480 ? 36 : 44,
                          color: t.ink,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Text(
                          'Every branch becomes a limb and every commit a '
                          'leaf. Merged work blossoms. Forgotten branches dry '
                          'out.',
                          style: TextStyle(
                            fontSize: 16,
                            color: t.ink2,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (stacked) ...[
                        _field(t),
                        const SizedBox(height: 12),
                        plantButton,
                      ] else
                        Row(
                          children: [
                            Expanded(child: _field(t)),
                            const SizedBox(width: 12),
                            plantButton,
                          ],
                        ),
                      if (err != null) ...[const SizedBox(height: 12), err],
                      if (names.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _didYouMean(t, names),
                      ],
                      const SizedBox(height: 24),
                      _chips(t),
                      const Spacer(),
                      if (recent.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _recent(t, recent, 3),
                      ],
                      const SizedBox(height: 24),
                      _connectFooter(t),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: t.line)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: TreeView(
                    model: _sample,
                    palette: t.tree,
                    labels: TreeLabels.compact,
                    wind: .5,
                    petals: true,
                    still: reduce,
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: GCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: t.moss,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('example/lantern', style: mono(13, color: t.ink)),
                        const SizedBox(width: 12),
                        Text(
                          'sample · $_sampleBranches branches',
                          style: TextStyle(fontSize: 12, color: t.ink3),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(top: 12, right: 12, child: SettingsMenu()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------- phone

  Widget _phone(BuildContext context) {
    final t = context.tokens;
    final recent = ref.watch(recentTreesProvider);
    final signedIn = ref.watch(tokenProvider).value != null;
    final err = _errorMessage(t);
    final names = _suggestions(recent);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(children: [Brand(), Spacer(), SettingsMenu()]),
                  const SizedBox(height: 24),
                  Text(
                    'Grow a tree from any repository.',
                    style: TextStyles.display.copyWith(
                      fontSize: 32,
                      height: 1.1,
                      color: t.ink,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _field(t),
                  if (err != null) ...[const SizedBox(height: 12), err],
                  if (names.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _didYouMean(t, names),
                  ],
                  if (recent.isEmpty && err == null) ...[
                    const SizedBox(height: 24),
                    _chips(t),
                  ],
                  if (recent.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _recent(t, recent, 2),
                  ],
                  const Spacer(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Plant tree'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (signedIn)
                    TextButton(
                      onPressed: () =>
                          ref.read(tokenProvider.notifier).signOut(),
                      child: const Text('Connected to GitHub · Sign out'),
                    )
                  else
                    TextButton(
                      onPressed: () => showConnectGitHubSheet(context),
                      child: const Text('Connect GitHub'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The "github.com/" prefixed input.
class _RepoField extends StatelessWidget {
  const _RepoField({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        final color = error ? t.rust : (focused ? t.cta : t.line);
        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: error || focused ? 2 : 1),
          ),
          child: Row(
            children: [
              Text('github.com/', style: mono(15, color: t.ink3)),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: mono(15, color: t.ink),
                  cursorColor: t.cta,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    hintText: 'owner/repo',
                    hintStyle: mono(15, color: t.ink3.withValues(alpha: .6)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pill chip, mono; [selected] uses the soft accent.
class RepoChip extends StatelessWidget {
  const RepoChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: selected ? t.ctaSoft : t.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? t.ctaLine : t.line),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: mono(12, color: selected ? t.ink : t.ink2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.tree,
    required this.now,
    required this.onTap,
  });

  final RecentTree tree;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.line2),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const MiniTree(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tree.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: mono(13, color: t.ink, weight: FontWeight.w500),
                    ),
                    Text(
                      '${tree.branches} branches · '
                      '${formatNumber(tree.commits)} commits',
                      style: TextStyle(fontSize: 12, color: t.ink3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatRelative(tree.plantedAt, now),
                style: TextStyle(fontSize: 12, color: t.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: t.ink2,
          height: 1.5,
          decoration: TextDecoration.underline,
          decorationColor: t.ink3,
        ),
      ),
    );
  }
}
