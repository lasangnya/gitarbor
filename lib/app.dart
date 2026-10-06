import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/app_state.dart';
import 'ui/plant_screen.dart';
import 'ui/theme.dart';

class GitarborApp extends ConsumerWidget {
  const GitarborApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(settingsProvider.select((s) => s.theme));
    return MaterialApp(
      title: 'Gitarbor',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(GitarborTokens.day, Brightness.light),
      darkTheme: buildTheme(GitarborTokens.night, Brightness.dark),
      themeMode: switch (choice) {
        ThemeChoice.system => ThemeMode.system,
        ThemeChoice.day => ThemeMode.light,
        ThemeChoice.night => ThemeMode.dark,
      },
      home: const PlantScreen(),
    );
  }
}
