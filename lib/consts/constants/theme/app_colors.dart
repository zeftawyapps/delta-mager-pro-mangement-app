import 'package:flutter/material.dart';

/// أداة لتحويل كود اللون من JSON إلى كائن Color
class ColorUtils {
  static Color fromHex(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    String hex = hexString.replaceFirst('#', '').replaceFirst('0x', '');
    if (hex.length == 6) hex = 'FF$hex';
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return fallback;
    }
  }
}

/// الألوان الأساسية للوضع الفاتح
class LightColors {
  static Color _getDynamicColor(String key, Color fallback) {
    if (AppColors.useDynamicTheme && AppColors._dynamicLightColors.containsKey(key)) {
      return AppColors._dynamicLightColors[key]!;
    }
    return fallback;
  }

  static Color get primary => _getDynamicColor('primary', const Color(0xFFD4AF37));
  static Color get secondary => _getDynamicColor('secondary', const Color(0xFF1A2332));
  static Color get accent => _getDynamicColor('accent', const Color(0xFFECC951));
  static Color get background => _getDynamicColor('background', const Color(0xFFFAF8F3));
  static Color get surface => _getDynamicColor('surface', const Color(0xFFFFFFFF));
  static Color get surfaceVariant => _getDynamicColor('surfaceVariant', const Color(0xFFF5F0E8));
  
  static Color get textPrimary => _getDynamicColor('textPrimary', const Color(0xFF1A2332));
  static Color get textSecondary => _getDynamicColor('textSecondary', const Color(0xFF5A6779));
  static Color get textHint => _getDynamicColor('textHint', const Color(0xFF9CA3AF));
  static Color get textOnPrimary => _getDynamicColor('textOnPrimary', const Color(0xFFFFFFFF));
  
  static Color get buttonPrimary => _getDynamicColor('buttonPrimary', const Color(0xFFD4AF37));
  static Color get buttonSecondary => _getDynamicColor('buttonSecondary', const Color(0xFF1A2332));
  static Color get buttonText => _getDynamicColor('buttonText', const Color(0xFFFFFFFF));
  
  static Color get divider => _getDynamicColor('divider', const Color(0xFFE5DCC8));
  static Color get icon => _getDynamicColor('icon', const Color(0xFFD4AF37));
  
  static Color get inputBackground => _getDynamicColor('inputBackground', const Color(0xFFFAF8F3));
  static Color get inputBorder => _getDynamicColor('inputBorder', const Color(0xFFD4C9B0));
  static Color get inputFocus => _getDynamicColor('inputFocus', const Color(0xFFD4AF37));

  // حالات
  static Color get success => _getDynamicColor('success', const Color(0xFF4CAF50));
  static Color get error => _getDynamicColor('error', const Color(0xFFE53935));
  static Color get warning => _getDynamicColor('warning', const Color(0xFFFFB300));
  static Color get info => _getDynamicColor('info', const Color(0xFF2196F3));
  static Color get herbGreen => _getDynamicColor('herbGreen', const Color(0xFF8FA883));
}

/// الألوان الأساسية للوضع الداكن
class DarkColors {
  static Color _getDynamicColor(String key, Color fallback) {
    if (AppColors.useDynamicTheme && AppColors._dynamicDarkColors.containsKey(key)) {
      return AppColors._dynamicDarkColors[key]!;
    }
    return fallback;
  }

  static Color get primary => _getDynamicColor('primary', const Color(0xFFD4AF37));
  static Color get secondary => _getDynamicColor('secondary', const Color(0xFFECC951));
  static Color get background => _getDynamicColor('background', const Color(0xFF1A2332));
  static Color get surface => _getDynamicColor('surface', const Color(0xFF242F3F));
  static Color get surfaceVariant => _getDynamicColor('surfaceVariant', const Color(0xFF2D3847));

  static Color get textPrimary => _getDynamicColor('textPrimary', const Color(0xFFFAF8F3));
  static Color get textSecondary => _getDynamicColor('textSecondary', const Color(0xFFD4C9B0));
  static Color get textHint => _getDynamicColor('textHint', const Color(0xFF8A8574));
  static Color get textOnPrimary => _getDynamicColor('textOnPrimary', const Color(0xFF1A2332));

