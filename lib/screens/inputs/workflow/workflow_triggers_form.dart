import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class WorkflowTriggersForm extends StatefulWidget {
  final WorkflowConfigModel config;
  final WorkflowStep step;
  final String organizationId;
  final bool isDark;

  const WorkflowTriggersForm({
    super.key,
    required this.config,
    required this.step,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<WorkflowTriggersForm> createState() => _WorkflowTriggersFormState();
}

class _WorkflowTriggersFormState extends State<WorkflowTriggersForm> {
  late List<String> selectedTriggers;

  @override
  void initState() {
    super.initState();
    selectedTriggers = List<String>.from(widget.step.stepTriggers);
  }

  void saveTriggers() {
    final updatedStep = WorkflowStep(
      id: widget.step.id,
      stepKey: widget.step.stepKey,
      stepNumber: widget.step.stepNumber,
      stepName: widget.step.stepName,
      stepRole: widget.step.stepRole,
      stepColor: widget.step.stepColor,
      selectionMode: widget.step.selectionMode,
      targetType: widget.step.targetType,
      requiredApprovalsCount: widget.step.requiredApprovalsCount,
      statusTag: widget.step.statusTag,
      ableToEditOrderItems: widget.step.ableToEditOrderItems,
      allowDirectAssignment: widget.step.allowDirectAssignment,
      stepTriggers: selectedTriggers,
      actions: widget.step.actions,
    );

    context.read<WorkflowManagementBloc>().updateStep(
      organizationId: widget.organizationId,
      stepNumber: widget.step.stepNumber,
      entityType: 'orders',
      step: updatedStep,
      slug: widget.config.workflowSlug,
    );
  }

  void _showCustomTriggerDialog(BuildContext context, Color primaryColor) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("إضافة محفز مخصص"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "أدخل كود المحفز (مثال: SEND_NOTIFICATION)",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim().toUpperCase();
                if (text.isNotEmpty) {
                  if (!selectedTriggers.contains(text)) {
                    setState(() {
                      selectedTriggers.add(text);
                    });
                  }
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<
      WorkflowManagementBloc,
      FeaturDataSourceState<WorkflowConfigModel>
    >(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ المحفزات بنجاح'),
              ),
            );
            Navigator.of(context).pop(data);
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('❌ ${error.message ?? 'حدث خطأ أثناء حفظ المحفزات'}'),
              ),
            );
          },
          orElse: () {},
        );
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings_suggest_outlined, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "إدارة محفزات الخطوة: ${widget.step.stepName.ar}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "تتيح لك هذه الشاشة إدارة المحفزات البرمجية التي ينفذها النظام تلقائياً بمجرد دخول الطلب إلى هذه الخطوة.",
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "المحفزات النشطة للخطوة (${selectedTriggers.length}):",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (selectedTriggers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: const Center(
                    child: Text(
                      "لا توجد محفزات نشطة حالياً لهذه الخطوة.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedTriggers.map((trigger) {
                    String friendlyName = trigger;
                    if (trigger == 'POST_SALES') {
                      friendlyName = "ترحيل تلقائي للمبيعات (POST_SALES)";
                    }
                    return Chip(
                      label: Text(friendlyName),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedTriggers.remove(trigger);
                        });
                      },
                      backgroundColor: primaryColor.withOpacity(0.08),
                      side: BorderSide(color: primaryColor.withOpacity(0.2)),
                      labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                "إضافة محفز جديد:",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: null,
                decoration: const InputDecoration(
                  hintText: "اختر محفز لإضافته للخطوة",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'POST_SALES',
                    child: Text("ترحيل تلقائي للمبيعات (POST_SALES)"),
                  ),
                  DropdownMenuItem(
                    value: 'CUSTOM',
                    child: Text("إضافة كود محفز مخصص..."),
                  ),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  if (val == 'CUSTOM') {
                    _showCustomTriggerDialog(context, primaryColor);
                  } else {
                    if (!selectedTriggers.contains(val)) {
                      setState(() {
                        selectedTriggers.add(val);
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: saveTriggers,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'حفظ المحفزات',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text(
                          "إلغاء",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
