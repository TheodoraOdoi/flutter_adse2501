// -------------------------------------------
// Class to create and edit assignments
// ------------------------------------------

// imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/database_helper.dart';
import '../../models/course.dart';
import '../../utils/snackbar_helper.dart';

class CreateEditAssignmentScreen extends StatefulWidget {
  final Map<String, dynamic>? assignment;

  const CreateEditAssignmentScreen({
    super.key,
    this.assignment,
  });

  @override
  State<CreateEditAssignmentScreen> createState() =>
      _CreateEditAssignmentScreenState();
}

class _CreateEditAssignmentScreenState
    extends State<CreateEditAssignmentScreen> {
  final _databaseHelper = DatabaseHelper.instance;
  final _client = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Controllers for assignment fields
  // ---------------------------------------------------------------------------

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Form state
  // ---------------------------------------------------------------------------

  // List<Map<String, dynamic>> _courses = [];
  List<Course> _courses = [];

  int? _selectedCourseId;

  String _selectedPriority = 'medium';
  String _selectedStatus = 'not_started';

  DateTime? _dueDate;

  bool _isLoading = false;

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Load courses and existing assignment data
  // ---------------------------------------------------------------------------

  Future<void> _loadForm() async {
    try {
      final courses = await _databaseHelper.getCourses();

      if (!mounted) {
        return;
      }

      setState(() {
        _courses = courses;
      });

      if (widget.assignment != null) {
        final assignment = widget.assignment!;

        final courseId = assignment['course_id'];

        DateTime? dueDate;

        final dueDateValue = assignment['due_date'];

        if (dueDateValue != null &&
            dueDateValue.toString().trim().isNotEmpty) {
          dueDate = DateTime.tryParse(
            dueDateValue.toString(),
          );
        }

        setState(() {
          _titleController.text =
              assignment['title']?.toString() ?? '';

          _descriptionController.text =
              assignment['description']?.toString() ?? '';

          _selectedCourseId = courseId is int
              ? courseId
              : int.tryParse(courseId.toString());

          _selectedPriority =
              assignment['priority']?.toString() ?? 'medium';

          _selectedStatus =
              assignment['status']?.toString() ?? 'not_started';

          _dueDate = dueDate;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'Unable to load the assignment form.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Select assignment due date
  // ---------------------------------------------------------------------------

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _dueDate = selectedDate;
    });
  }

  // ---------------------------------------------------------------------------
  // Save assignment
  // ---------------------------------------------------------------------------

  Future<void> _saveAssignment() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // -------------------------------------------------------------------------
    // Validate the form
    // -------------------------------------------------------------------------

    if (title.isEmpty) {
      context.showMessage(
        'Please enter an assignment title.',
      );
      return;
    }

    if (_selectedCourseId == null) {
      context.showMessage(
        'Please select a course.',
      );
      return;
    }

    if (_dueDate == null) {
      context.showMessage(
        'Please select a due date.',
      );
      return;
    }

    // -------------------------------------------------------------------------
    // Get the authenticated Supabase user
    // -------------------------------------------------------------------------

    final currentUser = _client.auth.currentUser;

    if (currentUser == null) {
      context.showMessage(
        'Your session has expired. Please log in again.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now().toUtc();
      final nowString = now.toIso8601String();

      // -----------------------------------------------------------------------
      // Update existing assignment
      // -----------------------------------------------------------------------

      if (_isEditing) {
        final assignmentId = widget.assignment!['id'];

        final int? parsedAssignmentId = assignmentId is int
            ? assignmentId
            : int.tryParse(
          assignmentId.toString(),
        );

        if (parsedAssignmentId == null) {
          throw Exception(
            'Invalid local assignment ID.',
          );
        }

        await _databaseHelper.updateAssignment(
          parsedAssignmentId,
          {
            'user_id': currentUser.id,
            'course_id': _selectedCourseId,
            'title': title,
            'description': description.isEmpty
                ? null
                : description,
            'due_date': _dueDate!.toUtc().toIso8601String(),
            'priority': _selectedPriority,
            'status': _selectedStatus,
            'updated_at': nowString,
            'sync_status': 'pending',
            'last_synced_at': null,
          },
        );
      }

      // -----------------------------------------------------------------------
      // Create new assignment
      // -----------------------------------------------------------------------

      else {
        await _databaseHelper.insertAssignment(
          {
            'user_id': currentUser.id,
            'course_id': _selectedCourseId,
            'title': title,
            'description': description.isEmpty
                ? null
                : description,
            'due_date': _dueDate!.toUtc().toIso8601String(),
            'priority': _selectedPriority,
            'status': _selectedStatus,
            'created_at': nowString,
            'updated_at': nowString,
            'sync_status': 'pending',
            'last_synced_at': null,
          },
        );
      }

      if (!mounted) {
        return;
      }

      context.showMessage(
        _isEditing
            ? 'Assignment updated successfully.'
            : 'Assignment created successfully.',
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        _isEditing
            ? 'Unable to update the assignment.'
            : 'Unable to create the assignment.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build screen
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit Assignment'
              : 'New Assignment',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // Assignment title
            // -----------------------------------------------------------------

            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter assignment title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // Assignment description
            // -----------------------------------------------------------------

            TextField(
              controller: _descriptionController,
              enabled: !_isLoading,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter assignment description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // Course selection
            // -----------------------------------------------------------------

            DropdownButtonFormField<int>(
              initialValue: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
              items: _courses.map(
                    (course) {
                  final courseId = course.id;

                  final int? parsedCourseId = courseId is int
                      ? courseId
                      : int.tryParse(
                    courseId.toString(),
                  );

                  return DropdownMenuItem<int>(
                    value: parsedCourseId,
                    child: Text(
                      '${course.courseCode} - '
                          '${course.name}',
                    ),
                  );
                },
              ).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                setState(() {
                  _selectedCourseId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // Priority selection
            // -----------------------------------------------------------------

            DropdownButtonFormField<String>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text('High'),
                ),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedPriority = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // Status selection
            // -----------------------------------------------------------------

            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'not_started',
                  child: Text('Not Started'),
                ),
                DropdownMenuItem(
                  value: 'in_progress',
                  child: Text('In Progress'),
                ),
                DropdownMenuItem(
                  value: 'completed',
                  child: Text('Completed'),
                ),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedStatus = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // Due date
            // -----------------------------------------------------------------

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date'),
              subtitle: Text(
                _dueDate == null
                    ? 'No date selected'
                    : '${_dueDate!.day}/'
                    '${_dueDate!.month}/'
                    '${_dueDate!.year}',
              ),
              trailing: const Icon(
                Icons.calendar_today,
              ),
              enabled: !_isLoading,
              onTap: _isLoading
                  ? null
                  : _selectDueDate,
            ),

            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // Save button
            // -----------------------------------------------------------------

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                _isLoading ? null : _saveAssignment,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  _isEditing
                      ? 'Update Assignment'
                      : 'Create Assignment',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}