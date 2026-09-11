// --------------------------------------------------------------------------
// Screen to display a list of study sessions
// --------------------------------------------------------------------------

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/database_helper.dart';
import '../../models/course.dart';
import '../../utils/snackbar_helper.dart';
import 'log_study_session_screen.dart';

class StudySessionListScreen extends StatefulWidget {
  const StudySessionListScreen({super.key});

  @override
  State<StudySessionListScreen> createState() =>
      _StudySessionListScreenState();
}

class _StudySessionListScreenState
    extends State<StudySessionListScreen> {
  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _sessions = [];
  // List<Map<String, dynamic>> _courses = [];
  List<Course> _courses = [];

  String? _selectedCourseId;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      return;
    }

    try {
      final courses =
      await _databaseHelper.getCourses(user.id);

      final sessions =
      await _databaseHelper.getStudySessions(
        userId: user.id,
        courseId: _selectedCourseId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _courses = courses;
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      context.showMessage(
        'Unable to load study sessions.',
      );
    }
  }

  Future<void> _deleteSession(int id) async {
    try {
      await _databaseHelper.deleteStudySession(id);

      await _loadData();

      if (!mounted) {
        return;
      }

      context.showMessage('Study session deleted.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'Unable to delete the study session.',
      );
    }
  }

  String _formatDateTime(String value) {
    final date = DateTime.parse(value);

    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Sessions'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const LogStudySessionScreen(),
            ),
          );

          if (mounted) {
            await _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Filter by course',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All courses'),
                ),
                ..._courses.map(
                      (course) => DropdownMenuItem<String>(
                    value: course.id.toString(),
                    child: Text(
                      '${course.courseCode} - '
                          '${course.name}',
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value;
                });

                _loadData();
              },
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _sessions.isEmpty
                ? const Center(
              child: Text(
                'No study sessions recorded.',
              ),
            )
                : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session =
                _sessions[index];

                return Card(
                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.timer,
                    ),
                    title: Text(
                      '${session['duration_minutes']} '
                          'minutes',
                    ),
                    subtitle: Text(
                      'Start: ${_formatDateTime(
                        session['start_time']
                            .toString(),
                      )}\n'
                          'End: ${_formatDateTime(
                        session['end_time']
                            .toString(),
                      )}',
                    ),
                    isThreeLine: true,
                    trailing:
                    PopupMenuButton<String>(
                      onSelected:
                          (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LogStudySessionScreen(
                                    studySession:
                                    session,
                                  ),
                            ),
                          );

                          if (mounted) {
                            await _loadData();
                          }
                        }

                        if (value == 'delete') {
                          await _deleteSession(
                            session['id'] as int,
                          );
                        }
                      },
                      itemBuilder: (_) =>
                      const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}