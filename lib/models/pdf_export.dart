// Data model for a generated PDF record stored in the history database.

class PdfExport {
  final String id;
  final String title;
  final String fileName;
  final String filePath;
  final int imageCount;
  final int fileSizeBytes;
  final DateTime createdAt;

  PdfExport({
    required this.id,
    required this.title,
    required this.fileName,
    required this.filePath,
    required this.imageCount,
    required this.fileSizeBytes,
    required this.createdAt,
  });

  /// Convert to a map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_name': fileName,
      'file_path': filePath,
      'image_count': imageCount,
      'file_size': fileSizeBytes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Reconstruct from a SQLite row.
  factory PdfExport.fromMap(Map<String, dynamic> map) {
    return PdfExport(
      id: map['id'] as String,
      title: map['title'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      imageCount: map['image_count'] as int,
      fileSizeBytes: map['file_size'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
