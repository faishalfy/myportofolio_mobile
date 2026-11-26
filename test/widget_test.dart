import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_detail_screen.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
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
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/education/');
      expect(request.headers['authorization'], isNull);
      return http.Response(
        '[{"institution":"Universitas Indonesia","education_level":"S1",'
        '"study_program":"Ilmu Komputer","start_year":2025}]',
        200,
      );
    });
    addTearDown(client.close);
    await tester.pumpWidget(MyApp(apiClient: ApiClient(client: client)));

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
    expect(find.byType(EducationListScreen), findsOneWidget);
    await tester.tap(find.text('Universitas Indonesia'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationDetailScreen), findsOneWidget);
    expect(find.text('Ilmu Komputer'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

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

  testWidgets(
    'Education drawer route refreshes and saves after reauthentication',
    (tester) async {
      final initialResponse = Completer<http.Response>();
      var listRequests = 0;
      var logins = 0;
      final posts = <http.Request>[];
      final logoutTokens = <String?>[];
      Map<String, dynamic>? createdEducation;
      final client = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/token/') {
          return http.Response(
            jsonEncode({'token': 'session-${++logins}'}),
            200,
          );
        }
        if (request.url.path == '/api/v1/auth/logout/') {
          logoutTokens.add(request.headers['authorization']);
          return http.Response('', 204);
        }
        expect(request.url.path, '/api/v1/education/');
        if (request.method == 'POST') {
          posts.add(request);
          if (posts.length == 1) return http.Response('Token revoked', 401);
          if (posts.length == 2) return http.Response('Owner only', 403);
          createdEducation = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode(createdEducation), 201);
        }
        expect(request.method, 'GET');
        expect(request.headers['authorization'], isNull);
        return switch (++listRequests) {
          1 => await initialResponse.future,
          2 => http.Response('[]', 200),
          3 => http.Response(
            '[{"institution":"UI","education_level":"S1","start_year":2025}]',
            200,
          ),
          _ => http.Response(jsonEncode([createdEducation!]), 200),
        };
      });
      addTearDown(client.close);

      Future<void> login() async {
        expect(find.byType(LoginScreen), findsOneWidget);
        await tester.enterText(find.byType(TextFormField).at(0), 'owner');
        await tester.enterText(find.byType(TextFormField).at(1), 'password');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
      }

      Future<void> save() async {
        final button = find.widgetWithText(ElevatedButton, 'Simpan');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(MyApp(apiClient: ApiClient(client: client)));
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Edukasi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      initialResponse.complete(http.Response('Unavailable', 500));
      await tester.pumpAndSettle();
      expect(find.text('Gagal memuat daftar pendidikan.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada riwayat pendidikan.'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(find.text('UI'), findsOneWidget);
      expect(listRequests, 3);

      await tester.tap(find.byTooltip('Tambah pendidikan'));
      await tester.pumpAndSettle();
      expect(find.text('Add Education'), findsNothing);
      await login();

      await save();
      expect(find.text('Institusi wajib diisi.'), findsOneWidget);
      expect(find.text('Jenjang wajib diisi.'), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), ' Universitas UI ');
      await tester.enterText(fields.at(1), 'S1');
      await tester.enterText(fields.at(2), 'Informatika');
      await tester.enterText(fields.at(3), '2024');
      await tester.enterText(fields.at(4), '2023');
      await save();
      expect(
        find.text('Tahun lulus harus sesudah tahun mulai.'),
        findsOneWidget,
      );
      expect(posts, isEmpty);

      await tester.enterText(fields.at(4), '');
      await save();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sesi berakhir. Silakan login ulang.'), findsOneWidget);
      expect(logoutTokens, isEmpty);

      await login();
      expect(find.text(' Universitas UI '), findsOneWidget);
      expect(posts, hasLength(1));
      await save();
      expect(
        find.text('Hanya pemilik portofolio yang dapat menambah pendidikan.'),
        findsOneWidget,
      );
      expect(find.byType(LoginScreen), findsNothing);

      await save();
      expect(find.text('Pendidikan berhasil ditambahkan!'), findsOneWidget);
      expect(posts.map((request) => request.headers['authorization']), [
        'Token session-1',
        'Token session-2',
        'Token session-2',
      ]);
      expect(createdEducation, {
        'institution': 'Universitas UI',
        'education_level': 'S1',
        'study_program': 'Informatika',
        'start_year': 2024,
        'end_year': null,
        'logo_url': '',
      });

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationListScreen), findsOneWidget);
      expect(find.text('Universitas UI'), findsOneWidget);
      expect(listRequests, 4);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await tester.pumpAndSettle();
      expect(logoutTokens, ['Token session-2']);
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
