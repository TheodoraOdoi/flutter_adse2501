// --------------------------------------------------------------------------
// Application's synchronisation services
// --------------------------------------------------------------------------

// Imports
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';

class SyncService {
  SyncService._internal();

  static final SyncService instance = SyncService._internal();

  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;

  bool _isSynchronising = false;

  // ---------------------------------------------------------------------------
  // Synchronisation state
  // ---------------------------------------------------------------------------

  bool get isSynchronising => _isSynchronising;

  // ---------------------------------------------------------------------------
  // Start connectivity monitoring
  // ---------------------------------------------------------------------------

  void startMonitoring() {
    _connectivitySubscription ??=
        Connectivity().onConnectivityChanged.listen(
              (results) {
            final hasConnection = results.any(
                  (result) => result != ConnectivityResult.none,
            );

            if (hasConnection) {
              syncNow();
            }
          },
        );
  }

  // ---------------------------------------------------------------------------
  // Stop connectivity monitoring
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  // ---------------------------------------------------------------------------
  // Manually start synchronisation
  // ---------------------------------------------------------------------------

  Future<void> syncNow() async {
    if (_isSynchronising) {
      return;
    }

    _isSynchronising = true;

    try {
      final connectivityResults =
      await Connectivity().checkConnectivity();

      final hasConnection = connectivityResults.any(
            (result) => result != ConnectivityResult.none,
      );

      if (!hasConnection) {
        return;
      }

      final currentUser = _client.auth.currentUser;

      if (currentUser == null) {
        return;
      }

      final userId = currentUser.id;

      // Parent records must be synchronised before child records.
      await _synchroniseCourses(userId);
      await _synchroniseNotes(userId);
      await _synchroniseAssignments(userId);
      await _synchroniseStudySessions(userId);
    } catch (error) {
      // Individual records are marked as failed inside each
      // synchronisation method.
      //
      // This catch prevents one unexpected synchronisation error
      // from crashing the application.
    } finally {
      _isSynchronising = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Synchronise courses
  // ---------------------------------------------------------------------------

  Future<void> _synchroniseCourses(String userId) async {
    final rows = await _databaseHelper.getPendingRows('courses');

    for (final row in rows) {
      final localId = row['id'] as int;

      // Do not synchronise a row belonging to another authenticated user.
      if (row['user_id']?.toString() != userId) {
        continue;
      }

      try {
        final remoteId = await _ensureRemoteId(
          'courses',
          localId,
          row['remote_id']?.toString(),
        );

        final data = {
          'id': remoteId,
          'user_id': userId,
          'title': row['title'],
          'description': row['description'],
          'lecturer': row['lecturer'],
          'course_code': row['course_code'],
          'semester': row['semester'],
          'academic_year': row['academic_year'],
          'colour': row['colour'],
          'icon': row['icon'],
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
        };

        await _client
            .from('courses')
            .upsert(
          data,
          onConflict: 'id',
        );

        await _databaseHelper.markRowSynced(
          'courses',
          localId,
        );
      } catch (error) {
        await _databaseHelper.markRowFailed(
          'courses',
          localId,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Synchronise study notes
  // ---------------------------------------------------------------------------

  Future<void> _synchroniseNotes(String userId) async {
    final rows =
    await _databaseHelper.getPendingRows('study_notes');

    for (final row in rows) {
      final localId = row['id'] as int;

      // Do not synchronise a row belonging to another authenticated user.
      if (row['user_id']?.toString() != userId) {
        continue;
      }

      try {
        final remoteId = await _ensureRemoteId(
          'study_notes',
          localId,
          row['remote_id']?.toString(),
        );

        final localCourseId = row['course_id'] as int;

        final course = await _getLocalCourse(
          localCourseId,
          userId,
        );

        if (course == null) {
          throw Exception(
            'The local course could not be found.',
          );
        }

        final remoteCourseId =
        course['remote_id']?.toString();

        if (remoteCourseId == null ||
            remoteCourseId.isEmpty) {
          throw Exception(
            'The course has not been synchronised yet.',
          );
        }

        final data = {
          'id': remoteId,
          'user_id': userId,
          'course_id': remoteCourseId,
          'title': row['title'],
          'content': row['content'],
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
        };

        await _client
            .from('study_notes')
            .upsert(
          data,
          onConflict: 'id',
        );

        await _databaseHelper.markRowSynced(
          'study_notes',
          localId,
        );
      } catch (error) {
        await _databaseHelper.markRowFailed(
          'study_notes',
          localId,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Synchronise assignments
  // ---------------------------------------------------------------------------

  Future<void> _synchroniseAssignments(String userId) async {
    final rows =
    await _databaseHelper.getPendingRows('assignments');

    for (final row in rows) {
      final localId = row['id'] as int;

      // Do not synchronise a row belonging to another authenticated user.
      if (row['user_id']?.toString() != userId) {
        continue;
      }

      try {
        final remoteId = await _ensureRemoteId(
          'assignments',
          localId,
          row['remote_id']?.toString(),
        );

        final localCourseId = row['course_id'] as int;

        final course = await _getLocalCourse(
          localCourseId,
          userId,
        );

        if (course == null) {
          throw Exception(
            'The local course could not be found.',
          );
        }

        final remoteCourseId =
        course['remote_id']?.toString();

        if (remoteCourseId == null ||
            remoteCourseId.isEmpty) {
          throw Exception(
            'The course has not been synchronised yet.',
          );
        }

        final data = {
          'id': remoteId,
          'user_id': userId,
          'course_id': remoteCourseId,
          'title': row['title'],
          'description': row['description'],
          'due_date': row['due_date'],
          'priority': row['priority'],
          'status': row['status'],
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
        };

        await _client
            .from('assignments')
            .upsert(
          data,
          onConflict: 'id',
        );

        await _databaseHelper.markRowSynced(
          'assignments',
          localId,
        );
      } catch (error) {
        await _databaseHelper.markRowFailed(
          'assignments',
          localId,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Synchronise study sessions
  // ---------------------------------------------------------------------------

  Future<void> _synchroniseStudySessions(String userId) async {
    final rows =
    await _databaseHelper.getPendingRows('study_sessions');

    for (final row in rows) {
      final localId = row['id'] as int;

      // Do not synchronise a row belonging to another authenticated user.
      if (row['user_id']?.toString() != userId) {
        continue;
      }

      try {
        final remoteId = await _ensureRemoteId(
          'study_sessions',
          localId,
          row['remote_id']?.toString(),
        );

        final localCourseId = row['course_id'] as int;

        final course = await _getLocalCourse(
          localCourseId,
          userId,
        );

        if (course == null) {
          throw Exception(
            'The local course could not be found.',
          );
        }

        final remoteCourseId =
        course['remote_id']?.toString();

        if (remoteCourseId == null ||
            remoteCourseId.isEmpty) {
          throw Exception(
            'The course has not been synchronised yet.',
          );
        }

        String? remoteAssignmentId;

        final localAssignmentId =
        row['assignment_id'] as int?;

        if (localAssignmentId != null) {
          final assignment =
          await _getLocalAssignment(
            localAssignmentId,
            userId,
          );

          if (assignment != null) {
            remoteAssignmentId =
                assignment['remote_id']?.toString();

            // If an assignment is linked locally but does not
            // have a remote ID yet, wait for the assignment
            // to synchronise first.
            if (remoteAssignmentId == null ||
                remoteAssignmentId.isEmpty) {
              throw Exception(
                'The linked assignment has not been '
                    'synchronised yet.',
              );
            }
          }
        }

        final data = {
          'id': remoteId,
          'user_id': userId,
          'course_id': remoteCourseId,
          'assignment_id': remoteAssignmentId,
          'started_at': row['started_at'],
          'ended_at': row['ended_at'],
          'duration_minutes': row['duration_minutes'],
          'notes': row['notes'],
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
        };

        await _client
            .from('study_sessions')
            .upsert(
          data,
          onConflict: 'id',
        );

        await _databaseHelper.markRowSynced(
          'study_sessions',
          localId,
        );
      } catch (error) {
        await _databaseHelper.markRowFailed(
          'study_sessions',
          localId,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Generate or retrieve a stable remote UUID
  // ---------------------------------------------------------------------------

  Future<String> _ensureRemoteId(
      String tableName,
      int localId,
      String? existingRemoteId,
      ) async {
    if (existingRemoteId != null &&
        existingRemoteId.isNotEmpty) {
      return existingRemoteId;
    }

    final remoteId = _uuid.v4();

    await _databaseHelper.setRemoteId(
      tableName,
      localId,
      remoteId,
    );

    return remoteId;
  }

  // ---------------------------------------------------------------------------
  // Retrieve a local course
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _getLocalCourse(
      int courseId,
      String userId,
      ) async {
    final database = await _databaseHelper.database;

    final rows = await database.query(
      'courses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [
        courseId,
        userId,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  // ---------------------------------------------------------------------------
  // Retrieve a local assignment
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _getLocalAssignment(
      int assignmentId,
      String userId,
      ) async {
    final database = await _databaseHelper.database;

    final rows = await database.query(
      'assignments',
      where: 'id = ? AND user_id = ?',
      whereArgs: [
        assignmentId,
        userId,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }
}