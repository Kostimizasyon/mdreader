import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_md_explorer/main.dart';

void main() {
  testWidgets('App renders navigation shell and switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const GithubMarkdownExplorerApp());
    await tester.pumpAndSettle();

    expect(find.text('GitHub Markdown Explorer'), findsOneWidget);
    expect(find.text('No Active Repository Selected'), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('Repositories'), findsOneWidget);

    await tester.tap(find.text('Repositories'));
    await tester.pumpAndSettle();

    expect(find.text('Repository Manager'), findsOneWidget);
    expect(find.text('Saved Repositories'), findsOneWidget);
    expect(find.text('Add Repo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });
}