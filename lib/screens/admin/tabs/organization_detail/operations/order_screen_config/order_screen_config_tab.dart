import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/order_path_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

import 'models/role_orders_config.dart';
import 'widgets/group_card.dart';
import 'widgets/configured_role_chip.dart';
import 'widgets/role_customization_panel.dart';

class OrderScreenConfigTab extends StatefulWidget {
  final OrganizationConfig config;
  final String organizationId;
  final bool isDark;

  const OrderScreenConfigTab({
    super.key,
    required this.config,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<OrderScreenConfigTab> createState() => _OrderScreenConfigTabState();
}

class _OrderScreenConfigTabState extends State<OrderScreenConfigTab> {
  bool _isEditing = false;
  Map<String, dynamic> _data = {};

  // --- Role config variables ---
  String? _selectedRoleId;
  Map<String, RoleOrdersConfig> _rolesConfig = {};

  // --- Workflow & Steps variables ---
  String? _selectedWorkflowId;
  List<String> _selectedStepsFromPermissions = [];
  List<String> _availableWorkflowSteps = [];
  Map<String, String> _stepDisplayNames = {}; // stepKey -> displayName

  @override
  void initState() {
    super.initState();
    context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
    context.read<WorkflowManagementBloc>().loadSpecificConfig(
      widget.organizationId,
      entityType: 'orders',
    );
    context.read<OrderPathBloc>().loadOrderPaths(widget.organizationId);
    _loadData();
  }

  @override
  void didUpdateWidget(covariant OrderScreenConfigTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _loadData();
    }
  }

  void _loadData() {
    final existingData = widget.config.ordersConfig;
    if (existingData != null && existingData is Map) {
      setState(() {
        _data = Map<String, dynamic>.from(existingData);
        final rolesRaw = _data['rolesConfig'];
        
        final allRoles = BlocProvider.of<RolesBloc>(context).state.listState.maybeWhen(
          success: (list) => list ?? [],
          orElse: () => <RoleModel>[],
        );

        if (rolesRaw != null && rolesRaw is Map) {
          _rolesConfig = {};
          rolesRaw.forEach((key, value) {
            if (value is Map) {
              String roleKey = key.toString();
              // Migration: if key matches a role ID, migrate it to the role name
              final matchedRole = allRoles.where((r) => r.id == roleKey).firstOrNull;
              if (matchedRole != null) {
                roleKey = matchedRole.name;
              }
              _rolesConfig[roleKey] = RoleOrdersConfig.fromMap(
                Map<String, dynamic>.from(value),
              );
            }
          });
        } else {
          _rolesConfig = {};
        }

        // Migrate _selectedRoleId if it was set to an ID
        if (_selectedRoleId != null) {
          final matchedRole = allRoles.where((r) => r.id == _selectedRoleId).firstOrNull;
          if (matchedRole != null) {
            _selectedRoleId = matchedRole.name;
          }
        }

        // 🔄 تحديد الدور الأول كخيار افتراضي إن لم يكن هناك دور محدد
        if (_selectedRoleId == null && _rolesConfig.isNotEmpty) {
          _selectedRoleId = _rolesConfig.keys.first;
        }

        // 🔄 تحديث الخطوات للدور المحدد حالياً إن وجد
        if (_selectedRoleId != null) {
          final savedConfig = _rolesConfig[_selectedRoleId];
          if (savedConfig?.selectedWorkflowId != null) {
            final workflowState = context.read<WorkflowManagementBloc>().state;
            final configs = workflowState.listState.maybeWhen(
              success: (list) => list ?? [],
              orElse: () => <WorkflowConfigModel>[],
            );
            _loadStepsFromPermissions(_selectedRoleId!, savedConfig!.selectedWorkflowId, configs);
          } else {
            _selectedWorkflowId = null;
            _availableWorkflowSteps = [];
            _stepDisplayNames = {};
            _selectedStepsFromPermissions = [];
          }
        }
      });
    } else {
      setState(() {
        _data = {};
        _rolesConfig = {};
        _selectedWorkflowId = null;
        _availableWorkflowSteps = [];
        _stepDisplayNames = {};
        _selectedStepsFromPermissions = [];
      });
    }
  }

  Future<void> _saveConfig() async {
    final rolesRaw = <String, dynamic>{};
    _rolesConfig.forEach((roleId, config) {
      rolesRaw[roleId] = config.toMap();
    });
    _data['rolesConfig'] = rolesRaw;

    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
          organizationId: widget.organizationId,
          section: "ordersConfig",
          sectionData: _data,
        );

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم حفظ إعدادات الطلبات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  RoleOrdersConfig _getRoleConfig(String roleId) {
    return _rolesConfig[roleId] ?? RoleOrdersConfig.defaultConfig();
  }

  void _updateRoleConfig(String roleId, RoleOrdersConfig newConfig) {
    setState(() {
      _rolesConfig[roleId] = newConfig;
    });
  }

  void _removeRoleConfig(String roleId) {
    setState(() {
      _rolesConfig.remove(roleId);
      if (_selectedRoleId == roleId) {
        _selectedRoleId = null;
      }
    });
  }

  void _loadStepsFromPermissions(
    String roleId,
    String? workflowId,
    List<WorkflowConfigModel> configs,
  ) {
    _selectedWorkflowId = workflowId;

    if (workflowId == null) {
      _availableWorkflowSteps = [];
      _stepDisplayNames = {};
      _selectedStepsFromPermissions = [];
      return;
    }

    // 1. ابحث عن الـ workflow المحدد
    final selectedConfig = configs.where((c) => c.id == workflowId).firstOrNull;
    if (selectedConfig == null) {
      // إذا لم يتم تحميل تفاصيل سير العمل بعد، نفرغ الخطوات مؤقتاً
      _availableWorkflowSteps = [];
      _stepDisplayNames = {};
      _selectedStepsFromPermissions = [];
      return;
    }

    // 2. استخرج كل الخطوات من الـ workflow
    final Map<String, String> stepsMap = {};
    for (var step in selectedConfig.workflow.steps) {
      final stepKey = step.stepKey;
      final displayName = step.stepName.ar;
      stepsMap[stepKey] = displayName;
    }

    // 3. اعرف إيه الصلاحيات اللي عند الدور
    final allRoles = BlocProvider.of<RolesBloc>(context).state.listState.maybeWhen(
      success: (list) => list ?? [],
      orElse: () => <RoleModel>[],
    );
    final selectedRole = allRoles.where(
      (r) => r.id == roleId || r.name == roleId,
    ).firstOrNull;
    final rolePermissions = selectedRole?.permissions ?? [];

    // 4. استخرج step keys من صلاحيات الدور اللي على شكل order:workflowAction.[stepKey]
    final Set<String> permissionStepKeys = {};
    for (var perm in rolePermissions) {
      final actionMatch = RegExp(r'^order:workflowAction\.(.+)$').firstMatch(perm);
      if (actionMatch != null) {
        permissionStepKeys.add(actionMatch.group(1)!);
      }
      if (perm == '*:*') {
        permissionStepKeys.addAll(stepsMap.keys);
      }
    }

    // 5. availableSteps = كل الخطوات اللي في الـ workflow واللي موجودة في صلاحيات الدور
    final List<String> availableSteps = stepsMap.keys.where(
      (stepKey) => permissionStepKeys.contains(stepKey),
    ).toList();

    // 6. selectedSteps = الخطوات المتاحة اللي كانت محفوظة سابقاً في config
    final isConfigured = _rolesConfig.containsKey(roleId) && _rolesConfig[roleId]?.selectedWorkflowId == workflowId;
    final savedSteps = _rolesConfig[roleId]?.allowedSteps ?? [];
    final List<String> selectedSteps = isConfigured
        ? savedSteps.where((s) => availableSteps.contains(s)).toList()
        : List<String>.from(availableSteps); // أول مرة: نحدد كل الخطوات المتاحة

    _availableWorkflowSteps = availableSteps;
    _stepDisplayNames = stepsMap;
    _selectedStepsFromPermissions = selectedSteps;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;
    final orderPathState = context.watch<OrderPathBloc>().state;
    final allOrderPaths = orderPathState.listState.maybeWhen(
      success: (list) => list ?? [],
      orElse: () => <OrderPathModel>[],
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<WorkflowManagementBloc, FeaturDataSourceState<WorkflowConfigModel>>(
          listener: (context, workflowState) {
            workflowState.listState.maybeWhen(
              success: (configs) {
                if (_selectedRoleId != null) {
                  final savedConfig = _rolesConfig[_selectedRoleId];
                  if (savedConfig?.selectedWorkflowId != null) {
                    setState(() {
                      _loadStepsFromPermissions(
                        _selectedRoleId!,
                        savedConfig!.selectedWorkflowId,
                        configs ?? [],
                      );
                    });
                  }
                }
              },
              orElse: () {},
            );
          },
        ),
        BlocListener<RolesBloc, FeaturDataSourceState<RoleModel>>(
          listener: (context, rolesState) {
            rolesState.listState.maybeWhen(
              success: (roles) {
                _loadData();
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "إعدادات شاشة الطلبات",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isEditing
                      ? _saveConfig
                      : () => setState(() => _isEditing = true),
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  label: Text(_isEditing ? "حفظ التغييرات" : "تعديل الإعدادات"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? Colors.green : primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Role-Based Screen Config Section
            _buildRolesSection(primaryColor, allOrderPaths),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesSection(Color primaryColor, List<OrderPathModel> allOrderPaths) {
    return GroupCard(
      title: "تخصيص شاشة الطلبات حسب الدور (Role-Based Screen)",
      icon: Icons.admin_panel_settings,
      isDark: widget.isDark,
      children: [
        const SizedBox(height: 8),
        Text(
          "قم بتحديد كل دور على حدة وتخصيص شاشة الطلبات بما يتناسب مع مهامه. مثلاً: مندوب التوصيل يشوف فقط الطلبات المطلوب توصيلها، والمحاسب يشوف الفواتير فقط.",
          style: TextStyle(
            fontSize: 12,
            color: widget.isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<RolesBloc, FeaturDataSourceState<RoleModel>>(
          builder: (context, rolesState) {
            final allRoles = rolesState.listState.maybeWhen(
              success: (list) => list ?? [],
              orElse: () => <RoleModel>[],
            );
            final isLoading = rolesState.listState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (allRoles.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "لا توجد أدوار في هذه المنظمة. قم بإنشاء الأدوار أولاً من شاشة إدارة الأدوار.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            final roles = allRoles.where((role) {
              final perms = role.permissions ?? [];
              return perms.any((p) =>
                p == 'screen.orders:view' ||
                p == 'screen.orders:*' ||
                p == '*:*'
              );
            }).toList();

            return Column(
              children: [
                if (roles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "لا توجد أدوار لديها صلاحية الوصول لشاشة الطلبات (screenOrders). قم بمنح صلاحية 'شاشة الطلبات' للدور المطلوب من شاشة إدارة الأدوار.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: roles.any((r) => r.name == _selectedRoleId) ? _selectedRoleId : null,
                    decoration: const InputDecoration(
                      labelText: "اختر الدور",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: roles.map((role) {
                      final isConfigured = _rolesConfig.containsKey(role.name);
                      return DropdownMenuItem<String>(
                        value: role.name,
                        child: Row(
                          children: [
                            Icon(
                              isConfigured ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 16,
                              color: isConfigured ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(role.displayName ?? role.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedRoleId = val;
                        final savedConfig = _rolesConfig[val];
                        if (savedConfig?.selectedWorkflowId != null) {
                          final workflowState = context.read<WorkflowManagementBloc>().state;
                          final configs = workflowState.listState.maybeWhen(
                            success: (list) => list ?? [],
                            orElse: () => <WorkflowConfigModel>[],
                          );
                          _loadStepsFromPermissions(val!, savedConfig!.selectedWorkflowId, configs);
                        } else {
                          _selectedWorkflowId = null;
                          _availableWorkflowSteps = [];
                          _stepDisplayNames = {};
                          _selectedStepsFromPermissions = [];
                        }
                      });
                    },
                  ),
                const SizedBox(height: 16),

                if (_selectedRoleId != null)
                  RoleCustomizationPanel(
                    roleId: _selectedRoleId!,
                    config: _getRoleConfig(_selectedRoleId!),
                    isDark: widget.isDark,
                    isEditing: _isEditing,
                    selectedWorkflowId: _selectedWorkflowId,
                    availableWorkflowSteps: _availableWorkflowSteps,
                    stepDisplayNames: _stepDisplayNames,
                    selectedStepsFromPermissions: _selectedStepsFromPermissions,
                    allOrderPaths: allOrderPaths,
                    hasCustomization: _rolesConfig.containsKey(_selectedRoleId!),
                    onWorkflowChanged: (val) {
                      setState(() {
                        _selectedWorkflowId = val;
                        final workflowState = context.read<WorkflowManagementBloc>().state;
                        final configs = workflowState.listState.maybeWhen(
                          success: (list) => list ?? [],
                          orElse: () => <WorkflowConfigModel>[],
                        );
                        _loadStepsFromPermissions(_selectedRoleId!, val, configs);
                        _updateRoleConfig(
                          _selectedRoleId!,
                          _getRoleConfig(_selectedRoleId!).copyWith(
                            selectedWorkflowId: val,
                            allowedSteps: List.from(_selectedStepsFromPermissions),
                            allowedPaths: const [],
                          ),
                        );
                      });
                    },
                    onStepSelected: (stepKey, isSelected) {
                      setState(() {
                        if (isSelected) {
                          _selectedStepsFromPermissions.add(stepKey);
                        } else {
                          _selectedStepsFromPermissions.remove(stepKey);
                        }
                        _updateRoleConfig(
                          _selectedRoleId!,
                          _getRoleConfig(_selectedRoleId!).copyWith(
                            allowedSteps: List.from(_selectedStepsFromPermissions),
                          ),
                        );
                      });
                    },
                    onConfigUpdated: (updatedConfig) {
                      _updateRoleConfig(_selectedRoleId!, updatedConfig);
                    },
                    onRemoveCustomization: () {
                      _removeRoleConfig(_selectedRoleId!);
                    },
                    onApply: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ تم تطبيق إعدادات الدور"),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                if (_rolesConfig.isNotEmpty) ...[
                  const Divider(height: 32),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "الأدوار المكونة حالياً:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._rolesConfig.entries.map((entry) {
                    final role = allRoles.where(
                      (r) => r.id == entry.key || r.name == entry.key,
                    ).firstOrNull;
                    final roleName = role?.displayName ?? role?.name ?? entry.key;
                    return ConfiguredRoleChip(
                      roleName: roleName,
                      roleId: entry.key,
                      config: entry.value,
                      isDark: widget.isDark,
                      onTap: () {
                        setState(() {
                          _selectedRoleId = entry.key;
                          final savedConfig = entry.value;
                          if (savedConfig.selectedWorkflowId != null) {
                            final workflowState = context.read<WorkflowManagementBloc>().state;
                            final configs = workflowState.listState.maybeWhen(
                              success: (list) => list ?? [],
                              orElse: () => <WorkflowConfigModel>[],
                            );
                            _loadStepsFromPermissions(entry.key, savedConfig.selectedWorkflowId, configs);
                          } else {
                            _selectedWorkflowId = null;
                            _availableWorkflowSteps = [];
                            _stepDisplayNames = {};
                            _selectedStepsFromPermissions = [];
                          }
                        });
                      },
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
