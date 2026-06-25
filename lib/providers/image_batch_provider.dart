// Manages the working set of selected images: add, remove, reorder, rotate.

import 'package:flutter/foundation.dart';

import '../models/image_data.dart';

class ImageBatchProvider extends ChangeNotifier {
  final List<ImageData> _images = [];

  List<ImageData> get images => List.unmodifiable(_images);
  bool get isEmpty => _images.isEmpty;
  int get count => _images.length;

  /// Add newly picked images, skipping duplicates by path.
  void addAll(List<ImageData> newImages) {
    final existingPaths = _images.map((e) => e.path).toSet();
    _images.addAll(newImages.where((e) => !existingPaths.contains(e.path)));
    notifyListeners();
  }

  /// Remove an image by id.
  void remove(String id) {
    _images.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Reorder via drag-and-drop indices.
  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    notifyListeners();
  }

  /// Rotate a single image 90 degrees clockwise.
  void rotate(String id) {
    final image = _images.firstWhere((e) => e.id == id);
    image.rotateClockwise();
    notifyListeners();
  }

  /// Clear all images (after a successful export).
  void clear() {
    _images.clear();
    notifyListeners();
  }
}
