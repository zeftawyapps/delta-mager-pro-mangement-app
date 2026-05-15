import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:delta_mager_pro_mangement_app/screens/b2b/widgets/b2b_cart_badge.dart';

// ignore: must_be_immutable
class ProductDetailsScreen extends StatefulWidget with AppShellRouterMixin {
  final ProductModel product;
  ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  PriceOption? _selectedPrice;
  final TextEditingController _qtyController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    if (widget.product.priceOptions.isNotEmpty) {
      _selectedPrice = widget.product.priceOptions.first;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final product = widget.product;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);
    
    // Add Cart Badge to actions
    appBarConfig.actions?.insert(0, B2BCartBadge(organizationId: product.organizationId));

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: '${AppStrings.productDetailsTitle}: ${product.name.ar}',
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Images and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery Section
                  Expanded(flex: 1, child: _buildImageGallery(product, isDark)),
                  const SizedBox(width: 32),
                  // Basic Info Section
                  Expanded(
                    flex: 2,
                    child: _buildBasicInfo(product, isDark, theme),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(ProductModel product, bool isDark) {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? DarkColors.surface : LightColors.surface,
            border: Border.all(
              color: isDark ? DarkColors.divider : LightColors.divider,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: product.images.isNotEmpty
                ? Hero(
                    tag: 'product_image_${product.id}',
                    child: Image.network(
                      product.mainImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported, size: 64),
                      ),
                    ),
                  )
                : const Center(child: Icon(Icons.image, size: 64)),
          ),
        ),
        if (product.images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBasicInfo(ProductModel product, bool isDark, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? DarkColors.divider : LightColors.divider,
        ),
      ),
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name.ar,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                ),
                _buildBadge(
                  product.isActive ? AppStrings.active : AppStrings.inactive,
                  product.isActive ? Colors.green : Colors.red,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.name.en,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            const Divider(height: 32),
            Text(
              AppStrings.description,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description.ar,
              style: TextStyle(
                height: 1.5,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 32),
            
            // Wholesale Selection Section
            Text(
              'خيارات الطلب والكمية',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            if (product.priceOptions.isNotEmpty) ...[
              const Text('اختر فئة السعر:', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.priceOptions.map((opt) {
                  final isSelected = _selectedPrice == opt;
                  final discount = product.discount ?? 0;
                  final discountedPrice = discount > 0 ? opt.price * (1 - (discount / 100)) : opt.price;
                  
                  return ChoiceChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${opt.sizeDisplay?.ar ?? opt.unit}',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${discountedPrice.toStringAsFixed(1)} ج.م',
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (discount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${opt.price.toStringAsFixed(1)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: isSelected ? Colors.white54 : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedPrice = opt),
                    selectedColor: isDark ? DarkColors.primary : LightColors.primary,
                    backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  );
                }).toList(),
              ),
            ] else ...[
               (() {
                 final discount = product.discount ?? 0;
                 final discountedPrice = discount > 0 ? product.price * (1 - (discount / 100)) : product.price;
                 return Row(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Text(
                      '${discountedPrice.toStringAsFixed(1)} ج.م',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? DarkColors.primary : LightColors.primary,
                      ),
                     ),
                     if (discount > 0) ...[
                       const SizedBox(width: 12),
                       Text(
                         '${product.price.toStringAsFixed(1)} ج.م',
                         style: const TextStyle(
                           fontSize: 18,
                           decoration: TextDecoration.lineThrough,
                           color: Colors.grey,
                         ),
                       ),
                     ],
                   ],
                 );
               })(),
            ],

            const SizedBox(height: 24),
            // Show total for current selection
            (() {
              final basePrice = _selectedPrice?.price ?? product.price;
              final discount = product.discount ?? 0;
              final discountedPrice = discount > 0 ? basePrice * (1 - (discount / 100)) : basePrice;
              final total = discountedPrice * _quantity;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إجمالي الطلب:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${total.toStringAsFixed(1)} ج.م',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? DarkColors.primary : LightColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            })(),

            const SizedBox(height: 24),
            Row(
              children: [
                // Quantity Capsule
                Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _qtyBtn(Icons.remove, () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                            _qtyController.text = '$_quantity';
                          });
                        }
                      }, isDark),
                      Expanded(
                        child: TextField(
                          controller: _qtyController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          onChanged: (val) {
                            final q = int.tryParse(val);
                            if (q != null && q > 0) _quantity = q;
                          },
                        ),
                      ),
                      _qtyBtn(Icons.add, () {
                        setState(() {
                          _quantity++;
                          _qtyController.text = '$_quantity';
                        });
                      }, isDark),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Add to Cart Button
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: isDark 
                          ? [DarkColors.primary, DarkColors.primary.withOpacity(0.8)]
                          : [LightColors.primary, LightColors.primary.withOpacity(0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final basePrice = _selectedPrice?.price ?? product.price;
                        final discount = product.discount ?? 0;
                        final finalPrice = discount > 0 ? basePrice * (1 - (discount / 100)) : basePrice;
                        
                        context.read<CartProvider>().addItem(
                          product,
                          customPrice: basePrice, // CartProvider will calculate discount again or I should pass final?
                          // Actually CartProvider.addItem calculates discount internally based on product.discount
                          quantity: _quantity,
                        );
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 12),
                                Text('تمت إضافة $_quantity من ${product.name.ar}'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: isDark ? DarkColors.primary : LightColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: const Text(
                        'إضافة للسلة',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 20, color: isDark ? DarkColors.primary : LightColors.primary),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? DarkColors.primary : LightColors.primary,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
