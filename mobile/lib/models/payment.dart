import 'parse.dart';

class Payment {
  const Payment({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.paidDate,
    required this.periodStart,
    required this.note,
    required this.createdAt,
  });

  final int id;
  final int tenantId;
  final double amount;
  final DateTime paidDate;
  final DateTime? periodStart;
  final String? note;
  final DateTime createdAt;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as int,
        tenantId: json['tenant_id'] as int,
        amount: parseDouble(json['amount']),
        paidDate: parseDate(json['paid_date']),
        periodStart: parseNullableDate(json['period_start']),
        note: json['note'] as String?,
        createdAt: parseDate(json['created_at']),
      );
}
