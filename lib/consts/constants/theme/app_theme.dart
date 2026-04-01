import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  /// الثيم الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // نظام الألوان
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkText,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevationRegular,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // نصوص التطبيق
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeHuge,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.normal,
          color: AppColors.darkText,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.normal,
          color: AppColors.lightText,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeSmall,
          fontWeight: FontWeight.normal,
          color: AppColors.textHint,
        ),
      ),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
          elevation: AppDimensions.elevationRegular,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: AppDimensions.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderWidthRegular,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: AppDimensions.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.inputBackground.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: LightColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: LightColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(
            color: LightColors.inputFocus,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: LightColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingRegular,
        ),
        hintStyle: TextStyle(color: LightColors.textHint),
        labelStyle: TextStyle(color: LightColors.textSecondary),
      ),

      // البطاقات
      cardTheme: CardThemeData(
        color: LightColors.surface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.all(AppDimensions.paddingSmall),
      ),

      // الأيقونات
      iconTheme: IconThemeData(
        color: LightColors.icon,
        size: AppDimensions.iconSizeRegular,
      ),

      // الفواصل
      dividerTheme: DividerThemeData(
        color: LightColors.divider.withOpacity(0.2),
        thickness: AppDimensions.borderWidthThin,
      ),
    );
  }

  /// الثيم الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // نظام الألوان
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        error: AppColors.darkError,
        onPrimary: AppColors.darkTextPrimary,
        onSecondary: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: AppDimensions.elevationRegular,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),

      // نصوص التطبيق
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeHuge,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextSecondary,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeSmall,
          fontWeight: FontWeight.normal,
          color: AppColors.textHint,
        ),
      ),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkButtonPrimary,
          foregroundColor: AppColors.buttonText,
          elevation: AppDimensions.elevationRegular,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: AppDimensions.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: BorderSide(
            color: AppColors.darkPrimary,
            width: AppDimensions.borderWidthRegular,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: AppDimensions.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.inputBackground.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: DarkColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: DarkColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(
            color: DarkColors.inputFocus,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: DarkColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingRegular,
        ),
        hintStyle: TextStyle(color: DarkColors.textHint),
        labelStyle: TextStyle(color: DarkColors.textSecondary),
      ),

      // البطاقات
      cardTheme: CardThemeData(
        color: DarkColors.surface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.all(AppDimensions.paddingSmall),
      ),

      // الأيقونات
      iconTheme: IconThemeData(
        color: DarkColors.icon,
        size: AppDimensions.iconSizeRegular,
      ),

      // الفواصل
      dividerTheme: DividerThemeData(
        color: DarkColors.divider.withOpacity(0.2),
        thickness: AppDimensions.borderWidthThin,
      ),
    );
  }
}
