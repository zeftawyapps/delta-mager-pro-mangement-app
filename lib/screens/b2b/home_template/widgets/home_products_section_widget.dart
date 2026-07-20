import 'dart:async';
import 'package:flutter/material.dart';
import '../delegate/home_screen_delegate.dart';
import '../configs/home_section_config.dart';

/// Products section — يدعم grid / horizontalList / slider
class HomeProductsSectionWidget extends StatelessWidget {
  final List<HomeProductItem> allProducts;
  final ProductsHomeSectionConfig config;
  final bool isDark;
  final void Function(String productId) onProductTap;
  final void Function(HomeProductItem product)? onAddToCart;
  final void Function(HomeProductItem product)? onRemoveFromCart;

  /// custom card builder (اختياري)
  final Widget Function(HomeProductItem product, bool isDark)? cardBuilder;

  const HomeProductsSectionWidget({
    super.key,
    required this.allProducts,
    required this.config,
    required this.isDark,
    required this.onProductTap,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.cardBuilder,
  });

  List<HomeProductItem> get _filtered {
    return allProducts.where((p) {
      switch (config.filter) {
        case HomeProductFilter.isNew:
          return p.isNew;
        case HomeProductFilter.isBestSeller:
          return p.isBestSeller;
        case HomeProductFilter.isOnSale:
          return p.isOnSale;
        case HomeProductFilter.isJoker:
          return p.isJoker;
        case HomeProductFilter.isSuperJoker:
          return p.isSuperJoker;
        case HomeProductFilter.none:
          return true;
      }
    }).take(config.maxItems ?? allProducts.length).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filtered;
    if (products.isEmpty) return const SizedBox.shrink();

    switch (config.displayMode) {
      case HomeSectionDisplayMode.slider:
        return HomeZoomSliderWidget(
          products: products,
          isDark: isDark,
          onProductTap: onProductTap,
          onAddToCart: onAddToCart,
          onRemoveFromCart: onRemoveFromCart,
          cardBuilder: cardBuilder,
          addToCartText: config.addToCartText,
        );

      case HomeSectionDisplayMode.horizontalList:
        return SizedBox(
          height: config.horizontalListHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) => Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              child: _buildCard(context, products[index]),
            ),
          ),
        );

      case HomeSectionDisplayMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: config.crossAxisCount,
            childAspectRatio: config.resolvedAspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildCard(context, products[index]),
        );
    }
  }

  Widget _buildCard(BuildContext context, HomeProductItem product) {
    if (cardBuilder != null) return cardBuilder!(product, isDark);
    return _DefaultProductCard(
      product: product,
      isDark: isDark,
      onTap: () => onProductTap(product.id),
      onAddToCart: onAddToCart != null ? () => onAddToCart!(product) : null,
      onRemoveFromCart: onRemoveFromCart != null ? () => onRemoveFromCart!(product) : null,
      addToCartText: config.addToCartText,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Zoom Slider للمنتجات
// ─────────────────────────────────────────────────────────────────────────────
class HomeZoomSliderWidget extends StatefulWidget {
  final List<HomeProductItem> products;
  final bool isDark;
  final void Function(String productId) onProductTap;
  final void Function(HomeProductItem product)? onAddToCart;
  final void Function(HomeProductItem product)? onRemoveFromCart;
  final Widget Function(HomeProductItem product, bool isDark)? cardBuilder;
  final String? addToCartText;

  const HomeZoomSliderWidget({
    super.key,
    required this.products,
    required this.isDark,
    required this.onProductTap,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.cardBuilder,
    this.addToCartText,
  });

  @override
  State<HomeZoomSliderWidget> createState() => _HomeZoomSliderWidgetState();
}

class _HomeZoomSliderWidgetState extends State<HomeZoomSliderWidget> {
  late final PageController _controller;
  double _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.7);
    _controller.addListener(() {
      if (mounted) setState(() => _currentPage = _controller.page ?? 0);
    });
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_currentPage.round() + 1) % widget.products.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final rel = index - _currentPage;
          final scale = (1 - rel.abs() * 0.2).clamp(0.8, 1.0);
          final opacity = (1 - rel.abs() * 0.3).clamp(0.5, 1.0);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: widget.cardBuilder != null
                  ? widget.cardBuilder!(widget.products[index], widget.isDark)
                  : _DefaultZoomCard(
                      product: widget.products[index],
                      isDark: widget.isDark,
                      onTap: () => widget.onProductTap(widget.products[index].id),
                      onAddToCart: widget.onAddToCart != null
                          ? () => widget.onAddToCart!(widget.products[index])
                          : null,
                      onRemoveFromCart: widget.onRemoveFromCart != null
                          ? () => widget.onRemoveFromCart!(widget.products[index])
                          : null,
                      addToCartText: widget.addToCartText,
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Joker Section — image-only full-bleed grid
// ─────────────────────────────────────────────────────────────────────────────
class HomeJokerSectionWidget extends StatelessWidget {
  final List<HomeProductItem> allProducts;
  final HomeProductFilter filter;
  final int crossAxisCount;
  final double childAspectRatio;
  final void Function(String productId) onProductTap;
  final Widget Function(HomeProductItem product)? jokerCardBuilder;

  const HomeJokerSectionWidget({
    super.key,
    required this.allProducts,
    required this.filter,
    required this.onProductTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.jokerCardBuilder,
  });

  List<HomeProductItem> get _filtered => allProducts.where((p) {
        return filter == HomeProductFilter.isJoker ? p.isJoker : p.isSuperJoker;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final products = _filtered;
    if (products.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return jokerCardBuilder != null
            ? jokerCardBuilder!(product)
            : _DefaultJokerCard(
                product: product,
                onTap: () => onProductTap(product.id),
              );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Default product card (fallback إذا مش فيه custom builder)
// ─────────────────────────────────────────────────────────────────────────────
class _DefaultProductCard extends StatelessWidget {
  final HomeProductItem product;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;
  final String? addToCartText;

  const _DefaultProductCard({
    required this.product,
    required this.isDark,
    required this.onTap,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.addToCartText,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.nameAr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      product.price,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (product.quantityInCart > 0)
                      // متحكم الكمية الكبير المدمج بالكامل في موضع زر الإضافة
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryColor, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // زر ناقص - تقليل
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onRemoveFromCart,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(7),
                                ),
                                child: Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '${product.quantityInCart}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            // زر زائد - زيادة
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onAddToCart,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(7),
                                ),
                                child: Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (onAddToCart != null)
                      // زر إضافة للسلة الكبير الافتراضي
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onAddToCart,
                          borderRadius: BorderRadius.circular(8),
                          child: Ink(
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_shopping_cart,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  addToCartText ?? 'إضافة للسلة',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey, size: 40),
      );
}

/// Default zoom card
class _DefaultZoomCard extends StatelessWidget {
  final HomeProductItem product;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;
  final String? addToCartText;

  const _DefaultZoomCard({
    required this.product,
    required this.isDark,
    required this.onTap,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.addToCartText,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 50),
                          ))
                      : const Icon(Icons.image, size: 50),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.nameAr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (product.quantityInCart > 0)
                        // متحكم الكمية الدائري العريض المدمج بالكامل في موضع زر الإضافة
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: primaryColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // زر ناقص
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onRemoveFromCart,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(29),
                                  ),
                                  child: Container(
                                    width: 44,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.remove,
                                      size: 20,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              // الكمية
                              Text(
                                '${product.quantityInCart}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              // زر زائد
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onAddToCart,
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(29),
                                  ),
                                  child: Container(
                                    width: 44,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.add,
                                      size: 20,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (onAddToCart != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onAddToCart,
                            borderRadius: BorderRadius.circular(30),
                            child: Ink(
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    addToCartText ?? 'إضافة إلى السلة',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Default Joker card — image only
class _DefaultJokerCard extends StatelessWidget {
  final HomeProductItem product;
  final VoidCallback onTap;

  const _DefaultJokerCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: product.imageUrl != null && product.imageUrl!.isNotEmpty
              ? Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
        ),
      ),
    );
  }
}
