import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/theam/theam.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart'
    show AppRoutes;

import 'package:flutter/material.dart';
import '../consts/constants/theme/app_colors.dart';

class AppShellConfigs {
  // 🆕 الإعدادات الأساسية - يمكن تعديلها من main.dart
  static bool isAdminMode = true;
  static String titleApp = 'Domancy';
  static String defaultOrgName = 'domansy';
  static Duration animationDuration = const Duration(milliseconds: 1000);
  static String languageCode = 'ar';
  static SidBarAnimationType animationType = SidBarAnimationType.slideAndFade;
  static bool showAppBarOnSmallScreen = false;
  static bool showAppBarOnLargeScreen = false;
  static bool debugShowCheckedModeBanner = false;
  static bool isDarkMode = false;
  static bool isProduction = false;

  // 🚀 المسار الابتدائي - يعتمد ديناميكياً على وضع الإدمن
  static String get initRouter =>
      isAdminMode ? AppRoutes.loginAdmin : AppRoutes.splash;

  // 🎨 ألوان الـ Sidebar
  static Color sidebarBackgroundColor = AppColors.darkBackground;
  static Color sidebarTextColor = AppColors.textOnDark;
  static Color sidebarHoverColor = AppColors.darkSurface;
  static Color sidebarHoverTextColor = AppColors.decorativeLight;
  static Color sidebarSelectedColor = AppColors.primary;
  static Color sidebarSelectedIconColor = AppColors.secondary;
  static Color sidebarSelectedTextColor = AppColors.secondary;
  static Color sidebarIconColor = AppColors.primary;

  // 📂 ألوان القوائم المنسدلة (Expanded Sidebar)
  static Color sidebarExpandedArrowColor = AppColors.decorativeLight;
  static Color sidebarExpandedBackgroundColor = AppColors.darkSurface;
  static Color sidebarExpandedIconColor = AppColors.decorativeLight;
  static Color sidebarExpandedTextColor = AppColors.decorativeLight;
}
