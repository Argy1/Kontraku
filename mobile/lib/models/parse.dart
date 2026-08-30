// Fungsi bantu parsing JSON — dipakai semua model.

/// Backend mengirim uang (Decimal) sebagai string ("800000.00") atau angka.
double? parseNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

double parseDouble(Object? value) => parseNullableDouble(value) ?? 0;

/// Tanggal murni ("2026-09-08") atau datetime ISO ("2026-08-29T13:05:12Z").
DateTime? parseNullableDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

DateTime parseDate(Object? value) =>
    parseNullableDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
