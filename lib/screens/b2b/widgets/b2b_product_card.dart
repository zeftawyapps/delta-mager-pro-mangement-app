import 'package:delta_mager_pro_mangement_app/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_unit.dart' as model_unit;
import 'package:delta_mager_pro_mangement_app/logic/providers/cart_provider.dart';

class B2BProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isDark;

  const B2BProductCard({
    super.key,
    required this.product,
    required this.isDark,
  });

  @override
  State<B2BProductCard> createState() => _B2BProductCardState();
}

class _B2BProductCardState extends State<B2BProductCard> {
  int _quantity = 1;
  PriceOption? _selectedPrice;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '$_quantity');
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
  void didUpdateWidget(B2BProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _quantity = 1;
      _qtyController.text = '1';
      if (widget.product.priceOptions.isNotEmpty) {
        _selectedPrice = widget.product.priceOptions.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isDark = widget.isDark;
    final currentPrice = _selectedPrice?.price ?? product.price;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section (Clickable)
          Expanded(
            flex: 3,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product),
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? DarkColors.primary : LightColors.primary)
                                .withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: product.images.isNotEmpty
                          ? Hero(
                              tag: 'product_image_${product.id}',
                              child: Image.network(
                                product.mainImage,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.broken_image,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                    if ((product.discount ?? 0) > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discount!.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Info Section
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: product),
                        ),
                      ),
                      child: Text(
                        product.name.ar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),

                  // Price Tiers / Options (Modern Chips instead of Dropdown)
                  if (product.priceOptions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: product.priceOptions.map((opt) {
                            final isSelected = _selectedPrice == opt;
                            final discount = product.discount ?? 0;
                            final originalPrice = opt.price;
                            final discountedPrice = discount > 0
                                ? originalPrice * (1 - (discount / 100))
                                : originalPrice;

                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: ChoiceChip(
                                label: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${opt.quantity.toInt()} ${opt.sizeDisplay?.ar ?? model_unit.ProductUnit.fromString(opt.unit)?.nameAr ?? opt.unit}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      '${discountedPrice.toStringAsFixed(1)} ${context.watch<CartProvider>().currency}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                selected: isSelected,
                                selectedColor: isDark
                                    ? DarkColors.primary
                                    : LightColors.primary,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black.withOpacity(0.05),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                labelPadding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onSelected: (selected) {
                                  if (selected)
                                    setState(() => _selectedPrice = opt);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${currentPrice.toStringAsFixed(1)} ${context.watch<CartProvider>().currency}',
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // Modern Capsule Quantity Selector
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _qtyBtnCapsule(Icons.remove, () {
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
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              final q = int.tryParse(val);
                              if (q != null && q > 0) {
                                _quantity = q;
                              }
                            },
                          ),
                        ),
                        _qtyBtnCapsule(Icons.add, () {
                          setState(() {
                            _quantity++;
                            _qtyController.text = '$_quantity';
                          });
                        }, isDark),
                      ],
                    ),
                  ),

                  (() {
                    final discount = product.discount ?? 0;
                    final basePrice = _selectedPrice?.price ?? product.price;
                    final finalPrice = discount > 0
                        ? basePrice * (1 - (discount / 100))
                        : basePrice;
                    final multiplier = _selectedPrice?.quantity ?? 1.0;
                    final total = finalPrice * _quantity * multiplier;

                    return Container(
                      width: double.infinity,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  DarkColors.primary,
                                  DarkColors.primary.withOpacity(0.8),
                                ]
                              : [
                                  LightColors.primary,
                                  LightColors.primary.withOpacity(0.8),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isDark
                                        ? DarkColors.primary
                                        : LightColors.primary)
                                    .withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<CartProvider>().addItem(
                            product,
                            customPrice: basePrice,
                            quantity: _quantity,
                            multiplier: _selectedPrice?.quantity ?? 1.0,
                            unitName: _selectedPrice?.sizeDisplay?.ar ?? 
                                      model_unit.ProductUnit.fromString(_selectedPrice?.unit ?? '')?.nameAr ?? 
                                      _selectedPrice?.unit,
                          );
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تمت إضافة $_quantity من ${product.name.ar}',
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(milliseconds: 1200),
                              backgroundColor: (isDark
                                  ? DarkColors.primary
                                  : LightColors.primary),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'أضف (${total.toStringAsFixed(1)} ${context.watch<CartProvider>().currency})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  }()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtnCapsule(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? DarkColors.primary : LightColors.primary,
        ),
      ),
    );
  }
}
