import 'parse.dart';

class Tenant {
  const Tenant({
    required this.id,
    required this.unitId,
    required this.name,
    required this.phone,
    required this.contractStart,
    required this.contractEnd,
    required this.rentAmount,
    required this.dueDay,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final int unitId;
  final String name;
  final String? phone;
  final DateTime? contractStart;
  final DateTime? contractEnd;
  final double? rentAmount;
  final int? dueDay;
  final bool isActive;
  final DateTime createdAt;

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json['id'] as int,
        unitId: json['unit_id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        contractStart: parseNullableDate(json['contract_start']),
        contractEnd: parseNullableDate(json['contract_end']),
        rentAmount: parseNullableDouble(json['rent_amount']),
        dueDay: json['due_day'] as int?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: parseDate(json['created_at']),
      );
}
