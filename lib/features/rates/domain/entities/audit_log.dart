/// One row from `GET api/rates/audit-logs`. The exact response shape isn't
/// documented anywhere in this repo (only the request params are), so
/// parsing is defensive — tries a few plausible key names per field and
/// falls back to null/unknown rather than throwing, and keeps [raw] around
/// so a detail view can show the whole entry regardless of which fields
/// above matched.
class AuditLog {
  const AuditLog({
    required this.id,
    this.recordId,
    this.tableName,
    this.action,
    this.userName,
    this.createdAt,
    this.raw = const {},
  });

  final String id;
  final String? recordId;
  final String? tableName;
  final String? action;
  final String? userName;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    String? str(dynamic v) => v?.toString();

    final user = json['user'] ?? json['causer'] ?? json['actor'];
    final userName = user is Map<String, dynamic>
        ? str(user['name'] ?? user['full_name'] ?? user['email'])
        : str(json['user_name'] ?? json['causer_name'] ?? json['actor_name']);

    return AuditLog(
      id: str(json['id'] ?? json['uuid']) ?? '',
      recordId: str(
        json['record_id'] ?? json['auditable_id'] ?? json['subject_id'],
      ),
      tableName: str(
        json['table_name'] ?? json['auditable_type'] ?? json['subject_type'],
      ),
      action: str(json['action'] ?? json['event'])?.toLowerCase(),
      userName: userName,
      createdAt: DateTime.tryParse(
        str(json['created_at'] ?? json['timestamp']) ?? '',
      ),
      raw: json,
    );
  }

  String get actionLabel => switch (action) {
    'create' => 'Created',
    'update' => 'Updated',
    'delete' => 'Deleted',
    null => '—',
    _ => '${action![0].toUpperCase()}${action!.substring(1)}',
  };
}
