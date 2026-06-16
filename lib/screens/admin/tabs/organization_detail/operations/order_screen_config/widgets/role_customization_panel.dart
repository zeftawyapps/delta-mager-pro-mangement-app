import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import '../models/role_orders_config.dart';
import 'toggle_option.dart';

class RoleCustomizationPanel extends StatelessWidget {
  final String roleId;
  final RoleOrdersConfig config;
  final bool isDark;
  final bool isEditing;
  final String? selectedWorkflowId;
  final List<String> availableWorkflowSteps;
  final Map<String, String> stepDisplayNames;
  final List<String> selectedStepsFromPermissions;
  final List<OrderPathModel> allOrderPaths;
  final bool hasCustomization;
  final ValueChanged<String?> onWorkflowChanged;
  final Function(String stepKey, bool isSelected) onStepSelected;
  final Function(RoleOrdersConfig updatedConfig) onConfigUpdated;
  final VoidCallback onRemoveCustomization;
  final VoidCallback onApply;

  const RoleCustomizationPanel({
    super.key,
    required this.roleId,
    required this.config,
    required this.isDark,
    required this.isEditing,
    required this.selectedWorkflowId,
    required this.availableWorkflowSteps,
    required this.stepDisplayNames,
    required this.selectedStepsFromPermissions,
    required this.allOrderPaths,
    required this.hasCustomization,
    required this.onWorkflowChanged,
    required this.onStepSelected,
    required this.onConfigUpdated,
    required this.onRemoveCustomization,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "إعدادات مخصصة للدور",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ========== Workflow Selector ==========
          BlocBuilder<WorkflowManagementBloc, FeaturDataSourceState<WorkflowConfigModel>>(
            builder: (context, workflowState) {
              final configs = workflowState.listState.maybeWhen(
                success: (list) => list ?? [],
                orElse: () => <WorkflowConfigModel>[],
              );
              final isLoading = workflowState.listState.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }

              if (configs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "لا توجد سير عمل (Workflows) للطلبات في هذه المنظمة.",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final dropdownValue = configs.any((cfg) => cfg.id == selectedWorkflowId)
                  ? selectedWorkflowId
                  : null;

              return DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: const InputDecoration(
                  labelText: "اختر سير العمل",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_tree_outlined, size: 20),
                ),
                items: configs.map((cfg) {
                  return DropdownMenuItem<String>(
                    value: cfg.id,
                    child: Text(cfg.workflow.workflowName.ar),
                  );
                }).toList(),
                onChanged: isEditing ? onWorkflowChanged : null,
              );
            },
          ),
          const SizedBox(height: 16),

