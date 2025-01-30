import 'package:beat_it/core/core.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
  );

  static final _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.grey1,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        surfaceTint: Colors.transparent,
      ),
      cardTheme: const CardTheme(
        color: AppColors.white1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.grey1,
        foregroundColor: AppColors.black1,
      ),
      textTheme: _textTheme.apply(
        bodyColor: AppColors.black1,
        displayColor: AppColors.black1,
      ),
      filledButtonTheme: _filledButtonTheme,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.black1,
        behavior: SnackBarBehavior.fixed,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.black1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.black1,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryColor,
        onPrimary: AppColors.black1,
        secondary: AppColors.primaryColor,
        onSecondary: AppColors.black1,
        error: AppColors.red1,
        onError: AppColors.white1,
        surface: AppColors.grey2,
        onSurface: AppColors.white1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.black1,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.grey1,
        behavior: SnackBarBehavior.fixed,
      ),
      // colorScheme: ColorScheme.fromSeed(
      //   surface: AppColors.black1,
      //   seedColor: AppColors.primaryColor,
      //   surfaceTint: Colors.transparent,
      //   brightness: Brightness.dark,
      // ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black1,
        foregroundColor: AppColors.white1,
      ),
      textTheme: _textTheme.apply(
        bodyColor: AppColors.white1,
        displayColor: AppColors.white1,
      ),
      filledButtonTheme: _filledButtonTheme,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.grey1,
      ),
    );
  }
}
