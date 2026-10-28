import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const double defaultBorderRadius = 6.0;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkAccentBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccentBlue,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkErrorRed,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        labelStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccentBlue,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          backgroundColor: AppColors.darkCardFill,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary),
        titleLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightAccentBlue,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccentBlue,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightErrorRed,
        outline: AppColors.lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        labelStyle: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          backgroundColor: AppColors.lightSurface,
          side: const BorderSide(color: AppColors.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
        bodySmall: TextStyle(color: AppColors.lightTextSecondary),
        titleLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}