          // ========== Steps from Permissions ==========
          if (selectedWorkflowId != null) ...[
            if (availableWorkflowSteps.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "هذا السير لا يحتوي على خطوات متاحة بناءً على صلاحيات الدور. قدّم صلاحية 'order:workflowAction.[stepKey]' للدور من شاشة إدارة الأدوار.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الخطوات المسموح بها (من صلاحيات الدور):",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "الصلاحيات المستخرجة من الدور بصيغة order:workflowAction.[stepKey]",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableWorkflowSteps.map((stepKey) {
                      final displayName = stepDisplayNames[stepKey] ?? stepKey;
                      final isSelected = selectedStepsFromPermissions.contains(stepKey);
                      return FilterChip(
                        label: Text(displayName),
                        selected: isSelected,
                        selectedColor: primaryColor.withOpacity(0.2),
                        checkmarkColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? primaryColor : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: isEditing
                            ? (val) => onStepSelected(stepKey, val)
                            : null,
                        backgroundColor: primaryColor.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? primaryColor : primaryColor.withOpacity(0.2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "المحدد: ${selectedStepsFromPermissions.length} من ${availableWorkflowSteps.length}",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
          ],

          const SizedBox(height: 16),
          // ========== switches/toggles ==========
          ToggleOption(
            title: "إظهار معلومات المرسل (العميل)",
            subtitle: "الاسم، رقم الهاتف، العنوان",
            value: config.showSenderInfo,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(showSenderInfo: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "إظهار معلومات المستلم",
            subtitle: "اسم المستلم، عنوان التوصيل",
            value: config.showRecipientInfo,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(showRecipientInfo: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "إظهار المنتجات في الطلب",
            subtitle: "قائمة المنتجات المطلوبة",
            value: config.showItems,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(showItems: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "إظهار السعر الإجمالي",
            subtitle: "سعر الطلب بالكامل",
            value: config.showPrice,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(showPrice: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "السماح بتعديل محتوى الطلب",
            subtitle: "إضافة/إزالة منتجات، تغيير الكميات",
            value: config.canEditOrder,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(canEditOrder: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "السماح بإلغاء الطلب",
            subtitle: "إلغاء الطلب بالكامل",
            value: config.canCancelOrder,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(canCancelOrder: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "السماح بتعيين منفذ للطلب",
            subtitle: "تعيين الطلب لمستخدم معين",
            value: config.canAssignOrder,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(canAssignOrder: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "إظهار بار التصفية حسب خطوط السير",
            subtitle: "السماح للمستخدم بالتصفية اليدوية بين خطوط السير من شريط علوي",
            value: config.showPathFilterBar,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(showPathFilterBar: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "تصفية الطلبات حسب الشخص المعين",
            subtitle: "إظهار الطلبات المعينة للمستخدم الحالي فقط",
            value: config.filterByAssignedUser,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(filterByAssignedUser: val))
                : null,
          ),
          const SizedBox(height: 8),

          ToggleOption(
            title: "تصفية حسب خطوط السير",
            subtitle: "السماح لهذا الدور برؤية الطلبات في خطوط سير محددة فقط",
            value: config.filterByPath,
            isDark: isDark,
            onChanged: isEditing
                ? (val) => onConfigUpdated(config.copyWith(
                      filterByPath: val,
                      allowedPaths: val ? config.allowedPaths : const [],
                    ))
                : null,
          ),

          if (config.filterByPath) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final workflowState = context.watch<WorkflowManagementBloc>().state;
                final configs = workflowState.listState.maybeWhen(
                  success: (list) => list ?? [],
                  orElse: () => <WorkflowConfigModel>[],
                );
                final activeWorkflow = configs.where((c) => c.id == selectedWorkflowId).firstOrNull;

                if (selectedWorkflowId == null || activeWorkflow == null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "يرجى اختيار سير عمل للدور أولاً لتصفية خطوط السير.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final activeWorkflowSlug = activeWorkflow.workflowSlug;
                final filteredPaths = allOrderPaths.where((path) => path.workflowSlug == activeWorkflowSlug).toList();

                if (filteredPaths.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "لا توجد خطوط سير مرتبطة بسير العمل الحالي (${activeWorkflow.workflow.workflowName.ar}).",
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تحديد خطوط السير المتاحة للدور:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredPaths.map((path) {
                          final isSelected = config.allowedPaths.contains(path.id);
                          return FilterChip(
                            label: Text(path.name),
                            selected: isSelected,
                            selectedColor: primaryColor.withOpacity(0.2),
                            checkmarkColor: primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: isEditing
                                ? (val) {
                                    final newAllowed = List<String>.from(config.allowedPaths);
                                    if (val) {
                                      if (path.id != null) newAllowed.add(path.id!);
                                    } else {
                                      newAllowed.remove(path.id);
                                    }
                                    onConfigUpdated(config.copyWith(allowedPaths: newAllowed));
                                  }
                                : null,
                            backgroundColor: primaryColor.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? primaryColor : primaryColor.withOpacity(0.2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "المحدد: ${config.allowedPaths.length} من ${filteredPaths.length}",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasCustomization)
                TextButton.icon(
                  onPressed: isEditing ? onRemoveCustomization : null,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    "إزالة التخصيص",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isEditing ? onApply : null,
                icon: const Icon(Icons.check, size: 18),
                label: const Text("تطبيق"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
