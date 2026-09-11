// --------------------------------------------------------------------------
// Screen to display a list of study notes for a course
// --------------------------------------------------------------------------

// Imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../models/course.dart';
import '../models/study_note.dart';
import '../utils/snackbar_helper.dart';
import 'create_edit_note_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({
    super.key,
    required this.course,
  });

  final Course course;

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;

  List<StudyNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // ---------------------------------------------------------------------------
  // Load notes for this course
  // ---------------------------------------------------------------------------

  Future<void> _loadNotes() async {
    final user = _client.auth.currentUser;

    if (user == null || widget.course.id == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _databaseHelper.getStudyNotes(
        widget.course.id!,
        user.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _notes = notes;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage('Unable to load study notes.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Open note editor
  // ---------------------------------------------------------------------------

  Future<void> _openNoteEditor({
    StudyNote? note,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateEditNoteScreen(
          course: widget.course,
          note: note,
        ),
      ),
    );

    if (mounted) {
      await _loadNotes();
    }
  }

  // ---------------------------------------------------------------------------
  // Delete note
  // ---------------------------------------------------------------------------

  Future<void> _deleteNote(StudyNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: const Text(
            'The note and its attachment will be deleted.',
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

    if (user == null || note.id == null) {
      return;
    }

    try {
      // The note screen handles removal of the Storage attachment.
      // This method removes the local note record.
      await _databaseHelper.deleteStudyNote(
        note.id!,
        user.id,
      );

      if (!mounted) {
        return;
      }

      await _loadNotes();

      if (mounted) {
        context.showMessage('Note deleted locally.');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage('Unable to delete the note.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _notes.isEmpty
          ? const Center(
        child: Text(
          'No study notes yet.\nTap + to create one.',
          textAlign: TextAlign.center,
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadNotes,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];

            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.note_outlined,
                ),
                title: Text(note.title),
                subtitle: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openNoteEditor(
                  note: note,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteNote(note),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}