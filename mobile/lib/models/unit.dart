import 'enums.dart';
import 'parse.dart';

class Unit {
  const Unit({
    required this.id,
    required this.kontrakanId,
    required this.name,
    required this.status,
    required this.price,
    required this.createdAt,
  });

  final int id;
  final int kontrakanId;
  final String name;
  final UnitStatus status;
  final double? price;
  final DateTime createdAt;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json['id'] as int,
        kontrakanId: json['kontrakan_id'] as int,
        name: json['name'] as String,
        status: UnitStatus.fromApi(json['status'] as String),
        price: parseNullableDouble(json['price']),
        createdAt: parseDate(json['created_at']),
      );
}
