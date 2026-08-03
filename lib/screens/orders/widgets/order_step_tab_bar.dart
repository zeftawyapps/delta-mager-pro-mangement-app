import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/helpers/order_role_config_helper.dart';

class OrderStepTabBar extends StatelessWidget {
  final List<WorkflowStep> visibleSteps;
  final int selectedIndex;
  final ValueChanged<int> onStepSelected;

  const OrderStepTabBar({
    super.key,
    required this.visibleSteps,
    required this.selectedIndex,
    required this.onStepSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (visibleSteps.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        Widget buildStepItem(int index) {
          final step = visibleSteps[index];
          final isSelected = selectedIndex == index;
          final stepColor = OrderRoleConfigHelper.getStepColor(step);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: isSmall
                ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
                : const EdgeInsets.only(left: 10, top: 4, bottom: 4),
            child: InkWell(
              onTap: () => onStepSelected(index),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 14 : 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: isSelected ? stepColor : stepColor.withOpacity(0.08),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : stepColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: stepColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      step.stepName.ar,
                      style: TextStyle(
                        color: isSelected ? Colors.white : stepColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: isSmall ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isSmall) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            width: double.infinity,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: List.generate(
                visibleSteps.length,
                (index) => buildStepItem(index),
              ),
            ),
          );
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: visibleSteps.length,
            itemBuilder: (context, index) => buildStepItem(index),
          ),
        );
      },
    );
  }
}
