import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/app_state.dart';
import '../../tree/debug_tree_screen.dart';
import '../theme.dart';

enum _Act { day, system, night, motion, debug, print }

/// Theme choice, reduced motion and the hidden renderer debug screen.
/// With [onPrint] it also lists Print, for the phone's "more" menu.
class SettingsMenu extends ConsumerWidget {
  const SettingsMenu({
    super.key,
    this.icon = Icons.tune_rounded,
    this.size = 40,
    this.onPrint,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final s = ref.watch(settingsProvider);

    PopupMenuEntry<_Act> choice(_Act a, String label, bool on) => PopupMenuItem(
      value: a,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: on ? Icon(Icons.check, size: 18, color: t.cta) : null,
          ),
          Text(label),
        ],
      ),
    );

    return PopupMenuButton<_Act>(
      tooltip: 'Settings',
      color: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: t.line),
      ),
      constraints: BoxConstraints(minWidth: 220, maxWidth: 220),
      onSelected: (a) {
        final n = ref.read(settingsProvider.notifier);
        switch (a) {
          case _Act.day:
            n.set(s.copyWith(theme: ThemeChoice.day));
          case _Act.system:
            n.set(s.copyWith(theme: ThemeChoice.system));
          case _Act.night:
            n.set(s.copyWith(theme: ThemeChoice.night));
          case _Act.motion:
            n.set(s.copyWith(reduceMotion: !s.reduceMotion));
          case _Act.debug:
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DebugTreeScreen()),
            );
          case _Act.print:
            onPrint?.call();
        }
      },
      itemBuilder: (_) => [
        if (onPrint != null) ...[
          const PopupMenuItem(
            value: _Act.print,
            child: Row(children: [SizedBox(width: 24), Text('Print')]),
          ),
          const PopupMenuDivider(),
        ],
        choice(_Act.day, 'Day garden', s.theme == ThemeChoice.day),
        choice(_Act.system, 'Match system', s.theme == ThemeChoice.system),
        choice(_Act.night, 'Night garden', s.theme == ThemeChoice.night),
        const PopupMenuDivider(),
        choice(_Act.motion, 'Reduce motion', s.reduceMotion),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _Act.debug,
          child: Row(children: [SizedBox(width: 24), Text('Renderer debug')]),
        ),
      ],
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: t.ink2, size: 22),
      ),
    );
  }
}
