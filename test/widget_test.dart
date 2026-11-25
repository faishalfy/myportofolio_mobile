import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(800, 600),
    const Size(1440, 500),
  ]) {
    testWidgets('Homepage fits ${size.width} x ${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('MyPortfolio'), findsOneWidget);
      expect(find.byType(InfoCard), findsNWidgets(3));
      expect(find.text('2506612064'), findsOneWidget);
      expect(find.text('Faishal Falih'), findsOneWidget);
      expect(find.text('PBP B'), findsOneWidget);
      expect(find.byType(ItemCard), findsNWidgets(4));
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Kamu belum login.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Menu cards navigate or show their own SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();
    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Add Achievement'));
    await tester.tap(find.text('Add Achievement'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsNWidgets(2));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsNothing);

    await tester.ensureVisible(find.text('Edukasi'));
    await tester.tap(find.text('Edukasi'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu belum login.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Project creation preserves the form through a 401', (
    tester,
  ) async {
    final projectRequests = <http.Request>[];
    final logoutTokens = <String?>[];
    var logins = 0;
    final client = MockClient((request) async {
      switch (request.url.path) {
        case '/api/v1/auth/token/':
          return http.Response(
            jsonEncode({'token': 'session-${++logins}'}),
            200,
          );
        case '/api/v1/auth/logout/':
          logoutTokens.add(request.headers['authorization']);
          return http.Response('', 204);
        case '/api/v1/projects/':
          projectRequests.add(request);
          if (projectRequests.length == 1) return http.Response('', 401);
          return http.Response(request.body, 201);
        default:
          throw StateError('Unexpected request: ${request.url}');
      }
    });
    addTearDown(client.close);

    Future<void> login() async {
      await tester.enterText(find.byType(TextFormField).at(0), 'owner');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
    }

    final menuButton = find.byTooltip('Open navigation menu');
    await tester.pumpWidget(MyApp(apiClient: ApiClient(client: client)));
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Add Achievement'));
    await tester.pumpAndSettle();
    await login();
    expect(find.text('Add Project Form'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), ' Portfolio ');
    await tester.enterText(fields.at(1), 'A showcase');
    await tester.enterText(fields.at(2), 'Flutter');
    await tester.enterText(fields.at(3), 'example.com');
    final save = find.text('Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(
      find.text('Masukkan URL HTTP atau HTTPS yang valid.'),
      findsOneWidget,
    );
    expect(projectRequests, isEmpty);

    await tester.enterText(fields.at(3), 'https://example.com');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(logoutTokens, ['Token session-1']);
    expect(find.text('Sesi berakhir. Silakan login ulang.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await login();
    expect(find.text('https://example.com'), findsOneWidget);
    expect(projectRequests, hasLength(1));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(projectRequests.map((request) => request.headers['authorization']), [
      'Token session-1',
      'Token session-2',
    ]);
    expect(jsonDecode(projectRequests.last.body), {
      'title': 'Portfolio',
      'description': 'A showcase',
      'tech_stack': 'Flutter',
      'project_url': 'https://example.com',
      'project_image_url': '',
    });

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('https://example.com'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    final logoutCard = find.widgetWithText(ItemCard, 'Logout');
    await tester.ensureVisible(logoutCard);
    await tester.tap(logoutCard);
    await tester.pumpAndSettle();
    expect(logoutTokens, ['Token session-1', 'Token session-2']);
    expect(find.text('Logout berhasil.'), findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
  });

  testWidgets('Education form is reachable from drawer and validates years', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Institusi wajib diisi.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Universitas UI');
    await tester.enterText(find.byType(TextFormField).at(1), 'Informatika');
    await tester.enterText(find.byType(TextFormField).at(2), '2024');
    await tester.enterText(find.byType(TextFormField).at(3), '2023');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Tahun lulus harus sesudah tahun mulai.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(3), '2028');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Pendidikan berhasil ditambahkan!'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
