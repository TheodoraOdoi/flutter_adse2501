// This class models a student's study session(s)

// --------------------------------------------------------
// Study session model
// -----------------------------------------------------------
class StudySession
{
  // ===============================================
  // Local and remote identifiers
  // ==============================================
  final int? id;
  final String? remoteId;

  // ===============================================================
  // Ownership and course relationship
  // ===============================================================
  final String userId;
  final int courseId;
  final int? assignmentId;

  // ==============================================================
  // Study session information
  // ==============================================================
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? notes;
  
  // ======================================
  // Synchronisation information
  //===================================
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  // ============================================
  // Constructor
  // ==========================================
  StudySession({
        this.id,
        this.remoteId,
        required this.userId,
        required this.courseId,
        this.assignmentId,
        required this.startedAt,
        this.endedAt,
        this.durationMinutes,
        this.notes,
        required this.createdAt,
        required this.updatedAt,
        this.syncStatus = "pending",
        this.lastSyncedAt});

  // ========================================================
  // Copy with constructor
  // ========================================================
  StudySession copyWith({
    int? id,
    String? remoteId,
    String? userId,
    int? courseId,
    int? assignmentId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      assignmentId: assignmentId ?? this.assignmentId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  // ========================================================
  // Convert model to SQLite map
  // ========================================================
  Map<String, dynamic> toMap()
  {
    return { // course_id -> snake case (used in sqlite fields and Python)
      'id': id,
      'remote_id': remoteId,
      'user_id': userId,
      'course_id': courseId,
      'assignment_id': assignmentId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  // ========================================================
  // Create model from SQLite map
  // ========================================================
  factory StudySession.fromMap(Map<String, dynamic> map)
  {
    return StudySession(
      id: map['id'] as int?,
      remoteId: map['remote_id'] as String?,
      userId: map['user_id'] as String,
      courseId: map['course_id'] as int,
      assignmentId: map['assignment_id'] as int?,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] == null
          ? null
          : DateTime.parse(map['ended_at'] as String),
      durationMinutes: map['duration_minutes'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncStatus: map['sync_status'] as String? ?? 'pending',
      lastSyncedAt: map['last_synced_at'] == null
          ? null
          : DateTime.parse(map['last_synced_at'] as String),
    );
  }
}