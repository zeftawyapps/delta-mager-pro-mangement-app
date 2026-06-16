import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'product_badge.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final bool canUpdate;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onShowActions;

  const ProductCard({
    super.key,
    required this.product,
    required this.isDark,
    required this.canUpdate,
    required this.canDelete,
    required this.onEdit,
    required this.onShowActions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.images.isNotEmpty
                        ? Image.network(
                            product.mainImage,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
                    if (!product.isAvailable)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: const Center(
                          child: Icon(
                            Icons.block,
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name.ar,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${product.price} ج.م',
                            style: TextStyle(
                              color: isDark
                                  ? DarkColors.primary
                                  : LightColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!product.isAvailable)
                            const Text(
                              AppStrings.notAvailable,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action Menu Button
          if (canUpdate || canDelete)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? DarkColors.surface : LightColors.surface)
                      .withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onPressed: onShowActions,
                ),
              ),
            ),

          // Badges (New, Joker, etc.)
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.isNew) ProductBadge(text: AppStrings.isNew, color: Colors.green),
                if (product.isSuperJoker)
                  ProductBadge(text: AppStrings.superJoker, color: Colors.deepPurple),
                if (product.isJoker)
                  ProductBadge(text: AppStrings.joker, color: Colors.blueAccent),
                if (product.isBestSeller)
                  ProductBadge(text: AppStrings.bestSeller, color: Colors.orange),
                if (product.isOnSale)
                  ProductBadge(text: AppStrings.onSale, color: Colors.redAccent),
                if (product.additionalData['isInsideOffer'] == true ||
                    product.additionalData['isInsideOffer']?.toString().toLowerCase() == 'true')
                  ProductBadge(text: AppStrings.insideOffer, color: Colors.orangeAccent),
              ],
            ),
          ),

          // Missing Image Warning
          if (ProductInputConfig.showImages && product.images.isEmpty)
            Positioned(
              bottom: 60,
              right: 4,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (product.isNew ||
                            product.isJoker ||
                            product.isOnSale ||
                            product.isBestSeller)
                        ? Colors.red.withValues(alpha: 0.9)
                        : Colors.orange.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          (product.isNew ||
                                  product.isJoker ||
                                  product.isOnSale ||
                                  product.isBestSeller)
                              ? 'إضافة صورة (مطلوب فوراً)'
                              : 'يرجى إضافة صورة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
