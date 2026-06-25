// Loads and mutates the PDF history list backed by SQLite.

import 'package:flutter/foundation.dart';

import '../models/pdf_export.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<PdfExport> _items = [];
  bool _loading = false;

  List<PdfExport> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get isEmpty => _items.isEmpty;

  /// Load all history records from the database.
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await DatabaseService.getAll();
    _loading = false;
    notifyListeners();
  }

  /// Persist a freshly generated PDF and refresh the list.
  Future<void> add(PdfExport export) async {
    await DatabaseService.insert(export);
    await load();
  }

  /// Delete a record and its file from disk.
  Future<void> remove(PdfExport export) async {
    await FileService.deleteFile(export.filePath);
    await DatabaseService.delete(export.id);
    await load();
  }
}
