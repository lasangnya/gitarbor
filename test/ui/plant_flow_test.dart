import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/data/github_api.dart';
import 'package:gitarbor/state/app_state.dart';
import 'package:gitarbor/ui/live_screen.dart';
import 'package:gitarbor/ui/plant_screen.dart';

import 'test_app.dart';

void main() {
  testWidgets('plants example/lantern and lands on the live tree', (
    tester,
  ) async {
    setSize(tester, 1280, 800);
    await tester.pumpWidget(testApp(const PlantScreen()));
    expect(
      find.text('Grow a living tree from any Git repository.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'example/lantern');
    await tester.tap(find.text('Plant tree'));
    await pumpFor(tester, const Duration(seconds: 5));

    expect(find.byType(LiveScreen), findsOneWidget);
    final rail = find.byKey(const Key('rail'));
    expect(rail, findsOneWidget);
    expect(
      find.descendant(of: rail, matching: find.text('branches')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.text('authors')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.text('AUTHORS')),
      findsOneWidget,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveScreen)),
    );
    expect(
      container.read(recentTreesProvider).single.fullName,
      'example/lantern',
    );
  });

  testWidgets('invalid input shows an inline error', (tester) async {
    setSize(tester, 1280, 800);
    await tester.pumpWidget(testApp(const PlantScreen()));
    await tester.enterText(find.byType(TextField), 'not a repo');
    await tester.tap(find.text('Plant tree'));
    await tester.pump();
    expect(
      find.textContaining("doesn't look like a GitHub repository"),
      findsOneWidget,
    );
    expect(find.text('!'), findsOneWidget);
  });

  testWidgets('phone layout shows the phone headline', (tester) async {
    setSize(tester, 390, 844);
    await tester.pumpWidget(testApp(const PlantScreen()));
    expect(find.text('Grow a tree from any repository.'), findsOneWidget);
    expect(find.text('Connect GitHub'), findsOneWidget);
  });

  testWidgets('not found goes back to Plant with the error', (tester) async {
    setSize(tester, 1280, 800);
    await tester.pumpWidget(testApp(const PlantScreen()));
    await tester.enterText(find.byType(TextField), 'nobody/nothing');
    await tester.tap(find.text('Plant tree'));
    await pumpFor(tester, const Duration(seconds: 2));
    expect(find.byType(PlantScreen), findsOneWidget);
    expect(find.textContaining("We couldn't find"), findsOneWidget);
  });

  Future<void> errorCase(
    WidgetTester tester,
    GitHubException e,
    String message,
    List<String> buttons,
  ) async {
    setSize(tester, 1280, 800);
    await tester.pumpWidget(testApp(const PlantScreen(), api: ThrowingApi(e)));
    await tester.enterText(find.byType(TextField), 'example/lantern');
    await tester.tap(find.text('Plant tree'));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.textContaining(message), findsOneWidget);
    for (final b in buttons) {
      expect(find.text(b), findsOneWidget);
    }
  }

  testWidgets(
    'unauthorized error card',
    (tester) => errorCase(
      tester,
      const UnauthorizedException('no'),
      "This repository is private or your token can't see it.",
      ['Connect GitHub', 'Back'],
    ),
  );

  testWidgets(
    'rate limit error card',
    (tester) => errorCase(
      tester,
      RateLimitException(
        'limit',
        resetAt: DateTime.now().add(const Duration(minutes: 20)),
      ),
      "GitHub's hourly limit is used up. It resets at",
      ['Connect GitHub to lift the limit', 'Back'],
    ),
  );

  testWidgets(
    'network error card',
    (tester) => errorCase(
      tester,
      const NetworkException('down'),
      "Couldn't reach GitHub.",
      ['Retry', 'Back'],
    ),
  );

  test('suggestRepos matches names within edit distance 2', () {
    final r = [
      RecentTree(
        fullName: 'example/lantern',
        branches: 1,
        commits: 1,
        plantedAt: DateTime(2026),
      ),
      RecentTree(
        fullName: 'a/zzzzzzzz',
        branches: 1,
        commits: 1,
        plantedAt: DateTime(2026),
      ),
    ];
    expect(suggestRepos('lantern', 'lantern', r), ['example/lantern']);
    expect(suggestRepos('example', 'lantern', r), isEmpty);
    expect(suggestRepos('x', 'lanturn', r), ['example/lantern']);
  });
}
