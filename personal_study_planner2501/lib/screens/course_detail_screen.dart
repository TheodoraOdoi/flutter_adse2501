// --------------------------------------------------------------------------
// Screen to display the details of a course and allow the user to edit it
// --------------------------------------------------------------------------

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../models/course.dart';
import '../utils/snackbar_helper.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    this.course,
  });

  final Course? course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  final _courseCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _semesterController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();

    final course = widget.course;

    if (course != null) {
      _courseCodeController.text = course.courseCode;
      _nameController.text = course.name;
      _lecturerController.text = course.lecturer ?? '';
      _semesterController.text = course.semester ?? '';
      _academicYearController.text =
          course.academicYear?.toString() ?? '';
      _descriptionController.text = course.description ?? '';
    }
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _nameController.dispose();
    _lecturerController.dispose();
    _semesterController.dispose();
    _academicYearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Save course
  // ---------------------------------------------------------------------------

  Future<void> _saveCourse() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      context.showMessage('Your session has expired. Please sign in again.');
      return;
    }

    final courseCode = _courseCodeController.text.trim();
    final name = _nameController.text.trim();
    final lecturer = _lecturerController.text.trim();
    final semester = _semesterController.text.trim();
    final academicYearText =
    _academicYearController.text.trim();
    final description =
    _descriptionController.text.trim();

    if (courseCode.isEmpty) {
      context.showMessage('Please enter the course code.');
      return;
    }

    if (name.isEmpty) {
      context.showMessage('Please enter the course name.');
      return;
    }

    int? academicYear;

    if (academicYearText.isNotEmpty) {
      academicYear = int.tryParse(academicYearText);

      if (academicYear == null) {
        context.showMessage('Please enter a valid academic year.');
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now().toUtc().toIso8601String();

      if (_isEditing) {
        final course = Course(
          id: widget.course!.id,
          remoteId: widget.course!.remoteId,
          userId: user.id,
          courseCode: courseCode,
          name: name,
          description: description.isEmpty ? null : description,
          lecturer: lecturer.isEmpty ? null : lecturer,
          semester: semester.isEmpty ? null : semester,
          academicYear: academicYear,
          colour: widget.course!.colour,
          icon: widget.course!.icon,
          createdAt: widget.course!.createdAt,
          updatedAt: now,
          syncStatus: 'pending',
          lastSyncedAt: widget.course!.lastSyncedAt,
        );

        await _databaseHelper.updateCourse(course);
      } else {
        final course = Course(
          userId: user.id,
          courseCode: courseCode,
          name: name,
          description: description.isEmpty ? null : description,
          lecturer: lecturer.isEmpty ? null : lecturer,
          semester: semester.isEmpty ? null : semester,
          academicYear: academicYear,
          createdAt: now,
          updatedAt: now,
          syncStatus: 'pending',
        );

        await _databaseHelper.insertCourse(course);
      }

      if (!mounted) {
        return;
      }

      context.showMessage(
        _isEditing
            ? 'Course updated locally.'
            : 'Course created locally.',
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage('Unable to save the course.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Course' : 'New Course',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _courseCodeController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Course code',
                  hintText: 'e.g. CSC301',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Course name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _lecturerController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Lecturer / instructor',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _semesterController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  hintText: 'e.g. Semester 1',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _academicYearController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Academic year',
                  hintText: 'e.g. 2026',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveCourse,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Course',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}