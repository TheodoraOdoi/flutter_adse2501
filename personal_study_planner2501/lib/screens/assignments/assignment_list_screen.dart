// --------------------------------------------------------------------------
// Assignment List Screen
// --------------------------------------------------------------------------

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../database/database_helper.dart';
import '../../models/course.dart';
import '../../utils/snackbar_helper.dart';

import 'create_edit_assignment_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen> {
  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  final _searchController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Screen state
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _assignments = [];
  List<Course> _courses = [];

  int? _selectedCourseId;
  String? _selectedStatus;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Load courses and assignments
  // ---------------------------------------------------------------------------

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

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final courses = await _databaseHelper.getCourses(user.id);

      final assignments =
      await _databaseHelper.searchAssignments(
        userId: user.id,
        keyword: _searchController.text,
        courseId: _selectedCourseId,
        status: _selectedStatus,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _courses = courses;
        _assignments = assignments;
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
        'Unable to load assignments. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Mark assignment as completed
  // ---------------------------------------------------------------------------

  Future<void> _markCompleted(int assignmentId) async {
    try {
      await _databaseHelper.markAssignmentCompleted(
        assignmentId,
      );

      await _loadData();

      if (!mounted) {
        return;
      }

      context.showMessage(
        'Assignment marked as completed.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'Unable to update the assignment.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Delete assignment
  // ---------------------------------------------------------------------------

  Future<void> _deleteAssignment(int assignmentId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: const Text(
            'Are you sure you want to delete this assignment?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _databaseHelper.deleteAssignment(
        assignmentId,
      );

      await _loadData();

      if (!mounted) {
        return;
      }

      context.showMessage('Assignment deleted.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'Unable to delete the assignment.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Format assignment due date
  // ---------------------------------------------------------------------------

  String _formatDueDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'No due date';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day}/${date.month}/${date.year}';
    } catch (error) {
      return 'Invalid date';
    }
  }

  // ---------------------------------------------------------------------------
  // Get a readable course name
  // ---------------------------------------------------------------------------

  String _getCourseDisplayName(Course course) {
    if (course.courseCode.trim().isNotEmpty) {
      return '${course.courseCode} - ${course.name}';
    }

    return course.name;
  }

  // ---------------------------------------------------------------------------
  // Build screen
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),

      // -----------------------------------------------------------------------
      // Create assignment
      // -----------------------------------------------------------------------

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const CreateEditAssignmentScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await _loadData();
        },
        child: const Icon(Icons.add),
      ),

      // -----------------------------------------------------------------------
      // Assignment content
      // -----------------------------------------------------------------------

      body: Column(
        children: [
          // -------------------------------------------------------------------
          // Search
          // -------------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search assignments',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                _loadData();
              },
            ),
          ),

          // -------------------------------------------------------------------
          // Filters
          // -------------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                // -------------------------------------------------------------
                // Course filter
                // -------------------------------------------------------------

                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _selectedCourseId,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All courses'),
                      ),

                      ..._courses.map(
                            (course) {
                          return DropdownMenuItem<int?>(
                            value: course.id,
                            child: Text(
                              _getCourseDisplayName(course),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
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

                const SizedBox(width: 12),

                // -------------------------------------------------------------
                // Status filter
                // -------------------------------------------------------------

                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'not_started',
                        child: Text('Not Started'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'in_progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });

                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // -------------------------------------------------------------------
          // Assignment list
          // -------------------------------------------------------------------

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _assignments.isEmpty
                ? const Center(
              child: Text(
                'No assignments found.',
              ),
            )
                : ListView.builder(
              itemCount: _assignments.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                final assignment =
                _assignments[index];

                final assignmentId =
                assignment['id'] as int;

                final isCompleted =
                    assignment['status'] ==
                        'completed';

                final title =
                    assignment['title']
                        ?.toString() ??
                        'Untitled assignment';

                final priority =
                    assignment['priority']
                        ?.toString() ??
                        'Not specified';

                final dueDate =
                assignment['due_date']
                    ?.toString();

                return Card(
                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    // ------------------------------------------------
                    // Completion checkbox
                    // ------------------------------------------------

                    leading: Checkbox(
                      value: isCompleted,
                      onChanged: isCompleted
                          ? null
                          : (_) {
                        _markCompleted(
                          assignmentId,
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // Assignment information
                    // ------------------------------------------------

                    title: Text(title),

                    subtitle: Text(
                      'Due: ${_formatDueDate(dueDate)}\n'
                          'Priority: $priority',
                    ),

                    isThreeLine: true,

                    // ------------------------------------------------
                    // Edit/delete menu
                    // ------------------------------------------------

                    trailing:
                    PopupMenuButton<String>(
                      onSelected:
                          (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CreateEditAssignmentScreen(
                                    assignment:
                                    assignment,
                                  ),
                            ),
                          );

                          if (!mounted) {
                            return;
                          }

                          await _loadData();
                        }

                        if (value == 'delete') {
                          await _deleteAssignment(
                            assignmentId,
                          );
                        }
                      },
                      itemBuilder: (_) =>
                      const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem<String>(
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