import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GymThemePalette {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color surfaceColor;
  final Color cardColor;
  final String emoji;

  const GymThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.surfaceColor,
    required this.cardColor,
    required this.emoji,
  });
}

class ThemeService extends ChangeNotifier {
  static const List<GymThemePalette> availablePalettes = [
    GymThemePalette(
      id: 'cyber_lime',
      name: 'Cyber Lime',
      primary: Color(0xFFCCFF00),
      secondary: Color(0xFF00E5FF),
      surfaceColor: Color(0xFF1E1E1E),
      cardColor: Color(0xFF252525),
      emoji: '⚡',
    ),
    GymThemePalette(
      id: 'neon_cyan',
      name: 'Neon Cyan',
      primary: Color(0xFF00E5FF),
      secondary: Color(0xFF7C4DFF),
      surfaceColor: Color(0xFF151C24),
      cardColor: Color(0xFF1A232E),
      emoji: '🌊',
    ),
    GymThemePalette(
      id: 'sunset_blaze',
      name: 'Sunset Blaze',
      primary: Color(0xFFFF5722),
      secondary: Color(0xFFFFB300),
      surfaceColor: Color(0xFF201614),
      cardColor: Color(0xFF2B1D1A),
      emoji: '🔥',
    ),
    GymThemePalette(
      id: 'electric_violet',
      name: 'Electric Violet',
      primary: Color(0xFFD500F9),
      secondary: Color(0xFF00E5FF),
      surfaceColor: Color(0xFF1C1324),
      cardColor: Color(0xFF261A32),
      emoji: '🔮',
    ),
    GymThemePalette(
      id: 'crimson_fury',
      name: 'Crimson Fury',
      primary: Color(0xFFFF1744),
      secondary: Color(0xFFFF9100),
      surfaceColor: Color(0xFF211315),
      cardColor: Color(0xFF2D181C),
      emoji: '🩸',
    ),
    GymThemePalette(
      id: 'gold_standard',
      name: 'Gold Standard',
      primary: Color(0xFFFFD700),
      secondary: Color(0xFFFFA000),
      surfaceColor: Color(0xFF1C1A14),
      cardColor: Color(0xFF262217),
      emoji: '🥇',
    ),
  ];

  GymThemePalette _currentPalette = availablePalettes[0];

  GymThemePalette get currentPalette => _currentPalette;
  Color get primaryColor => _currentPalette.primary;
  Color get secondaryColor => _currentPalette.secondary;
  Color get cardColor => _currentPalette.cardColor;

  void setPalette(GymThemePalette palette) {
    _currentPalette = palette;
    notifyListeners();
  }

  ThemeData getThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: _currentPalette.primary,
      colorScheme: ColorScheme.dark(
        primary: _currentPalette.primary,
        secondary: _currentPalette.secondary,
        surface: _currentPalette.surfaceColor,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _currentPalette.surfaceColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: _currentPalette.cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentPalette.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _currentPalette.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _currentPalette.surfaceColor,
        selectedItemColor: _currentPalette.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
