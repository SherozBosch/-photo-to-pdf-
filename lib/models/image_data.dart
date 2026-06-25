// Data model representing a selected image and its editing state.

import 'dart:typed_data';

class ImageData {
  final String id;
  final String path;
  int rotation; // degrees: 0, 90, 180, 270

  /// Cached decoded thumbnail bytes (optional, used for previews).
  Uint8List? thumbnailBytes;

  ImageData({
    required this.id,
    required this.path,
    this.rotation = 0,
    this.thumbnailBytes,
  });

  /// Rotate the image 90 degrees clockwise, wrapping at 360.
  void rotateClockwise() {
    rotation = (rotation + 90) % 360;
  }

  ImageData copyWith({
    String? id,
    String? path,
    int? rotation,
    Uint8List? thumbnailBytes,
  }) {
    return ImageData(
      id: id ?? this.id,
      path: path ?? this.path,
      rotation: rotation ?? this.rotation,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
    );
  }
}
