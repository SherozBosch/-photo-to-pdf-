// Holds user-facing PDF settings (title, layout, quality) and persists the
// defaults via shared_preferences.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class PdfSettingsProvider extends ChangeNotifier {
  String _title = 'My Document';
  GridLayout _layout = GridLayout.one;
  PdfQuality _quality = PdfQuality.high;

  String get title => _title;
  GridLayout get layout => _layout;
  PdfQuality get quality => _quality;

  /// Load saved defaults at startup.
  Future<void> loadDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutIndex = prefs.getInt(PrefKeys.defaultLayout);
    final qualityIndex = prefs.getInt(PrefKeys.defaultQuality);
    if (layoutIndex != null && layoutIndex < GridLayout.values.length) {
      _layout = GridLayout.values[layoutIndex];
    }
    if (qualityIndex != null && qualityIndex < PdfQuality.values.length) {
      _quality = PdfQuality.values[qualityIndex];
    }
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  Future<void> setLayout(GridLayout value) async {
    _layout = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKeys.defaultLayout, value.index);
    notifyListeners();
  }

  Future<void> setQuality(PdfQuality value) async {
    _quality = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKeys.defaultQuality, value.index);
    notifyListeners();
  }
}
