import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/user_input_form.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/tabs/general/users_tab.dart';

class CustomersTab extends StatefulWidget {
  final bool isDark;
  final String? organizationIdFromRoute;
  final double childAspectRatio;
  final int crossAxisCountSmall;
  final int crossAxisCountMedium;
  final int crossAxisCountLarge;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final String? noDataMessage;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool canAdd;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final String? restorationId;
  final Clip clipBehavior;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final int debounceMs;
  final String? searchHint;
  final bool Function(UserViewProfileModel)? where;

  const CustomersTab({
    super.key,
    required this.isDark,
    this.organizationIdFromRoute,
    this.childAspectRatio = UserGridConfigs.childAspectRatio,
    this.crossAxisCountSmall = UserGridConfigs.crossAxisCountSmall,
    this.crossAxisCountMedium = UserGridConfigs.crossAxisCountMedium,
    this.crossAxisCountLarge = UserGridConfigs.crossAxisCountLarge,
    this.crossAxisSpacing = UserGridConfigs.crossAxisSpacing,
    this.mainAxisSpacing = UserGridConfigs.mainAxisSpacing,
    this.padding = UserGridConfigs.padding,
    this.noDataMessage = UserGridConfigs.noDataMessage,
    this.physics = UserGridConfigs.physics,
    this.shrinkWrap = UserGridConfigs.shrinkWrap,
    this.scrollController,
    this.canAdd = false,
    this.addAutomaticKeepAlives = UserGridConfigs.addAutomaticKeepAlives,
    this.addRepaintBoundaries = UserGridConfigs.addRepaintBoundaries,
    this.addSemanticIndexes = UserGridConfigs.addSemanticIndexes,
    this.cacheExtent = UserGridConfigs.cacheExtent,
    this.restorationId = UserGridConfigs.restorationId,
    this.clipBehavior = UserGridConfigs.clipBehavior,
    this.scrollDirection = UserGridConfigs.scrollDirection,
    this.reverse = UserGridConfigs.reverse,
    this.primary = UserGridConfigs.primary,
    this.debounceMs = UserGridConfigs.debounceMs,
    this.searchHint = "بحث في العملاء...",
    this.where,
  });

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersBloc>().loadCustomersByRole();
    });
  }

  void _addCustomer() {
    showCustomInputDialog(
      context: context,
      content: const UserInputForm(isCustomer: true),
      height: 700,
      width: 600,
      onResult: (result) {
        context.read<UsersBloc>().loadCustomersByRole();
      },
    );
  }

  void _editCustomer(UserViewProfileModel user) {
    showCustomInputDialog(
      context: context,
      content: UserInputForm(
        user: user,
        isCustomer: true,
      ),
      height: 700,
      width: 600,
      onResult: (result) {
        context.read<UsersBloc>().loadCustomersByRole();
      },
    );
  }

  void _toggleUserStatus(UserViewProfileModel user) {
    if (user.isActiveProfile) {
      context.read<UsersBloc>().deactivateUser(
        user.userId,
      );
    } else {
      context.read<UsersBloc>().activateUser(
        user.userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.watch<AppChangesValues>();
    final user = appConfig.user;

    final bool canAdd = false;
    final canUpdate = user?.can(SystemFeatures.user, SystemJobs.update) ?? true;

    final configBloc = context.watch<OrganizationConfigBloc>();
    final featureConfig = configBloc.state.itemState.maybeWhen(
      success: (data) => data?.feature?.users,
      orElse: () => null,
    );

    return MasterGrid<UserViewProfileModel, UsersBloc>(
      title: "الزبائن",
      viewMode: ViewMode.list,
      childAspectRatio: 9,
      searchHint: widget.searchHint,
      onItemTap: _editCustomer,
      where: widget.where,
      itemBuilder: (context, userItem, isSelected) => UserCardItem(
        user: userItem,
        isDark: widget.isDark,
        onEdit: () => _editCustomer(userItem),
        onToggleStatus: () => _toggleUserStatus(userItem),
        canUpdate: canUpdate,
      ),
      canMultiSelect: true,
      onAdd: _addCustomer,
      onLoad: (bloc) => bloc.loadCustomersByRole(),
      onSearch: (bloc, query) => bloc.searchCustomersByRole(query),
      canAdd: canAdd,
      showAddInGrid: featureConfig?.showAddInGrid ?? false,
      crossAxisCountSmall:
          featureConfig?.crossAxisCountSmall ?? widget.crossAxisCountSmall,
      crossAxisCountMedium:
          featureConfig?.crossAxisCountMedium ?? widget.crossAxisCountMedium,
      crossAxisCountLarge:
          featureConfig?.crossAxisCountLarge ?? widget.crossAxisCountLarge,
      crossAxisSpacing:
          featureConfig?.crossAxisSpacing ?? widget.crossAxisSpacing,
      mainAxisSpacing: featureConfig?.mainAxisSpacing ?? widget.mainAxisSpacing,
      padding: featureConfig?.padding != null
          ? EdgeInsets.fromLTRB(
              featureConfig!.padding![3],
              featureConfig.padding![0],
              featureConfig.padding![1],
              featureConfig.padding![2],
            )
          : widget.padding,
      noDataMessage: widget.noDataMessage ?? 'لا يوجد زبائن',
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      scrollController: widget.scrollController,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      debounceMs: widget.debounceMs,
    );
  }
}
