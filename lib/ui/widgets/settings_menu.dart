import 'package:flutter/material.dart';

import '../settings_sheet.dart';
import '../theme.dart';

/// Gear button that opens the settings sheet. With [onPrint] the sheet also
/// lists Print, for the phone's "more" menu.
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    super.key,
    this.icon = Icons.settings_outlined,
    this.size = 40,
    this.onPrint,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IconButton(
      tooltip: 'Settings',
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: EdgeInsets.zero,
      onPressed: () => showSettingsSheet(context, onPrint: onPrint),
      icon: Icon(icon, color: t.ink2, size: 22),
    );
  }
}
