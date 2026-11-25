import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Project list refreshes from empty and opens details', (
    tester,
  ) async {
    const projects = '''
[
  {
    "title": "Portfolio",
    "description": "A showcase of my work",
    "tech_stack": "Flutter",
    "project_url": "https://example.com"
  }
]
''';
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return switch (requests) {
        1 => http.Response('[]', 200),
        3 => http.Response('Unavailable', 500),
        _ => http.Response(projects, 200),
      };
    });
    addTearDown(client.close);

    await tester.pumpWidget(
      Provider<ApiClient>.value(
        value: ApiClient(client: client),
        child: const MaterialApp(home: ProjectListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final emptyMessage = find.text('No projects found.');
    final emptyScrollView = find.byType(SingleChildScrollView);
    expect(tester.getCenter(emptyMessage), tester.getCenter(emptyScrollView));

    await tester.drag(emptyScrollView, const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.text('Flutter\nA showcase of my work'), findsOneWidget);

    await tester.tap(find.text('Portfolio'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('A showcase of my work'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.textContaining('Failed to load projects'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Portfolio'), findsOneWidget);
  });
}
