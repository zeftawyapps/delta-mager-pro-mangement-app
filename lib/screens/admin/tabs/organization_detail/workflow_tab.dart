import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';

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
  final String _entityType =
      'orders'; // Fixed to orders as requested to remove selection
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
          SingleChildScrollView(
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "خطوات مسار العمل",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(config.workflow.steps.length, (index) {
            final step = config.workflow.steps[index];
            final isLast = index == config.workflow.steps.length - 1;
            return _buildTimelineStep(step, primaryColor, isLast);
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
                "المنفذ الأساسي لهذا المسار",
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

  Widget _buildTimelineStep(
    WorkflowStep step,
    Color primaryColor,
    bool isLast,
  ) {
    final stepColor = _getStepColor(step);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: stepColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: stepColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    step.stepNumber.toString(),
                    style: TextStyle(
                      color: stepColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDark ? DarkColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: stepColor.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step.stepName.ar,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stepColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            step.statusTag,
                            style: TextStyle(
                              color: stepColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow(Icons.security, "الدور", step.stepRole),
                    _buildStepRow(
                      Icons.touch_app,
                      "الإسناد",
                      step.selectionMode,
                    ),
                    _buildStepRow(Icons.group, "الهدف", step.targetType),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "الإجراءات المتاحة (${step.actions.length}):",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddActionDialog(step),
                          icon: const Icon(Icons.add_circle_outline, size: 14),
                          label: const Text(
                            "إضافة إجراء",
                            style: TextStyle(fontSize: 11),
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (step.actions.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: step.actions
                            .map((action) => _buildActionChip(action))
                            .toList(),
                      )
                    else
                      Text(
                        "لا توجد إجراءات مضافة لهذه الخطوة من الـ API حالياً",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(WorkflowAction action) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.herbGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.herbGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flash_on, size: 14, color: AppColors.herbGreen),
              const SizedBox(width: 6),
              Text(
                action.actionName.ar,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.herbGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.subdirectory_arrow_right,
                size: 12,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                "الوجهة: ",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  action.actionReturnToStepKey,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStepColor(WorkflowStep step) {
    // 1. If API color is provided and it's NOT the default black, use it
    if (step.stepColor != null &&
        step.stepColor!.isNotEmpty &&
        step.stepColor != '#000000' &&
        step.stepColor != '0x000000') {
      try {
        String hex = step.stepColor!.replaceAll('#', '').replaceAll('0x', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      } catch (_) {}
    }

    // 2. Semantic Fallbacks based on stepKey (Very important for visual distinction)
    final key = step.stepKey.toLowerCase();
    if (key.contains('start')) return Colors.blue;
    if (key.contains('processing') || key.contains('prepare'))
      return Colors.orange;
    if (key.contains('ship') || key.contains('delivery'))
      return Colors.deepPurple;
    if (key.contains('complete') ||
        key.contains('success') ||
        key.contains('done'))
      return Colors.green;
    if (key.contains('cancel') || key.contains('reject')) return Colors.red;
    if (key.contains('claim') || key.contains('accept')) return Colors.teal;

    // 3. Fallback based on step number if no key matches
    final List<Color> palette = [
      Colors.blue,
      Colors.orange,
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return palette[(step.stepNumber - 1) % palette.length];
  }

  void _showAddActionDialog(WorkflowStep step) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "إضافة إجراء جديد لخطوة: ${step.stepName.ar} (قيد التطوير)",
        ),
      ),
    );
  }

  void _showAddStepDialog(WorkflowConfigModel config) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("هذه الميزة قيد التطوير")));
  }
}
