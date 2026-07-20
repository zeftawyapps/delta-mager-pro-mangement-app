import 'package:flutter/material.dart';
import '../delegate/home_screen_delegate.dart';
import '../configs/home_section_config.dart';

/// Categories horizontal scroll list
class HomeCategoriesSectionWidget extends StatelessWidget {
  final List<HomeCategoryItem> categories;
  final CategoriesHomeSectionConfig config;
  final bool isDark;
  final void Function(String categoryId) onCategoryTap;

  /// custom builder — لو مش موجود يستخدم الـ default
  final Widget Function(HomeCategoryItem category, bool isDark)? itemBuilder;

  const HomeCategoriesSectionWidget({
    super.key,
    required this.categories,
    required this.config,
    required this.isDark,
    required this.onCategoryTap,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: config.listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onCategoryTap(category.id),
              child: itemBuilder != null
                  ? itemBuilder!(category, isDark)
                  : _DefaultCategoryItem(
                      category: category,
                      isDark: isDark,
                      itemWidth: config.itemWidth,
                      imageSize: config.itemImageSize,
                      borderRadius: config.itemBorderRadius,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _DefaultCategoryItem extends StatelessWidget {
  final HomeCategoryItem category;
  final bool isDark;
  final double itemWidth;
  final double imageSize;
  final double borderRadius;

  const _DefaultCategoryItem({
    required this.category,
    required this.isDark,
    required this.itemWidth,
    required this.imageSize,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: itemWidth,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          // Image container
          Container(
            height: imageSize,
            width: imageSize,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey)
                      .withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black)
                    .withOpacity(0.05),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? Image.network(
                      category.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholder(primaryColor),
                    )
                  : _placeholder(primaryColor),
            ),
          ),

          const SizedBox(height: 10),

          // Name
          Text(
            category.nameAr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(Color primaryColor) {
    return Center(
      child: Icon(
        Icons.category_outlined,
        color: primaryColor.withOpacity(0.5),
        size: 30,
      ),
    );
  }
}
