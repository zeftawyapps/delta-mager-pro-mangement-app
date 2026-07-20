/// ─────────────────────────────────────────────────────────────────────────────
/// Home Screen Section Configs
/// كل نوع section له class خاص بخصائصه — قابل للتمرير من الخارج
/// ─────────────────────────────────────────────────────────────────────────────

/// Display mode for sections
enum HomeSectionDisplayMode {
  slider,
  horizontalList,
  grid,
}

/// Filter type for product sections
enum HomeProductFilter {
  none,
  isNew,
  isBestSeller,
  isOnSale,
  isJoker,
  isSuperJoker,
}

/// Base class for all section configs
abstract class HomeSectionConfig {
  final String id;
  final bool isActive;
  final String? title;

  const HomeSectionConfig({
    required this.id,
    required this.isActive,
    this.title,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
/// Offers/Promotions Section
// ─────────────────────────────────────────────────────────────────────────────
class OffersHomeSectionConfig extends HomeSectionConfig {
  final HomeSectionDisplayMode displayMode;
  final double sliderHeight;
  final double horizontalListHeight;
  final int gridCrossAxisCount;
  final double gridChildAspectRatio;
  final bool autoPlay;
  final Duration autoPlayDuration;

  const OffersHomeSectionConfig({
    required super.id,
    super.isActive = true,
    super.title,
    this.displayMode = HomeSectionDisplayMode.slider,
    this.sliderHeight = 180,
    this.horizontalListHeight = 180,
    this.gridCrossAxisCount = 2,
    this.gridChildAspectRatio = 1.8,
    this.autoPlay = true,
    this.autoPlayDuration = const Duration(seconds: 5),
  });
}

// ─────────────────────────────────────────────────────────────────────────────
/// Categories Section
// ─────────────────────────────────────────────────────────────────────────────
class CategoriesHomeSectionConfig extends HomeSectionConfig {
  final double listHeight;
  final double itemWidth;
  final double itemImageSize;
  final double itemBorderRadius;

  const CategoriesHomeSectionConfig({
    required super.id,
    super.isActive = true,
    super.title,
    this.listHeight = 130,
    this.itemWidth = 100,
    this.itemImageSize = 80,
    this.itemBorderRadius = 20,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
/// Products Section (new, bestseller, on-sale, joker, super-joker)
// ─────────────────────────────────────────────────────────────────────────────
class ProductsHomeSectionConfig extends HomeSectionConfig {
  final HomeSectionDisplayMode displayMode;
  final HomeProductFilter filter;
  final int crossAxisCount;
  final double? childAspectRatio;
  final int? maxItems;
  final double horizontalListHeight;
  final String? addToCartText;

  const ProductsHomeSectionConfig({
    required super.id,
    super.isActive = true,
    super.title,
    required this.filter,
    this.displayMode = HomeSectionDisplayMode.grid,
    this.crossAxisCount = 4,
    this.childAspectRatio,
    this.maxItems,
    this.horizontalListHeight = 330,
    this.addToCartText,
  });

  double get resolvedAspectRatio {
    if (childAspectRatio != null) return childAspectRatio!;
    if (crossAxisCount >= 4) return 0.65;
    if (crossAxisCount == 3) return 0.7;
    if (crossAxisCount == 2) return 0.72;
    if (crossAxisCount == 1) return 1.1;
    return 0.75;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Joker / Super Joker Section — image-only full-bleed grid
// ─────────────────────────────────────────────────────────────────────────────
class JokerHomeSectionConfig extends HomeSectionConfig {
  final HomeProductFilter filter; // isJoker or isSuperJoker
  final int crossAxisCount;
  final double childAspectRatio;

  const JokerHomeSectionConfig({
    required super.id,
    super.isActive = true,
    super.title,
    required this.filter,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
/// Custom Banner Section
// ─────────────────────────────────────────────────────────────────────────────
class CustomBannerHomeSectionConfig extends HomeSectionConfig {
  final String imageUrl;
  final double? height;
  final double borderRadius;

  const CustomBannerHomeSectionConfig({
    required super.id,
    super.isActive = true,
    super.title,
    required this.imageUrl,
    this.height,
    this.borderRadius = 12,
  });
}
