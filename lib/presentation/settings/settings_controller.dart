import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Настройки приложения. Базовый сценарий управления состоянием на Provider (ChangeNotifier).
/// Значения сохраняются в SharedPreferences.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    final theme = _prefs.getString(_kTheme);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == theme,
      orElse: () => ThemeMode.system,
    );
    final lang = _prefs.getString(_kLanguage);
    _locale = Locale(lang == 'en' ? 'en' : 'ru');
    _yearlyGoal = _prefs.getInt(_kGoal) ?? 12;
  }

  static const _kTheme = 'theme_mode';
  static const _kLanguage = 'language';
  static const _kGoal = 'yearly_goal';

  final SharedPreferences _prefs;

  late ThemeMode _themeMode;
  late Locale _locale;
  late int _yearlyGoal;

  ThemeMode get themeMode => _themeMode;

  Locale get locale => _locale;

  /// Цель: сколько книг прочитать за год.
  int get yearlyGoal => _yearlyGoal;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_kTheme, mode.name);
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _locale.languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    await _prefs.setString(_kLanguage, languageCode);
  }

  Future<void> setYearlyGoal(int goal) async {
    final value = goal.clamp(1, 365);
    if (value == _yearlyGoal) return;
    _yearlyGoal = value;
    notifyListeners();
    await _prefs.setInt(_kGoal, value);
  }
}
