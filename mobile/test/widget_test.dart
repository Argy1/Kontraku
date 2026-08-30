// Test unit untuk model & helper. Tidak butuh backend.

import 'package:flutter_test/flutter_test.dart';
import 'package:kontraku/models/models.dart';
import 'package:kontraku/utils/formatters.dart';

void main() {
  group('User.initials', () {
    User make(String name) => User(
          id: 1,
          name: name,
          email: 'a@b.com',
          createdAt: DateTime(2026, 1, 1),
        );

    test('dua kata -> dua huruf', () {
      expect(make('Pak Budi').initials, 'PB');
    });
    test('satu kata -> satu huruf', () {
      expect(make('Budi').initials, 'B');
    });
    test('kosong -> tanda tanya', () {
      expect(make('   ').initials, '?');
    });
  });

  group('Reminder.daysLeft', () {
    Reminder due(DateTime date) => Reminder.fromJson({
          'id': 1,
          'unit_id': 1,
          'tenant_id': null,
          'type': 'maintenance',
          'due_date': date.toIso8601String(),
          'lead_days': 3,
          'status': 'pending',
          'title': 'x',
          'created_at': '2026-01-01T00:00:00Z',
        });

    test('hari ini -> 0', () {
      expect(due(DateTime.now()).daysLeft, 0);
    });
    test('3 hari lagi', () {
      expect(due(DateTime.now().add(const Duration(days: 3))).daysLeft, 3);
    });
  });

  group('enum round-trip ke API', () {
    test('UnitStatus', () {
      expect(UnitStatus.fromApi('terisi'), UnitStatus.terisi);
      expect(UnitStatus.terisi.api, 'terisi');
    });
    test('ReminderType snake_case', () {
      expect(ReminderType.fromApi('sewa_jatuh_tempo'),
          ReminderType.sewaJatuhTempo);
      expect(ReminderType.sewaJatuhTempo.api, 'sewa_jatuh_tempo');
    });
  });

  group('relativeDays', () {
    test('kata-kata relatif', () {
      expect(relativeDays(0), 'Hari ini');
      expect(relativeDays(1), 'Besok');
      expect(relativeDays(5), '5 hari lagi');
      expect(relativeDays(-2), 'Terlambat 2 hari');
    });
  });

  group('parsing uang dari JSON', () {
    test('string dan angka sama-sama jadi double', () {
      final p1 = Payment.fromJson({
        'id': 1,
        'tenant_id': 1,
        'amount': '800000.00',
        'paid_date': '2026-08-01',
        'period_start': null,
        'note': null,
        'created_at': '2026-08-01T00:00:00Z',
      });
      expect(p1.amount, 800000);
    });
  });
}
