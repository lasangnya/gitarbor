import 'package:flutter/material.dart';

import 'sample_tree.dart';
import 'tree_model.dart';
import 'tree_painter.dart';
import 'tree_palette.dart';
import 'tree_view.dart';

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

/// Plain debug screen for the tree renderer. Phase 4 replaces it.
class DebugTreeScreen extends StatefulWidget {
  const DebugTreeScreen({super.key});

  @override
  State<DebugTreeScreen> createState() => _DebugTreeScreenState();
}

class _DebugTreeScreenState extends State<DebugTreeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _replay;
  late final TreeModel _sample;
  TreeModel? _stress;
  bool _useStress = false;
  String _palette = 'day';
  double _wind = .55;
  double _grow = 1;
  TreeLabels _labels = TreeLabels.full;
  LeafHover? _hover;

  @override
  void initState() {
    super.initState();
    _sample = TreeModelBuilder().build(sampleSnapshot());
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

  TreeModel get _model => _useStress
      ? (_stress ??= TreeModelBuilder().build(stressSnapshot()))
      : _sample;

  TreePalette get _pal => switch (_palette) {
    'night' => TreePalette.night,
    'print' => TreePalette.print,
    _ => TreePalette.day,
  };

  int get _leafCount => _model.limbs.fold(0, (n, l) => n + l.leaves.length);

  @override
  Widget build(BuildContext context) {
    final model = _model;
    final hover = _hover;
    return Scaffold(
      backgroundColor: _pal.paper,
      body: Stack(
        children: [
          Positioned.fill(
            child: TreeView(
              model: model,
              palette: _pal,
              grow: _grow,
              wind: _wind,
              labels: _labels,
              onHover: (h) => setState(() => _hover = h),
            ),
          ),
          if (hover != null) _tooltip(hover),
          Positioned(top: 12, left: 12, child: _panel()),
        ],
      ),
    );
  }

  Widget _tooltip(LeafHover h) {
    final c = h.leaf.commits.first;
    return Positioned(
      left: h.position.dx + 12,
      top: h.position.dy + 12,
      child: IgnorePointer(
        child: Material(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    h.limb.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(c.message),
                  Text('${c.author} · ${formatAge(h.leaf.age)}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white.withValues(alpha: .92),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gitarbor',
                style: TextStyle(
                  fontFamily: 'Young Serif',
                  fontSize: 22,
                  color: Color(0xFF1C2826),
                ),
              ),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'day', label: Text('Day')),
                  ButtonSegment(value: 'night', label: Text('Night')),
                  ButtonSegment(value: 'print', label: Text('Print')),
                ],
                selected: {_palette},
                onSelectionChanged: (s) => setState(() => _palette = s.first),
              ),
              Row(
                children: [
                  const SizedBox(width: 44, child: Text('Wind')),
                  Expanded(
                    child: Slider(
                      value: _wind,
                      max: 1.25,
                      onChanged: (v) => setState(() => _wind = v),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 44, child: Text('Grow')),
                  Expanded(
                    child: Slider(
                      value: _grow,
                      onChanged: (v) {
                        _replay.stop();
                        setState(() => _grow = v);
                      },
                    ),
                  ),
                ],
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => _replay.forward(from: 0),
                    child: const Text('Replay'),
                  ),
                  Text('leaves: $_leafCount'),
                ],
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Text('Labels'),
                  DropdownButton<TreeLabels>(
                    value: _labels,
                    isDense: true,
                    items: [
                      for (final l in TreeLabels.values)
                        DropdownMenuItem(value: l, child: Text(l.name)),
                    ],
                    onChanged: (v) => setState(() => _labels = v ?? _labels),
                  ),
                ],
              ),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('Sample')),
                  ButtonSegment(value: true, label: Text('Stress')),
                ],
                selected: {_useStress},
                onSelectionChanged: (s) => setState(() {
                  _useStress = s.first;
                  _hover = null;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
