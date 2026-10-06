import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/repo_models.dart';
import '../print/print_screen.dart';
import '../state/app_state.dart';
import '../tree/tree_geometry.dart';
import '../tree/tree_model.dart';
import '../tree/tree_painter.dart';
import '../tree/tree_view.dart';
import 'format.dart';
import 'live_parts.dart';
import 'theme.dart';
import 'widgets/author_avatar.dart';
import 'widgets/focus_ring.dart';
import 'widgets/brand.dart';
import 'widgets/gcard.dart';
import 'widgets/legend.dart';
import 'widgets/repo_crumb.dart';
import 'widgets/settings_menu.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key, required this.snapshot});

  final RepoSnapshot snapshot;

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen>
    with SingleTickerProviderStateMixin {
  late final TreeModel _model = TreeModelBuilder().build(widget.snapshot);
  late final Rect _bounds = TreeGeometry.bounds(_model);

  /// The tree's bounds with room for floating bars, in tree units.
  Rect _roomy({double top = 0, double bottom = 0}) => Rect.fromLTRB(
    _bounds.left,
    _bounds.top - top,
    _bounds.right,
    _bounds.bottom + bottom,
  );
  late final AnimationController _replay;

  double _grow = 1;
  double _windValue = 45;
  double _zoom = 1;
  Offset _pan = Offset.zero;
  bool _labels = true;

  /// Phone only: branch tags on the tree, off by default (they crowd 390 px).
  bool _tags = false;
  TreeFocus? _focus;
  LimbSpec? _selected;
  LeafHover? _hover;
  int _phoneTab = 0;

  RepoSnapshot get _snap => widget.snapshot;
  double get _wind => _windValue / 100 * 1.25;
  bool get _reduce => ref.read(settingsProvider).reduceMotion;

  @override
  void initState() {
    super.initState();
    _replay = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..addListener(() => setState(() => _grow = _replay.value));
  }

  @override
  void dispose() {
    _replay.dispose();
    super.dispose();
  }

  void _play() {
    if (_reduce) {
      _replay.stop();
      setState(() => _grow = 1);
      return;
    }
    _replay.forward(from: 0);
  }

  void _scrub(double v) {
    _replay.stop();
    setState(() => _grow = v);
  }

  void _scrubBy(double d) => _scrub((_grow + d).clamp(.04, 1));

  void _toggleLabels() {
    if (MediaQuery.sizeOf(context).width < 700) {
      setState(() => _tags = !_tags);
    } else {
      setState(() => _labels = !_labels);
    }
  }

  void _zoomBy(double f) => setState(() => _zoom = (_zoom * f).clamp(.6, 2.2));

  void _fit() => setState(() {
    _zoom = 1;
    _pan = Offset.zero;
  });

  void _toggleAuthor(String login) => setState(() {
    final f = _focus;
    _focus = f is AuthorFocus && f.login == login ? null : AuthorFocus(login);
    _selected = null;
  });

  void _toggleBranch(String name) => setState(() {
    final f = _focus;
    _focus = f is BranchFocus && f.name == name ? null : BranchFocus(name);
  });

  void _tapLimb(LimbSpec l) => setState(() {
    if (_selected?.name == l.name) {
      _selected = null;
      _focus = null;
    } else {
      _selected = l;
      _focus = BranchFocus(l.name);
    }
  });

  void _clearSelection() => setState(() {
    _selected = null;
    _focus = null;
  });

  void _print() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => PrintScreen(snapshot: _snap)));

  void _cycleWind() => setState(() {
    final l = windLabel(_windValue);
    _windValue = l == 'Calm' ? 45 : (l == 'Breeze' ? 85 : 0);
  });

  int _rank(String? login) => _model.authorRanks[login] ?? -1;

  Widget _tree({
    required TreeLabels labels,
    bool hover = false,
    bool tap = false,
    bool pan = false,
    Rect? viewBox,
  }) {
    final t = context.tokens;
    final reduce = ref.watch(settingsProvider.select((s) => s.reduceMotion));
    return Semantics(
      label:
          'Tree of ${_snap.fullName}: ${_snap.branches.length} branches, '
          '${formatNumber(_snap.totalCommits)} commits',
      image: true,
      child: TreeView(
        model: _model,
        palette: t.tree,
        grow: _grow,
        wind: _wind,
        still: reduce,
        labels: labels,
        petals: true,
        viewBox: viewBox,
        focus: _focus,
        selected: _selected?.name,
        zoom: _zoom,
        pan: _pan,
        onHover: hover ? (h) => setState(() => _hover = h) : null,
        onLimbTap: tap ? _tapLimb : null,
        onPan: pan ? (d) => setState(() => _pan += d) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.space): _play,
            const SingleActivator(LogicalKeyboardKey.equal): () =>
                _zoomBy(1.15),
            const SingleActivator(LogicalKeyboardKey.equal, shift: true): () =>
                _zoomBy(1.15),
            const SingleActivator(LogicalKeyboardKey.add): () => _zoomBy(1.15),
            const SingleActivator(LogicalKeyboardKey.numpadAdd): () =>
                _zoomBy(1.15),
            const SingleActivator(LogicalKeyboardKey.minus): () => _zoomBy(.87),
            const SingleActivator(LogicalKeyboardKey.numpadSubtract): () =>
                _zoomBy(.87),
            const SingleActivator(LogicalKeyboardKey.digit0): _fit,
            const SingleActivator(LogicalKeyboardKey.numpad0): _fit,
            const SingleActivator(LogicalKeyboardKey.keyL): _toggleLabels,
            const SingleActivator(LogicalKeyboardKey.escape): _clearSelection,
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                _scrubBy(-.05),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                _scrubBy(.05),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              body: w >= 1200
                  ? _desktop(context)
                  : w >= 700
                  ? _tablet(context)
                  : _phone(context),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------- shared

  Widget _scrubber(GitarborTokens t, {required double button}) {
    return Row(
      children: [
        PlayButton(onTap: _play, size: button),
        const SizedBox(width: 16),
        Expanded(
          child: Slider(
            value: _grow.clamp(.04, 1),
            min: .04,
            max: 1,
            onChanged: _scrub,
            semanticFormatterCallback: (_) =>
                monthYear(_model.dateAtGrowth(_grow)),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 72,
          child: Text(
            monthYear(_model.dateAtGrowth(_grow)),
            textAlign: TextAlign.right,
            style: mono(13, color: t.ink),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- desktop

  Widget _desktop(BuildContext context) {
    final t = context.tokens;
    final labelsOn = _labels;
    return Column(
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
                child: RepoCrumb(
                  owner: _snap.owner,
                  repo: _snap.name,
                  stars: _snap.stars,
                ),
              ),
              const Spacer(),
              LiveTabs(onPrint: _print),
              const SizedBox(width: 16),
              WindControl(
                value: _windValue,
                onChanged: (v) => setState(() => _windValue = v),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => setState(() => _labels = !_labels),
                style: OutlinedButton.styleFrom(
                  backgroundColor: labelsOn ? t.ctaSoft : t.surface,
                  side: BorderSide(color: labelsOn ? t.ctaLine : t.line),
                ),
                icon: const Icon(Icons.sell_outlined, size: 18),
                label: const Text('Labels'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _print,
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Print'),
              ),
              const SizedBox(width: 8),
              const SettingsMenu(),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rail(t),
              Expanded(child: _stage(t)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rail(GitarborTokens t) {
    final s = _snap;
    Widget stat(String v, String l) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: t.paper,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              v,
              style: mono(20, color: t.ink, weight: FontWeight.w500),
            ),
            Text(l, style: TextStyle(fontSize: 12, color: t.ink3)),
          ],
        ),
      ),
    );
    return Container(
      key: const Key('rail'),
      width: 296,
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(right: BorderSide(color: t.line)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.name,
              style: TextStyles.display.copyWith(fontSize: 22, color: t.ink),
            ),
            const SizedBox(height: 4),
            if ((s.description ?? '').isNotEmpty)
              Text(
                s.description!,
                style: TextStyle(fontSize: 13, color: t.ink2, height: 1.45),
              ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: t.ink2),
                children: [
                  const TextSpan(text: 'Default branch '),
                  TextSpan(
                    text: s.defaultBranch,
                    style: mono(13, color: t.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                stat('${s.branches.length}', 'branches'),
                const SizedBox(width: 8),
                stat(formatNumber(s.totalCommits), 'commits'),
                const SizedBox(width: 8),
                stat('${s.authors.length}', 'authors'),
              ],
            ),
            const SizedBox(height: 24),
            Text('AUTHORS', style: TextStyles.label(t)),
            const SizedBox(height: 8),
            for (final a in s.authors)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: AuthorTile(
                  author: a,
                  rank: _rank(a.login),
                  pressed:
                      _focus is AuthorFocus &&
                      (_focus as AuthorFocus).login == a.login,
                  onTap: () => _toggleAuthor(a.login),
                ),
              ),
            const SizedBox(height: 24),
            const Legend(),
            if (s.omittedBranches > 0) ...[
              const SizedBox(height: 16),
              Text(
                '${s.omittedBranches} older branches not drawn',
                style: TextStyle(fontSize: 12, color: t.ink3),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stage(GitarborTokens t) {
    return LayoutBuilder(
      builder: (context, c) {
        final hover = _hover;
        final scrubW = math.min(560.0, c.maxWidth - 32);
        return Stack(
          children: [
            Positioned.fill(
              child: Listener(
                onPointerSignal: (e) {
                  if (e is PointerScrollEvent) {
                    _zoomBy(e.scrollDelta.dy < 0 ? 1.1 : 1 / 1.1);
                  }
                },
                child: _tree(
                  labels: _labels ? TreeLabels.full : TreeLabels.none,
                  hover: true,
                  pan: true,
                  viewBox: _roomy(bottom: 100),
                ),
              ),
            ),
            if (hover != null)
              Positioned(
                left:
                    hover.position.dx.clamp(
                      128.0,
                      math.max(128.0, c.maxWidth - 128),
                    ) -
                    120,
                top: hover.position.dy - 14,
                child: IgnorePointer(
                  child: FractionalTranslation(
                    translation: const Offset(0, -1),
                    child: GCard(
                      width: 240,
                      padding: const EdgeInsets.all(12),
                      child: LeafTip(
                        limbName: hover.limb.name,
                        commit: hover.leaf.commits.first,
                        age: hover.leaf.age,
                        rank: _rank(hover.leaf.commits.first.author),
                        more: hover.leaf.commits.length - 1,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 24,
              top: 24,
              child: GCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ZoomButton(
                      label: '+',
                      tooltip: 'Zoom in',
                      onTap: () => _zoomBy(1.15),
                    ),
                    const SizedBox(height: 4),
                    ZoomButton(
                      label: '−',
                      tooltip: 'Zoom out',
                      onTap: () => _zoomBy(.87),
                    ),
                    const SizedBox(height: 4),
                    ZoomButton(
                      label: 'Fit',
                      tooltip: 'Fit',
                      fontSize: 12,
                      onTap: _fit,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: (c.maxWidth - scrubW) / 2,
              width: scrubW,
              child: GCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _scrubber(t, button: 40),
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------- tablet

  Widget _tablet(BuildContext context) {
    final t = context.tokens;
    final sel = _selected?.branch;
    return LayoutBuilder(
      builder: (context, c) {
        final barW = math.min(720.0, c.maxWidth - 32);
        return Stack(
          children: [
            Positioned.fill(
              child: _tree(
                labels: TreeLabels.full,
                tap: true,
                pan: true,
                viewBox: _roomy(top: 90, bottom: 110),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: 24,
              child: GCard(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                child: Row(
                  children: [
                    const Brand(showWord: false),
                    const SizedBox(width: 12),
                    Flexible(
                      child: RepoCrumb(
                        owner: _snap.owner,
                        repo: _snap.name,
                        leadingSlash: false,
                      ),
                    ),
                    const Spacer(),
                    _authorsButton(t),
                    const SizedBox(width: 16),
                    LiveTabs(onPrint: _print, height: 40),
                    const SizedBox(width: 8),
                    const SettingsMenu(size: 48),
                  ],
                ),
              ),
            ),
            if (sel != null)
              Positioned(
                left: 24,
                top: 112,
                width: 300,
                child: GCard(
                  padding: const EdgeInsets.all(20),
                  child: LimbCard(
                    snapshot: _snap,
                    branch: sel,
                    authorRank: _rank(sel.author),
                    now: _model.now,
                    onClose: _clearSelection,
                    onOpen: () => launchUrl(
                      branchUrl(_snap, sel),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 24,
              left: (c.maxWidth - barW) / 2,
              width: barW,
              child: GCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(child: _scrubber(t, button: 48)),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _cycleWind,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      icon: const Icon(Icons.air, size: 18),
                      label: Text(windLabel(_windValue)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _print,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Print'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _authorsButton(GitarborTokens t) {
    final f = _focus;
    return PopupMenuButton<String?>(
      tooltip: 'Authors',
      color: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: t.line),
      ),
      onSelected: (login) =>
          login == null ? setState(() => _focus = null) : _toggleAuthor(login),
      itemBuilder: (_) => [
        PopupMenuItem<String?>(
          height: 48,
          value: null,
          child: Text('All authors', style: TextStyle(color: t.ink2)),
        ),
        for (final a in _snap.authors)
          PopupMenuItem<String?>(
            height: 48,
            value: a.login,
            child: Row(
              children: [
                AuthorAvatar(login: a.login, rank: _rank(a.login)),
                const SizedBox(width: 10),
                Expanded(child: Text(a.login)),
                if (f is AuthorFocus && f.login == a.login)
                  Icon(Icons.check, size: 18, color: t.cta)
                else
                  Text('${a.commits}', style: mono(12, color: t.ink3)),
              ],
            ),
          ),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: f is AuthorFocus ? t.ctaSoft : t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: f is AuthorFocus ? t.ctaLine : t.line),
        ),
        child: Text(
          'Authors · ${_snap.authors.length}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- phone

  Widget _tagsToggle(GitarborTokens t) {
    return Semantics(
      button: true,
      toggled: _tags,
      label: 'Tags',
      excludeSemantics: true,
      onTap: _toggleLabels,
      child: FocusRing(
        radius: 16,
        child: Material(
          color: _tags ? t.ctaSoft : t.surface,
          shape: StadiumBorder(
            side: BorderSide(color: _tags ? t.ctaLine : t.line),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: _toggleLabels,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                'Tags',
                style: TextStyle(fontSize: 13, color: _tags ? t.ink : t.ink2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phone(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  Expanded(
                    child: Center(
                      child: RepoCrumb(
                        owner: _snap.owner,
                        repo: _snap.name,
                        leadingSlash: false,
                        center: true,
                      ),
                    ),
                  ),
                  _tagsToggle(t),
                  const SizedBox(width: 4),
                  SettingsMenu(
                    icon: Icons.more_horiz,
                    size: 48,
                    onPrint: _print,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final h = c.maxHeight;
                final treeH = math.min(420.0, h * .6);
                final initial = ((h - treeH + 24) / h).clamp(.25, .9);
                final branches = [..._snap.branches]
                  ..sort((a, b) {
                    final x = a.lastActivity, y = b.lastActivity;
                    if (x == null && y == null) return 0;
                    if (x == null) return 1;
                    if (y == null) return -1;
                    return y.compareTo(x);
                  });
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: treeH,
                      child: _tree(
                        labels: _tags ? TreeLabels.compact : TreeLabels.none,
                        tap: true,
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: initial,
                      minChildSize: math.min(.25, initial),
                      maxChildSize: .95,
                      snap: true,
                      builder: (context, scroll) => Container(
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: t.shadow,
                              offset: const Offset(0, -12),
                              blurRadius: 32,
                              spreadRadius: -16,
                            ),
                          ],
                        ),
                        child: CustomScrollView(
                          controller: scroll,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  12,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.line,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    PhoneTabs(
                                      index: _phoneTab,
                                      onChanged: (i) =>
                                          setState(() => _phoneTab = i),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_phoneTab == 0)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverList.builder(
                                  itemCount: branches.length,
                                  itemBuilder: (_, i) => BranchRow(
                                    branch: branches[i],
                                    now: _model.now,
                                    selected:
                                        _focus is BranchFocus &&
                                        (_focus as BranchFocus).name ==
                                            branches[i].name,
                                    onTap: () =>
                                        _toggleBranch(branches[i].name),
                                  ),
                                ),
                              )
                            else if (_phoneTab == 1)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverList.builder(
                                  itemCount: _snap.authors.length,
                                  itemBuilder: (_, i) {
                                    final a = _snap.authors[i];
                                    return AuthorTile(
                                      author: a,
                                      rank: _rank(a.login),
                                      minHeight: 48,
                                      pressed:
                                          _focus is AuthorFocus &&
                                          (_focus as AuthorFocus).login ==
                                              a.login,
                                      onTap: () => _toggleAuthor(a.login),
                                    );
                                  },
                                ),
                              )
                            else
                              const SliverPadding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                                sliver: SliverToBoxAdapter(
                                  child: Legend(showLabel: false),
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
