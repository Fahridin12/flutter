import 'package:flutter/material.dart';

/// Material 3: цветовая схема строится от одного seed-цвета, светлая и тёмная темы.
abstract final class AppTheme {
  static const _seed = Color(0xFF7A4E2D);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
    );
  }
}
