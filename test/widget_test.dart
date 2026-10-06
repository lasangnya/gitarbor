import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/app.dart';
import 'package:gitarbor/data/github_auth.dart';
import 'package:gitarbor/state/app_state.dart';
import 'package:gitarbor/ui/plant_screen.dart';

import 'ui/test_app.dart';

void main() {
  testWidgets('opens on the plant screen', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            TokenStore(store: MemorySecretStore()),
          ),
        ],
        child: const GitarborApp(),
      ),
    );
    expect(find.byType(PlantScreen), findsOneWidget);
    expect(
      find.text('Grow a living tree from any Git repository.'),
      findsOneWidget,
    );
  });
}
