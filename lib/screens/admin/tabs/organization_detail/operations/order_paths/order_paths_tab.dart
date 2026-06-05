import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/order_path_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';

import 'widgets/order_path_card_item.dart';
import 'widgets/order_path_editor_dialog.dart';

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
  @override
  void initState() {
    super.initState();
    // Load workflows and governorates to ensure they are available in memory
    context.read<WorkflowManagementBloc>().loadSpecificConfig(widget.organizationId);
    
    final locationsBloc = context.read<LocationsBloc>();
    locationsBloc.loadGovernorates('EG').then((_) {
      locationsBloc.state.governoratesState.maybeWhen(
        success: (list) {
          if (list != null) {
            for (var gov in list) {
              locationsBloc.loadCities(gov.id);
            }
          }
        },
        orElse: () {},
      );
    });
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => OrderPathEditorDialog(
        organizationId: widget.organizationId,
        isDark: widget.isDark,
      ),
    );
  }

  void _showEditDialog(OrderPathModel path) {
    showDialog(
      context: context,
      builder: (context) => OrderPathEditorDialog(
        path: path,
        organizationId: widget.organizationId,
        isDark: widget.isDark,
      ),
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
      childAspectRatio: 6,
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
