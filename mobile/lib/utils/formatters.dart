import 'package:intl/intl.dart';

/// Format tanggal & uang, semuanya gaya Indonesia.

final _dateFmt = DateFormat('d MMM yyyy', 'id_ID');
final _dayMonthFmt = DateFormat('d MMM', 'id_ID');

String formatDate(DateTime? date) => date == null ? '-' : _dateFmt.format(date);

String formatDayMonth(DateTime date) => _dayMonthFmt.format(date);

/// "Rp 800.000"
String rupiah(num? amount) {
  if (amount == null) return '-';
  final f = NumberFormat.decimalPattern('id_ID');
  return 'Rp ${f.format(amount.round())}';
}

/// Versi ringkas untuk kartu: "Rp 800rb", "Rp 1,2jt".
String rupiahShort(num? amount) {
  if (amount == null) return '-';
  final v = amount.toDouble();
  if (v >= 1000000) {
    final jt = v / 1000000;
    final s = jt == jt.roundToDouble()
        ? jt.toStringAsFixed(0)
        : jt.toStringAsFixed(1).replaceAll('.', ',');
    return 'Rp ${s}jt';
  }
  if (v >= 1000) return 'Rp ${(v / 1000).round()}rb';
  return 'Rp ${v.round()}';
}

/// "Hari ini", "Besok", "3 hari lagi", "Terlambat 2 hari".
String relativeDays(int daysLeft) {
  if (daysLeft == 0) return 'Hari ini';
  if (daysLeft == 1) return 'Besok';
  if (daysLeft > 1) return '$daysLeft hari lagi';
  if (daysLeft == -1) return 'Kemarin';
  return 'Terlambat ${-daysLeft} hari';
}

/// Sapaan menurut jam sekarang.
String greeting([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 11) return 'Selamat pagi';
  if (hour < 15) return 'Selamat siang';
  if (hour < 19) return 'Selamat sore';
  return 'Selamat malam';
}
