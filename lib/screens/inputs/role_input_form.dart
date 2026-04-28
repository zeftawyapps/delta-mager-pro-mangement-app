import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:matger_pro_core_logic/core/auth/data/permission_model.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_model.dart';

class RoleInputForm extends StatefulWidget {
  final String? organizationId;
  final RoleModel? role;
  final bool isCopy;

  const RoleInputForm({
    super.key,
    this.organizationId,
    this.role,
    this.isCopy = false,
  });

  @override
  State<RoleInputForm> createState() => _RoleInputFormState();
}

class _RoleInputFormState extends State<RoleInputForm> {
  final ValidationsForm form = ValidationsForm();

  late TextEditingController nameController;
  late TextEditingController displayNameController;
  late TextEditingController descriptionController;

  List<String> selectedPermissions = [];
  List<PermissionModel> availablePermissions = [];
  Map<String, List<PermissionModel>> groupedPermissions = {};
  bool isLoadingPermissions = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  String? selectedOrganizationId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.role?.name ?? '');
    displayNameController = TextEditingController(
      text: widget.role?.displayName ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.role?.description ?? '',
    );
    selectedPermissions = List<String>.from(widget.role?.permissions ?? []);
    _loadPermissions();

    // Load workflow configs if organization context exists
    if (widget.organizationId != null) {
      context.read<WorkflowManagementBloc>().loadSpecificConfig(
        widget.organizationId!,
        entityType: 'orders',
      );
    }

    if (widget.isCopy) {
      context.read<AdminOrganizationsBloc>().loadActiveOrganizations();
    }
  }

  Future<void> _loadPermissions() async {
    try {
      final rolesBloc = context.read<RolesBloc>();
      final result = await rolesBloc.repo.getAllPermissions();
      if (mounted) {
        setState(() {
          availablePermissions = result.data ?? [];
          _groupPermissions();
          isLoadingPermissions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingPermissions = false;
        });
      }
    }
  }

  void _groupPermissions() {
    groupedPermissions.clear();
    final filtered = availablePermissions.where((p) {
      final nameMatch = p.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final keyMatch = p.permissionKey.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final resourceMatch = p.resource.toRawString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return nameMatch || keyMatch || resourceMatch;
    }).toList();

    for (var perm in filtered) {
      final resource = perm.resource.toRawString();
      if (!groupedPermissions.containsKey(resource)) {
        groupedPermissions[resource] = [];
      }
      groupedPermissions[resource]!.add(perm);
    }
  }

  Map<String, Map<String, dynamic>> _getPermissionCategories() {
    return {
      'screens': {
        'title': 'شاشات العرض والتقارير',
        'icon': Icons.monitor,
        'color': Colors.blue,
        'features': [
          SystemFeatures.screenDashboard,
          SystemFeatures.screenReports,
          SystemFeatures.screenUsers,
          SystemFeatures.screenSettings,
          SystemFeatures.screenOrders,
          SystemFeatures.screenProducts,
          SystemFeatures.screenProfile,
          SystemFeatures.screenCategories,
          SystemFeatures.screenOffers,
          SystemFeatures.screenPolicies,
        ],
      },
      'management': {
        'title': 'إدارة البيانات والعمليات',
        'icon': Icons.inventory_2,
        'color': Colors.green,
        'features': [
          SystemFeatures.product,
          SystemFeatures.category,
          SystemFeatures.order,
          SystemFeatures.offer,
        ],
      },
      'security': {
        'title': 'الأمن والمستخدمين',
        'icon': Icons.security,
        'color': Colors.orange,
        'features': [
          SystemFeatures.user,
          SystemFeatures.role,
          SystemFeatures.permission,
          SystemFeatures.orgnizationownerData,
        ],
      },
      'system': {
        'title': 'إعدادات النظام والمنظمات',
        'icon': Icons.settings_applications,
        'color': Colors.purple,
        'features': [
          SystemFeatures.organization,
          SystemFeatures.system,
          SystemFeatures.controlPanel,
          SystemFeatures.superAdmin,
        ],
      },
    };
  }

  @override
  void dispose() {
    nameController.dispose();
    displayNameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _deleteRole() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف الدور'),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف دور "${widget.role?.displayName ?? widget.role?.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (widget.role?.id != null) {
                  context.read<RolesBloc>().deleteRole(
                    widget.role!.id!,
                    organizationId: widget.organizationId,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  void saveRole() {
    if (!form.form.currentState!.validate()) return;

    final finalPermissions = selectedPermissions
        .where((p) => p.isNotEmpty)
        .toList();

    final targetOrgId = widget.isCopy
        ? selectedOrganizationId
        : widget.organizationId;

    if (widget.isCopy) {
      if (targetOrgId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار المنظمة أولاً')),
        );
        return;
      }
      context.read<RolesBloc>().createRole(
        name: nameController.text.trim(),
        displayName: displayNameController.text.trim(),
        description: descriptionController.text.trim(),
        permissions: finalPermissions,
        organizationId: targetOrgId,
      );
    } else if (widget.role != null && widget.role!.id != null) {
      context.read<RolesBloc>().updateRole(
        roleId: widget.role!.id!,
        name: nameController.text.trim(),
        displayName: displayNameController.text.trim(),
        description: descriptionController.text.trim(),
        permissions: finalPermissions,
        organizationId: widget.organizationId,
      );
    } else {
      context.read<RolesBloc>().createRole(
        name: nameController.text.trim(),
        displayName: displayNameController.text.trim(),
        description: descriptionController.text.trim(),
        permissions: finalPermissions,
        organizationId: widget.organizationId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RolesBloc, FeaturDataSourceState<RoleModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          orElse: () {},
          success: (data) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم حفظ الدور بنجاح')));

            // Close ONLY the dialog using rootNavigator to be safe
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop(data);
            }
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: const Text('❌ خطأ في الإدخال راجع الدعم الفني'),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isSaving = state.itemState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                  ),
                  Text(
                    widget.isCopy
                        ? "نسخ الدور للمنظمة"
                        : (widget.role != null
                              ? "تعديل الدور"
                              : "إنشاء دور جديد"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.role != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _deleteRole,
                      tooltip: 'حذف الدور',
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              form.buildChildrenWithColumn(
                context: context,
                children: [
                  if (widget.isCopy) ...[
                    _buildOrganizationDropdown(),
                    const SizedBox(height: 16),
                  ],
                  TextFomrFildValidtion(
                    controller: nameController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: const InputDecoration(
                      labelText: 'اسم الدور (Technical Name)',
                      hintText: 'مثال: admin, editor',
                      prefixIcon: Icon(Icons.code),
                    ),
                    labalText: 'اسم الدور',
                    keyData: "name",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: displayNameController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: const InputDecoration(
                      labelText: 'الاسم الظاهر (Display Name)',
                      hintText: 'مثال: مدير النظام',
                      prefixIcon: Icon(Icons.title),
                    ),
                    labalText: 'الاسم الظاهر',
                    keyData: "displayName",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: descriptionController,
                    form: form,
                    baseValidation: const [],
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                      prefixIcon: Icon(Icons.description),
                    ),
                    labalText: 'الوصف',
                    keyData: "description",
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "الصلاحيات (Permissions)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${selectedPermissions.length} مختارة",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث في الصلاحيات...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                        _groupPermissions();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (isLoadingPermissions)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    if (widget.organizationId == null) ...[
                      _buildSuperAdminToggle(),
                      const SizedBox(height: 16),
                    ],
                    if (widget.organizationId != null) ...[
                      _buildWorkflowPermissionsSection(),
                      const SizedBox(height: 16),
                    ],
                    _buildCategorizedPermissions(),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : saveRole,
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ الدور'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrganizationDropdown() {
    return BlocBuilder<
      AdminOrganizationsBloc,
      FeaturDataSourceState<OrganizationModel>
    >(
      builder: (context, state) {
        final organizations = state.listState.maybeWhen(
          success: (data) => data,
          orElse: () => <OrganizationModel>[],
        );

        final isLoading = state.listState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return DropdownButtonFormField<String>(
          value: selectedOrganizationId,
          decoration: InputDecoration(
            labelText: 'اختر المنظمة',
            hintText: isLoading
                ? 'جاري التحميل...'
                : 'اختر المنظمة المراد النسخ إليها',
            prefixIcon: const Icon(Icons.business),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: organizations?.map((org) {
            return DropdownMenuItem<String>(
              value: org.id,
              child: Text(org.orgName ?? org.id ?? ''),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedOrganizationId = val;
            });
            if (val != null) {
              context.read<WorkflowManagementBloc>().loadSpecificConfig(
                val,
                entityType: 'orders',
              );
            }
          },
          validator: (val) => val == null ? 'يرجى اختيار المنظمة' : null,
        );
      },
    );
  }

  Widget _buildSuperAdminToggle() {
    final isSuperAdmin = selectedPermissions.contains('*:*');
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: CheckboxListTile(
        title: const Text(
          "صلاحية الوصول الكامل (Super Admin)",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        subtitle: const Text(
          "تمنح هذه الصلاحية وصولاً كاملاً لجميع الموارد والعمليات (*:*)",
          style: TextStyle(fontSize: 11),
        ),
        secondary: const Icon(Icons.stars, color: Colors.orange),
        value: isSuperAdmin,
        onChanged: (val) {
          setState(() {
            if (val == true) {
              if (!selectedPermissions.contains('*:*')) {
                selectedPermissions.add('*:*');
              }
            } else {
              selectedPermissions.remove('*:*');
            }
          });
        },
      ),
    );
  }

  Widget _buildCategorizedPermissions() {
    final categories = _getPermissionCategories();
    final allResources = SystemFeatures.translations.keys.toList();

    // Track which features we've already categorized to catch remaining ones
    Set<String> categorizedFeatures = {};
    for (var cat in categories.values) {
      categorizedFeatures.addAll(List<String>.from(cat['features']));
    }

    final otherFeatures = allResources
        .where((r) => !categorizedFeatures.contains(r))
        .toList();

    List<Widget> categoryWidgets = [];

    // Add defined categories
    categories.forEach((key, data) {
      final features = List<String>.from(data['features']);
      final widget = _buildCategorySection(
        title: data['title'],
        icon: data['icon'],
        color: data['color'],
        features: features,
      );
      if (widget != null) categoryWidgets.add(widget);
    });

    // Add "Others" category if there are any uncategorized features
    if (otherFeatures.isNotEmpty) {
      final widget = _buildCategorySection(
        title: 'أخرى',
        icon: Icons.more_horiz,
        color: Colors.grey,
        features: otherFeatures,
      );
      if (widget != null) categoryWidgets.add(widget);
    }

    return Column(children: categoryWidgets);
  }

  Widget _buildWorkflowPermissionsSection() {
    return BlocBuilder<
      WorkflowManagementBloc,
      FeaturDataSourceState<WorkflowConfigModel>
    >(
      builder: (context, state) {
        return state.listState.maybeWhen(
          success: (configs) {
            if (configs == null || configs.isEmpty) return const SizedBox();

            // Store unique actions per resource
            final Map<String, List<Map<String, dynamic>>> resourceActions = {};

            return Column(
              children: configs.map((config) {
                final resource = config.entityType == 'orders'
                    ? 'order'
                    : config.entityType;
                final workflowName = config.workflow.workflowName.ar;
                final executor = config.roleExecutor;

                // Extract steps for this specific workflow
                final List<Map<String, dynamic>> steps = [];
                for (var step in config.workflow.steps) {
                  final String technicalKey = step.stepRole.isNotEmpty
                      ? step.stepRole
                      : step.stepKey;
                  final String displayName = step.stepName.ar;

                  // Keep them unique within this list if necessary
                  if (!steps.any((s) => s['key'] == technicalKey)) {
                    steps.add({'key': technicalKey, 'name': displayName});
                  }
                }

                if (steps.isEmpty) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_tree_outlined,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      workflowName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      "المنفذ: $executor | عدد الخطوات: ${steps.length}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: [
                            // 1. General Action Permission for this resource
                            _buildWorkflowChip(
                              label: "كافة الإجراءات (عام)",
                              permissionKey: "$resource:workflowAction",
                              color: Colors.teal,
                            ),
                            // 2. Assigned Workflow Chip
                            _buildWorkflowChip(
                              label: "تحويل المهام (Assigner)",
                              permissionKey: "$resource:workflowAssigner",
                              color: Colors.orange,
                            ),
                            const Divider(),
                            const Text(
                              "الخطوات المتاحة للتفويض:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: double.infinity),
                            // 3. Dynamic Steps
                            ...steps.map((step) {
                              final String technicalKey = step['key'];
                              // Check if the key already contains the full path to avoid duplication
                              final String finalPermissionKey =
                                  technicalKey.contains(':')
                                  ? technicalKey
                                  : "$resource:workflowAction.$technicalKey";

                              return _buildWorkflowChip(
                                label: step['name'],
                                permissionKey: finalPermissionKey,
                                color: Colors.blue,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          orElse: () => const SizedBox(),
        );
      },
    );
  }

  Widget _buildWorkflowChip({
    required String label,
    required String permissionKey,
    required Color color,
    bool isGeneral = false,
  }) {
    final isSelected = selectedPermissions.contains(permissionKey);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        setState(() {
          if (val) {
            selectedPermissions.add(permissionKey);
          } else {
            selectedPermissions.remove(permissionKey);
          }
        });
      },
      backgroundColor: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? color : color.withOpacity(0.2)),
      ),
    );
  }

  Widget? _buildCategorySection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> features,
  }) {
    // Filter features based on organization context and search query
    final filteredFeatures = features.where((r) {
      // 1. Context filtering
      if (widget.organizationId != null) {
        final allowedInOrg = [
          SystemFeatures.product,
          SystemFeatures.category,
          SystemFeatures.user,
          SystemFeatures.screenProducts,
          SystemFeatures.screenUsers,
          SystemFeatures.screenOrders,
          SystemFeatures.screenOffers,
          SystemFeatures.order,
          SystemFeatures.offer,
        ];
        if (!allowedInOrg.contains(r)) return false;
      }

      // 2. Search filtering
      final nameAr = SystemFeatures.translations[r]?['ar'] ?? '';
      final nameEn = SystemFeatures.translations[r]?['en'] ?? '';

      // Filter out streams as requested
      if (r.toLowerCase().contains('stream')) return false;

      return r.toLowerCase().contains(searchQuery.toLowerCase()) ||
          nameAr.contains(searchQuery) ||
          nameEn.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredFeatures.isEmpty) return null;

    final allJobs = SystemJobs.translations.keys.toList();
    final isScreensCategory = title.contains('شاشات') || title == 'screens';

    // Filter jobs:
    // - Screens: only show View/Access (exclude Read)
    // - Resources: show only essential CRUD (Read, Add, Update, Delete) + Admin/All
    final categoryJobs = isScreensCategory
        ? [SystemJobs.view]
        : allJobs
              .where(
                (j) => [
                  SystemJobs.read,
                  SystemJobs.add,
                  SystemJobs.update,
                  SystemJobs.delete,
                  SystemJobs.all,
                  SystemJobs.admin,
                ].contains(j),
              )
              .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: searchQuery.isNotEmpty || isScreensCategory,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withAlpha(200),
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            "${filteredFeatures.length} مورد متاح",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          children: [
            const Divider(height: 1),
            Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 12),
                child: DataTable(
                  columnSpacing: isScreensCategory ? 60 : 30,
                  horizontalMargin: 16,
                  headingRowHeight: 45,
                  dataRowHeight: 48,
                  headingRowColor: WidgetStateProperty.all(
                    color.withOpacity(0.05),
                  ),
                  columns: [
                    DataColumn(
                      label: Row(
                        children: [
                          Checkbox(
                            value: filteredFeatures.every(
                              (res) => categoryJobs.every(
                                (job) => selectedPermissions.contains(
                                  "$res:${job == SystemJobs.all ? '*' : job}",
                                ),
                              ),
                            ),
                            tristate: true,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  for (var res in filteredFeatures) {
                                    for (var job in categoryJobs) {
                                      final key =
                                          "$res:${job == SystemJobs.all ? '*' : job}";
                                      if (!selectedPermissions.contains(key))
                                        selectedPermissions.add(key);
                                    }
                                  }
                                } else {
                                  for (var res in filteredFeatures) {
                                    for (var job in categoryJobs) {
                                      selectedPermissions.remove(
                                        "$res:${job == SystemJobs.all ? '*' : job}",
                                      );
                                    }
                                  }
                                }
                              });
                            },
                          ),
                          const Text(
                            'المورد / الشاشة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...categoryJobs.map((j) {
                      final jobName = SystemJobs.translations[j]?['ar'] ?? j;
                      return DataColumn(
                        label: Text(
                          jobName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color:
                                (j == SystemJobs.all || j == SystemJobs.admin)
                                ? Colors.orange.shade800
                                : (j == SystemJobs.view || j == SystemJobs.read)
                                ? Colors.blue.shade700
                                : (j == SystemJobs.add ||
                                      j == SystemJobs.update ||
                                      j == SystemJobs.delete)
                                ? Colors.green.shade700
                                : Colors.black87,
                          ),
                        ),
                      );
                    }),
                  ],
                  rows: filteredFeatures.map((resKey) {
                    final resName =
                        SystemFeatures.translations[resKey]?['ar'] ?? resKey;
                    final allInRowSelected = categoryJobs.every(
                      (job) => selectedPermissions.contains(
                        "$resKey:${job == SystemJobs.all ? '*' : job}",
                      ),
                    );

                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 280,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: allInRowSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        for (var job in categoryJobs) {
                                          final key =
                                              "$resKey:${job == SystemJobs.all ? '*' : job}";
                                          if (!selectedPermissions.contains(
                                            key,
                                          ))
                                            selectedPermissions.add(key);
                                        }
                                      } else {
                                        for (var job in categoryJobs) {
                                          selectedPermissions.remove(
                                            "$resKey:${job == SystemJobs.all ? '*' : job}",
                                          );
                                        }
                                      }
                                    });
                                  },
                                ),
                                Icon(
                                  _getResourceIcon(resKey),
                                  size: 14,
                                  color: color.withOpacity(0.6),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    resName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...categoryJobs.map((jobKey) {
                          String technicalJobKey = jobKey == SystemJobs.all
                              ? '*'
                              : jobKey;
                          final permKey = "$resKey:$technicalJobKey";
                          final isSelected = selectedPermissions.contains(
                            permKey,
                          );

                          return DataCell(
                            Center(
                              child: Checkbox(
                                value: isSelected,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor:
                                    (jobKey == SystemJobs.all ||
                                        jobKey == SystemJobs.admin)
                                    ? Colors.orange
                                    : color,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedPermissions.add(permKey);
                                      if (jobKey == SystemJobs.all ||
                                          jobKey == SystemJobs.admin) {
                                        for (var j in categoryJobs) {
                                          final k =
                                              "$resKey:${j == SystemJobs.all ? '*' : j}";
                                          if (!selectedPermissions.contains(k))
                                            selectedPermissions.add(k);
                                        }
                                      }
                                    } else {
                                      selectedPermissions.remove(permKey);
                                      if (jobKey == SystemJobs.all ||
                                          jobKey == SystemJobs.admin) {
                                        for (var j in categoryJobs) {
                                          final k =
                                              "$resKey:${j == SystemJobs.all ? '*' : j}";
                                          selectedPermissions.remove(k);
                                        }
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getResourceIcon(String resource) {
    resource = resource.toLowerCase();
    if (resource.contains('product')) return Icons.shopping_bag;
    if (resource.contains('categor')) return Icons.category;
    if (resource.contains('order')) return Icons.receipt;
    if (resource.contains('user')) return Icons.people;
    if (resource.contains('role')) return Icons.security;
    if (resource.contains('setting')) return Icons.settings;
    if (resource.contains('report')) return Icons.assessment;
    if (resource.contains('inventory')) return Icons.inventory;
    if (resource.contains('offer')) return Icons.local_offer;
    if (resource.contains('organization')) return Icons.business;
    if (resource.contains('dashboard')) return Icons.dashboard;
    return Icons.settings_input_component;
  }
}
