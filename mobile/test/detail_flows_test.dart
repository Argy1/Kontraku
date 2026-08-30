import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kontraku/models/models.dart';
import 'package:kontraku/widgets/app_bottom_nav.dart';
import 'package:kontraku/widgets/kontrakan_card.dart';

import 'support/harness.dart';

void main() {
  setUpAll(initLocale);

  Finder navItem(String label) => find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text(label),
      );

  Future<void> openFirstKontrakan(WidgetTester tester) async {
    await tester.tap(find.byType(KontrakanCard).first);
    await tester.pumpAndSettle();
  }

  testWidgets('detail: tambah unit lewat bottom sheet', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await openFirstKontrakan(tester);

    expect(find.text('Kamar 1'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Tambah unit'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah unit'), findsWidgets);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'mis. Kamar 3'), 'Kamar Baru');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Kamar Baru'), findsWidgets);
    expect(find.textContaining('Unit (3)'), findsOneWidget);
  });

  testWidgets('detail -> unit -> tambah penyewa + status jadi terisi',
      (tester) async {
    await pumpApp(tester, token: 'user-1');
    await openFirstKontrakan(tester);

    // buka unit "Kamar 2" (kosong di seed)
    await tester.tap(find.text('Kamar 2').first);
    await tester.pumpAndSettle();
    expect(find.text('Ubah status'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah penyewa'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama penyewa'), 'Bu Sari');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan penyewa'));
    await tester.pumpAndSettle();

    expect(find.text('Bu Sari'), findsWidgets);
    // status otomatis jadi "Terisi"
    expect(find.text('Terisi'), findsWidgets);
  });

  testWidgets('unit: ubah penyewa (due_day) lewat tombol Ubah', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await openFirstKontrakan(tester);
    await tester.tap(find.text('Kamar 1').first); // Pak Joko, due_day 15
    await tester.pumpAndSettle();

    expect(find.text('Jatuh tempo tgl 15'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Ubah'));
    await tester.pumpAndSettle();
    expect(find.text('Ubah penyewa'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Jatuh tempo'), '25');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan perubahan'));
    await tester.pumpAndSettle();

    expect(find.text('Jatuh tempo tgl 25'), findsOneWidget);
  });

  testWidgets('unit: catat pembayaran + lihat riwayat', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await openFirstKontrakan(tester);
    await tester.tap(find.text('Kamar 1').first); // ada Pak Joko di seed
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Pembayaran'));
    await tester.pumpAndSettle();
    expect(find.text('Catat pembayaran'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Jumlah'), '800000');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Riwayat bayar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pembayaran'), findsWidgets);
    expect(find.textContaining('Rp'), findsWidgets);
  });

  testWidgets('unit: ganti status lewat chip', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await openFirstKontrakan(tester);
    await tester.tap(find.text('Kamar 2').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Renovasi'));
    await tester.pumpAndSettle();
    expect(find.text('Renovasi'), findsWidgets);
  });

  testWidgets('reminder manual lewat FAB', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await tester.tap(navItem('Reminder'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Reminder baru'), findsOneWidget);

    // pilih kontrakan -> unit
    await tester.tap(find.byType(DropdownButtonFormField<Kontrakan>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kontrakan melati').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<Unit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kamar 1').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul'), 'Servis pompa air');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan reminder'));
    await tester.pumpAndSettle();

    expect(find.text('Servis pompa air'), findsWidgets);
  });

  testWidgets('kontrakan: edit nama lalu hapus', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await tester.tap(navItem('Kontrakan'));
    await tester.pumpAndSettle();
    await openFirstKontrakan(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Ubah kontrakan'), findsOneWidget);

    final nameField = find.byType(TextFormField).first;
    await tester.enterText(nameField, 'Kontrakan Ganti Nama');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan perubahan'));
    await tester.pumpAndSettle();
    expect(find.text('Kontrakan Ganti Nama'), findsWidgets);

    // hapus
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Hapus kontrakan'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();

    // kembali ke daftar, tinggal 1 kontrakan
    expect(find.widgetWithText(AppBar, 'Kontrakan'), findsOneWidget);
    expect(find.byType(KontrakanCard), findsOneWidget);
  });

  testWidgets('reminder: filter kategori', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await tester.tap(navItem('Reminder'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Kontrak'));
    await tester.pumpAndSettle();
    // seed punya 1 reminder kontrak_habis
    expect(find.textContaining('Kontrak akan habis'), findsWidgets);
  });
}
