import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';

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

      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
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

    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

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
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
