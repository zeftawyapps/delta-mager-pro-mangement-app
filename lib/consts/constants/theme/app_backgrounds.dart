import 'package:flutter/material.dart';
import 'app_colors.dart';

/// خلفيات التطبيق - تعتمد على وضع الألوان (فاتح/داكن)
class AppBackgrounds {
  /// الحصول على خلفيات الوضع الفاتح
  static LightBackgrounds get light => LightBackgrounds();
  
  /// الحصول على خلفيات الوضع الداكن
  static DarkBackgrounds get dark => DarkBackgrounds();
}

/// خلفيات الوضع الفاتح
class LightBackgrounds {
  /// خلفية الشاشة الرئيسية
  LinearGradient get screen => LinearGradient(
        colors: [LightColors.surfaceVariant, LightColors.surfaceVariant],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية شاشة البداية (Splash)
  LinearGradient get splash => LinearGradient(
        colors: [LightColors.surfaceVariant, LightColors.info],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// خلفية الأزرار الأساسية
  LinearGradient get primaryButton => LinearGradient(
        colors: [LightColors.buttonPrimary, LightColors.buttonPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الأزرار الثانوية
  LinearGradient get secondaryButton => LinearGradient(
        colors: [LightColors.buttonSecondary, LightColors.buttonSecondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الأزرار الشفافة
  LinearGradient get transparentButton => LinearGradient(
        colors: [
          LightColors.buttonSecondary.withOpacity(0.2),
          LightColors.buttonSecondary.withOpacity(0.1)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الهيدر والفوتر
  LinearGradient get headerFooter => LinearGradient(
        colors: [
          FixedColors.headerFooter1,
          FixedColors.headerFooter2,
          FixedColors.headerFooter3
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// خلفية الهيدر والفوتر معكوسة
  LinearGradient get headerFooterReverse => LinearGradient(
        colors: [
          FixedColors.headerFooter3,
          FixedColors.headerFooter2,
          FixedColors.headerFooter1
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// خلفية البطاقات
  LinearGradient get card => LinearGradient(
        colors: [LightColors.surface, LightColors.surface],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الـ AppBar
  LinearGradient get appBar => LinearGradient(
        colors: [LightColors.primary, LightColors.primary],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// خلفية النجاح
  LinearGradient get success => LinearGradient(
        colors: [LightColors.success, LightColors.success.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الخطأ
  LinearGradient get error => LinearGradient(
        colors: [LightColors.error, LightColors.error.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية التحذير
  LinearGradient get warning => LinearGradient(
        colors: [LightColors.warning, LightColors.warning.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// خلفيات الوضع الداكن
class DarkBackgrounds {
  /// خلفية الشاشة الرئيسية
  LinearGradient get screen => LinearGradient(
        colors: [DarkColors.surfaceVariant, DarkColors.surfaceVariant],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية شاشة البداية (Splash)
  LinearGradient get splash => LinearGradient(
        colors: [DarkColors.surfaceVariant, DarkColors.info],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// خلفية الأزرار الأساسية
  LinearGradient get primaryButton => LinearGradient(
        colors: [DarkColors.buttonPrimary, DarkColors.buttonPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الأزرار الثانوية
  LinearGradient get secondaryButton => LinearGradient(
        colors: [DarkColors.buttonSecondary, DarkColors.buttonSecondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الأزرار الشفافة
  LinearGradient get transparentButton => LinearGradient(
        colors: [
          DarkColors.buttonSecondary.withOpacity(0.2),
          DarkColors.buttonSecondary.withOpacity(0.1)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الهيدر والفوتر
  LinearGradient get headerFooter => LinearGradient(
        colors: [
          FixedColors.headerFooter1,
          FixedColors.headerFooter2,
          FixedColors.headerFooter3
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// خلفية الهيدر والفوتر معكوسة
  LinearGradient get headerFooterReverse => LinearGradient(
        colors: [
          FixedColors.headerFooter3,
          FixedColors.headerFooter2,
          FixedColors.headerFooter1
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// خلفية البطاقات
  LinearGradient get card => LinearGradient(
        colors: [DarkColors.surface, DarkColors.surface],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الـ AppBar
  LinearGradient get appBar => LinearGradient(
        colors: [DarkColors.primary, DarkColors.primary],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// خلفية النجاح
  LinearGradient get success => LinearGradient(
        colors: [DarkColors.success, DarkColors.success.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية الخطأ
  LinearGradient get error => LinearGradient(
        colors: [DarkColors.error, DarkColors.error.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// خلفية التحذير
  LinearGradient get warning => LinearGradient(
        colors: [DarkColors.warning, DarkColors.warning.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
