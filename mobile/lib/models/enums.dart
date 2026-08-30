// Enum yang nilainya HARUS sama persis dengan string dari backend.

enum UnitStatus {
  kosong,
  terisi,
  renovasi;

  static UnitStatus fromApi(String value) => UnitStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => UnitStatus.kosong,
      );

  String get api => name;

  String get label => switch (this) {
        UnitStatus.kosong => 'Kosong',
        UnitStatus.terisi => 'Terisi',
        UnitStatus.renovasi => 'Renovasi',
      };
}

enum ReminderType {
  sewaJatuhTempo,
  kontrakHabis,
  maintenance,
  utilitas;

  static ReminderType fromApi(String value) => switch (value) {
        'sewa_jatuh_tempo' => ReminderType.sewaJatuhTempo,
        'kontrak_habis' => ReminderType.kontrakHabis,
        'maintenance' => ReminderType.maintenance,
        'utilitas' => ReminderType.utilitas,
        _ => ReminderType.maintenance,
      };

  String get api => switch (this) {
        ReminderType.sewaJatuhTempo => 'sewa_jatuh_tempo',
        ReminderType.kontrakHabis => 'kontrak_habis',
        ReminderType.maintenance => 'maintenance',
        ReminderType.utilitas => 'utilitas',
      };

  String get label => switch (this) {
        ReminderType.sewaJatuhTempo => 'Sewa jatuh tempo',
        ReminderType.kontrakHabis => 'Kontrak akan habis',
        ReminderType.maintenance => 'Maintenance',
        ReminderType.utilitas => 'Tagihan utilitas',
      };
}

enum ReminderStatus {
  pending,
  sent,
  done,
  dismissed;

  static ReminderStatus fromApi(String value) =>
      ReminderStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ReminderStatus.pending,
      );

  String get api => name;
}

enum DocumentType {
  ktp,
  suratKontrak,
  foto,
  lainnya;

  static DocumentType fromApi(String value) => switch (value) {
        'ktp' => DocumentType.ktp,
        'surat_kontrak' => DocumentType.suratKontrak,
        'foto' => DocumentType.foto,
        _ => DocumentType.lainnya,
      };

  String get api => switch (this) {
        DocumentType.ktp => 'ktp',
        DocumentType.suratKontrak => 'surat_kontrak',
        DocumentType.foto => 'foto',
        DocumentType.lainnya => 'lainnya',
      };

  String get label => switch (this) {
        DocumentType.ktp => 'KTP',
        DocumentType.suratKontrak => 'Surat kontrak',
        DocumentType.foto => 'Foto',
        DocumentType.lainnya => 'Lainnya',
      };
}
