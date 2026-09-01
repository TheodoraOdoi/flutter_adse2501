// ----------------------------------------------------------------------------
// The course model represents the course the student is enrolled in
// ----------------------------------------------------------------------------

class Course
{
  // ==================================================================
  // Local and remote identifiers
  // ==================================================================
  final int? id;
  final String? remoteId;

  // =================================================================
  // Course information
  // =================================================================
  final String userId;
  final String courseCode;
  final String name;
  final String? description;
  final String? lecturer;
  final String? semester;
  final int? academicYear;
  final String? colour;
  final String? icon;

  // ====================================================================
  // Synchronisation information
  // ====================================================================
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  final String? lastSyncedAt;

  // ===================================================================
  //Constructor
  //====================================================================
  const Course(
      {
        this.id,
        this.remoteId,
        required this.userId,
        required this.courseCode,
        required this.name,
        this.description,
        this.lecturer,
        this.semester,
        this.academicYear,
        this.colour,
        this.icon,
        required this.createdAt,
        required this.updatedAt,
        this.syncStatus = "pending",
        this.lastSyncedAt
      });

  // =======================================================
  // Convert model to SQLite map
  // =======================================================
  Map<String, dynamic> toMap()
  {
    return {
      'id': id,
      'remote_id': remoteId,
      'user_id': userId,
      'course_code': courseCode,

      // Sqlite column title will be mapped to Dart property "name"
      'title': name,
      'description': description,
      'lecturer': lecturer,
      'semester': semester,
      'academic_year': academicYear,
      'colour': colour,
      'icon': icon,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt
    };
  }

  // =============================================================
  // Create model from SQLite row
  // =============================================================
  factory Course.fromMap(Map<String, dynamic> map)
  {
    return Course(
      id: map["id"] as int?,
      remoteId: map["remote_id"] as String?,
      userId: map["user_id"] as String,
      courseCode: map["course_code"] as String,
      name: map["title"] as String,
      description: map["description"] as String?,
      lecturer: map["lecturer"] as String?,
      semester: map["semester"] as String?,
      academicYear: map["academic_year"] as int?,
      colour: map["colour"] as String?,
      icon: map["icon"] as String?,
      createdAt: map["created_at"] as String,
      updatedAt: map["updated_at"] as String,
      syncStatus: map["sync_status"] as String ?? "pending",
      lastSyncedAt: map["last_synced_at"] as String?,

    );
  }

  // ============================================================
  // Named Constructor for copying selected
  // ============================================================
  Course copyWith(
      {
        int? id,
        String? remoteId,
        String? userId,
        String? courseCode,
        String? name,
        String? description,
        String? lecturer,
        String? semester,
        int? academicYear,
        String? colour,
        String? icon,
        String? createdAt,
        String? updatedAt,
        String? syncStatus,
        String? lastSyncedAt,
      }) {
    return Course(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      courseCode: courseCode ?? this.courseCode,
      name: name ?? this.name,
      description: description ?? this.description,
      lecturer: lecturer ?? this.lecturer,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      colour: colour ?? this.colour,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
