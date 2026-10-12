import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/presentation/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsController', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('loads default values when preferences are empty', () {
      final controller = SettingsController(prefs);
      expect(controller.themeMode, ThemeMode.system);
      expect(controller.locale.languageCode, 'ru');
      expect(controller.yearlyGoal, 12);
    });

    test('loads persisted values from preferences', () async {
      await prefs.setString('theme_mode', 'dark');
      await prefs.setString('language', 'en');
      await prefs.setInt('yearly_goal', 25);

      final controller = SettingsController(prefs);
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.locale.languageCode, 'en');
      expect(controller.yearlyGoal, 25);
    });

    test('updates and persists theme mode', () async {
      final controller = SettingsController(prefs);
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');
      expect(notified, isTrue);
    });

    test('updates and persists language', () async {
      final controller = SettingsController(prefs);
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.setLanguage('en');
      expect(controller.locale.languageCode, 'en');
      expect(prefs.getString('language'), 'en');
      expect(notified, isTrue);
    });

    test('updates and clamps yearly goal', () async {
      final controller = SettingsController(prefs);
      await controller.setYearlyGoal(50);
      expect(controller.yearlyGoal, 50);
      expect(prefs.getInt('yearly_goal'), 50);

      // Clamp negative or zero to minimum 1
      await controller.setYearlyGoal(-5);
      expect(controller.yearlyGoal, 1);

      // Clamp excessively high to 365
      await controller.setYearlyGoal(1000);
      expect(controller.yearlyGoal, 365);
    });
  });
}
