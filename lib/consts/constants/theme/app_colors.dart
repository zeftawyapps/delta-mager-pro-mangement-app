import 'package:flutter/material.dart';

/// أداة لتحويل كود اللون من JSON إلى كائن Color
class ColorUtils {
  static Color fromHex(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;

    // تنظيف السلسلة النصية
    String hex = hexString.replaceFirst('#', '').replaceFirst('0x', '');

    // إذا كان الطول 6، نفترض أن الشفافية كاملة (FF)
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return fallback;
    }
  }
}

/// الألوان الأساسية للوضع الفاتح - مستوحاة من شاشة تسجيل الدخول وشعار TANTASTE
class LightColors {
  // الألوان الأساسية - ذهبي من الشعار
  static Color get primary => const Color(0xFFD4AF37);
  static Color get secondary => const Color(0xFF1A2332);
  static Color get accent => const Color(0xFFECC951);

  // الخلفيات
  static Color get background => const Color(0xFFFAF8F3);
  static Color get surface => const Color(0xFFFFFFFF);
  static Color get surfaceVariant => const Color(0xFFF5F0E8);

  // خلفيات داكنة (للـ gradient والـ cards)
  static Color get darkBackground => const Color(0xFF1A2332);
  static Color get darkSurface => const Color(0xFF242F3F);
  static Color get darkAccent => const Color(0xFF090B10);

  // النصوص
  static Color get textPrimary => const Color(0xFF1A2332);
  static Color get textSecondary => const Color(0xFF5A6779);
  static Color get textHint => const Color(0xFF9CA3AF);
  static Color get textOnDark => const Color(0xFFFAF8F3);
  static Color get textOnPrimary => const Color(0xFF1A2332);

  // الأزرار
  static Color get buttonPrimary => const Color(0xFFD4AF37);
  static Color get buttonSecondary => const Color(0xFF1A2332);
  static Color get buttonText => const Color(0xFF1A2332);
  static Color get buttonTextOnDark => const Color(0xFFD4AF37);

  // الحقول
  static Color get inputBackground => const Color(0xFFFAF8F3);
  static Color get inputBorder => const Color(0xFFD4C9B0);
  static Color get inputFocus => const Color(0xFFD4AF37);

  // حالات
  static Color get success => const Color(0xFF4CAF50);
  static Color get error => const Color(0xFFE53935);
  static Color get warning => const Color(0xFFFFB300);
  static Color get info => const Color(0xFF2196F3);

  // ألوان زخرفية
  static Color get decorative => const Color(0xFFD4AF37);
  static Color get decorativeLight => const Color(0xFFECC951);
  static Color get decorativeDark => const Color(0xFFC19A3E);
  static Color get overlay => const Color(0xE41A2332);

  // أخرى
  static Color get divider => const Color(0xFFE5DCC8);
  static Color get shadow => const Color(0x1A1A2332);
  static Color get icon => const Color(0xFFD4AF37);
  static Color get iconOnDark => const Color(0xFFD4AF37);

  // ألوان طبيعية
  static Color get herbGreen => const Color(0xFF8FA883);
  static Color get darkGreen => const Color(0xFF5A7555);
}

/// الألوان الأساسية للوضع الداكن - مستوحاة من شعار TANTASTE
class DarkColors {
  // الألوان الأساسية - خلفية الشعار الداكنة مع الذهبي
  static Color get primary => const Color(0xFFD4AF37);
  static Color get secondary => const Color(0xFFECC951);
  static Color get accent => const Color(0xFFC19A3E);

  // الخلفيات - داكنة مستوحاة من خلفية الشعار
  static Color get background => const Color(0xFF1A2332);
  static Color get surface => const Color(0xFF242F3F);
  static Color get surfaceVariant => const Color(0xFF2D3847);

  // النصوص - فاتحة مع لمسة بيج
  static Color get textPrimary => const Color(0xFFFAF8F3);
  static Color get textSecondary => const Color(0xFFD4C9B0);
  static Color get textHint => const Color(0xFF8A8574);

  // الأزرار - ذهبي مع نص داكن
  static Color get buttonPrimary => const Color(0xFFD4AF37);
  static Color get buttonSecondary => const Color(0xFF2D3847);
  static Color get buttonText => const Color(0xFF1A2332);

  // الحقول - داكنة مع حد ذهبي
  static Color get inputBackground => const Color(0xFF242F3F);
  static Color get inputBorder => const Color(0xFF3D4A5C);
  static Color get inputFocus => const Color(0xFFD4AF37);

  // حالات
  static Color get success => const Color(0xFF66BB6A);
  static Color get error => const Color(0xFFEF5350);
  static Color get warning => const Color(0xFFFFCA28);
  static Color get info => const Color(0xFF42A5F5);

