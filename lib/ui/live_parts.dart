import 'package:flutter/material.dart';

import '../data/models/repo_models.dart';
import 'format.dart';
import 'theme.dart';
import 'widgets/author_avatar.dart';
import 'widgets/focus_ring.dart';
import 'widgets/status_icon.dart';

/// Live / Print segmented tabs. Live is the current screen unless
/// [printActive] is set (the print screen), where [onLive] goes back.
class LiveTabs extends StatelessWidget {
  const LiveTabs({
    super.key,
    this.onPrint,
    this.onLive,
    this.printActive = false,
    this.height = 32,
  });

  final VoidCallback? onPrint;
  final VoidCallback? onLive;
  final bool printActive;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget tab(String label, bool on, VoidCallback? tap) => Semantics(
      button: true,
      selected: on,
      label: label,
      excludeSemantics: true,
      onTap: tap,
      child: FocusRing(
        radius: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: on ? t.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: t.line,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: tap,
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: on ? t.ink : t.ink2),
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab('Live', !printActive, printActive ? onLive : null),
          const SizedBox(width: 4),
          tab('Print', printActive, printActive ? null : onPrint),
        ],
      ),
    );
  }
}

String windLabel(double v) => v < 12 ? 'Calm' : (v < 60 ? 'Breeze' : 'Gusty');

/// Wind icon, label and a 96 px slider (0 to 100).
class WindControl extends StatelessWidget {
  const WindControl({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.air, size: 18, color: t.ink2),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            windLabel(value),
            style: TextStyle(fontSize: 13, color: t.ink2),
          ),
        ),
        SizedBox(
          width: 96,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(0, 100),
              min: 0,
              max: 100,
              onChanged: onChanged,
              semanticFormatterCallback: (_) => windLabel(value),
            ),
          ),
        ),
      ],
    );
  }
}

/// One author row; pressed uses the soft accent.
class AuthorTile extends StatelessWidget {
  const AuthorTile({
    super.key,
    required this.author,
    required this.rank,
    required this.pressed,
    required this.onTap,
    this.minHeight = 40,
  });

  final Author author;
  final int rank;
  final bool pressed;
  final VoidCallback onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: pressed,
      label: '${author.login}, ${author.commits} commits',
      excludeSemantics: true,
      onTap: onTap,
      child: FocusRing(
        radius: 10,
        child: Material(
          color: pressed ? t.ctaSoft : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: pressed ? t.ctaLine : Colors.transparent),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    AuthorAvatar(login: author.login, rank: rank),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        author.login,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text('${author.commits}', style: mono(12, color: t.ink3)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Branches/Authors/Legend tab strip for the phone sheet.
class PhoneTabs extends StatelessWidget {
  const PhoneTabs({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.paper,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                label: const ['Branches', 'Authors', 'Legend'][i],
                excludeSemantics: true,
                onTap: () => onChanged(i),
                child: FocusRing(
                  radius: 8,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onChanged(i),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == index ? t.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: i == index
                            ? [
                                BoxShadow(
                                  color: t.line,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        const ['Branches', 'Authors', 'Legend'][i],
                        style: TextStyle(
                          fontSize: 13,
                          color: i == index ? t.ink : t.ink2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A branch row in the phone sheet.
class BranchRow extends StatelessWidget {
  const BranchRow({
    super.key,
    required this.branch,
    required this.now,
    required this.selected,
    required this.onTap,
  });
  final Branch branch;
  final DateTime now;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final last = branch.lastActivity;
    final sub = [
      if (branch.author != null) branch.author!,
      if (last != null) formatAge(daysBetween(now, last)),
    ].join(' · ');
    return Semantics(
      button: true,
      selected: selected,
      label: '${branch.name}, $sub, ${branch.commitCount} commits',
      excludeSemantics: true,
      onTap: onTap,
      child: FocusRing(
        radius: 4,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? t.ctaSoft : null,
              border: Border(bottom: BorderSide(color: t.line2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.paper,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: StatusIcon(branch.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mono(13, color: t.ink, weight: FontWeight.w500),
                      ),
                      Text(sub, style: TextStyle(fontSize: 12, color: t.ink3)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text('${branch.commitCount}', style: mono(12, color: t.ink3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hover tooltip content.
class LeafTip extends StatelessWidget {
  const LeafTip({
    super.key,
    required this.limbName,
    required this.commit,
    required this.age,
    required this.rank,
    required this.more,
  });
  final String limbName;
  final Commit commit;
  final double age;
  final int rank;
  final int more;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(limbName, style: mono(12, color: t.ink3)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            commit.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank < 0 ? t.ink3 : t.author(rank),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${commit.author} · ${formatAge(age)}',
                style: TextStyle(fontSize: 12, color: t.ink2),
              ),
            ),
          ],
        ),
        if (more > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+$more more commits',
              style: TextStyle(fontSize: 12, color: t.ink3),
            ),
          ),
      ],
    );
  }
}

/// Small square-ish control used for zoom.
class ZoomButton extends StatelessWidget {
  const ZoomButton({
    super.key,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.fontSize = 18,
  });
  final String label, tooltip;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: FocusRing(
          radius: 8,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(label, style: TextStyle(fontSize: fontSize)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round play button.
class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.onTap, this.size = 40});
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: 'Replay growth',
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: 'Replay growth',
        child: FocusRing(
          radius: size / 2,
          child: Material(
            color: t.ink,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(Icons.play_arrow_rounded, color: t.paper, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The selected-limb card (tablet).
class LimbCard extends StatelessWidget {
  const LimbCard({
    super.key,
    required this.snapshot,
    required this.branch,
    required this.authorRank,
    required this.now,
    required this.onClose,
    required this.onOpen,
  });
  final RepoSnapshot snapshot;
  final Branch branch;
  final int authorRank;
  final DateTime now;
  final VoidCallback onClose, onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (label, color) = switch (branch.status) {
      BranchStatus.active => ('Active', t.sprout),
      BranchStatus.merged => ('Merged', t.blossom),
      BranchStatus.stale => ('Stale', t.amber),
      BranchStatus.pruned => ('Closed', t.tree.bark),
    };
    final last = branch.commits.isEmpty ? null : branch.commits.first;
    final fork = branch.forkDate;
    Widget key(String s) => Padding(
      padding: const EdgeInsets.only(right: 16, top: 3, bottom: 3),
      child: Text(s, style: TextStyle(fontSize: 13, color: t.ink3)),
    );
    Widget val(Widget w) =>
        Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: w);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: t.paper,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: t.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    branch.deleted ? '$label, deleted' : label,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Close',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: onClose,
              icon: Icon(Icons.close, size: 20, color: t.ink3),
            ),
          ],
        ),
        Text(
          branch.name,
          style: mono(16, color: t.ink, weight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(
              children: [
                key('Author'),
                val(
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: authorRank < 0 ? t.ink3 : t.author(authorRank),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          branch.author ?? 'unknown',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                key('Commits'),
                val(Text('${branch.commitCount}', style: mono(13))),
              ],
            ),
            TableRow(
              children: [
                key('Forked'),
                val(
                  Text(
                    'from ${branch.parent ?? snapshot.defaultBranch}${fork == null ? '' : ', ${formatAge(daysBetween(now, fork))}'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                key('Last leaf'),
                val(
                  Text(
                    last == null
                        ? '—'
                        : '“${last.message}” · ${formatAge(daysBetween(now, last.date))}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onOpen,
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          child: const Text('Open on GitHub'),
        ),
      ],
    );
  }
}
