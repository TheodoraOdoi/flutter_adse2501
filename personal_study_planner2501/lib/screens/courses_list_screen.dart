// --------------------------------------------------------------------------
// Screen to display a list of courses.
// --------------------------------------------------------------------------
// This course displays and allow a user/student to add, edit or delete a course

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../models/course.dart';
import '../utils/snackbar_helper.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;

  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // ---------------------------------------------------------------------------
  // Load courses from SQLite
  // ---------------------------------------------------------------------------

  Future<void> _loadCourses() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final courses = await _databaseHelper.getCourses(user.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _courses = courses;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage('Unable to load your courses.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Open course form
  // ---------------------------------------------------------------------------

  Future<void> _openCourseForm({Course? course}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          course: course,
        ),
      ),
    );

    if (mounted) {
      await _loadCourses();
    }
  }

  // ---------------------------------------------------------------------------
  // Delete course
  // ---------------------------------------------------------------------------

  Future<void> _deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete course?'),
          content: Text(
            'Deleting ${course.courseCode} will also remove its local notes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final user = _client.auth.currentUser;

    if (user == null || course.id == null) {
      return;
    }

    try {
      await _databaseHelper.deleteCourse(
        course.id!,
        user.id,
      );

      if (!mounted) {
        return;
      }

      await _loadCourses();

      if (mounted) {
        context.showMessage('Course deleted.');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage('Unable to delete the course.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _courses.isEmpty
          ? const Center(
        child: Text(
          'No courses yet.\nTap + to add your first course.',
          textAlign: TextAlign.center,
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadCourses,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _courses.length,
          itemBuilder: (context, index) {
            final course = _courses[index];

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    course.courseCode.isNotEmpty
                        ? course.courseCode[0]
                        : '?',
                  ),
                ),
                title: Text(course.name),
                subtitle: Text(
                  '${course.courseCode}'
                      '${course.lecturer == null ? '' : '\n${course.lecturer}'}',
                ),
                isThreeLine: course.lecturer != null,
                onTap: () => _openCourseForm(
                  course: course,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteCourse(course),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCourseForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
