import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

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
      expect(find.byType(ItemCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Each menu button shows its own SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (final name in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
