import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/app.dart';
import 'package:gitarbor/tree/debug_tree_screen.dart';

void main() {
  testWidgets('shows the debug tree screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GitarborApp()));
    expect(find.byType(DebugTreeScreen), findsOneWidget);
    expect(find.text('Gitarbor'), findsOneWidget);
  });
}
