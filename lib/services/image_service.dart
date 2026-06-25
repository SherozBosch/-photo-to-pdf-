// Image selection and thumbnail generation.
//
// Uses image_picker for multi-image gallery selection and the `image`
// package to decode + downscale thumbnails for fast previews. The `image`
// package's decoders already bake in EXIF orientation, so thumbnails and
// the final PDF are upright automatically.

import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/image_data.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  /// Open the gallery and let the user pick multiple images.
  /// Returns a list of [ImageData] with generated thumbnails.
  static Future<List<ImageData>> pickImages() async {
    final List<XFile> files = await _picker.pickMultiImage();
    if (files.isEmpty) return [];

    final List<ImageData> result = [];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final thumb = await _makeThumbnail(bytes);
      result.add(
        ImageData(
          id: _uuid.v4(),
          path: file.path,
          thumbnailBytes: thumb,
        ),
      );
    }
    return result;
  }

  /// Take a single photo with the camera.
  static Future<ImageData?> captureFromCamera() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final thumb = await _makeThumbnail(bytes);
    return ImageData(
      id: _uuid.v4(),
      path: file.path,
      thumbnailBytes: thumb,
    );
  }

  /// Decode and downscale image bytes into a small JPEG thumbnail.
  /// Runs the heavy decode work; callers may wrap in compute if needed.
  static Future<Uint8List> _makeThumbnail(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    // Bake in EXIF orientation so previews are upright.
    final oriented = img.bakeOrientation(decoded);
    final thumb = img.copyResize(oriented, width: 300);
    return Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
  }
}
