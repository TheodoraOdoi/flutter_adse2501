// --------------------------------------------------------------------------
// Screen to create or edit a study note.
// --------------------------------------------------------------------------

// Imports
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../models/course.dart';
import '../models/study_note.dart';
import '../utils/snackbar_helper.dart';

class CreateEditNoteScreen extends StatefulWidget {
  const CreateEditNoteScreen({
    super.key,
    required this.course,
    this.note,
  });

  final Course course;
  final StudyNote? note;

  @override
  State<CreateEditNoteScreen> createState() =>
      _CreateEditNoteScreenState();
}

class _CreateEditNoteScreenState
    extends State<CreateEditNoteScreen> {
  final _client = Supabase.instance.client;
  final _databaseHelper = DatabaseHelper.instance;

  // ---------------------------------------------------------------------------
  // Note controllers
  // ---------------------------------------------------------------------------

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSaving = false;
  bool _isValidatingFile = false;
  bool _isUploadingFile = false;

  String? _attachmentFileName;
  int? _attachmentFileSize;
  String? _attachmentMimeType;
  String? _attachmentStoragePath;

  bool get _isEditing => widget.note != null;

  static const int _maximumFileSize = 2 * 1024 * 1024;

  static const Set<String> _allowedExtensions = {
    'pdf',
    'docx',
    'txt',
    'png',
    'jpg',
    'jpeg',
  };

  static const Map<String, String> _mimeTypes = {
    'pdf': 'application/pdf',
    'docx':
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt': 'text/plain',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
  };

  @override
  void initState() {
    super.initState();

    final note = widget.note;

    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;

      _loadExistingAttachment();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Load existing attachment metadata
  // ---------------------------------------------------------------------------

  Future<void> _loadExistingAttachment() async {
    final noteId = widget.note?.id;

    if (noteId == null) {
      return;
    }

    try {
      final attachment = await _client
          .from('note_attachments')
          .select()
          .eq('study_note_id', noteId)
          .maybeSingle();

      if (!mounted || attachment == null) {
        return;
      }

      setState(() {
        _attachmentFileName =
        attachment['file_name'] as String?;

        _attachmentFileSize =
        attachment['file_size'] as int?;

        _attachmentMimeType =
        attachment['mime_type'] as String?;

        _attachmentStoragePath =
        attachment['storage_path'] as String?;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'The note loaded, but its attachment could not be loaded.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Save note
  // ---------------------------------------------------------------------------

  Future<void> _saveNote() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      context.showMessage(
        'Your session has expired. Please sign in again.',
      );
      return;
    }

    if (widget.course.id == null) {
      context.showMessage('The selected course is invalid.');
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      context.showMessage('Please enter a note title.');
      return;
    }

    if (content.isEmpty) {
      context.showMessage('Please enter some note content.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now().toUtc().toIso8601String();

      if (_isEditing) {
        final note = StudyNote(
          id: widget.note!.id,
          remoteId: widget.note!.remoteId,
          userId: user.id,
          courseId: widget.course.id!,
          title: title,
          content: content,
          createdAt: widget.note!.createdAt,
          updatedAt: now,
          syncStatus: 'pending',
          lastSyncedAt: widget.note!.lastSyncedAt,
        );

        await _databaseHelper.updateStudyNote(note);
      } else {
        final note = StudyNote(
          userId: user.id,
          courseId: widget.course.id!,
          title: title,
          content: content,
          createdAt: now,
          updatedAt: now,
          syncStatus: 'pending',
        );

        final noteId = await _databaseHelper.insertStudyNote(note);

        if (!mounted) {
          return;
        }

        context.showMessage('Note saved locally.');

        Navigator.of(context).pop(noteId);
        return;
      }

      if (!mounted) {
        return;
      }

      context.showMessage('Note updated locally.');

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage('Unable to save the note.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Pick and upload an attachment
  // ---------------------------------------------------------------------------

  Future<void> _pickAndUploadAttachment() async {
    final user = _client.auth.currentUser;
    final noteId = widget.note?.id;
    final courseId = widget.course.id;

    if (user == null) {
      context.showMessage(
        'Your session has expired. Please sign in again.',
      );
      return;
    }

    if (noteId == null) {
      context.showMessage(
        'Save the note before adding an attachment.',
      );
      return;
    }

    if (courseId == null) {
      context.showMessage('The selected course is invalid.');
      return;
    }

    final existingAttachment = await _getAttachment(noteId);

    if (existingAttachment != null) {
      context.showMessage(
        'Only one attachment is allowed per study note.',
      );
      return;
    }

    try {
      setState(() {
        _isValidatingFile = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'docx',
          'txt',
          'png',
          'jpg',
          'jpeg',
        ],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.single;

      final extension = _getExtension(pickedFile.name);

      if (!_allowedExtensions.contains(extension)) {
        context.showMessage(
          'This file type is not allowed.',
        );
        return;
      }

      final filePath = pickedFile.path;

      if (filePath == null) {
        context.showMessage(
          'The selected file could not be accessed.',
        );
        return;
      }

      final file = File(filePath);

      final fileSize = await file.length();

      if (fileSize > _maximumFileSize) {
        context.showMessage(
          'The file is too large. Maximum size is 2 MB.',
        );
        return;
      }

      if (fileSize == 0) {
        context.showMessage('The selected file is empty.');
        return;
      }

      final mimeType = _mimeTypes[extension];

      if (mimeType == null) {
        context.showMessage('The file type could not be identified.');
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isValidatingFile = false;
        _isUploadingFile = true;
      });

      // ---------------------------------------------------------------
      // Generate a safe Storage path.
      // ---------------------------------------------------------------

      final safeFileName = _createSafeFileName(
        pickedFile.name,
      );

      final storagePath =
          '${user.id}/$courseId/$noteId/$safeFileName';

      bool storageUploadSucceeded = false;

      try {
        // -------------------------------------------------------------
        // Upload file to Supabase Storage.
        // -------------------------------------------------------------

        await _client.storage.from('note-attachments').upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: mimeType,
          ),
        );

        storageUploadSucceeded = true;

        // -------------------------------------------------------------
        // Insert attachment metadata into PostgreSQL.
        // -------------------------------------------------------------

        await _client.from('note_attachments').insert({
          'study_note_id': noteId,
          'file_name': pickedFile.name,
          'file_size': fileSize,
          'mime_type': mimeType,
          'storage_path': storagePath,
          'uploaded_at':
          DateTime.now().toUtc().toIso8601String(),
        });

        // -------------------------------------------------------------
        // Mark the local note as changed.
        // -------------------------------------------------------------

        await _databaseHelper.markNotePending(noteId);

        if (!mounted) {
          return;
        }

        setState(() {
          _attachmentFileName = pickedFile.name;
          _attachmentFileSize = fileSize;
          _attachmentMimeType = mimeType;
          _attachmentStoragePath = storagePath;
        });

        context.showMessage(
          'Attachment uploaded successfully.',
        );
      } catch (error) {
        // -------------------------------------------------------------
        // Compensating action:
        // remove the Storage object if metadata insertion failed.
        // -------------------------------------------------------------

        if (storageUploadSucceeded) {
          try {
            await _client.storage
                .from('note-attachments')
                .remove([storagePath]);
          } catch (_) {
            // The original failure is more useful to the user.
            // A later reconciliation job can handle rare cleanup failures.
          }
        }

        if (!mounted) {
          return;
        }

        context.showMessage(
          'The attachment could not be saved. '
              'Please try again.',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'The file could not be selected.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isValidatingFile = false;
          _isUploadingFile = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Get existing attachment
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _getAttachment(
      int noteId,
      ) async {
    return _client
        .from('note_attachments')
        .select()
        .eq('study_note_id', noteId)
        .maybeSingle();
  }

  // ---------------------------------------------------------------------------
  // Delete attachment
  // ---------------------------------------------------------------------------

  Future<void> _deleteAttachment() async {
    final noteId = widget.note?.id;

    if (noteId == null) {
      return;
    }

    final storagePath = _attachmentStoragePath;

    try {
      if (storagePath != null) {
        await _client.storage
            .from('note-attachments')
            .remove([storagePath]);
      }

      await _client
          .from('note_attachments')
          .delete()
          .eq('study_note_id', noteId);

      await _databaseHelper.markNotePending(noteId);

      if (!mounted) {
        return;
      }

      setState(() {
        _attachmentFileName = null;
        _attachmentFileSize = null;
        _attachmentMimeType = null;
        _attachmentStoragePath = null;
      });

      context.showMessage('Attachment deleted.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'The attachment could not be deleted completely.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Delete the note and its attachment
  // ---------------------------------------------------------------------------

  Future<void> _deleteNote() async {
    final user = _client.auth.currentUser;
    final noteId = widget.note?.id;

    if (user == null || noteId == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: const Text(
            'This will delete the note and its attachment.',
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

    try {
      if (_attachmentStoragePath != null) {
        await _client.storage
            .from('note-attachments')
            .remove([_attachmentStoragePath!]);
      }

      await _client
          .from('note_attachments')
          .delete()
          .eq('study_note_id', noteId);

      await _databaseHelper.deleteStudyNote(
        noteId,
        user.id,
      );

      if (!mounted) {
        return;
      }

      context.showMessage('Note deleted.');

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showMessage(
        'The note could not be deleted completely.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // File extension
  // ---------------------------------------------------------------------------

  String _getExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');

    if (lastDot == -1) {
      return '';
    }

    return fileName.substring(lastDot + 1).toLowerCase();
  }

  // ---------------------------------------------------------------------------
  // Create a safe Storage filename
  // ---------------------------------------------------------------------------

  String _createSafeFileName(String originalName) {
    final extension = _getExtension(originalName);

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    return 'attachment_$timestamp.$extension';
  }

  // ---------------------------------------------------------------------------
  // Format file size
  // ---------------------------------------------------------------------------

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isBusy =
        _isSaving ||
            _isValidatingFile ||
            _isUploadingFile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Note' : 'New Note',
        ),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: isBusy ? null : _deleteNote,
              tooltip: 'Delete note',
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.course.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                enabled: !isBusy,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Note title',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _contentController,
                enabled: !isBusy,
                minLines: 10,
                maxLines: 18,
                decoration: const InputDecoration(
                  labelText: 'Note content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // ----------------------------------------------------------------
              // Attachment section
              // ----------------------------------------------------------------

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Attachment',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'PDF, DOCX, TXT, PNG or JPEG. '
                            'Maximum size: 2 MB. '
                            'One attachment per note.',
                      ),

                      const SizedBox(height: 16),

                      if (_attachmentFileName != null) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.attach_file,
                          ),
                          title: Text(
                            _attachmentFileName!,
                          ),
                          subtitle: _attachmentFileSize == null
                              ? null
                              : Text(
                            _formatFileSize(
                              _attachmentFileSize!,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: isBusy
                                ? null
                                : _deleteAttachment,
                            icon: const Icon(
                              Icons.delete_outline,
                            ),
                          ),
                        ),
                      ] else
                        OutlinedButton.icon(
                          onPressed: isBusy
                              ? null
                              : _pickAndUploadAttachment,
                          icon: _isValidatingFile
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : _isUploadingFile
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.attach_file,
                          ),
                          label: Text(
                            _isValidatingFile
                                ? 'Validating...'
                                : _isUploadingFile
                                ? 'Uploading...'
                                : 'Add attachment',
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: isBusy ? null : _saveNote,
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
                  _isSaving
                      ? 'Saving...'
                      : 'Save Note',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}