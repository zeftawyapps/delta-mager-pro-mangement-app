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

/// الألوان الأساسية للوضع الفاتح - مستوحاة من الشعار الجديد (Delta Matger Pro)
class LightColors {
  ///Helper to get dynamic color from AppColors
  static Color _getDynamicColor(String key, Color fallback) {
    if (AppColors.useDynamicTheme && AppColors._dynamicLightColors.containsKey(key)) {
      return AppColors._dynamicLightColors[key]!;
    }
    return fallback;
  }

  // الألوان الأساسية
  static Color get primary => _getDynamicColor('primary', const Color(0xFFD4AF37));
  static Color get secondary => _getDynamicColor('secondary', const Color(0xFF1A2332));
  static Color get accent => _getDynamicColor('accent', const Color(0xFFECC951)); 

  // الخلفيات
  static Color get background => _getDynamicColor('background', const Color(0xFFFAF8F3));
  static Color get surface => _getDynamicColor('surface', const Color(0xFFFFFFFF));
  static Color get surfaceVariant => _getDynamicColor('surfaceVariant', const Color(0xFFF5F0E8));

  // خلفيات داكنة (Defaults for dark sections in light theme)
  static Color get darkBackground => const Color(0xFF1A2332);
  static Color get darkSurface => const Color(0xFF242F3F);
  static Color get darkAccent => const Color(0xFF090B10);

  // النصوص
  static Color get textPrimary => _getDynamicColor('textPrimary', const Color(0xFF1A2332));
  static Color get textSecondary => _getDynamicColor('textSecondary', const Color(0xFF5A6779));
  static Color get textHint => _getDynamicColor('textHint', const Color(0xFF9CA3AF));
  static Color get textOnDark => _getDynamicColor('textOnDark', const Color(0xFFFAF8F3));
  static Color get textOnPrimary => _getDynamicColor('textOnPrimary', const Color(0xFF1A2332));

  // الأزرار
  static Color get buttonPrimary => _getDynamicColor('buttonPrimary', const Color(0xFFD4AF37));
  static Color get buttonSecondary => _getDynamicColor('buttonSecondary', const Color(0xFF1A2332));
  static Color get buttonText => _getDynamicColor('buttonText', const Color(0xFF1A2332));
  static Color get buttonTextOnDark => const Color(0xFFD4AF37);

  // الحقول
  static Color get inputBackground => _getDynamicColor('background', const Color(0xFFFAF8F3));
  static Color get inputBorder => const Color(0xFFD4C9B0);
  static Color get inputFocus => const Color(0xFFD4AF37);

  // حالات
  static Color get success => _getDynamicColor('success', const Color(0xFF4CAF50));
  static Color get error => _getDynamicColor('error', const Color(0xFFE53935));
  static Color get warning => _getDynamicColor('warning', const Color(0xFFFFB300));
  static Color get info => _getDynamicColor('info', const Color(0xFF2196F3));

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

/// الألوان الأساسية للوضع الداكن - مستوحاة من الشعار الجديد
class DarkColors {
  ///Helper to get dynamic color from AppColors
  static Color _getDynamicColor(String key, Color fallback) {
    if (AppColors.useDynamicTheme && AppColors._dynamicDarkColors.containsKey(key)) {
      return AppColors._dynamicDarkColors[key]!;
    }
    return fallback;
  }

  // الألوان الأساسية
  static Color get primary => _getDynamicColor('primary', const Color(0xFFD4AF37));
  static Color get secondary => _getDynamicColor('secondary', const Color(0xFFECC951));
  static Color get accent => _getDynamicColor('accent', const Color(0xFFC19A3E));

  // الخلفيات
  static Color get background => _getDynamicColor('background', const Color(0xFF1A2332));
  static Color get surface => _getDynamicColor('surface', const Color(0xFF242F3F));
  static Color get surfaceVariant => _getDynamicColor('surfaceVariant', const Color(0xFF2D3847));

  // خلفيات داكنة ممتدة
  static Color get darkBackground => const Color(0xFF131A24);
  static Color get darkSurface => const Color(0xFF1B2433);
  static Color get darkAccent => const Color(0xFF0C121A);

  // النصوص
  static Color get textPrimary => _getDynamicColor('textPrimary', const Color(0xFFFAF8F3));
  static Color get textSecondary => _getDynamicColor('textSecondary', const Color(0xFFD4C9B0));
  static Color get textHint => _getDynamicColor('textHint', const Color(0xFF8A8574));
  static Color get textOnDark => _getDynamicColor('textOnDark', const Color(0xFFFAF8F3));
  static Color get textOnPrimary => _getDynamicColor('textOnPrimary', const Color(0xFF1A2332));

  // الأزرار
  static Color get buttonPrimary => _getDynamicColor('buttonPrimary', const Color(0xFFD4AF37));
  static Color get buttonSecondary => _getDynamicColor('buttonSecondary', const Color(0xFF2D3847));
  static Color get buttonText => _getDynamicColor('buttonText', const Color(0xFF1A2332));
  static Color get buttonTextOnDark => const Color(0xFFD4AF37);

