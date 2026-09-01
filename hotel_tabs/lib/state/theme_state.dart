import 'package:flutter/material.dart';

class ThemeState extends ChangeNotifier {
  ThemeState._();

  static final ThemeState instance = ThemeState._();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();
  }
}