  static Color get buttonPrimary => _getDynamicColor('buttonPrimary', const Color(0xFFD4AF37));
  static Color get buttonSecondary => _getDynamicColor('buttonSecondary', const Color(0xFF2D3847));
  static Color get buttonText => _getDynamicColor('buttonText', const Color(0xFF1A2332));

  static Color get divider => _getDynamicColor('divider', const Color(0xFF3D4A5C));
  static Color get icon => _getDynamicColor('icon', const Color(0xFFD4AF37));

  static Color get inputBackground => _getDynamicColor('inputBackground', const Color(0xFF242F3F));
  static Color get inputBorder => _getDynamicColor('inputBorder', const Color(0xFF3D4A5C));
  static Color get inputFocus => _getDynamicColor('inputFocus', const Color(0xFFD4AF37));

  // حالات
  static Color get success => _getDynamicColor('success', const Color(0xFF66BB6A));
  static Color get error => _getDynamicColor('error', const Color(0xFFEF5350));
  static Color get warning => _getDynamicColor('warning', const Color(0xFFFFCA28));
  static Color get info => _getDynamicColor('info', const Color(0xFF42A5F5));
  static Color get herbGreen => _getDynamicColor('herbGreen', const Color(0xFF8FA883));
}

/// كلاس الألوان الرئيسي للتطبيق
class AppColors {
  static Map<String, Color> _dynamicLightColors = {};
  static Map<String, Color> _dynamicDarkColors = {};
  static bool useDynamicTheme = false;

  static void setDynamicColors({Map<String, Color>? light, Map<String, Color>? dark}) {
    if (light != null) _dynamicLightColors = light;
    if (dark != null) _dynamicDarkColors = dark;
    useDynamicTheme = true;
  }

  // الأساسيات
  static Color get primary => LightColors.primary;
  static Color get secondary => LightColors.secondary;
  static Color get accent => LightColors.accent;
  static Color get background => LightColors.background;
  static Color get surface => LightColors.surface;
  static Color get surfaceVariant => LightColors.surfaceVariant;

  // النصوص
  static Color get darkText => LightColors.textPrimary;
  static Color get lightText => LightColors.textSecondary;
  static Color get textHint => LightColors.textHint;
  static Color get textOnPrimary => LightColors.textOnPrimary;
  static Color get textOnDark => const Color(0xFFFAF8F3);

  // أزرار
  static Color get buttonPrimary => LightColors.buttonPrimary;
  static Color get buttonSecondary => LightColors.buttonSecondary;
  static Color get buttonText => LightColors.buttonText;

  // حالات
  static Color get success => LightColors.success;
  static Color get error => LightColors.error;
  static Color get warning => LightColors.warning;
  static Color get info => LightColors.info;
  static Color get herbGreen => LightColors.herbGreen;

  // ألوان داكنة إضافية مستخدمة في الكود
  static Color get darkPrimary => DarkColors.primary;
  static Color get darkSecondary => DarkColors.secondary;
  static Color get darkBackground => DarkColors.background;
  static Color get darkSurface => DarkColors.surface;
  static Color get darkTextPrimary => DarkColors.textPrimary;
  static Color get darkTextSecondary => DarkColors.textSecondary;
  static Color get darkError => DarkColors.error;
  static Color get darkButtonPrimary => darkPrimary;

  // أخرى
  static Color get divider => LightColors.divider;
  static Color get shadow => const Color(0x1A1A2332);
  static Color get icon => LightColors.icon;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // ألوان زخرفية
  static Color get decorative => primary;
  static Color get decorativeLight => accent;
}

/// ألوان ثابتة للهيدر والفوتر
class FixedColors {
  static const Color primary = Color(0xFFD4AF37);
  static const Color secondary = Color(0xFF1A2332);
  static const Color headerFooter1 = Color(0xFFD4AF37);
  static const Color headerFooter2 = Color(0xFFC19A3E);
  static const Color headerFooter3 = Color(0xFF1A2332);
}
