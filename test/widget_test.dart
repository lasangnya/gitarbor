import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/app.dart';

void main() {
  testWidgets('shows the Gitarbor title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GitarborApp()));
    expect(find.text('Gitarbor'), findsOneWidget);
  });
}
