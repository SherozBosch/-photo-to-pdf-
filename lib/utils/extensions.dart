// Helpful extensions used across the app.

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Show a snackbar with a message.
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Theme.of(this).colorScheme.error : null,
        ),
      );
  }

  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension IntFileSize on int {
  /// Convert a byte count to a human-readable string.
  String get readableFileSize {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