  // الحقول
  static Color get inputBackground => _getDynamicColor('background', const Color(0xFF242F3F));
  static Color get inputBorder => const Color(0xFF3D4A5C);
  static Color get inputFocus => const Color(0xFFD4AF37);

  // حالات
  static Color get success => _getDynamicColor('success', const Color(0xFF66BB6A));
  static Color get error => _getDynamicColor('error', const Color(0xFFEF5350));
  static Color get warning => _getDynamicColor('warning', const Color(0xFFFFCA28));
  static Color get info => _getDynamicColor('info', const Color(0xFF42A5F5));

  // ألوان زخرفية داكنة مضافة
  static Color get decorative => const Color(0xFFD4AF37);
  static Color get decorativeLight => const Color(0xFFECC951);
  static Color get decorativeDark => const Color(0xFFC19A3E);
  static Color get overlay => const Color(0xE4090B10);

  // أخرى
  static Color get divider => const Color(0xFF3D4A5C);
  static Color get shadow => const Color(0x40000000);
  static Color get icon => const Color(0xFFD4AF37);
  static Color get iconOnDark => const Color(0xFFD4AF37);

  // ألوان طبيعية ممتدة
  static Color get herbGreen => const Color(0xFF8FA883);
  static Color get darkGreen => const Color(0xFF5A7555);
}

/// ألوان الموقع الإلكتروني
class WebsiteColors {
  static Color get beige => const Color(0xFFFAF8F3);
  static Color get lightBeige => const Color(0xFFFFFDF9);
  static Color get darkBackground => const Color(0xFF1A2332);
  static Color get gold => const Color(0xFFD4AF37);
  static Color get goldLight => const Color(0xFFECC951);
  static Color get goldDark => const Color(0xFFC19A3E);

  static Color get herbGreen => const Color(0xFF8FA883);
  static Color get darkGreen => const Color(0xFF5A7555);
  static Color get paleGold => const Color(0xFFF3E5AB);

  static const Color white = Color(0xFFFFFFFF);
  static Color get darkText => const Color(0xFF1A2332);
  static Color get lightText => const Color(0xFF8A8574);
  static Color get accent => const Color(0xFFB8956A);
  
  static Color get error => const Color(0xFFE53935);
  static Color get success => const Color(0xFF4CAF50);
  static Color get rating => const Color(0xFFD4AF37);
}

// للتوافق مع الكود القديم والاستخدام العام في التطبيق
class AppColors {
  // 🆕 تم جعل منطق الألوان مركزياً في LightColors و DarkColors لضمان التوافق
  static Map<String, Color> _dynamicLightColors = {};
  static Map<String, Color> _dynamicDarkColors = {};
  static bool useDynamicTheme = false;

  static void setDynamicColors({
    Map<String, Color>? light,
    Map<String, Color>? dark,
  }) {
    if (light != null) _dynamicLightColors = light;
    if (dark != null) _dynamicDarkColors = dark;
    useDynamicTheme = true;
  }

  static void resetToDefault() {
    _dynamicLightColors.clear();
    _dynamicDarkColors.clear();
    useDynamicTheme = false;
  }

  // الألوان الأساسية - يتم جلبها الآن من الكلاسات المرتبطة
  static Color get primary => LightColors.primary;
  static Color get secondary => LightColors.secondary;
  static Color get accent => LightColors.accent;

  // الألوان الأساسية - الوضع الداكن
  static Color get darkPrimary => DarkColors.primary;
  static Color get darkSecondary => DarkColors.secondary;
  static Color get darkAccent => DarkColors.accent;

  // الخلفيات الفاتحة
  static Color get background => LightColors.background;
  static Color get surface => LightColors.surface;
  static Color get surfaceVariant => LightColors.surfaceVariant;
  static Color get beige => background;
  static Color get lightBeige => surfaceVariant;

  // الخلفيات الداكنة
  static Color get darkBackground => DarkColors.background;
  static Color get darkSurface => DarkColors.surface;

  // نصوص
  static Color get darkText => LightColors.textPrimary;
  static Color get lightText => LightColors.textSecondary;
  static Color get textHint => LightColors.textHint;
  static Color get textOnDark => LightColors.textOnDark;
  static Color get textOnPrimary => LightColors.textOnPrimary;

  // نصوص داكنة
  static Color get darkTextPrimary => DarkColors.textPrimary;
  static Color get darkTextSecondary => DarkColors.textSecondary;

  // الأزرار
  static Color get buttonPrimary => LightColors.buttonPrimary;
  static Color get buttonSecondary => LightColors.buttonSecondary;
  static Color get buttonText => LightColors.buttonText;

  // الأزرار الداكنة
  static Color get darkButtonPrimary => DarkColors.buttonPrimary;

  // حالات
  static Color get success => LightColors.success;
  static Color get error => LightColors.error;
  static Color get warning => LightColors.warning;
  static Color get info => LightColors.info;

  // حالات داكنة
  static Color get darkError => DarkColors.error;

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

  // ألوان طبيعية واستعارات سابقة للواجهة
  static Color get herbGreen => LightColors.herbGreen;
  static Color get darkGreen => DarkColors.darkGreen;
  static Color get lightGold => primary;
  static Color get paleGold => accent;
  static Color get rating => accent;
}

/// ألوان ثابتة (للهيدر والفوتر)
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
