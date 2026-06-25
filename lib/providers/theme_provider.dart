// Manages the app's theme mode (system / light / dark) and persists it.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Load the saved theme preference at startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(PrefKeys.themeMode);
    if (index != null && index < ThemeMode.values.length) {
      _mode = ThemeMode.values[index];
      notifyListeners();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKeys.themeMode, mode.index);
    notifyListeners();
  }
}
