import 'dart:convert';

class AuditEvent {
  AuditEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.targetDate,
    this.category,
    this.oldValue,
    this.newValue,
    this.reason,
    this.createdAt,
    this.metadata,
  });

  final String id;
  final String userId;
  final String eventType;
  final DateTime targetDate;
  final String? category;
  final int? oldValue;
  final int? newValue;
  final String? reason;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  AuditEvent withId(String id) => copyWith(id: id);

  AuditEvent ensureId(String Function() idFactory) => id.isEmpty ? copyWith(id: idFactory()) : this;

  AuditEvent ensureTimestamp() => createdAt == null ? copyWith(createdAt: DateTime.now()) : this;

  AuditEvent copyWith({
    String? id,
    DateTime? createdAt,
  }) {
    return AuditEvent(
      id: id ?? this.id,
      userId: userId,
      eventType: eventType,
      targetDate: targetDate,
      category: category,
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
      'oldValue': oldValue,
      'newValue': newValue,
      'reason': reason,
      'createdAt': createdAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AuditEvent.fromMap(Map<String, dynamic> map) {
    return AuditEvent(
      id: map['id'] as String,
      userId: map['userId'] as String,
      eventType: map['eventType'] as String,
      targetDate: DateTime.parse(map['targetDate'] as String),
      category: map['category'] as String?,
      oldValue: map['oldValue'] != null ? (map['oldValue'] as num).toInt() : null,
      newValue: map['newValue'] != null ? (map['newValue'] as num).toInt() : null,
      reason: map['reason'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_type': eventType,
      'target_date': targetDate.toIso8601String(),
      'category': category,
      'old_value': oldValue,
      'new_value': newValue,
      'reason': reason,
      'created_at': createdAt?.toIso8601String(),
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
    };
  }

  factory AuditEvent.fromDbMap(Map<String, dynamic> map) {
    return AuditEvent(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventType: map['event_type'] as String,
      targetDate: DateTime.parse(map['target_date'] as String),
      category: map['category'] as String?,
      oldValue: map['old_value'] != null ? (map['old_value'] as num).toInt() : null,
      newValue: map['new_value'] != null ? (map['new_value'] as num).toInt() : null,
      reason: map['reason'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata'] as String) : null,
    );
  }

  static String _encodeMetadata(Map<String, dynamic> metadata) => metadata.isEmpty ? '' : jsonEncode(metadata);

  static Map<String, dynamic> _decodeMetadata(String metadata) {
    if (metadata.isEmpty) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(metadata) as Map);
    } catch (_) {
      return {};
    }
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType,
      'targetDate': targetDate,
      'category': category,
      'oldValue': oldValue,
      'newValue': newValue,
      'reason': reason,
      'createdAt': createdAt ?? DateTime.now(),
      'lastModified': createdAt ?? DateTime.now(), // For sync tracking
      'metadata': metadata,
    };
  }

  /// Create from Firestore document
  factory AuditEvent.fromFirestore(Map<String, dynamic> data) {
    return AuditEvent(
      id: data['id'] as String,
      userId: data['userId'] as String,
      eventType: data['eventType'] as String,
      targetDate: (data['targetDate'] as DateTime),
      category: data['category'] as String?,
      oldValue: (data['oldValue'] as num?)?.toInt(),
      newValue: (data['newValue'] as num?)?.toInt(),
      reason: data['reason'] as String?,
      createdAt: (data['createdAt'] as DateTime),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}
