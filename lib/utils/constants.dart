// App-wide constants: strings, sizes, quality presets, and layout options.

class AppStrings {
  static const String appName = 'Photo to PDF';
  static const String createTab = 'Create';
  static const String historyTab = 'History';
  static const String settingsTab = 'Settings';

  static const String selectPhotos = 'Select Photos';
  static const String addMore = 'Add More';
  static const String noPhotosSelected = 'No photos selected yet';
  static const String noPhotosHint = 'Tap "Select Photos" to get started';
  static const String noHistory = 'No PDFs created yet';
  static const String noHistoryHint = 'Generated PDFs will appear here';
  static const String generatePdf = 'Generate PDF';
  static const String generating = 'Generating PDF...';
  static const String next = 'Next';
}

/// PDF quality presets mapped to JPEG compression quality (0-100).
enum PdfQuality {
  low(40, 'Low'),
  medium(70, 'Medium'),
  high(95, 'High');

  final int jpegQuality;
  final String label;
  const PdfQuality(this.jpegQuality, this.label);
}

/// Number of images placed per PDF page.
enum GridLayout {
  one(1, '1 per page'),
  two(2, '2 per page'),
  three(3, '3 per page'),
  four(4, '4 per page');

  final int perPage;
  final String label;
  const GridLayout(this.perPage, this.label);
}

class AppDimensions {
  static const double pagePadding = 16.0;
  static const double cardRadius = 16.0;
  static const double thumbnailSize = 96.0;
  static const double pdfPageMargin = 24.0; // in PDF points
}

class PrefKeys {
  static const String themeMode = 'theme_mode';
  static const String defaultQuality = 'default_quality';
  static const String defaultLayout = 'default_layout';
}
