import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/user_input_form.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:matger_core_logic/core/auth/utils/permission_manager.dart';
import 'package:matger_core_logic/core/auth/utils/permission_constants.dart';

class UsersTab extends StatefulWidget {
  final bool isDark;
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

  const UsersTab({
    super.key,
    required this.isDark,
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
    this.canAdd = UserGridConfigs.canAdd,
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
    this.searchHint = UserGridConfigs.searchHint,
  });

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  @override
  void initState() {
    super.initState();
  }

  String? _getOrgId() {
    final isAdmin = AppShellConfigs.isAdminMode;
    if (isAdmin) return null;

    final authState = context.read<AuthBloc>().state;
    return authState.itemState.maybeWhen(
      success: (user) => user?.organizationId,
      orElse: () => null,
    );
  }

  void _addUser() {
    final orgId = _getOrgId();
    showCustomInputDialog(
      context: context,
      content: UserInputForm(organizationId: orgId),
      height: 700,
      width: 600,
      onResult: (result) {
        context.read<UsersBloc>().loadUsers(organizationId: orgId);
      },
    );
  }

  void _editUser(UserViewProfileModel user) {
    final orgId = _getOrgId();
    showCustomInputDialog(
      context: context,
      content: UserInputForm(user: user, organizationId: orgId),
      height: 700,
      width: 600,
      onResult: (result) {
        context.read<UsersBloc>().loadUsers(organizationId: orgId);
      },
    );
  }

  void _toggleUserStatus(UserViewProfileModel user) {
    final orgId = _getOrgId();
    if (user.isActiveProfile) {
      context.read<UsersBloc>().deactivateUser(
        user.userId,
        organizationId: orgId,
      );
    } else {
      context.read<UsersBloc>().activateUser(
        user.userId,
        organizationId: orgId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.watch<AppChangesValues>();
    final user = appConfig.user;
    final canAdd = user?.can(SystemFeatures.user, SystemJobs.add) ?? widget.canAdd;
    final canUpdate = user?.can(SystemFeatures.user, SystemJobs.update) ?? true;

    final configBloc = context.watch<OrganizationConfigBloc>();
    final featureConfig = configBloc.state.itemState.maybeWhen(
      success: (data) => data?.feature?.users,
      orElse: () => null,
    );

    return MasterGrid<UserViewProfileModel, UsersBloc>(
      title: "المستخدمين",
      searchHint: widget.searchHint,
      itemBuilder: (context, userItem) => UserCardItem(
        user: userItem,
        isDark: widget.isDark,
        onEdit: () => _editUser(userItem),
        onToggleStatus: () => _toggleUserStatus(userItem),
        canUpdate: canUpdate,
      ),
      onAdd: _addUser,
      onLoad: (bloc) => bloc.loadUsers(organizationId: _getOrgId()),
      onSearch: (bloc, query) =>
          bloc.searchUsers(query, organizationId: _getOrgId()),
      canAdd: canAdd,
      childAspectRatio:
          featureConfig?.childAspectRatio ?? widget.childAspectRatio,
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
      noDataMessage: widget.noDataMessage ?? 'لا يوجد مستخدمين',
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

class UserCardItem extends StatefulWidget {
  final UserViewProfileModel user;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final bool canUpdate;

  const UserCardItem({
    super.key,
    required this.user,
    required this.isDark,
    required this.onEdit,
    required this.onToggleStatus,
    this.canUpdate = true,
  });

  @override
  State<UserCardItem> createState() => _UserCardItemState();
}

class _UserCardItemState extends State<UserCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.canUpdate ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.canUpdate ? widget.onEdit : null,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isDark ? DarkColors.surface : LightColors.surface,
              border: Border.all(
                color: _isHovered
                    ? primaryColor
                    : (widget.isDark
                          ? DarkColors.divider.withOpacity(0.1)
                          : LightColors.divider.withOpacity(0.1)),
              ),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.username,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.user.email,
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.canUpdate)
                      IconButton(
                        icon: Icon(
                          widget.user.isActiveProfile
                              ? Icons.check_circle
                              : Icons.do_not_disturb_on,
                          color: widget.user.isActiveProfile
                              ? Colors.green
                              : Colors.grey,
                          size: 20,
                        ),
                        onPressed: widget.onToggleStatus,
                        tooltip: widget.user.isActiveProfile
                            ? 'تعطيل المستخدم'
                            : 'تفعيل المستخدم',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.user.phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.user.phone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: widget.user.roles.map((role) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.user.isActiveProfile ? "نشط" : "غير نشط",
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.user.isActiveProfile
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
