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
        primary: LightColors.primary,
        secondary: LightColors.secondary,
        surface: LightColors.surface,
        error: LightColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LightColors.textPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: LightColors.background,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: LightColors.primary,
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
          color: LightColors.textPrimary,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: LightColors.textPrimary,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: LightColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: LightColors.textPrimary,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: LightColors.textPrimary,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.w500,
          color: LightColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.normal,
          color: LightColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.normal,
          color: LightColors.textSecondary,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeSmall,
          fontWeight: FontWeight.normal,
          color: LightColors.textHint,
        ),
      ),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightColors.buttonPrimary,
          foregroundColor: LightColors.buttonText,
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
          foregroundColor: LightColors.primary,
          side: BorderSide(
            color: LightColors.primary,
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
        primary: DarkColors.primary,
        secondary: DarkColors.secondary,
        surface: DarkColors.surface,
        error: DarkColors.error,
        onPrimary: DarkColors.textPrimary,
        onSecondary: DarkColors.textPrimary,
        onSurface: DarkColors.textPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: DarkColors.background,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: DarkColors.primary,
        foregroundColor: DarkColors.textPrimary,
        elevation: AppDimensions.elevationRegular,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: DarkColors.textPrimary,
        ),
      ),

      // نصوص التطبيق
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeHuge,
          fontWeight: FontWeight.bold,
          color: DarkColors.textPrimary,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: DarkColors.textPrimary,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: DarkColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: DarkColors.textPrimary,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: DarkColors.textPrimary,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.w500,
          color: DarkColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.normal,
          color: DarkColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.normal,
          color: DarkColors.textSecondary,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: AppDimensions.fontSizeSmall,
          fontWeight: FontWeight.normal,
          color: DarkColors.textHint,
        ),
      ),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkColors.buttonPrimary,
          foregroundColor: DarkColors.buttonText,
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
          foregroundColor: DarkColors.primary,
          side: BorderSide(
            color: DarkColors.primary,
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
