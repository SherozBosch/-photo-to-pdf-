// Saves generated PDF bytes to persistent storage and shares them.
//
// PDFs are written to the app's documents directory (always allowed, no
// special permission needed). The system share sheet lets the user save a
// copy to Downloads / Drive / email, which is the scoped-storage-friendly
// way to export files on modern Android.

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SavedPdf {
  final File file;
  final int sizeBytes;
  SavedPdf(this.file, this.sizeBytes);
}

class FileService {
  /// Directory where generated PDFs are kept.
  static Future<Directory> _pdfDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'pdfs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Write [bytes] to a PDF file named after [fileName] (without extension).
  static Future<SavedPdf> savePdf(Uint8List bytes, String fileName) async {
    final dir = await _pdfDir();
    final safeName = _sanitize(fileName);
    final file = File(p.join(dir.path, '$safeName.pdf'));
    await file.writeAsBytes(bytes, flush: true);
    return SavedPdf(file, bytes.length);
  }

  /// Open the system share sheet for an existing PDF file.
  static Future<void> sharePdf(String filePath, {String? title}) async {
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/pdf')],
      subject: title,
    );
  }

  /// Delete a PDF file from disk (used when removing history entries).
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Make a filesystem-safe file name from arbitrary user input.
  static String _sanitize(String input) {
    final cleaned =
        input.trim().replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    if (cleaned.isEmpty) {
      return 'document_${DateTime.now().millisecondsSinceEpoch}';
    }
    return cleaned;
  }
}
