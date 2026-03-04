import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final stored = await StorageService.getThemeMode();
    switch (stored) {
      case "light":
        _mode = ThemeMode.light;
        break;
      case "dark":
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final raw = switch (mode) {
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      ThemeMode.system => "system",
    };
    await StorageService.saveThemeMode(raw);
    notifyListeners();
  }
}
