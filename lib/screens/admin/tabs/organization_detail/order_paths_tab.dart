import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/order_path_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';

class OrderPathsSectionTab extends StatefulWidget {
  final String organizationId;
  final bool isDark;

  const OrderPathsSectionTab({
    super.key,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<OrderPathsSectionTab> createState() => _OrderPathsSectionTabState();
}

class _OrderPathsSectionTabState extends State<OrderPathsSectionTab> {
  void _showCreateDialog() {
    final nameController = TextEditingController();
    final regionsController = TextEditingController();
    final slugController = TextEditingController();
    final stepController = TextEditingController();
    bool autoAssign = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_road, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("إنشاء خط سير جديد"),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "اسم خط السير *",
                          hintText: "مثال: خط القاهرة - الجيزة",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.label_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: regionsController,
                        decoration: InputDecoration(
                          labelText: "المناطق (IDs) *",
                          hintText: "أدخل IDs المناطق مفصولة بفواصل",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          helperText: "مثال: 65f1..., 65f2..., 65f3...",
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: slugController,
                        decoration: InputDecoration(
                          labelText: "كود الـ Workflow (Slug)",
                          hintText: "مثال: delivery-workflow",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.account_tree_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: stepController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "رقم خطوة الربط (Trigger Step)",
                          hintText: "مثال: 3",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.flag_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("الربط التلقائي"),
                        subtitle: const Text(
                          "ربط الطلبات بالخط آلياً عند التطابق الجغرافي",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: autoAssign,
                        onChanged: (val) {
                          setDialogState(() => autoAssign = val);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        regionsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("يرجى إدخال اسم الخط والمناطق"),
                        ),
                      );
                      return;
                    }

                    final regions = regionsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    context.read<OrderPathBloc>().createOrderPath(
                          organizationId: widget.organizationId,
                          name: nameController.text.trim(),
                          regions: regions,
                          workflowSlug: slugController.text.trim().isNotEmpty
                              ? slugController.text.trim()
                              : null,
                          triggerStepNumber:
                              stepController.text.trim().isNotEmpty
                                  ? int.tryParse(stepController.text.trim())
                                  : null,
                          autoAssign: autoAssign,
                        );
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LightColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("إنشاء"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(OrderPathModel path) {
    final nameController = TextEditingController(text: path.name);
    final regionsController =
        TextEditingController(text: path.regions.join(', '));
    final slugController =
        TextEditingController(text: path.workflowSlug ?? '');
    final stepController = TextEditingController(
      text: path.triggerStepNumber?.toString() ?? '',
    );
    bool autoAssign = path.autoAssign;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.edit_road, color: Colors.orange),
                  SizedBox(width: 10),
                  Text("تعديل خط السير"),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "اسم خط السير",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.label_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: regionsController,
                        decoration: InputDecoration(
                          labelText: "المناطق (IDs)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: slugController,
                        decoration: InputDecoration(
                          labelText: "كود الـ Workflow (Slug)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.account_tree_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: stepController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "رقم خطوة الربط (Trigger Step)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.flag_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("الربط التلقائي"),
                        subtitle: const Text(
                          "ربط الطلبات بالخط آلياً عند التطابق الجغرافي",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: autoAssign,
                        onChanged: (val) {
                          setDialogState(() => autoAssign = val);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final regions = regionsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    context.read<OrderPathBloc>().updateOrderPath(
                          pathId: path.id,
                          organizationId: widget.organizationId,
                          name: nameController.text.trim().isNotEmpty
                              ? nameController.text.trim()
                              : null,
                          regions: regions.isNotEmpty ? regions : null,
                          workflowSlug:
                              slugController.text.trim().isNotEmpty
                                  ? slugController.text.trim()
                                  : null,
                          triggerStepNumber:
                              stepController.text.trim().isNotEmpty
                                  ? int.tryParse(stepController.text.trim())
                                  : null,
                          autoAssign: autoAssign,
                        );
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("حفظ التعديلات"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _togglePathStatus(OrderPathModel path) {
    context.read<OrderPathBloc>().updateOrderPath(
          pathId: path.id,
          organizationId: widget.organizationId,
          isActive: !path.isActive,
        );
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.watch<AppChangesValues>();
    final user = appConfig.user;
    
    // Check permissions
    final canAdd = user?.can(SystemFeatures.orderPath, SystemJobs.add) ?? true;
    final canUpdate = user?.can(SystemFeatures.orderPath, SystemJobs.update) ?? true;

    final configBloc = context.watch<OrganizationConfigBloc>();
    final featureConfig = configBloc.state.itemState.maybeWhen(
      success: (data) => data?.feature?.orderPaths,
      orElse: () => null,
    );

    return MasterGrid<OrderPathModel, OrderPathBloc>(
      title: "خطوط السير",
      viewMode: ViewMode.list,
      childAspectRatio: 9,
      onItemTap: (path) => _showEditDialog(path),
      itemBuilder: (context, path, isSelected) => OrderPathCardItem(
        path: path,
        isDark: widget.isDark,
        onEdit: () => _showEditDialog(path),
        onToggleStatus: () => _togglePathStatus(path),
        canUpdate: canUpdate,
      ),
      onAdd: _showCreateDialog,
      onLoad: (bloc) => bloc.loadOrderPaths(widget.organizationId),
      onSearch: (bloc, query) =>
          bloc.searchOrderPaths(query, organizationId: widget.organizationId),
      canAdd: canAdd,
      showAddInGrid: featureConfig?.showAddInGrid ?? true,
      crossAxisCountSmall: featureConfig?.crossAxisCountSmall ?? 1,
      crossAxisCountMedium: featureConfig?.crossAxisCountMedium ?? 1,
      crossAxisCountLarge: featureConfig?.crossAxisCountLarge ?? 2,
      crossAxisSpacing: featureConfig?.crossAxisSpacing ?? 16.0,
      mainAxisSpacing: featureConfig?.mainAxisSpacing ?? 16.0,
      noDataMessage: 'لا يوجد خطوط سير',
    );
  }
}

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
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: (widget.isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary)
                              .withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.path.regions.length} مناطق",
                          style: TextStyle(
                            color: (widget.isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary)
                                .withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                        if (widget.path.workflowSlug != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.account_tree_outlined,
                            size: 10,
                            color: (widget.isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary)
                                .withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.path.workflowSlug!,
                            style: TextStyle(
                              color: (widget.isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary)
                                  .withOpacity(0.7),
                              fontSize: 10,
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
