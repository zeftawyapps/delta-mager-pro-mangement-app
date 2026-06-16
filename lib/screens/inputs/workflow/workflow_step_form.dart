import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:matger_pro_core_logic/models/localized_string.dart';

class WorkflowStepForm extends StatefulWidget {
  final WorkflowConfigModel config;
  final WorkflowStep? step;
  final String organizationId;
  final bool isDark;

  const WorkflowStepForm({
    super.key,
    required this.config,
    this.step,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<WorkflowStepForm> createState() => _WorkflowStepFormState();
}

class _WorkflowStepFormState extends State<WorkflowStepForm> {
  final ValidationsForm form = ValidationsForm();

  late TextEditingController nameArController;
  late TextEditingController nameEnController;
  late TextEditingController keyController;
  late TextEditingController statusTagController;
  late TextEditingController approvalsCountController;

  late int stepNumber;
  late String stepRole;
  late String stepColor;
  late String selectionMode;
  late String targetType;
  late bool ableToEditOrderItems;
  late bool allowDirectAssignment;
  late List<String> selectedTriggers;

  @override
  void initState() {
    super.initState();
    final s = widget.step;
    nameArController = TextEditingController(text: s?.stepName.ar ?? '');
    nameEnController = TextEditingController(text: s?.stepName.en ?? '');
    keyController = TextEditingController(text: s?.stepKey ?? '');
    statusTagController = TextEditingController(text: s?.statusTag ?? '');
    approvalsCountController = TextEditingController(
      text: (s?.requiredApprovalsCount ?? 1).toString(),
    );

    stepNumber = s?.stepNumber ?? (widget.config.workflow.steps.length + 1);
    stepRole = s?.stepRole ?? 'admin';
    stepColor = s?.stepColor ?? '#2196F3';
    selectionMode = s?.selectionMode ?? 'claim';
    targetType = s?.targetType ?? 'user';
    ableToEditOrderItems = s?.ableToEditOrderItems ?? false;
    allowDirectAssignment = s?.allowDirectAssignment ?? false;
    selectedTriggers = List<String>.from(s?.stepTriggers ?? []);

    // Load roles to ensure they are available
    context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    keyController.dispose();
    statusTagController.dispose();
    approvalsCountController.dispose();
    super.dispose();
  }

  void saveStep() {
    if (!form.form.currentState!.validate()) return;

    final isEditing = widget.step != null;
    final reqApprovals =
        int.tryParse(approvalsCountController.text.trim()) ?? 1;

    final newStep = WorkflowStep(
      id: widget.step?.id ?? 'step_${DateTime.now().millisecondsSinceEpoch}',
      stepKey: keyController.text.trim(),
      stepNumber: stepNumber,
      stepName: LocalizedString({
        'ar': nameArController.text.trim(),
        'en': nameEnController.text.trim(),
      }),
      stepRole: stepRole,
      stepColor: stepColor,
      selectionMode: selectionMode,
      targetType: targetType,
      requiredApprovalsCount: reqApprovals,
      statusTag: statusTagController.text.trim(),
      ableToEditOrderItems: ableToEditOrderItems,
      allowDirectAssignment: allowDirectAssignment,
      stepTriggers: selectedTriggers,
      actions: widget.step?.actions ?? [],
    );

    if (isEditing) {
      context.read<WorkflowManagementBloc>().updateStep(
        organizationId: widget.organizationId,
        stepNumber: widget.step!.stepNumber,
        entityType: 'orders',
        step: newStep,
        slug: widget.config.workflowSlug,
      );
    } else {
      context.read<WorkflowManagementBloc>().addStep(
        organizationId: widget.organizationId,
        entityType: 'orders',
        step: newStep,
        slug: widget.config.workflowSlug,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.step != null;
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
              SnackBar(
                content: Text(
                  isEditing ? 'تم تعديل الخطوة بنجاح' : 'تم إضافة الخطوة بنجاح',
                ),
              ),
            );
            Navigator.of(context).pop(data);
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('❌ ${error.message ?? 'حدث خطأ أثناء الحفظ'}'),
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
                      Icon(
                        isEditing ? Icons.edit : Icons.add_box_outlined,
                        color: primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing
                            ? "تعديل خطوة سير العمل"
                            : "إضافة خطوة سير عمل جديدة",
                        style: const TextStyle(
                          fontSize: 18,
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
                        "تتيح لك هذه الشاشة إضافة أو تعديل خطوة في مسار العمل الحالي للطلبات، مع تعيين الصلاحيات وطريقة الإسناد المناسبة.",
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
                      labelText: "اسم الخطوة (بالعربية)",
                    ),
                    labalText: "اسم الخطوة (بالعربية)",
                    keyData: "nameAr",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: nameEnController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.abc, color: primaryColor),
                      labelText: "اسم الخطوة (بالإنجليزية)",
                    ),
                    labalText: "اسم الخطوة (بالإنجليزية)",
                    keyData: "nameEn",
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFomrFildValidtion(
                          controller: keyController,
                          form: form,
                          baseValidation: [RequiredValidator()],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.key, color: primaryColor),
                            labelText: "مفتاح الخطوة (Unique Key)",
                          ),
                          labalText: "مفتاح الخطوة",
                          keyData: "stepKey",
                          isReadOnly: isEditing,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: stepNumber,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.format_list_numbered,
                              color: primaryColor,
                            ),
                            labelText: "رقم الخطوة (الترتيب)",
                            border: const OutlineInputBorder(),
                          ),
                          items: List.generate(20, (index) => index + 1)
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => stepNumber = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child:
                            BlocBuilder<
                              RolesBloc,
                              FeaturDataSourceState<RoleModel>
                            >(
                              builder: (context, rolesState) {
                                final roles = rolesState.listState.maybeWhen(
                                  success: (list) => list ?? <RoleModel>[],
                                  orElse: () => <RoleModel>[],
                                );

                                String? selectedValue;
                                if (roles.any((r) => r.name == stepRole)) {
                                  selectedValue = stepRole;
                                }

                                return DropdownButtonFormField<String>(
                                  value: selectedValue,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.security,
                                      color: primaryColor,
                                    ),
                                    labelText: "دور منفذ الخطوة (Role)",
                                    border: const OutlineInputBorder(),
                                  ),
                                  items: roles
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r.name,
                                          child: Text(r.displayName ?? r.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => stepRole = val);
                                    }
                                  },
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? "هذا الحقل مطلوب"
                                      : null,
                                );
                              },
                            ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: stepColor,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.palette,
                              color: primaryColor,
                            ),
                            labelText: "اللون المميز (Color)",
                            border: const OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '#2196F3',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text("أزرق"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '#FF9800',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text("برتقالي"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '#4CAF50',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text("أخضر"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '#F44336',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text("أحمر"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '#9C27B0',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.purple,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text("بنفسجي"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '#009688',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.teal,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text("تركواز"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: '#3F51B5',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.indigo,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text("كحلي"),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => stepColor = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectionMode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.touch_app,
                              color: primaryColor,
                            ),
                            labelText: "طريقة الإسناد (Selection Mode)",
                            border: const OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'claim',
                              child: Text('استلام المهمة (Claim)'),
                            ),
                            DropdownMenuItem(
                              value: 'direct',
                              child: Text('إسناد مباشر لـ مستخدم معين'),
                            ),
                            DropdownMenuItem(
                              value: 'consensus',
                              child: Text('موافقة جماعية (إجماع)'),
                            ),
                            DropdownMenuItem(
                              value: 'broadcast',
                              child: Text('بث داخلي للمؤسسة'),
                            ),
                            DropdownMenuItem(
                              value: 'market',
                              child: Text('سوق عمل خارجي (مفتوح)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectionMode = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: targetType,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.group, color: primaryColor),
                            labelText: "الهدف (Target Type)",
                            border: const OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('مستخدم (user)'),
                            ),
                            DropdownMenuItem(
                              value: 'org',
                              child: Text('مؤسسة (org)'),
                            ),
                            DropdownMenuItem(
                              value: 'both',
                              child: Text('كلاهما (both)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => targetType = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFomrFildValidtion(
                          controller: approvalsCountController,
                          form: form,
                          baseValidation: [RequiredValidator()],
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.check_circle,
                              color: primaryColor,
                            ),
                            labelText: "عدد الموافقات المطلوبة",
                          ),
                          labalText: "عدد الموافقات المطلوبة",
                          keyData: "requiredApprovalsCount",
                          textInputType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFomrFildValidtion(
                          controller: statusTagController,
                          form: form,
                          baseValidation: [RequiredValidator()],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.tag, color: primaryColor),
                            labelText: "علامة الحالة (Status Tag)",
                          ),
                          labalText: "علامة الحالة",
                          keyData: "statusTag",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text(
                      "السماح بتعديل منتجات الطلب",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: ableToEditOrderItems,
                    onChanged: (val) =>
                        setState(() => ableToEditOrderItems = val),
                    activeColor: primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text(
                      "السماح بالإسناد المباشر",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: allowDirectAssignment,
                    onChanged: (val) =>
                        setState(() => allowDirectAssignment = val),
                    activeColor: primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: saveStep,
                            icon: const Icon(Icons.save),
                            label: Text(
                              isEditing ? 'حفظ التعديلات' : 'إضافة الخطوة',
                              style: const TextStyle(
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
