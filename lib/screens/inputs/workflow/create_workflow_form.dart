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
import 'package:matger_pro_core_logic/features/workflow/request_body/workflow_request_bodies.dart';

class CreateWorkflowForm extends StatefulWidget {
  final String organizationId;
  final bool isDark;

  const CreateWorkflowForm({
    super.key,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<CreateWorkflowForm> createState() => _CreateWorkflowFormState();
}

class _CreateWorkflowFormState extends State<CreateWorkflowForm> {
  final ValidationsForm form = ValidationsForm();

  late TextEditingController nameArController;
  late TextEditingController nameEnController;
  late TextEditingController descArController;
  late TextEditingController descEnController;
  late TextEditingController slugController;

  String roleExecutor = 'admin';

  @override
  void initState() {
    super.initState();
    nameArController = TextEditingController();
    nameEnController = TextEditingController();
    descArController = TextEditingController();
    descEnController = TextEditingController();
    slugController = TextEditingController();

    // Load roles to ensure they are available
    context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    descArController.dispose();
    descEnController.dispose();
    slugController.dispose();
    super.dispose();
  }

  void saveWorkflow() {
    if (!form.form.currentState!.validate()) return;

    final defaultSteps = [
      {
        "stepName": {"en": "Order Started", "ar": "طلب جديد"},
        "stepNumber": 1,
        "stepKey": "started",
        "selectionMode": "broadcast",
        "stepRole": "admin",
        "stepColor": "#4CAF50",
        "targetType": "both",
        "statusTag": "started",
        "actions": [
          {
            "actionName": {
              "ar": "تأكيد وبدء التجهيز",
              "en": "Confirm & Process",
            },
            "actionKey": "process",
            "actionReturnToStepKey": "processing",
          },
          {
            "actionName": {"ar": "إلغاء الطلب", "en": "Cancel Order"},
            "actionKey": "cancel",
            "actionReturnToStepKey": "completed",
          },
        ],
      },
      {
        "stepName": {"en": "Processing", "ar": "قيد التجهيز"},
        "stepNumber": 2,
        "stepKey": "processing",
        "selectionMode": "direct",
        "stepRole": "admin",
        "stepColor": "#FF9800",
        "targetType": "user",
        "statusTag": "processing",
        "actions": [
          {
            "actionName": {"ar": "تم التوصيل بنجاح", "en": "Delivered"},
            "actionKey": "deliver",
            "actionReturnToStepKey": "completed",
          },
          {
            "actionName": {"ar": "إعادة للمراجعة", "en": "Reject to Start"},
            "actionKey": "reject",
            "actionReturnToStepKey": "started",
          },
          {
            "actionName": {"ar": "إلغاء الطلب", "en": "Cancel Order"},
            "actionKey": "cancel",
            "actionReturnToStepKey": "completed",
          },
        ],
      },
      {
        "stepName": {"en": "Completed", "ar": "تم التوصيل بنجاح"},
        "stepNumber": 3,
        "stepKey": "completed",
        "selectionMode": "broadcast",
        "stepRole": "admin",
        "stepColor": "#2196F3",
        "targetType": "both",
        "statusTag": "completed",
        "actions": [],
      },
    ];

    final request = WorkflowConfigRequest(
      entityType: 'orders',
      name: nameArController.text.trim(),
      description: descArController.text.trim(),
      workflowSlug: slugController.text.trim(),
      roleExecutor: roleExecutor,
      steps: defaultSteps,
    );

    context.read<WorkflowManagementBloc>().createOrUpdateConfig(
      organizationId: widget.organizationId,
      request: request,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    return BlocListener<
      WorkflowManagementBloc,
      FeaturDataSourceState<WorkflowConfigModel>
    >(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إنشاء مسار العمل بنجاح')),
            );
            Navigator.of(context).pop(data);
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  '❌ ${error.message ?? 'حدث خطأ أثناء إنشاء المسار'}',
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
                      Icon(Icons.add_road, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "إنشاء مسار عمل مخصص جديد",
                        style: TextStyle(
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
                        "تتيح لك هذه الشاشة إنشاء مسار عمل مخصص بالكامل مع إنشاء 3 خطوات افتراضية جاهزة للعمل فوراً (جديد، قيد التجهيز، مكتمل)، ومن ثم يمكنك تعديل وتخصيص هذه الخطوات بشكل أوسع.",
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
                      labelText: "اسم مسار العمل (بالعربية)",
                    ),
                    labalText: "اسم مسار العمل (بالعربية)",
                    keyData: "workflowNameAr",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: nameEnController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.abc, color: primaryColor),
                      labelText: "اسم مسار العمل (بالإنجليزية)",
                    ),
                    labalText: "اسم مسار العمل (بالإنجليزية)",
                    keyData: "workflowNameEn",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: descArController,
                    form: form,
                    baseValidation: const [],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.description, color: primaryColor),
                      labelText: "الوصف (بالعربية)",
                    ),
                    labalText: "الوصف (بالعربية)",
                    keyData: "descAr",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: descEnController,
                    form: form,
                    baseValidation: const [],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.description, color: primaryColor),
                      labelText: "الوصف (بالإنجليزية)",
                    ),
                    labalText: "الوصف (بالإنجليزية)",
                    keyData: "descEn",
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFomrFildValidtion(
                          controller: slugController,
                          form: form,
                          baseValidation: [RequiredValidator()],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.link, color: primaryColor),
                            labelText: "مفتاح المسار (Slug)",
                          ),
                          labalText: "مفتاح المسار (Slug)",
                          keyData: "workflowSlug",
                        ),
                      ),
                      const SizedBox(width: 16),
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
                                if (roles.any((r) => r.name == roleExecutor)) {
                                  selectedValue = roleExecutor;
                                }

                                return DropdownButtonFormField<String>(
                                  value: selectedValue,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.security,
                                      color: primaryColor,
                                    ),
                                    labelText: "المنفذ الرئيسي (Role Executor)",
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
                                      setState(() => roleExecutor = val);
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
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: saveWorkflow,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'إنشاء مسار العمل',
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
