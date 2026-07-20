import 'package:flutter/material.dart';

class HomeNavLinkConfig {
  final String label;
  final String? route;
  final void Function()? onTap;
  final Color? textColor;
  final FontWeight? fontWeight;
  final bool isUnderlined;

  const HomeNavLinkConfig({
    required this.label,
    this.route,
    this.onTap,
    this.textColor,
    this.fontWeight,
    this.isUnderlined = false,
  });
}

class HomeHeaderConfig {
  /// نص عنوان المتجر — يُعرض بجانب الـ logo
  final String title;

  /// مسار الـ asset للـ logo (اختياري)
  final String? logoAssetPath;

  /// URL للـ logo من الشبكة (اختياري — الأولوية للـ asset)
  final String? logoNetworkUrl;

  /// هل يظهر زر الكارت
  final bool showCartButton;

  /// هل يظهر قائمة التنقل (desktop nav links)
  final bool showNavLinks;

  /// روابط التنقل — تُعرض في الـ desktop فقط
  final List<HomeNavLinkConfig> navLinks;

  /// مسافة أفقية للـ header
  final double desktopHorizontalPadding;
  final double mobileHorizontalPadding;

  const HomeHeaderConfig({
    required this.title,
    this.logoAssetPath,
    this.logoNetworkUrl,
    this.showCartButton = true,
    this.showNavLinks = true,
    this.navLinks = const [],
    this.desktopHorizontalPadding = 24,
    this.mobileHorizontalPadding = 12,
  });
}
