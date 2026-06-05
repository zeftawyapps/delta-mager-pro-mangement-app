import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'category_chip.dart';

class CategoryFilterSection extends StatelessWidget {
  final String? selectedCategoryId;
  final bool isDark;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterSection({
    super.key,
    required this.selectedCategoryId,
    required this.isDark,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, FeaturDataSourceState<CategoryModel>>(
      builder: (context, state) {
        return state.listState.maybeWhen(
          success: (categories) {
            return Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CategoryChip(
                    label: AppStrings.all,
                    isSelected: selectedCategoryId == null,
                    isDark: isDark,
                    onSelected: (selected) => onCategorySelected(null),
                  ),
                  const SizedBox(width: 8),
                  ...(categories ?? [])
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: c.nameAr,
                            isSelected: selectedCategoryId == c.id,
                            isDark: isDark,
                            onSelected: (selected) =>
                                onCategorySelected(selected ? c.id : null),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
