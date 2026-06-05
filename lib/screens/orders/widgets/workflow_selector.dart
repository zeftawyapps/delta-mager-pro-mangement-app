import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class WorkflowSelector extends StatelessWidget {
  final List<WorkflowConfigModel> configs;
  final int selectedWorkflowIndex;
  final ValueChanged<int> onSelected;

  const WorkflowSelector({
    super.key,
    required this.configs,
    required this.selectedWorkflowIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDark ? DarkColors.background : Colors.grey[50],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: configs.length,
        itemBuilder: (context, index) {
          final isSelected = selectedWorkflowIndex == index;
          final primaryColor = isDark
              ? DarkColors.primary
              : LightColors.primary;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(configs[index].roleExecutor),
              selected: isSelected,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              selectedColor: primaryColor,
              backgroundColor: isDark ? DarkColors.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              onSelected: (val) {
                if (val) {
                  onSelected(index);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
