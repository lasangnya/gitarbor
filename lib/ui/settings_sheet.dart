import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../tree/debug_tree_screen.dart';
import 'connect_github_sheet.dart';
import 'theme.dart';
import 'widgets/focus_ring.dart';

/// Opens the settings sheet. [onPrint] adds a Print row (phone).
Future<void> showSettingsSheet(BuildContext context, {VoidCallback? onPrint}) {
  final t = context.tokens;
  final host = context;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: t.surface,
    constraints: const BoxConstraints(maxWidth: 520),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SettingsSheet(host: host, onPrint: onPrint),
  );
}

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key, required this.host, this.onPrint});

  /// Context under the sheet, used to open screens after it closes.
  final BuildContext host;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final signedIn = ref.watch(tokenProvider).value != null;
    final small = TextStyle(fontSize: 13, color: t.ink2, height: 1.4);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text.toUpperCase(), style: TextStyles.label(t)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Settings',
                    style: TextStyles.display.copyWith(
                      fontSize: 24,
                      color: t.ink,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, size: 20, color: t.ink3),
              ),
            ],
          ),
          if (onPrint != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onPrint!();
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Print'),
            ),
          ],
          heading('Theme'),
          Seg<ThemeChoice>(
            options: const {
              ThemeChoice.day: 'Day garden',
              ThemeChoice.system: 'Match system',
              ThemeChoice.night: 'Night garden',
            },
            value: s.theme,
            onChanged: (v) => notifier.set(s.copyWith(theme: v)),
          ),
          heading('Motion'),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reduce motion',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Stops the wind and the growing animation.',
                      style: small,
                    ),
                  ],
                ),
              ),
              Switch(
                value: s.reduceMotion,
                onChanged: (v) => notifier.set(s.copyWith(reduceMotion: v)),
              ),
            ],
          ),
          heading('GitHub'),
          Row(
            children: [
              Expanded(
                child: Text(
                  signedIn
                      ? 'Connected'
                      : 'Not connected. Public repositories work without it.',
                  style: small,
                ),
              ),
              const SizedBox(width: 12),
              signedIn
                  ? OutlinedButton(
                      onPressed: () =>
                          ref.read(tokenProvider.notifier).signOut(),
                      child: const Text('Sign out'),
                    )
                  : FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (host.mounted) showConnectGitHubSheet(host);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                      ),
                      child: const Text('Connect GitHub'),
                    ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!host.mounted) return;
                Navigator.of(host).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DebugTreeScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: t.ink3,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Renderer debug'),
            ),
          ),
        ],
      ),
    );
  }
}
