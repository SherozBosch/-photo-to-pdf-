// Handles runtime permission requests for gallery access on Android.

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request access to read images from the gallery.
  ///
  /// On Android 13+ this maps to READ_MEDIA_IMAGES (Permission.photos),
  /// on older versions to READ_EXTERNAL_STORAGE (Permission.storage).
  /// Returns true if access is granted (or limited, which is acceptable).
  static Future<bool> requestPhotoAccess() async {
    // Try the modern photos permission first (Android 13+).
    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) {
      return true;
    }

    // Fall back to legacy storage permission (Android 12 and below).
    final storage = await Permission.storage.request();
    return storage.isGranted || storage.isLimited;
  }

  /// Whether the user permanently denied access and must enable it in
  /// system settings.
  static Future<bool> isPermanentlyDenied() async {
    return await Permission.photos.isPermanentlyDenied &&
        await Permission.storage.isPermanentlyDenied;
  }

  /// Open the system app settings so the user can grant permission manually.
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
