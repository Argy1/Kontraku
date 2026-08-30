import 'enums.dart';
import 'parse.dart';

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.kontrakanId,
    required this.fileUrl,
    required this.type,
    required this.label,
    required this.createdAt,
  });

  final int id;
  final int kontrakanId;
  final String fileUrl;
  final DocumentType type;
  final String? label;
  final DateTime createdAt;

  factory DocumentItem.fromJson(Map<String, dynamic> json) => DocumentItem(
        id: json['id'] as int,
        kontrakanId: json['kontrakan_id'] as int,
        fileUrl: json['file_url'] as String,
        type: DocumentType.fromApi(json['type'] as String),
        label: json['label'] as String?,
        createdAt: parseDate(json['created_at']),
      );
}
