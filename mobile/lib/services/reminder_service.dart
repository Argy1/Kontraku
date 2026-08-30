import '../models/models.dart';
import 'api_client.dart';

class ReminderService {
  ReminderService(this._api);

  final ApiClient _api;

  Future<List<Reminder>> list({
    ReminderType? type,
    bool includeDone = false,
  }) async {
    final data = await _api.get('/reminders', query: {
      if (type != null) 'type': type.api,
      if (includeDone) 'include_done': true,
    }) as List;
    return data
        .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Reminder> create({
    required int unitId,
    int? tenantId,
    required ReminderType type,
    required DateTime dueDate,
    int leadDays = 3,
    String? title,
  }) async {
    final data = await _api.post('/reminders', body: {
      'unit_id': unitId,
      if (tenantId != null) 'tenant_id': tenantId,
      'type': type.api,
      'due_date': _date(dueDate),
      'lead_days': leadDays,
      if (title != null && title.isNotEmpty) 'title': title,
    });
    return Reminder.fromJson(data as Map<String, dynamic>);
  }

  Future<Reminder> updateStatus(int id, ReminderStatus status) async {
    final data = await _api.patch('/reminders/$id', body: {'status': status.api});
    return Reminder.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/reminders/$id');

  /// Buat ulang reminder otomatis dari data penyewa. Mengembalikan pesan backend.
  Future<String> refresh() async {
    final data = await _api.post('/reminders/refresh');
    return data['message'] as String;
  }

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
