import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/configs/b2b_home_config.dart';

class OrderSettingsCard extends StatelessWidget {
  final Map<String, dynamic> orderSettings;
  final bool isEditing;
  final bool isDark;
  final Color primaryColor;
  final String organizationId;
  final void Function(Map<String, dynamic>) onSettingsChanged;

  const OrderSettingsCard({
    super.key,
    required this.orderSettings,
    required this.isEditing,
    required this.isDark,
    required this.primaryColor,
    required this.organizationId,
    required this.onSettingsChanged,
  });

  Widget _buildDropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: options.containsKey(value) ? value : options.keys.first,
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: isEditing ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEditing
                ? AppColors.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      elevation: 0,
      color: primaryColor.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings_applications, color: primaryColor),
                    const SizedBox(width: 12),
                    const Text(
                      "إعدادات الطلبات الافتراضية",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isEditing)
                  const Chip(
                    label: Text(
                      "وضع التعديل",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              "نمط الطلب (Order Mode)",
              orderSettings[B2bHomeConfig.keyOrderMode] ?? "B2B",
              {
                "B2B": "B2B (Business to Business)",
                "C2B": "C2B (Customer to Business)",
              },
              (val) {
                final newSettings = Map<String, dynamic>.from(orderSettings);
                newSettings[B2bHomeConfig.keyOrderMode] = val;
                onSettingsChanged(newSettings);
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<
              WorkflowManagementBloc,
              FeaturDataSourceState<WorkflowConfigModel>
            >(
              builder: (context, state) {
                final workflows = state.listState.maybeWhen(
                  success: (data) => data ?? [],
                  orElse: () => [],
                );

                final Map<String, String> workflowOptions = {
                  "": "بدون سير عمل (Default)",
                };
                for (var wf in workflows) {
                  workflowOptions[wf.workflowSlug] = wf.workflowSlug;
                }

                return _buildDropdown(
                  "سير العمل (Workflow)",
                  orderSettings[B2bHomeConfig.keyWorkflowSlug] ?? "",
                  workflowOptions,
                  (val) {
                    final newSettings = Map<String, dynamic>.from(orderSettings);
                    newSettings[B2bHomeConfig.keyWorkflowSlug] = val;
                    onSettingsChanged(newSettings);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              "طريقة حساب السعر (Calculation Mode)",
              (orderSettings[B2bHomeConfig.keyCalculationMode] ?? 2).toString(),
              {
                "0": "يدوي (Manual) - قبول السعر كما هو",
                "1": "تصحيح (Auto-correction) - تعديل آلي في حال الخطأ",
                "2": "تحقق صارم (Strict Validation) - رفض في حال الخطأ",
              },
              (val) {
                final newSettings = Map<String, dynamic>.from(orderSettings);
                newSettings[B2bHomeConfig.keyCalculationMode] = int.tryParse(val!) ?? 2;
                onSettingsChanged(newSettings);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                "السماح بسير العمل الافتراضي (Allow Default Workflow)",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                "تفعيل هذا الخيار يسمح للنظام باستخدام سير العمل التلقائي في حال عدم توفر المخصص",
                style: TextStyle(fontSize: 12),
              ),
              value: orderSettings[B2bHomeConfig.keyAllowDefaultWorkflow] ?? true,
              onChanged: isEditing
                  ? (val) {
                      final newSettings = Map<String, dynamic>.from(orderSettings);
                      newSettings[B2bHomeConfig.keyAllowDefaultWorkflow] = val;
                      onSettingsChanged(newSettings);
                    }
                  : null,
              activeColor: primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
