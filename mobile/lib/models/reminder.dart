import 'enums.dart';
import 'parse.dart';

class Reminder {
  const Reminder({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.type,
    required this.dueDate,
    required this.leadDays,
    required this.status,
    required this.title,
    required this.createdAt,
  });

  final int id;
  final int unitId;
  final int? tenantId;
  final ReminderType type;
  final DateTime dueDate;
  final int leadDays;
  final ReminderStatus status;
  final String? title;
  final DateTime createdAt;

  /// Selisih hari dari hari ini (bisa negatif kalau sudah lewat).
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  String get displayTitle => title ?? type.label;

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as int,
        unitId: json['unit_id'] as int,
        tenantId: json['tenant_id'] as int?,
        type: ReminderType.fromApi(json['type'] as String),
        dueDate: parseDate(json['due_date']),
        leadDays: json['lead_days'] as int? ?? 3,
        status: ReminderStatus.fromApi(json['status'] as String),
        title: json['title'] as String?,
        createdAt: parseDate(json['created_at']),
      );
}
