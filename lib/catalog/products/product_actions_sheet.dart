import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'main_action_button.dart';
import 'toggle_option.dart';

class ProductActionsSheet extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final bool canUpdate;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onQuickChangePrice;
  final void Function(String property, bool value) onToggleProperty;

  const ProductActionsSheet({
    super.key,
    required this.product,
    required this.isDark,
    required this.canUpdate,
    required this.canDelete,
    required this.onDelete,
    required this.onEdit,
    required this.onQuickChangePrice,
    required this.onToggleProperty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.mainImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.ar,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${product.price} ج.م',
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Section: Main Actions
          if (canUpdate) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MainActionButton(
                    icon: Icons.edit_outlined,
                    label: 'تعديل',
                    color: Colors.blue,
                    onTap: onEdit,
                  ),
                  if (ProductInputConfig.enableMultiSizePricing)
                    MainActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'أحجام',
                      color: Colors.purple,
                      onTap: onEdit,
                    ),
                  if (ProductInputConfig.showChangePriceInPopup)
                    MainActionButton(
                      icon: Icons.price_change_outlined,
                      label: 'السعر',
                      color: Colors.green,
                      onTap: onQuickChangePrice,
                    ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Section: Options (Toggles)
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (canUpdate)
                  ToggleOption(
                    title: 'متوفر للبيع',
                    subtitle: 'إظهار المنتج للعملاء في المتجر',
                    icon: Icons.visibility_outlined,
                    value: product.isAvailable,
                    onChanged: (val) {
                      onToggleProperty('isAvailable', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsNew)
                  ToggleOption(
                    title: 'منتج جديد 🆕',
                    subtitle: 'إضافة شارة "جديد" على المنتج',
                    icon: Icons.new_releases_outlined,
                    value: product.isNew,
                    onChanged: (val) {
                      onToggleProperty('isNew', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsBestSeller)
                  ToggleOption(
                    title: 'الأكثر مبيعاً 🔥',
                    subtitle: 'تمييز المنتج كأكثر طلباً',
                    icon: Icons.star_outline,
                    value: product.isBestSeller,
                    onChanged: (val) {
                      onToggleProperty('isBestSeller', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsOnSale)
                  ToggleOption(
                    title: 'في العروض 🎁',
                    subtitle: 'إدراج المنتج في قسم التخفيضات',
                    icon: Icons.local_offer_outlined,
                    value: product.isOnSale,
                    onChanged: (val) {
                      onToggleProperty('isOnSale', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsJoker)
                  ToggleOption(
                    title: 'منتج جوكر 🃏',
                    subtitle: 'تمييز كمنتج مميز جداً',
                    icon: Icons.style_outlined,
                    value: product.isJoker,
                    onChanged: (val) {
                      onToggleProperty('isJoker', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsSuperJoker)
                  ToggleOption(
                    title: 'سوبر جوكر',
                    subtitle: 'أعلى درجة تمييز للمنتج',
                    icon: Icons.workspace_premium_outlined,
                    value: product.isSuperJoker,
                    onChanged: (val) {
                      onToggleProperty('isSuperJoker', val);
                    },
                  ),
                if (canUpdate)
                  ToggleOption(
                    title: 'نشر للعام 🌐',
                    subtitle: 'نشر المنتج للكتالوج العام للجمهور',
                    icon: Icons.public_outlined,
                    value: product.sharingLevel == 'public',
                    onChanged: (val) {
                      onToggleProperty('sharingLevel', val);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
