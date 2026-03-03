import 'package:flutter/cupertino.dart';
import '../theme/app_backgrounds.dart';

/// Deprecated: Use AppBackgrounds directly from theme folder
/// This file maintains backward compatibility for existing code
class Backgrounds {
  /// استخدام خلفية الشاشة (الوضع الفاتح)
  /// للوضع الداكن، استخدم AppBackgrounds.dark.screen()
  static LinearGradient screenBackGround() {
    return LightBackgrounds().screen;
  }

  /// استخدام خلفية شاشة البداية (الوضع الفاتح)
  /// للوضع الداكن، استخدم AppBackgrounds.dark.splash()
  static LinearGradient splashScreenBackGround() {
    return LightBackgrounds().splash;
  }

  /// استخدام خلفية الزر الأساسي (الوضع الفاتح)
  /// للوضع الداكن، استخدم AppBackgrounds.dark.primaryButton()
  static LinearGradient bottonBackGround() {
    return LightBackgrounds().primaryButton;
  }

  /// استخدام خلفية الزر الثانوي (الوضع الفاتح)
  /// للوضع الداكن، استخدم AppBackgrounds.dark.secondaryButton()
  static LinearGradient bottonBackGround2() {
    return LightBackgrounds().secondaryButton;
  }

  /// استخدام خلفية الهيدر (الوضع الفاتح)
  /// للوضع الداكن، استخدم AppBackgrounds.dark.headerFooter()
  static LinearGradient headerBackGround() {
    return LightBackgrounds().headerFooter;
  }

  /// استخدام خلفية الفوتر (الوضع الفاتح)
  /// للوضع الداكن، استخدم AppBackgrounds.dark.headerFooter().reverse()
  static LinearGradient footerBackGround() {
    return LightBackgrounds().headerFooterReverse;
  }
}
