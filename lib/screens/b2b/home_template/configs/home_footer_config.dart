import 'package:flutter/material.dart';

class HomeFooterLinkConfig {
  final String label;
  final void Function()? onTap;
  final Color? textColor;
  final FontWeight? fontWeight;
  final bool isUnderlined;

  const HomeFooterLinkConfig({
    required this.label,
    this.onTap,
    this.textColor,
    this.fontWeight,
    this.isUnderlined = false,
  });
}

class HomeContactConfig {
  final String? email;
  final String? phone;
  final String? address;

  const HomeContactConfig({this.email, this.phone, this.address});
}

class HomeSocialConfig {
  final String iconName; // 'facebook' | 'instagram' | 'whatsapp' | 'twitter'
  final void Function()? onTap;

  const HomeSocialConfig({required this.iconName, this.onTap});
}

class HomePaymentBadgeConfig {
  final String label;

  const HomePaymentBadgeConfig({required this.label});
}

class HomeFooterConfig {
  /// هل يظهر الـ footer
  final bool isEnabled;

  /// وصف المتجر
  final String? storeDescription;

  /// روابط سريعة في الـ footer
  final List<HomeFooterLinkConfig> quickLinks;

  /// بيانات التواصل
  final HomeContactConfig? contact;

  /// شارات الدفع
  final List<HomePaymentBadgeConfig> paymentBadges;

  /// روابط السوشيال
  final List<HomeSocialConfig> socialLinks;

  /// نص الـ copyright — لو null بيُبنى تلقائياً من عنوان المتجر
  final String? copyrightText;

  /// نص عمود الدفع والشحن
  final String? paymentSectionTitle;
  final String? paymentSectionBody;

  const HomeFooterConfig({
    this.isEnabled = true,
    this.storeDescription,
    this.quickLinks = const [],
    this.contact,
    this.paymentBadges = const [],
    this.socialLinks = const [],
    this.copyrightText,
    this.paymentSectionTitle,
    this.paymentSectionBody,
  });

  /// Footer معطل تماماً
  static const HomeFooterConfig disabled = HomeFooterConfig(isEnabled: false);
}
