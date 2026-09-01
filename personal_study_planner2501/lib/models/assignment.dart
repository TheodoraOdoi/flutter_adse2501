// This class models a student's assignment(s).

// ========================================================================
// Assignment model
// ========================================================================

class Assignment {
  const Assignment({
    this.id,
    this.remoteId,
    required this.userId,
    required this.courseId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'not_started',
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    this.lastSyncedAt,
  });

  // ===============================================================
  // Local and remote identifiers
  // ===============================================================

  final int? id;
  final String? remoteId;

  // ===================================================================
  // Ownership and course relationship
  // ===================================================================

  final String userId;
  final int courseId;

  // ======================================================================
  // Assignment information
  // ======================================================================

  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final String status;

  // ======================================================
  // Synchronisation information
  // ======================================================

  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  // =====================================================
  // Convert model to SQLite map
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  // ==================================================
  // Create model from SQLite row
  // ===================================================

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] as int?,
      remoteId: map['remote_id'] as String?,
      userId: map['user_id'] as String,
      courseId: map['course_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] == null
          ? null
          : DateTime.parse(map['due_date'] as String),
      priority: map['priority'] as String? ?? 'medium',
      status: map['status'] as String? ?? 'not_started',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncStatus: map['sync_status'] as String? ?? 'pending',
      lastSyncedAt: map['last_synced_at'] == null
          ? null
          : DateTime.parse(map['last_synced_at'] as String),
    );
  }

  // ===============================================
  // Create a copy with selected values changed
  // ===============================================

  Assignment copyWith({
    int? id,
    String? remoteId,
    String? userId,
    int? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}