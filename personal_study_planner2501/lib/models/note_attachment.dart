// This class represents a file attachment for a study note in the database.

// ---------------------------------------------------------------------------
// Note attachment model
// ---------------------------------------------------------------------------

class NoteAttachment {
  const NoteAttachment({
    this.id,
    required this.studyNoteId,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.storagePath,
    required this.uploadedAt,
  });

  final int? id;
  final int studyNoteId;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String storagePath;
  final String uploadedAt;

  factory NoteAttachment.fromMap(Map<String, dynamic> map) {
    return NoteAttachment(
      id: map['id'] as int?,
      studyNoteId: map['study_note_id'] as int,
      fileName: map['file_name'] as String,
      fileSize: map['file_size'] as int,
      mimeType: map['mime_type'] as String,
      storagePath: map['storage_path'] as String,
      uploadedAt: map['uploaded_at'] as String,
    );
  }
}