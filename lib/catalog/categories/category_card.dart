import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/items.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/pubUpmenu.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isDark;
  final bool canUpdate;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isDark,
    required this.canUpdate,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
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
              Expanded(
                flex: 3,
                child: category.image != null && category.image != ""
                    ? Image.network(
                        category.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 30),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.category, size: 40),
                      ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name.ar,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.productCount ?? 0} منتج',
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopUpMenu(
              iconSize: 18,
              items: [
                if (canUpdate)
                  pubMenuItems(
                    title: AppStrings.edit,
                    icon: Icons.edit,
                    value: 1,
                    onTap: onEdit,
                  ),
                if (canDelete)
                  pubMenuItems(
                    title: AppStrings.delete,
                    icon: Icons.delete,
                    value: 2,
                    onTap: onDelete,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
