/// ─────────────────────────────────────────────────────────────────────────────
/// Home Screen Delegate
/// العقد بين الـ Template وتطبيق الـ consumer
/// الـ Template لا يعرف أي model — كل شيء يصله عبر الـ delegate
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
/// Home Item — نموذج بيانات بسيط وgeneric يمثل أي عنصر (product/category/offer)
/// الـ consumer يحوّل الـ model الخاص به إلى هذا النموذج
// ─────────────────────────────────────────────────────────────────────────────

class HomeProductItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final String price;
  final String? imageUrl;

  /// flags للفلترة
  final bool isNew;
  final bool isBestSeller;
  final bool isOnSale;
  final bool isJoker;
  final bool isSuperJoker;

  /// كمية المنتج الحالية في السلة
  final int quantityInCart;

  /// الـ model الأصلي للـ custom builders والـ callbacks
  final dynamic originalModel;

  const HomeProductItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.imageUrl,
    this.isNew = false,
    this.isBestSeller = false,
    this.isOnSale = false,
    this.isJoker = false,
    this.isSuperJoker = false,
    this.quantityInCart = 0,
    this.originalModel,
  });
}

class HomeCategoryItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;

  /// الـ model الأصلي للـ custom builders والـ callbacks
  final dynamic originalModel;

  const HomeCategoryItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    this.originalModel,
  });
}

class HomeOfferItem {
  final String id;
  final String nameAr;
  final String? imageUrl;
  final String targetId;
  final bool isProductTarget; // true → product, false → offers list

  /// الـ model الأصلي للـ custom builders والـ callbacks
  final dynamic originalModel;

  const HomeOfferItem({
    required this.id,
    required this.nameAr,
    this.imageUrl,
    required this.targetId,
    this.isProductTarget = false,
    this.originalModel,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
/// Auth State للـ user في الـ header
// ─────────────────────────────────────────────────────────────────────────────

class HomeAuthState {
  final String? userName;
  final bool isLoggedIn;

  const HomeAuthState({this.userName, required this.isLoggedIn});

  static const HomeAuthState guest = HomeAuthState(isLoggedIn: false);
}

// ─────────────────────────────────────────────────────────────────────────────
/// الـ Delegate نفسه — يُمرر من consumer إلى الـ template
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreenDelegate {
  // ── Data ────────────────────────────────────────────────────────────────────

  /// قائمة المنتجات الحالية
  final List<HomeProductItem> products;

  /// قائمة التصنيفات
  final List<HomeCategoryItem> categories;

  /// قائمة العروض
  final List<HomeOfferItem> offers;

  /// حالة الـ user
  final HomeAuthState authState;

  /// عدد عناصر الكارت
  final int cartItemCount;

  // ── Loading States ───────────────────────────────────────────────────────────
  final bool isLoadingProducts;
  final bool isLoadingCategories;
  final bool isLoadingOffers;

  // ── Callbacks ────────────────────────────────────────────────────────────────

  /// يُستدعى لتحميل البيانات — مع إمكانية الـ force refresh
  final Future<void> Function({bool forceRefresh}) onLoadData;

  /// عند الضغط على منتج
  final void Function(String productId) onProductTap;

  /// عند الضغط على إضافة للسلة
  final void Function(HomeProductItem product)? onAddToCart;

  /// عند الضغط على تقليل الكمية أو حذفها من السلة
  final void Function(HomeProductItem product)? onRemoveFromCart;

  /// عند الضغط على تصنيف
  final void Function(String categoryId) onCategoryTap;

  /// عند الضغط على عرض
  final void Function(HomeOfferItem offer) onOfferTap;

  /// عند الضغط على الكارت
  final void Function()? onCartTap;

  /// عند الضغط على "كل المنتجات"
  final void Function()? onAllProductsTap;

  /// عند الضغط على تسجيل الدخول
  final void Function()? onLoginTap;

  /// عند الضغط على تسجيل الخروج
  final void Function()? onLogoutTap;

  /// عند الضغط على الملف الشخصي
  final void Function()? onProfileTap;

  /// عند الضغط على طلباتي
  final void Function()? onOrdersTap;

  // ── Custom Widget Builders ────────────────────────────────────────────────────

  /// بناء بطاقة المنتج — لو null بيستخدم الـ default card
  final Widget Function(HomeProductItem product, bool isDark)? productCardBuilder;

  /// بناء بطاقة الجوكر — لو null بيستخدم image-only card
  final Widget Function(HomeProductItem product)? jokerCardBuilder;

  /// بناء بطاقة التصنيف — لو null بيستخدم الـ default
  final Widget Function(HomeCategoryItem category, bool isDark)? categoryCardBuilder;

  const HomeScreenDelegate({
    required this.products,
    required this.categories,
    required this.offers,
    required this.onLoadData,
    required this.onProductTap,
    this.onAddToCart,
    this.onRemoveFromCart,
    required this.onCategoryTap,
    required this.onOfferTap,
    this.authState = HomeAuthState.guest,
    this.cartItemCount = 0,
    this.isLoadingProducts = false,
    this.isLoadingCategories = false,
    this.isLoadingOffers = false,
    this.onCartTap,
    this.onAllProductsTap,
    this.onLoginTap,
    this.onLogoutTap,
    this.onProfileTap,
    this.onOrdersTap,
    this.productCardBuilder,
    this.jokerCardBuilder,
    this.categoryCardBuilder,
  });
}
