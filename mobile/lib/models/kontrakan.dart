import 'document_item.dart';
import 'parse.dart';
import 'unit.dart';

/// Bentuk ringkas (dari GET /kontrakan dan di dalam /dashboard).
class Kontrakan {
  const Kontrakan({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.unitCount,
    required this.occupiedCount,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int unitCount;
  final int occupiedCount;
  final DateTime createdAt;

  bool get hasLocation => latitude != null && longitude != null;

  factory Kontrakan.fromJson(Map<String, dynamic> json) => Kontrakan(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String?,
        latitude: parseNullableDouble(json['latitude']),
        longitude: parseNullableDouble(json['longitude']),
        unitCount: (json['unit_count'] as int?) ?? 0,
        occupiedCount: (json['occupied_count'] as int?) ?? 0,
        createdAt: parseDate(json['created_at']),
      );
}

/// Bentuk lengkap (dari GET /kontrakan/{id}) — ringkas + daftar unit & dokumen.
class KontrakanDetail extends Kontrakan {
  const KontrakanDetail({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.unitCount,
    required super.occupiedCount,
    required super.createdAt,
    required this.units,
    required this.documents,
  });

  final List<Unit> units;
  final List<DocumentItem> documents;

  factory KontrakanDetail.fromJson(Map<String, dynamic> json) {
    final base = Kontrakan.fromJson(json);
    return KontrakanDetail(
      id: base.id,
      name: base.name,
      address: base.address,
      latitude: base.latitude,
      longitude: base.longitude,
      unitCount: base.unitCount,
      occupiedCount: base.occupiedCount,
      createdAt: base.createdAt,
      units: ((json['units'] as List?) ?? const [])
          .map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: ((json['documents'] as List?) ?? const [])
          .map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
