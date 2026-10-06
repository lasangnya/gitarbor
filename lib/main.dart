import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitarbor/app.dart';
import 'package:gitarbor/state/app_state.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  runApp(
    ProviderScope(
      overrides: [appDirProvider.overrideWithValue(dir)],
      child: const GitarborApp(),
    ),
  );
}
