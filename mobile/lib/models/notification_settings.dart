import 'enums.dart';

/// Preferensi notifikasi pengguna. Disimpan lewat StorageService.
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.types = const {
      ReminderType.sewaJatuhTempo,
      ReminderType.kontrakHabis,
      ReminderType.maintenance,
      ReminderType.utilitas,
    },
    this.hour = 8,
    this.minute = 0,
  });

  /// Saklar utama.
  final bool enabled;

  /// Tipe reminder mana saja yang dinotifikasi.
  final Set<ReminderType> types;

  /// Jam & menit pengingat dikirim (mis. 08:00).
  final int hour;
  final int minute;

  bool wants(ReminderType type) => enabled && types.contains(type);

  NotificationSettings copyWith({
    bool? enabled,
    Set<ReminderType>? types,
    int? hour,
    int? minute,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      types: types ?? this.types,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'types': types.map((t) => t.api).toList(),
        'hour': hour,
        'minute': minute,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final rawTypes = (json['types'] as List?) ?? const [];
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      types: rawTypes.isEmpty
          ? const {}
          : rawTypes.map((e) => ReminderType.fromApi(e as String)).toSet(),
      hour: json['hour'] as int? ?? 8,
      minute: json['minute'] as int? ?? 0,
    );
  }
}
