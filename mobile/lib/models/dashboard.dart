import 'enums.dart';
import 'kontrakan.dart';
import 'parse.dart';

class AttentionItem {
  const AttentionItem({
    required this.reminderId,
    required this.type,
    required this.title,
    required this.dueDate,
    required this.daysLeft,
    required this.unitName,
    required this.kontrakanName,
  });

  final int reminderId;
  final ReminderType type;
  final String title;
  final DateTime dueDate;
  final int daysLeft;
  final String unitName;
  final String kontrakanName;

  factory AttentionItem.fromJson(Map<String, dynamic> json) => AttentionItem(
        reminderId: json['reminder_id'] as int,
        type: ReminderType.fromApi(json['type'] as String),
        title: json['title'] as String,
        dueDate: parseDate(json['due_date']),
        daysLeft: json['days_left'] as int,
        unitName: json['unit_name'] as String,
        kontrakanName: json['kontrakan_name'] as String,
      );
}

class Dashboard {
  const Dashboard({
    required this.greetingName,
    required this.kontrakanCount,
    required this.activeReminderCount,
    required this.attention,
    required this.kontrakan,
  });

  final String greetingName;
  final int kontrakanCount;
  final int activeReminderCount;
  final List<AttentionItem> attention;
  final List<Kontrakan> kontrakan;

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
        greetingName: json['greeting_name'] as String,
        kontrakanCount: json['kontrakan_count'] as int,
        activeReminderCount: json['active_reminder_count'] as int,
        attention: ((json['attention'] as List?) ?? const [])
            .map((e) => AttentionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        kontrakan: ((json['kontrakan'] as List?) ?? const [])
            .map((e) => Kontrakan.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
