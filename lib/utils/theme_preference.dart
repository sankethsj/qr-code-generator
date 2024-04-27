// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:qr_code_gen/main.dart";

class ThemePreference extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.system;
  ThemeMode get currentTheme => _currentTheme;

  ThemePreference(bool isDark) {
    if (isDark) {
      _currentTheme = ThemeMode.dark;
    } else {
      _currentTheme = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    if (_currentTheme == ThemeMode.light) {
      _currentTheme = ThemeMode.dark;
      prefs.setBool("isDark", true);
    } else {
      _currentTheme = ThemeMode.light;
      prefs.setBool("isDark", false);
    }
    notifyListeners();
  }
}
