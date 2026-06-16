import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';

// New Input Forms
import 'package:delta_mager_pro_mangement_app/screens/inputs/workflow/workflow_step_form.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/workflow/workflow_action_form.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/workflow/create_workflow_form.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/workflow/workflow_triggers_form.dart';

import 'widgets/workflow_step_card.dart';

class WorkflowSectionTab extends StatefulWidget {
  final String organizationId;
  final bool isDark;

  const WorkflowSectionTab({
    super.key,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<WorkflowSectionTab> createState() => _WorkflowSectionTabState();
}

class _WorkflowSectionTabState extends State<WorkflowSectionTab> {
  final String _entityType = 'orders'; // Fixed to orders as requested to remove selection
  int _activeWorkflowIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<WorkflowManagementBloc>().loadSpecificConfig(
      widget.organizationId,
      entityType: _entityType,
    );
    context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    return BlocBuilder<
      WorkflowManagementBloc,
      FeaturDataSourceState<WorkflowConfigModel>
    >(
      builder: (context, state) {
        return state.listState.when(
          init: () => const SizedBox(),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (configs) {
            if (configs == null || configs.isEmpty) {
              return _buildEmptyState(primaryColor);
            }

            if (_activeWorkflowIndex >= configs.length) {
              _activeWorkflowIndex = 0;
            }

            return Column(
              children: [
                // Primary Navigation: Executors
                _buildExecutorHeader(configs, primaryColor),
                const Divider(height: 1),
                Expanded(
                  child: _buildWorkflowDetail(
                    configs[_activeWorkflowIndex],
                    primaryColor,
                  ),
                ),
              ],
            );
          },
          failure: (error, reload) {
            if (error.message?.contains("لم يتم العثور") ?? false) {
              return _buildEmptyState(primaryColor);
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error.message ?? "حدث خطأ ما"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: reload,
                    child: const Text("إعادة المحاولة"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExecutorHeader(
    List<WorkflowConfigModel> configs,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_outlined, size: 20, color: primaryColor),
              const SizedBox(width: 10),
              const Text(
                "مسارات العمل المتاحة:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(configs.length, (index) {
                      final isSelected = _activeWorkflowIndex == index;
                      final config = configs[index];

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: isSelected ? Colors.white : primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(config.roleExecutor),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (widget.isDark ? Colors.white : Colors.black87),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _activeWorkflowIndex = index);
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _showCreateWorkflowDialog(),
                icon: const Icon(Icons.add),
                label: const Text("إنشاء مسار عمل مخصص من الصفر"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text("لا يوجد مسارات عمل مُعرفه لهذه المنظمة"),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<WorkflowManagementBloc>().seedDefault(
                widget.organizationId,
                entityType: _entityType,
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text("تحقق من المسارات أو أنشئ المسار الافتراضي"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowDetail(WorkflowConfigModel config, Color primaryColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(config, primaryColor),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "خطوات مسار العمل",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddStepDialog(config),
                  icon: const Icon(Icons.add),
                  label: const Text("إضافة خطوة جديدة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(config.workflow.steps.length, (index) {
            final step = config.workflow.steps[index];
            final isLast = index == config.workflow.steps.length - 1;
            return WorkflowStepCard(
              config: config,
              step: step,
              primaryColor: primaryColor,
              isLast: isLast,
              isDark: widget.isDark,
              onEdit: () => _showEditStepDialog(config, step),
              onDelete: () => _showDeleteStepDialog(config, step),
              onAddAction: () => _showAddActionDialog(config, step),
              onConfigureTriggers: () => _showConfigureTriggersDialog(config, step),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(WorkflowConfigModel config, Color primaryColor) {
    final bgColor = widget.isDark ? DarkColors.surfaceVariant : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_tree_outlined,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.workflow.workflowName.ar,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Slug: ${config.workflowSlug}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(config.isActive),
            ],
          ),
          if (config.workflow.workflowDescription != null &&
              config.workflow.workflowDescription!.ar.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Text(
              config.workflow.workflowDescription!.ar,
              style: TextStyle(
                height: 1.5,
                color: widget.isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade700,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              _buildQuickInfo(
                Icons.person_outline,
                "المنفذ الأساسي لهذا مسار",
                config.roleExecutor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? "نشط" : "غير نشط",
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text("$label: $value", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showAddActionDialog(WorkflowConfigModel config, WorkflowStep step) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: WorkflowActionForm(
              config: config,
              step: step,
              organizationId: widget.organizationId,
              isDark: widget.isDark,
            ),
          ),
        );
      },
    ).then((_) {
      _loadData();
    });
  }

  void _showConfigureTriggersDialog(WorkflowConfigModel config, WorkflowStep step) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: WorkflowTriggersForm(
              config: config,
              step: step,
              organizationId: widget.organizationId,
              isDark: widget.isDark,
            ),
          ),
        );
      },
    ).then((_) {
      _loadData();
    });
  }

  void _showAddStepDialog(WorkflowConfigModel config) {
    _showStepFormDialog(config: config);
  }

  void _showEditStepDialog(WorkflowConfigModel config, WorkflowStep step) {
    _showStepFormDialog(config: config, step: step);
  }

  void _showDeleteStepDialog(WorkflowConfigModel config, WorkflowStep step) {
    showDialog(
      context: context,
      builder: (context) {
        final bgColor = widget.isDark ? DarkColors.surface : Colors.white;
        final textColor = widget.isDark ? DarkColors.textPrimary : LightColors.textPrimary;

        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                "تأكيد الحذف",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "هل أنت متأكد من حذف الخطوة \"${step.stepName.ar}\"؟ لا يمكن التراجع عن هذا الإجراء.",
            style: TextStyle(color: widget.isDark ? Colors.grey.shade300 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<WorkflowManagementBloc>().deleteStep(
                  organizationId: widget.organizationId,
                  stepNumber: step.stepNumber,
                  entityType: _entityType,
                  slug: config.workflowSlug,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );
  }

  void _showStepFormDialog({required WorkflowConfigModel config, WorkflowStep? step}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: WorkflowStepForm(
              config: config,
              step: step,
              organizationId: widget.organizationId,
              isDark: widget.isDark,
            ),
          ),
        );
      },
    ).then((_) {
      _loadData();
    });
  }

  void _showCreateWorkflowDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: CreateWorkflowForm(
              organizationId: widget.organizationId,
              isDark: widget.isDark,
            ),
          ),
        );
      },
    ).then((_) {
      _loadData();
    });
  }
}
