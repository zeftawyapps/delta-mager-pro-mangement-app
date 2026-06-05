import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';

class OrderPathCardItem extends StatefulWidget {
  final OrderPathModel path;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final bool canUpdate;

  const OrderPathCardItem({
    super.key,
    required this.path,
    required this.isDark,
    required this.onEdit,
    required this.onToggleStatus,
    required this.canUpdate,
  });

  @override
  State<OrderPathCardItem> createState() => _OrderPathCardItemState();
}

class _OrderPathCardItemState extends State<OrderPathCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    final locState = context.watch<LocationsBloc>().state;

    // Get region names dynamically
    final regionNames = widget.path.regions.map((id) {
      final cityName = locState.getCityName(id);
      if (cityName.isNotEmpty) return cityName;
      final govName = locState.getGovernorateName(id);
      if (govName.isNotEmpty) return govName;
      return id; // Fallback to ID if name not loaded
    }).toList();

    // Helper to format schedule text in Arabic
    String getScheduleText() {
      final schedule = widget.path.schedule;
      if (schedule == null) return "نشط دائماً";
      if (schedule.type == 'always') return "نشط دائماً";
      if (schedule.type == 'daily') return "يومي";
      if (schedule.type == 'weekly') {
        const Map<int, String> weekDays = {
          6: 'السبت',
          7: 'الأحد',
          1: 'الإثنين',
          2: 'الثلاثاء',
          3: 'الأربعاء',
          4: 'الخميس',
          5: 'الجمعة',
        };
        final dayNames = schedule.values.map((v) => weekDays[v] ?? '').where((n) => n.isNotEmpty).toList();
        if (dayNames.isEmpty) return "أسبوعي";
        return "أسبوعي: ${dayNames.join('، ')}";
      }
      return "جدول: ${schedule.type}";
    }

    final wfState = context.watch<WorkflowManagementBloc>().state;
    final configs = wfState.listState.maybeWhen(
      success: (list) => list ?? [],
      orElse: () => <WorkflowConfigModel>[],
    );

    // Get human-readable workflow config name instead of its raw slug
    String getWorkflowName() {
      final slug = widget.path.workflowSlug;
      if (slug == null) return "";
      try {
        final config = configs.firstWhere((c) => c.workflowSlug == slug);
        return config.workflow.workflowName.ar;
      } catch (_) {
        return slug;
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.canUpdate
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isDark ? DarkColors.surface : LightColors.surface,
            border: Border.all(
              color: _isHovered
                  ? primaryColor.withOpacity(0.5)
                  : (widget.isDark
                        ? DarkColors.divider.withOpacity(0.1)
                        : LightColors.divider.withOpacity(0.1)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.route, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.path.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (regionNames.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: regionNames.map((name) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.15),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 10,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: (widget.isDark
                                            ? DarkColors.textSecondary
                                            : LightColors.textSecondary)
                                        .withOpacity(0.9),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "لا يوجد مناطق مغطاة",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled_outlined,
                          size: 11,
                          color: Colors.orange.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          getScheduleText(),
                          style: TextStyle(
                            color: (widget.isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary)
                                .withOpacity(0.8),
                             fontSize: 11,
                          ),
                        ),
                        if (widget.path.workflowSlug != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.account_tree_outlined,
                            size: 11,
                            color: Colors.blue.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getWorkflowName(),
                            style: TextStyle(
                              color: (widget.isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary)
                                  .withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.path.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.path.isActive ? 'نشط' : 'معطل',
                      style: TextStyle(
                        color: widget.path.isActive
                            ? Colors.green
                            : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.canUpdate)
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          widget.path.isActive
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          color: widget.path.isActive
                              ? Colors.orange
                              : Colors.green,
                          size: 18,
                        ),
                        onPressed: widget.onToggleStatus,
                        tooltip: widget.path.isActive
                            ? 'تعطيل'
                            : 'تفعيل',
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
