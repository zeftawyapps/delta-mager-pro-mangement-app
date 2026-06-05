import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final ValueChanged<bool> onSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: isDark ? DarkColors.surface : LightColors.surface,
      selectedColor: isDark ? DarkColors.primary : LightColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? DarkColors.textPrimary : LightColors.textPrimary),
      ),
    );
  }
}
