import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kontraku/widgets/app_bottom_nav.dart';
import 'package:kontraku/widgets/kontrakan_card.dart';
import 'package:kontraku/widgets/reminder_widgets.dart';

import 'support/harness.dart';

void main() {
  setUpAll(initLocale);

  Finder navItem(String label) => find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text(label),
      );

  Future<void> tapText(WidgetTester tester, String text) async {
    final f = find.text(text);
    await tester.scrollUntilVisible(f, 120,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('boot dengan token -> beranda tampil isinya', (tester) async {
    await pumpApp(tester, token: 'user-1');

    expect(find.text('Pak Budi'), findsWidgets); // header sapaan
    expect(find.text('Perlu perhatian'), findsOneWidget);
    expect(find.text('Kontrakan melati'), findsWidgets);
    expect(find.byType(KontrakanCard), findsNWidgets(2));
    // kartu "perlu perhatian" muncul (ada reminder dari data seed)
    expect(find.byType(AttentionCard), findsWidgets);
  });

  testWidgets('pindah antar tab lewat bottom nav', (tester) async {
    await pumpApp(tester, token: 'user-1');

    await tester.tap(navItem('Kontrakan'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Kontrakan'), findsOneWidget);
    expect(find.byType(KontrakanCard), findsNWidgets(2));

    await tester.tap(navItem('Reminder'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Reminder'), findsOneWidget);
    expect(find.byType(ReminderTile), findsWidgets);

    await tester.tap(navItem('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('budi@email.com'), findsOneWidget);
    expect(find.text('Otomatis'), findsOneWidget);
  });

  testWidgets('buka detail kontrakan -> lihat unit', (tester) async {
    await pumpApp(tester, token: 'user-1');

    await tester.tap(find.byType(KontrakanCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Kamar 1'), findsWidgets);
    expect(find.text('Kamar 2'), findsWidgets);
    expect(find.textContaining('Unit ('), findsOneWidget);
  });

  testWidgets('tambah kontrakan lewat form', (tester) async {
    await pumpApp(tester, token: 'user-1');

    await tester.tap(navItem('Kontrakan'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah kontrakan'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'mis. Kontrakan melati'),
        'Kontrakan Baru E2E');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan kontrakan'));
    await tester.pumpAndSettle();

    // kembali ke daftar, item baru muncul
    expect(find.widgetWithText(AppBar, 'Kontrakan'), findsOneWidget);
    expect(find.text('Kontrakan Baru E2E'), findsWidgets);
    expect(find.byType(KontrakanCard), findsNWidgets(3));
  });

  testWidgets('tandai reminder selesai -> hilang dari daftar', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await tester.tap(navItem('Reminder'));
    await tester.pumpAndSettle();

    final before = tester.widgetList(find.byType(ReminderTile)).length;
    expect(before, greaterThan(0));

    await tester.tap(find.descendant(
      of: find.byType(ReminderTile).first,
      matching: find.byIcon(Icons.circle_outlined),
    ));
    await tester.pumpAndSettle();

    expect(tester.widgetList(find.byType(ReminderTile)).length, before - 1);
  });

  testWidgets('ganti tema ke Gelap tidak error', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await tester.tap(navItem('Profil'));
    await tester.pumpAndSettle();

    await tapText(tester, 'Gelap');

    final ctx = tester.element(find.text('Gelap'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });

  testWidgets('logout -> kembali ke layar login', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await tester.tap(navItem('Profil'));
    await tester.pumpAndSettle();

    await tapText(tester, 'Keluar');
    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Kontraku'), findsOneWidget);
  });

  testWidgets('login dari awal -> masuk beranda', (tester) async {
    await pumpApp(tester); // tanpa token

    expect(find.text('Masuk ke Kontraku'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'budi@email.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Perlu perhatian'), findsOneWidget);
    expect(find.byType(KontrakanCard), findsNWidgets(2));
  });

  testWidgets('login password salah -> pesan error', (tester) async {
    await pumpApp(tester);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'budi@email.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'salahsalah');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Kontraku'), findsOneWidget); // tetap di login
    expect(find.textContaining('salah'), findsWidgets); // snackbar
  });
}
