// This class represents a student's study note for a particular course in the database

// ---------------------------------------------------------------------------
// Study note model
// ---------------------------------------------------------------------------

class StudyNote {
  const StudyNote({
    this.id,
    this.remoteId,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    this.lastSyncedAt,
  });

  // ---------------------------------------------------------------------------
  // Local and remote identifiers
  // ---------------------------------------------------------------------------

  final int? id;
  final String? remoteId;

  // ---------------------------------------------------------------------------
  // Note information
  // ---------------------------------------------------------------------------

  final String userId;
  final int courseId;
  final String title;
  final String content;

  // ---------------------------------------------------------------------------
  // Synchronisation information
  // ---------------------------------------------------------------------------

  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  final String? lastSyncedAt;

  // ---------------------------------------------------------------------------
  // Convert model to SQLite map
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt,
    };
  }

  // ---------------------------------------------------------------------------
  // Create model from SQLite row
  // ---------------------------------------------------------------------------

  factory StudyNote.fromMap(Map<String, dynamic> map) {
    return StudyNote(
      id: map['id'] as int?,
      remoteId: map['remote_id'] as String?,
      userId: map['user_id'] as String,
      courseId: map['course_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      syncStatus: map['sync_status'] as String? ?? 'pending',
      lastSyncedAt: map['last_synced_at'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Create a copy with selected values changed
  // ---------------------------------------------------------------------------

  StudyNote copyWith({
    int? id,
    String? remoteId,
    String? userId,
    int? courseId,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
    String? lastSyncedAt,
  }) {
    return StudyNote(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}