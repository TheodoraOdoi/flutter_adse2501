// ------------------------------------
// Screen to log study sessions
// ------------------------------------

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/database_helper.dart';
import '../../models/course.dart';
import '../../utils/snackbar_helper.dart';

class LogStudySessionScreen extends StatefulWidget {
  final Map<String, dynamic>? studySession;

  const LogStudySessionScreen({
    super.key,
    this.studySession,
  });

  @override
  State<LogStudySessionScreen> createState() =>
      _LogStudySessionScreenState();
}

class _LogStudySessionScreenState
    extends State<LogStudySessionScreen> {
  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;

  final _descriptionController = TextEditingController();

  // List<Map<String, dynamic>> _courses = [];
  List<Course> _courses = [];

  String? _selectedCourseId;

  DateTime? _startTime;
  DateTime? _endTime;

  bool _isLoading = false;

  bool get _isEditing => widget.studySession != null;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadForm() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      final courses = await _databaseHelper.getCourses(user.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _courses = courses;
      });

      final session = widget.studySession;

      if (session != null) {
        _selectedCourseId =
            session['course_id'].toString();

        _startTime = DateTime.parse(
          session['start_time'].toString(),
        );

        _endTime = DateTime.parse(
          session['end_time'].toString(),
        );

        _descriptionController.text =
            session['description']?.toString() ?? '';

        if (mounted) {
          setState(() {});
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'Unable to load the study session.',
      );
    }
  }

  Future<void> _selectDateTime({
    required bool selectingStart,
  }) async {
    final initialDate =
    selectingStart
        ? _startTime ?? DateTime.now()
        : _endTime ?? _startTime ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        initialDate,
      ),
    );

    if (time == null || !mounted) {
      return;
    }

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (selectingStart) {
        _startTime = selectedDateTime;
      } else {
        _endTime = selectedDateTime;
      }
    });
  }

  Future<void> _saveStudySession() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      context.showMessage('Your session has expired. Please sign in again.');
      return;
    }

    if (_selectedCourseId == null) {
      context.showMessage('Please select a course.');
      return;
    }

    if (_startTime == null || _endTime == null) {
      context.showMessage(
        'Please select both start and end times.',
      );
      return;
    }

    if (!_endTime!.isAfter(_startTime!)) {
      context.showMessage(
        'The end time must be after the start time.',
      );
      return;
    }

    final duration =
        _endTime!.difference(_startTime!).inMinutes;

    if (duration <= 0) {
      context.showMessage(
        'Study session duration must be greater than zero.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      final data = {
        'user_id': user.id,
        'course_id': _selectedCourseId,
        'start_time': _startTime!.toIso8601String(),
        'end_time': _endTime!.toIso8601String(),
        'duration_minutes': duration,
        'description':
        _descriptionController.text.trim(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'pending',
        'last_synced_at': null,
      };

      if (_isEditing) {
        await _databaseHelper.updateStudySession(
          widget.studySession!['id'] as int,
          data,
        );
      } else {
        data['created_at'] =
            now.toIso8601String();

        await _databaseHelper.insertStudySession(
          data,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'Unable to save the study session.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Not selected';
    }

    return '${dateTime.day}/'
        '${dateTime.month}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit Study Session'
              : 'Log Study Session',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Course',
              ),
              items: _courses.map(
                    (course) {
                  return DropdownMenuItem<String>(
                    value: course.id.toString(),
                    child: Text(
                      '${course.courseCode} - '
                          '${course.name}',
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            ListTile(
              title: const Text('Start time'),
              subtitle: Text(
                _formatDateTime(_startTime),
              ),
              trailing: const Icon(Icons.play_arrow),
              onTap: () {
                _selectDateTime(
                  selectingStart: true,
                );
              },
            ),

            ListTile(
              title: const Text('End time'),
              subtitle: Text(
                _formatDateTime(_endTime),
              ),
              trailing: const Icon(Icons.stop),
              onTap: () {
                _selectDateTime(
                  selectingStart: false,
                );
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reflection / description',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading
                    ? null
                    : _saveStudySession,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                  _isEditing
                      ? 'Update Session'
                      : 'Save Session',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}