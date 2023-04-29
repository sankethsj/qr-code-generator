import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_currentTheme == ThemeMode.light) {
      _currentTheme = ThemeMode.dark;
      prefs.setBool('isDark', true);
    } else {
      _currentTheme = ThemeMode.light;
      prefs.setBool('isDark', false);
    }
    notifyListeners();
  }
}
