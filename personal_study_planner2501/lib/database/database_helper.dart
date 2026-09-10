// 💾 Database helper class to manage sqlite database operations

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/course.dart';
import '../models/study_note.dart';

class DatabaseHelper
{
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _databaseName = "personal_study_planner2501.db";

  // Database version 1 creates the initial database schema.
  static const int _databaseVersion = 1;

  Database? _database;

  //-------------------------------------------
  // Singleton database access
  //--------------------------------------------
  Future<Database> get database async
  {
    if (_database != null) {return _database!;}

    _database = await _openDatabase();

    return _database!;
  }

  //-------------------------------------
  // Open the local database
  //------------------------------------
  Future<Database> _openDatabase() async
  {
    final databaseDirectory = await getDatabasesPath();

    final databasePath = path.join(
        databaseDirectory,
        _databaseName,
    );

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  //--------------------------------------------
  // Method to pick and upload an avatar
  //--------------------------------------------
  Future<void> _onConfigure(Database database) async
  {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  //-----------------------------------------------
  // Create Database
  //-----------------------------------------------
  Future<void> _onCreate(Database database, int version) async
  {
    await database.execute(
      //-----------------------------------------------
      // Create the courses table
      //-----------------------------------------------
        '''
      Create table courses(
      id Integer primary key autoincrement,
      remote_id text unique,
      user_id text not null,
      title text not null,
      description text,
      lecturer text,
      course_code text not null,
      semester text,
      academic_year integer,
      colour text,
      icon text,
      created_at text not null,
      updated_at text not null
      sync_status text not null default 'pending'
        check(sync_status in ('synced', 'pending', 'failed')),
      last_synced_at text  
      )
      '''
    );

    //-----------------------------------------------
    // Create the study_notes table
    //-----------------------------------------------
    await database.execute(
      '''
      Create table study_notes(
      id Integer primary key autoincrement,
      remote_id text unique,
      user_id text not null,
      course_id integer not null,
      title text not null,
      content text not null,
      created_at text not null,
      updated_at text not null,
      sync_status text not null default 'pending'
        check(sync_status in ('synced', 'pending', 'failed')),
      last_synced_at text,
      foreign key(course_id) 
      references courses(id)
      on delete cascade
      )
      '''
    );

    // ---------------------------------------
    // Create the assignments table
    // ---------------------------------------
    await database.execute(
        '''
        CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT UNIQUE,
        user_id TEXT NOT NULL,
        course_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'medium'
          CHECK (priority IN ('low', 'medium', 'high')),
        status TEXT NOT NULL DEFAULT 'not_started'
          CHECK (status IN ('not_started', 'in_progress', 'completed')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
          CHECK (sync_status IN ('synced', 'pending', 'failed')),
        last_synced_at TEXT,
        FOREIGN KEY (course_id)
          REFERENCES courses (id)
          ON DELETE CASCADE
      )
    '''
    );

    // ---------------------------------------
    // Create the study sessions table
    // ---------------------------------------
    await database.execute(
        '''
        CREATE TABLE study_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT UNIQUE,
        user_id TEXT NOT NULL,
        course_id INTEGER NOT NULL,
        assignment_id INTEGER,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        duration_minutes INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
          CHECK (sync_status IN ('synced', 'pending', 'failed')),
        last_synced_at TEXT,
        FOREIGN KEY (course_id)
          REFERENCES courses (id)
          ON DELETE CASCADE,
        FOREIGN KEY (assignment_id)
          REFERENCES assignments (id)
          ON DELETE SET NULL
      )
    '''
    );

    await _createIndexes(database);
  }

  //-----------------------------------------------
  // Create Database Indexes
  //-----------------------------------------------
  Future<void> _createIndexes(Database database) async
  {
    await database.execute('''
      CREATE INDEX idx_courses_user_id
      ON courses (user_id)
    ''');

    await database.execute('''
      CREATE INDEX idx_courses_sync_status
      ON courses (sync_status)
    ''');

    await database.execute('''
      CREATE INDEX idx_notes_user_id
      ON study_notes (user_id)
    ''');

    await database.execute('''
      CREATE INDEX idx_notes_course_id
      ON study_notes (course_id)
    ''');

    await database.execute('''
      CREATE INDEX idx_notes_sync_status
      ON study_notes (sync_status)
    ''');

    await database.execute('''
      CREATE INDEX idx_assignments_user_id
      ON assignments (user_id)
    ''');

    await database.execute('''
      CREATE INDEX idx_assignments_course_id
      ON assignments (course_id)
    ''');

    await database.execute('''
      CREATE INDEX idx_assignments_status
      ON assignments (status)
    ''');

    await database.execute('''
      CREATE INDEX idx_assignments_due_date
      ON assignments (due_date)
    ''');

    await database.execute('''
      CREATE INDEX idx_assignments_sync_status
      ON assignments (sync_status)
    ''');

    await database.execute('''
      CREATE INDEX idx_sessions_user_id
      ON study_sessions (user_id)
    ''');

    await database.execute('''
      CREATE INDEX idx_sessions_course_id
      ON study_sessions (course_id)
    ''');

    await database.execute('''
      CREATE INDEX idx_sessions_started_at
      ON study_sessions (started_at)
    ''');

    await database.execute('''
      CREATE INDEX idx_sessions_sync_status
      ON study_sessions (sync_status)
    ''');
  }

  // ---------------------------------------------------------------------------
  // Database migrations
  // ---------------------------------------------------------------------------

  Future<void> _onUpgrade(
      Database database,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await database.execute('''
        ALTER TABLE courses
        ADD COLUMN course_code TEXT
      ''');

      await database.execute('''
        ALTER TABLE courses
        ADD COLUMN lecturer TEXT
      ''');

      await database.execute('''
        ALTER TABLE courses
        ADD COLUMN semester TEXT
      ''');

      await database.execute('''
        ALTER TABLE courses
        ADD COLUMN academic_year INTEGER
      ''');

      await database.execute('''
        ALTER TABLE courses
        ADD COLUMN colour TEXT
      ''');

      await database.execute('''
        ALTER TABLE courses
        ADD COLUMN icon TEXT
      ''');
    }

    if (oldVersion < 3) {
      await database.execute('''
        ALTER TABLE assignments
        ADD COLUMN priority TEXT NOT NULL DEFAULT 'medium'
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_assignments_user_id
        ON assignments (user_id)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_assignments_course_id
        ON assignments (course_id)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_assignments_status
        ON assignments (status)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_assignments_due_date
        ON assignments (due_date)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_assignments_sync_status
        ON assignments (sync_status)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_sessions_user_id
        ON study_sessions (user_id)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_sessions_course_id
        ON study_sessions (course_id)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_sessions_started_at
        ON study_sessions (started_at)
      ''');

      await database.execute('''
        CREATE INDEX IF NOT EXISTS idx_sessions_sync_status
        ON study_sessions (sync_status)
      ''');
    }
  }

  // --------------------------------------------------------------------
  // Courses CRUD operations
  //--------------------------------------------------------------------
  // Insert Course
  Future<int> insertCourse(Course course) async
  {
    final database = await this.database;

    final courseData = course.toMap();

    courseData.remove('id');

    courseData['sync_status'] = 'pending';
    courseData['last_synced_at'] = null;

    return database.insert('courses', courseData);
  }

  // Get courses: optional userId allows the same method to be used by
  // getCourses(userId) and getCourses().
  Future<List<Course>> getCourses([String? userId]) async
  {
    final database = await this.database;

    final rows = await database.query(
      'courses',
      where: userId == null ? null: 'userId = ?',
      whereArgs: userId == null ? null: [userId],
      orderBy: 'title collate nocase asc',
    );

    return rows.map(Course.fromMap).toList();
  }

  // Get course by local id
  Future<Course?> getCourseById(int courseId,String userId) async
  {
    final database = await this.database;
    final rows = await database.query(
        'courses',
        where: 'id = ? and user_id = ?',
        whereArgs: [courseId, userId],
        limit: 1
    );

    if(rows.isEmpty) {return null;}

    return Course.fromMap(rows.first);
  }

  // Get courses by emote supabase id
  Future<Course?> getCourseByRemoteId(String remoteId, String userId) async
  {
    final database = await this.database;
    final rows = await database.query(
        'courses',
        where: 'remote_id = ? and user_id = ?',
        whereArgs: [remoteId, userId],
        limit: 1
    );

    if(rows.isEmpty) {return null;}

    return Course.fromMap(rows.first);
  }

  // Update course
  Future<int> updateCourse(Course course) async
  {
    final database = await this.database;
    final courseData = course.toMap();

    courseData.remove('id');
    courseData.remove('remote_id');

    courseData['updated_at'] = DateTime.now().toUtc().toIso8601String();
    courseData['sync_status'] = 'pending';
    courseData['last_synced_at'] = null;

    return database.update(
      'courses',
      courseData,
      where: 'id = ? AND user_id = ?',
      whereArgs: [course.id, course.userId],
    );
  }

  // Delete course
  Future<int> deleteCourse(int courseId, String userId) async
  {
    final database = await this.database;

    return database.delete(
      'courses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [courseId, userId],
    );
  }

  //-----------------------------------------------------------
  // Study Notes CRUD operations
  //-----------------------------------------------------------
  // Insert Study Notes
  Future<int> insertStudyNote(StudyNote note) async {
    final database = await this.database;

    final noteData = note.toMap();

    noteData.remove('id');

    noteData['sync_status'] = 'pending';
    noteData['last_synced_at'] = null;

    return database.insert(
      'study_notes',
      noteData,
    );
  }

  // ---------------------------------------------------------------------------
  // Get study notes for a course
  // ---------------------------------------------------------------------------

  Future<List<StudyNote>> getStudyNotes(
      int courseId,
      String userId,
      ) async {
    final database = await this.database;

    final rows = await database.query(
      'study_notes',
      where: 'course_id = ? AND user_id = ?',
      whereArgs: [courseId, userId],
      orderBy: 'updated_at DESC',
    );

    return rows.map(StudyNote.fromMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Get all study notes for a user
  // ---------------------------------------------------------------------------

  Future<List<StudyNote>> getAllStudyNotes(
      String userId,
      ) async {
    final database = await this.database;

    final rows = await database.query(
      'study_notes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return rows.map(StudyNote.fromMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Get study note by local ID
  // ---------------------------------------------------------------------------

  Future<StudyNote?> getStudyNoteById(
      int noteId,
      String userId,
      ) async {
    final database = await this.database;

    final rows = await database.query(
      'study_notes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [noteId, userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return StudyNote.fromMap(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Get study note by remote Supabase ID
  // ---------------------------------------------------------------------------

  Future<StudyNote?> getStudyNoteByRemoteId(
      String remoteId,
      String userId,
      ) async {
    final database = await this.database;

    final rows = await database.query(
      'study_notes',
      where: 'remote_id = ? AND user_id = ?',
      whereArgs: [remoteId, userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return StudyNote.fromMap(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Update study note
  // ---------------------------------------------------------------------------

  Future<int> updateStudyNote(StudyNote note) async {
    final database = await this.database;

    final noteData = note.toMap();

    noteData.remove('id');
    noteData.remove('remote_id');

    noteData['updated_at'] =
        DateTime.now().toUtc().toIso8601String();

    noteData['sync_status'] = 'pending';
    noteData['last_synced_at'] = null;

    return database.update(
      'study_notes',
      noteData,
      where: 'id = ? AND user_id = ?',
      whereArgs: [note.id, note.userId],
    );
  }

  // ---------------------------------------------------------------------------
  // Delete study note
  // ---------------------------------------------------------------------------

  Future<int> deleteStudyNote(
      int noteId,
      String userId,
      ) async {
    final database = await this.database;

    return database.delete(
      'study_notes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [noteId, userId],
    );
  }

  // ===========================================================================
  // ASSIGNMENTS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Convert an assignment map into SQLite-compatible values
  //
  // Assignment.courseId is currently a String in the model, while SQLite
  // stores courses.id as INTEGER. Numeric strings are converted here so the
  // foreign-key relationship remains consistent.
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _prepareAssignmentMap(
      Map<String, dynamic> assignment,
      ) {
    final data = Map<String, dynamic>.from(assignment);

    if (data['course_id'] is String) {
      data['course_id'] = int.tryParse(
        data['course_id'] as String,
      );
    }

    return data;
  }

  // ---------------------------------------------------------------------------
  // Insert assignment
  // ---------------------------------------------------------------------------

  Future<int> insertAssignment(
      Map<String, dynamic> assignment,
      ) async {
    final database = await this.database;

    final assignmentData = _prepareAssignmentMap(assignment);

    assignmentData.remove('id');

    assignmentData['sync_status'] = 'pending';
    assignmentData['last_synced_at'] = null;

    return database.insert(
      'assignments',
      assignmentData,
    );
  }

  // ---------------------------------------------------------------------------
  // Get assignments
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getAssignments({
    String? userId,
    String? courseId,
    String? status,
  }) async {
    final database = await this.database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    if (courseId != null) {
      final localCourseId = int.tryParse(courseId);

      if (localCourseId != null) {
        conditions.add('course_id = ?');
        arguments.add(localCourseId);
      }
    }

    if (status != null) {
      conditions.add('status = ?');
      arguments.add(status);
    }

    return database.query(
      'assignments',
      where: conditions.isEmpty
          ? null
          : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'due_date ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // Get assignment by local ID
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getAssignment(
      int id,
      ) async {
    final database = await this.database;

    final result = await database.query(
      'assignments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ---------------------------------------------------------------------------
  // Get assignment by local ID and user
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getAssignmentForUser(
      int id,
      String userId,
      ) async {
    final database = await this.database;

    final result = await database.query(
      'assignments',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ---------------------------------------------------------------------------
  // Update assignment
  // ---------------------------------------------------------------------------

  Future<int> updateAssignment(
      int id,
      Map<String, dynamic> assignment,
      ) async {
    final database = await this.database;

    final assignmentData = _prepareAssignmentMap(assignment);

    assignmentData.remove('id');
    assignmentData.remove('remote_id');

    assignmentData['updated_at'] =
        DateTime.now().toUtc().toIso8601String();

    assignmentData['sync_status'] = 'pending';
    assignmentData['last_synced_at'] = null;

    return database.update(
      'assignments',
      assignmentData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Delete assignment
  // ---------------------------------------------------------------------------

  Future<int> deleteAssignment(
      int id,
      ) async {
    final database = await this.database;

    return database.delete(
      'assignments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Mark assignment as completed
  // ---------------------------------------------------------------------------

  Future<int> markAssignmentCompleted(
      int id,
      ) async {
    final database = await this.database;

    return database.update(
      'assignments',
      {
        'status': 'completed',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status': 'pending',
        'last_synced_at': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===========================================================================
  // STUDY SESSIONS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Convert a study-session map into SQLite-compatible values
  //
  // The current StudySession model uses start_time and end_time, while the
  // SQLite schema uses started_at and ended_at. This method keeps that
  // translation in one place.
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _prepareStudySessionMap(
      Map<String, dynamic> studySession,
      ) {
    final data = Map<String, dynamic>.from(studySession);

    if (data.containsKey('start_time')) {
      data['started_at'] = data['start_time'];
      data.remove('start_time');
    }

    if (data.containsKey('end_time')) {
      data['ended_at'] = data['end_time'];
      data.remove('end_time');
    }

    if (data['course_id'] is String) {
      data['course_id'] = int.tryParse(
        data['course_id'] as String,
      );
    }

    return data;
  }

  // ---------------------------------------------------------------------------
  // Convert a SQLite study-session row to the model's expected field names
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _prepareStudySessionRow(
      Map<String, dynamic> row,
      ) {
    final data = Map<String, dynamic>.from(row);

    data['start_time'] = data['started_at'];
    data['end_time'] = data['ended_at'];

    data.remove('started_at');
    data.remove('ended_at');

    return data;
  }

  // ---------------------------------------------------------------------------
  // Insert study session
  // ---------------------------------------------------------------------------

  Future<int> insertStudySession(
      Map<String, dynamic> studySession,
      ) async {
    final database = await this.database;

    final studySessionData =
    _prepareStudySessionMap(studySession);

    studySessionData.remove('id');

    studySessionData['sync_status'] = 'pending';
    studySessionData['last_synced_at'] = null;

    return database.insert(
      'study_sessions',
      studySessionData,
    );
  }

  // ---------------------------------------------------------------------------
  // Get study sessions
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getStudySessions({
    String? userId,
    String? courseId,
  }) async {
    final database = await this.database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    if (courseId != null) {
      final localCourseId = int.tryParse(courseId);

      if (localCourseId != null) {
        conditions.add('course_id = ?');
        arguments.add(localCourseId);
      }
    }

    final rows = await database.query(
      'study_sessions',
      where: conditions.isEmpty
          ? null
          : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'started_at DESC',
    );

    return rows.map(_prepareStudySessionRow).toList();
  }

  // ---------------------------------------------------------------------------
  // Get study session by ID
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getStudySession(
      int id,
      ) async {
    final database = await this.database;

    final result = await database.query(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return _prepareStudySessionRow(result.first);
  }

  // ---------------------------------------------------------------------------
  // Update study session
  // ---------------------------------------------------------------------------

  Future<int> updateStudySession(
      int id,
      Map<String, dynamic> studySession,
      ) async {
    final database = await this.database;

    final studySessionData =
    _prepareStudySessionMap(studySession);

    studySessionData.remove('id');
    studySessionData.remove('remote_id');

    studySessionData['updated_at'] =
        DateTime.now().toUtc().toIso8601String();

    studySessionData['sync_status'] = 'pending';
    studySessionData['last_synced_at'] = null;

    return database.update(
      'study_sessions',
      studySessionData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Delete study session
  // ---------------------------------------------------------------------------

  Future<int> deleteStudySession(
      int id,
      ) async {
    final database = await this.database;

    return database.delete(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===========================================================================
  // DASHBOARD — ASSIGNMENTS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Upcoming assignments
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getUpcomingAssignments({
    String? userId,
  }) async {
    final database = await this.database;

    final now = DateTime.now();
    final nextWeek = now.add(
      const Duration(days: 7),
    );

    final conditions = <String>[
      'assignments.status != ?',
      'assignments.due_date >= ?',
      'assignments.due_date <= ?',
    ];

    final arguments = <dynamic>[
      'completed',
      now.toIso8601String(),
      nextWeek.toIso8601String(),
    ];

    if (userId != null) {
      conditions.add('assignments.user_id = ?');
      arguments.add(userId);
    }

    return database.rawQuery(
      '''
    SELECT
      assignments.*,
      courses.title AS course_name,
      courses.course_code
    FROM assignments
    INNER JOIN courses
      ON assignments.course_id = courses.id
    WHERE ${conditions.join(' AND ')}
    ORDER BY assignments.due_date ASC
    ''',
      arguments,
    );
  }

  // ---------------------------------------------------------------------------
  // Overdue assignments
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getOverdueAssignments({
    String? userId,
  }) async {
    final database = await this.database;

    final conditions = <String>[
      'assignments.status != ?',
      'assignments.due_date < ?',
    ];

    final arguments = <dynamic>[
      'completed',
      DateTime.now().toIso8601String(),
    ];

    if (userId != null) {
      conditions.add('assignments.user_id = ?');
      arguments.add(userId);
    }

    return database.rawQuery(
      '''
    SELECT
      assignments.*,
      courses.title AS course_name,
      courses.course_code
    FROM assignments
    INNER JOIN courses
      ON assignments.course_id = courses.id
    WHERE ${conditions.join(' AND ')}
    ORDER BY assignments.due_date ASC
    ''',
      arguments,
    );
  }

  // ---------------------------------------------------------------------------
  // Completed assignment count
  // ---------------------------------------------------------------------------

  Future<int> getCompletedAssignmentCount({
    String? userId,
  }) async {
    final database = await this.database;

    final conditions = <String>[
      'status = ?',
    ];

    final arguments = <dynamic>[
      'completed',
    ];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    final result = await database.rawQuery(
      '''
    SELECT COUNT(*) AS completed_count
    FROM assignments
    WHERE ${conditions.join(' AND ')}
    ''',
      arguments,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ===========================================================================
  // DASHBOARD — STUDY SESSIONS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Study time today
  // ---------------------------------------------------------------------------

  Future<int> getStudyTimeToday({
    String? userId,
  }) async {
    final database = await this.database;

    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final startOfTomorrow = startOfDay.add(
      const Duration(days: 1),
    );

    final conditions = <String>[
      'started_at >= ?',
      'started_at < ?',
    ];

    final arguments = <dynamic>[
      startOfDay.toIso8601String(),
      startOfTomorrow.toIso8601String(),
    ];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    final result = await database.rawQuery(
      '''
    SELECT COALESCE(
      SUM(duration_minutes),
      0
    ) AS total_minutes
    FROM study_sessions
    WHERE ${conditions.join(' AND ')}
    ''',
      arguments,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Study time this week
  // ---------------------------------------------------------------------------

  Future<int> getStudyTimeThisWeek({
    String? userId,
  }) async {
    final database = await this.database;

    final now = DateTime.now();

    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1),
    );

    final weekStart = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final conditions = <String>[
      'started_at >= ?',
    ];

    final arguments = <dynamic>[
      weekStart.toIso8601String(),
    ];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    final result = await database.rawQuery(
      '''
    SELECT COALESCE(
      SUM(duration_minutes),
      0
    ) AS total_minutes
    FROM study_sessions
    WHERE ${conditions.join(' AND ')}
    ''',
      arguments,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Study time by course
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getStudyTimeByCourse({
    String? userId,
  }) async {
    final database = await this.database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (userId != null) {
      conditions.add('courses.user_id = ?');
      arguments.add(userId);
    }

    final whereClause = conditions.isEmpty
        ? ''
        : 'WHERE ${conditions.join(' AND ')}';

    return database.rawQuery(
      '''
    SELECT
      courses.id,
      courses.course_code,
      courses.title AS course_name,
      COALESCE(
        SUM(study_sessions.duration_minutes),
        0
      ) AS total_minutes
    FROM courses
    LEFT JOIN study_sessions
      ON study_sessions.course_id = courses.id
    $whereClause
    GROUP BY
      courses.id,
      courses.course_code,
      courses.title
    ORDER BY total_minutes DESC
    ''',
      arguments,
    );
  }

  // ---------------------------------------------------------------------------
  // Study session count
  // ---------------------------------------------------------------------------

  Future<int> getStudySessionCount({
    String? userId,
  }) async {
    final database = await this.database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    final whereClause = conditions.isEmpty
        ? ''
        : 'WHERE ${conditions.join(' AND ')}';

    final result = await database.rawQuery(
      '''
    SELECT COUNT(*) AS session_count
    FROM study_sessions
    $whereClause
    ''',
      arguments,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Today's study sessions
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getTodaysStudySessions({
    String? userId,
  }) async {
    final database = await this.database;

    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final startOfTomorrow = startOfDay.add(
      const Duration(days: 1),
    );

    final conditions = <String>[
      'study_sessions.started_at >= ?',
      'study_sessions.started_at < ?',
    ];

    final arguments = <dynamic>[
      startOfDay.toIso8601String(),
      startOfTomorrow.toIso8601String(),
    ];

    if (userId != null) {
      conditions.add('study_sessions.user_id = ?');
      arguments.add(userId);
    }

    return database.rawQuery(
      '''
    SELECT
      study_sessions.*,
      courses.title AS course_name,
      courses.course_code
    FROM study_sessions
    INNER JOIN courses
      ON study_sessions.course_id = courses.id
    WHERE ${conditions.join(' AND ')}
    ORDER BY study_sessions.started_at DESC
    ''',
      arguments,
    );
  }

  // ===========================================================================
  // DASHBOARD — NOTES
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Recently created notes
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getRecentNotes({
    String? userId,
  }) async {
    final database = await this.database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (userId != null) {
      conditions.add('study_notes.user_id = ?');
      arguments.add(userId);
    }

    final whereClause = conditions.isEmpty
        ? ''
        : 'WHERE ${conditions.join(' AND ')}';

    return database.rawQuery(
      '''
    SELECT
      study_notes.*,
      courses.title AS course_name,
      courses.course_code
    FROM study_notes
    INNER JOIN courses
      ON study_notes.course_id = courses.id
    $whereClause
    ORDER BY study_notes.created_at DESC
    LIMIT 5
    ''',
      arguments,
    );
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Search assignments
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> searchAssignments({
    String? userId,
    String? keyword,
    // String? courseId,
    int? courseId,
    String? status,
  }) async {
    final database = await this.database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      conditions.add(
        '(title LIKE ? OR description LIKE ?)',
      );

      final searchTerm = '%${keyword.trim()}%';

      arguments.add(searchTerm);
      arguments.add(searchTerm);
    }

    if (courseId != null) {
      // final localCourseId = int.tryParse(courseId);
      final localCourseId = courseId;

      if (localCourseId != null) {
        conditions.add('course_id = ?');
        arguments.add(localCourseId);
      }
    }

    if (status != null) {
      conditions.add('status = ?');
      arguments.add(status);
    }

    return database.query(
      'assignments',
      where: conditions.isEmpty
          ? null
          : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'due_date ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // Search study notes
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> searchNotes({
    String? userId,
    String? keyword,
    String? courseId,
  }) async {
    final database = await this.database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (userId != null) {
      conditions.add('user_id = ?');
      arguments.add(userId);
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      conditions.add(
        '(title LIKE ? OR content LIKE ?)',
      );

      final searchTerm = '%${keyword.trim()}%';

      arguments.add(searchTerm);
      arguments.add(searchTerm);
    }

    if (courseId != null) {
      final localCourseId = int.tryParse(courseId);

      if (localCourseId != null) {
        conditions.add('course_id = ?');
        arguments.add(localCourseId);
      }
    }

    return database.query(
      'study_notes',
      where: conditions.isEmpty
          ? null
          : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'created_at DESC',
    );
  }

  // ===========================================================================
  // SYNCHRONISATION SUPPORT
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Mark course as pending
  // ---------------------------------------------------------------------------

  Future<void> markCoursePending(
      int courseId,
      ) async {
    final database = await this.database;

    await database.update(
      'courses',
      {
        'sync_status': 'pending',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'last_synced_at': null,
      },
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  // ---------------------------------------------------------------------------
  // Mark study note as pending
  // ---------------------------------------------------------------------------

  Future<void> markNotePending(
      int noteId,
      ) async {
    final database = await this.database;

    await database.update(
      'study_notes',
      {
        'sync_status': 'pending',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'last_synced_at': null,
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // ---------------------------------------------------------------------------
  // Mark assignment as pending
  // ---------------------------------------------------------------------------

  Future<void> markAssignmentPending(
      int assignmentId,
      ) async {
    final database = await this.database;

    await database.update(
      'assignments',
      {
        'sync_status': 'pending',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'last_synced_at': null,
      },
      where: 'id = ?',
      whereArgs: [assignmentId],
    );
  }

  // ---------------------------------------------------------------------------
  // Mark study session as pending
  // ---------------------------------------------------------------------------

  Future<void> markStudySessionPending(
      int studySessionId,
      ) async {
    final database = await this.database;

    await database.update(
      'study_sessions',
      {
        'sync_status': 'pending',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'last_synced_at': null,
      },
      where: 'id = ?',
      whereArgs: [studySessionId],
    );
  }

  // ===========================================================================
  // PENDING SYNCHRONISATION RECORDS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Get pending courses
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getPendingCourses() async {
    final database = await this.database;

    return database.query(
      'courses',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'updated_at ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // Get pending study notes
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getPendingStudyNotes() async {
    final database = await this.database;

    return database.query(
      'study_notes',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'updated_at ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // Get pending assignments
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getPendingAssignments() async {
    final database = await this.database;

    return database.query(
      'assignments',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'updated_at ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // Get pending study sessions
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getPendingStudySessions() async {
    final database = await this.database;

    return database.query(
      'study_sessions',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'updated_at ASC',
    );
  }

  // ===========================================================================
  // SYNCHRONISATION STATUS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Mark a record as synchronised
  // ---------------------------------------------------------------------------

  Future<void> markAsSynced(
      String tableName,
      int localId,
      ) async {
    final database = await this.database;

    await database.update(
      tableName,
      {
        'sync_status': 'synced',
        'last_synced_at':
        DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ---------------------------------------------------------------------------
  // Mark a record as failed
  // ---------------------------------------------------------------------------

  Future<void> markAsSyncFailed(
      String tableName,
      int localId,
      ) async {
    final database = await this.database;

    await database.update(
      tableName,
      {
        'sync_status': 'failed',
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ---------------------------------------------------------------------------
  // Get total number of pending records
  // ---------------------------------------------------------------------------

  Future<int> getPendingSyncCount() async {
    final database = await this.database;

    final result = await database.rawQuery(
      '''
    SELECT
      (
        SELECT COUNT(*)
        FROM courses
        WHERE sync_status IN ('pending', 'failed')
      )
      +
      (
        SELECT COUNT(*)
        FROM study_notes
        WHERE sync_status IN ('pending', 'failed')
      )
      +
      (
        SELECT COUNT(*)
        FROM assignments
        WHERE sync_status IN ('pending', 'failed')
      )
      +
      (
        SELECT COUNT(*)
        FROM study_sessions
        WHERE sync_status IN ('pending', 'failed')
      )
      AS pending_count
    ''',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Synchronisation helper methods
  // ---------------------------------------------------------------------------

  /// Returns all local records waiting to be synchronised.
  ///
  /// Only tables that participate in the synchronisation process are allowed.
  Future<List<Map<String, dynamic>>> getPendingRows(
      String tableName,
      ) async {
    _validateSyncTable(tableName);

    final database = await this.database;

    return database.query(
      tableName,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'updated_at ASC',
    );
  }

  /// Marks a local record as successfully synchronised.
  ///
  /// The remote_id is deliberately left unchanged because it is the stable
  /// identifier used to match the local record with its Supabase record.
  Future<void> markRowSynced(
      String tableName,
      int localId,
      ) async {
    _validateSyncTable(tableName);

    final database = await this.database;

    await database.update(
      tableName,
      {
        'sync_status': 'synced',
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Marks a local record as failed after a synchronisation attempt.
  ///
  /// The record remains in SQLite so that a later synchronisation attempt
  /// can retry it after the problem has been resolved.
  Future<void> markRowFailed(
      String tableName,
      int localId,
      ) async {
    _validateSyncTable(tableName);

    final database = await this.database;

    await database.update(
      tableName,
      {
        'sync_status': 'failed',
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Stores the stable UUID generated for a local record.
  ///
  /// The UUID becomes the ID of the corresponding Supabase record.
  /// This prevents duplicate cloud records when synchronisation is retried.
  Future<void> setRemoteId(
      String tableName,
      int localId,
      String remoteId,
      ) async {
    _validateSyncTable(tableName);

    final database = await this.database;

    await database.update(
      tableName,
      {
        'remote_id': remoteId,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ---------------------------------------------------------------------------
  // Validate synchronisation table names
  // ---------------------------------------------------------------------------

  void _validateSyncTable(String tableName) {
    const allowedTables = {
      'courses',
      'study_notes',
      'assignments',
      'study_sessions',
    };

    if (!allowedTables.contains(tableName)) {
      throw ArgumentError(
        'Table is not allowed for synchronisation: $tableName',
      );
    }
  }

  //---------------------------------------------------
  // Close the database
  //---------------------------------------------------
  Future<void> closeDatabase() async
  {
    if (_database != null)
    {
      await _database!.close();
      _database = null;
    }
  }
}