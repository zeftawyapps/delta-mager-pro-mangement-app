import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:matger_pro_core_logic/models/localized_string.dart';

class WorkflowActionForm extends StatefulWidget {
  final WorkflowConfigModel config;
  final WorkflowStep step;
  final String organizationId;
  final bool isDark;

  const WorkflowActionForm({
    super.key,
    required this.config,
    required this.step,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<WorkflowActionForm> createState() => _WorkflowActionFormState();
}

class _WorkflowActionFormState extends State<WorkflowActionForm> {
  final ValidationsForm form = ValidationsForm();

  late TextEditingController nameArController;
  late TextEditingController nameEnController;
  late TextEditingController keyController;

  WorkflowStep? selectedDestStep;

  @override
  void initState() {
    super.initState();
    nameArController = TextEditingController();
    nameEnController = TextEditingController();
    keyController = TextEditingController();
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    keyController.dispose();
    super.dispose();
  }

  void saveAction() {
    if (!form.form.currentState!.validate() || selectedDestStep == null) {
      if (selectedDestStep == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى تحديد الخطوة التالية للطلب")),
        );
      }
      return;
    }

    final newAction = WorkflowAction(
      id: 'action_${DateTime.now().millisecondsSinceEpoch}',
      actionKey: keyController.text.trim(),
      actionName: LocalizedString({
        'ar': nameArController.text.trim(),
        'en': nameEnController.text.trim(),
      }),
      actionReturnToStepIndex: selectedDestStep!.stepNumber,
      actionReturnToStepKey: selectedDestStep!.stepKey,
    );

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
      actions: List<WorkflowAction>.from(widget.step.actions)..add(newAction),
    );

    context.read<WorkflowManagementBloc>().updateStep(
      organizationId: widget.organizationId,
      stepNumber: widget.step.stepNumber,
      entityType: 'orders',
      step: updatedStep,
      slug: widget.config.workflowSlug,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;
    final otherSteps = widget.config.workflow.steps;

    return BlocListener<
      WorkflowManagementBloc,
      FeaturDataSourceState<WorkflowConfigModel>
    >(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ الإجراء بنجاح')),
            );
            Navigator.of(context).pop(data);
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  '❌ ${error.message ?? 'حدث خطأ أثناء حفظ الإجراء'}',
                ),
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
                      Icon(Icons.flash_on, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "إضافة إجراء لخطوة: ${widget.step.stepName.ar}",
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

              // Documentation Banner (Requirement 4)
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
                        "تتيح لك هذه الشاشة إضافة زر إجراء مخصص (مثل: 'تأكيد'، 'إلغاء'، 'مراجعة') يظهر للمستخدم في هذه الخطوة لتحديد مسار التوجيه التالي.",
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              form.buildChildrenWithColumn(
                context: context,
                children: [
                  TextFomrFildValidtion(
                    controller: nameArController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.abc, color: primaryColor),
                      labelText: "اسم الإجراء (بالعربية)",
                    ),
                    labalText: "اسم الإجراء (بالعربية)",
                    keyData: "actionNameAr",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: nameEnController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.abc, color: primaryColor),
                      labelText: "اسم الإجراء (بالإنجليزية)",
                    ),
                    labalText: "اسم الإجراء (بالإنجليزية)",
                    keyData: "actionNameEn",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: keyController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.flash_on, color: primaryColor),
                      labelText: "مفتاح الإجراء (Action Key)",
                    ),
                    labalText: "مفتاح الإجراء",
                    keyData: "actionKey",
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<WorkflowStep>(
                    value: selectedDestStep,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.subdirectory_arrow_right,
                        color: primaryColor,
                      ),
                      labelText: "الخطوة التالية (Destination Step)",
                      border: const OutlineInputBorder(),
                    ),
                    items: otherSteps
                        .map(
                          (s) => DropdownMenuItem<WorkflowStep>(
                            value: s,
                            child: Text("${s.stepNumber} - ${s.stepName.ar}"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedDestStep = val),
                    validator: (value) =>
                        value == null ? "هذا الحقل مطلوب" : null,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: saveAction,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'حفظ الإجراء',
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
            ],
          ),
        ),
      ),
    );
  }
}
