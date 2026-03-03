import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/theam/theam.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart'
    show AppRoutes;

import 'package:flutter/material.dart';
import '../consts/constants/theme/app_colors.dart';

class AppShellConfigs {
  static String get titleApp => 'Domancy';

  static Duration get animationDuration => const Duration(milliseconds: 1000);

  static String get languageCode => 'ar';

  static SidBarAnimationType get animationType =>
      SidBarAnimationType.slideAndFade;

  static bool get showAppBarOnSmallScreen => false;

  static bool get showAppBarOnLargeScreen => false;

  static bool get debugShowCheckedModeBanner => false;

  static bool get isDarkMode => false;

  static String get initRouter => AppRoutes.login;

  // Sidebar Colors
  static Color get sidebarBackgroundColor => AppColors.darkBackground;
  static Color get sidebarTextColor => AppColors.textOnDark;
  static Color get sidebarHoverColor => AppColors.darkSurface;
  static Color get sidebarHoverTextColor => AppColors.decorativeLight;
  static Color get sidebarSelectedColor => AppColors.primary;
  static Color get sidebarSelectedIconColor => AppColors.secondary;
  static Color get sidebarSelectedTextColor => AppColors.secondary;
  static Color get sidebarIconColor => AppColors.primary;

  // Sidebar Expanded Colors
  static Color get sidebarExpandedArrowColor => AppColors.decorativeLight;
  static Color get sidebarExpandedBackgroundColor => AppColors.darkSurface;
  static Color get sidebarExpandedIconColor => AppColors.decorativeLight;
  static Color get sidebarExpandedTextColor => AppColors.decorativeLight;

  // Development Settings
  static bool get isProduction => false;
}