  // أخرى
  static Color get divider => const Color(0xFF3D4A5C);
  static Color get shadow => const Color(0x40000000);
  static Color get icon => const Color(0xFFD4AF37);
}

/// ألوان الموقع الإلكتروني - مستوحاة من شعار TANTASTE
class WebsiteColors {
  // ألوان الشعار الأساسية
  static Color get beige => const Color(0xFFFAF8F3);
  static Color get lightBeige => const Color(0xFFFFFDF9);
  static Color get darkBackground => const Color(0xFF1A2332);
  static Color get gold => const Color(0xFFD4AF37);
  static Color get goldLight => const Color(0xFFECC951);
  static Color get goldDark => const Color(0xFFC19A3E);

  // ألوان طبيعية منسجمة
  static Color get herbGreen => const Color(0xFF8FA883);
  static Color get darkGreen => const Color(0xFF5A7555);
  static Color get paleGold => const Color(0xFFF3E5AB);

  // ألوان محايدة
  static const Color white = Color(0xFFFFFFFF);
  static Color get darkText => const Color(0xFF1A2332);
  static Color get lightText => const Color(0xFF8A8574);
  static Color get accent => const Color(0xFFB8956A);

  // حالات
  static Color get error => const Color(0xFFE53935);
  static Color get success => const Color(0xFF4CAF50);
  static Color get rating => const Color(0xFFD4AF37);
}

// للتوافق مع الكود القديم - مع ألوان شاشة تسجيل الدخول
class AppColors {
  // الألوان الأساسية
  static Color get primary => LightColors.primary;
  static Color get secondary => LightColors.secondary;
  static Color get accent => LightColors.accent;

  // الخلفيات الفاتحة
  static Color get background => LightColors.background;
  static Color get surface => LightColors.surface;
  static Color get surfaceVariant => LightColors.surfaceVariant;
  static Color get beige => LightColors.background;
  static Color get lightBeige => LightColors.surfaceVariant;

  // الخلفيات الداكنة (من شاشة login)
  static Color get darkBackground => LightColors.darkBackground;
  static Color get darkSurface => LightColors.darkSurface;
  static Color get darkAccent => LightColors.darkAccent;

  // النصوص
  static Color get darkText => LightColors.textPrimary;
  static Color get lightText => LightColors.textSecondary;
  static Color get textHint => LightColors.textHint;
  static Color get textOnDark => LightColors.textOnDark;
  static Color get textOnPrimary => LightColors.textOnPrimary;

  // الأزرار
  static Color get buttonPrimary => LightColors.buttonPrimary;
  static Color get buttonSecondary => LightColors.buttonSecondary;
  static Color get buttonText => LightColors.buttonText;
  static Color get buttonTextOnDark => LightColors.buttonTextOnDark;

  // الحقول
  static Color get inputBackground => LightColors.inputBackground;
  static Color get inputBorder => LightColors.inputBorder;
  static Color get inputFocus => LightColors.inputFocus;

  // حالات
  static Color get success => LightColors.success;
  static Color get error => LightColors.error;
  static Color get warning => LightColors.warning;
  static Color get info => LightColors.info;

  // ألوان زخرفية
  static Color get decorative => LightColors.decorative;
  static Color get decorativeLight => LightColors.decorativeLight;
  static Color get decorativeDark => LightColors.decorativeDark;
  static Color get overlay => LightColors.overlay;

  // أخرى
  static Color get divider => LightColors.divider;
  static Color get shadow => LightColors.shadow;
  static Color get icon => LightColors.icon;
  static Color get iconOnDark => LightColors.iconOnDark;
  static const Color white = Color(0xFFFFFFFF);

  // ألوان طبيعية
  static Color get herbGreen => LightColors.herbGreen;
  static Color get darkGreen => LightColors.darkGreen;
  static Color get lightGold => LightColors.primary;
  static Color get paleGold => LightColors.accent;
  static Color get rating => LightColors.primary;
}

/// ألوان ثابتة (للهيدر والفوتر) - مستوحاة من شعار TANTASTE
class FixedColors {
  static Color get primary => const Color(0xFFD4AF37);
  static Color get secondary => const Color(0xFF1A2332);
  static Color get headerFooter1 => const Color(0xFFD4AF37);
  static Color get headerFooter2 => const Color(0xFFC19A3E);
  static Color get headerFooter3 => const Color(0xFF1A2332);
  static Color get accent => const Color(0xFFECC951);
  static Color get background => const Color(0xFF242F3F);
  static Color get overlay => const Color(0xE41A2332);
}
