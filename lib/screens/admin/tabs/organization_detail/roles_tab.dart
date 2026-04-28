import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/grid_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/role_input_form.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:matger_pro_core_logic/core/auth/data/permission_model.dart';

class RolesSectionTab extends StatefulWidget {
  final String organizationId;
  final bool isDark;

  const RolesSectionTab({
    super.key,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<RolesSectionTab> createState() => _RolesSectionTabState();
}

class _RolesSectionTabState extends State<RolesSectionTab> {
  List<PermissionModel> _allPermissions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPermissions();
  }

  void _loadData() {
    context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
  }

  Future<void> _loadPermissions() async {
    final rolesBloc = context.read<RolesBloc>();
    final result = await rolesBloc.repo.getAllPermissions();
    if (mounted) {
      setState(() {
        _allPermissions = result.data ?? [];
      });
    }
  }

  void _addRole() {
    showCustomInputDialog(
      context: context,
      content: RoleInputForm(organizationId: widget.organizationId),
      height: 700,
      width: 900,
      onResult: (result) {
        _loadData();
      },
    );
  }

  void _editRole(RoleModel role) {
    showCustomInputDialog(
      context: context,
      content: RoleInputForm(organizationId: widget.organizationId, role: role),
      height: 700,
      width: 900,
      onResult: (result) {
        _loadData();
      },
    );
  }

  void _deleteRole(RoleModel role) {
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
            'هل أنت متأكد من حذف دور "${role.displayName ?? role.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: widget.isDark ? Colors.white70 : Colors.grey,
                ),
              ),
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
                if (role.id != null) {
                  context.read<RolesBloc>().deleteRole(
                    role.id!,
                    organizationId: widget.organizationId,
                  );
                }
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RolesBloc, FeaturDataSourceState<RoleModel>>(
      builder: (context, state) {
        return state.listState.when(
          init: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (roles) {
            // Filter roles: Hide system roles (admin, customer, organizationowner) from org view
            final filteredRoles = (roles ?? []).where((role) {
              final name = role.name.toLowerCase();
              return name != 'admin' &&
                  name != 'customer' &&
                  name != 'organizationowner';
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final layoutWidth = constraints.maxWidth;
                final crossAxisCount = layoutWidth < 650
                    ? 2
                    : layoutWidth < 900
                    ? 3
                    : 4;

                return GridViewModel<RoleModel>(
                  data: filteredRoles,
                  canAdd: true,
                  onAdd: _addRole,
                  listItem: (index, role) {
                    return OrgRoleCardItem(
                      role: role,
                      allPermissions: _allPermissions,
                      isDark: widget.isDark,
                      onTap: () => _editRole(role),
                      onDelete: () => _deleteRole(role),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                );
              },
            );
          },
          failure: (error, callback) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.message ?? 'حدث خطأ',
                    style: const TextStyle(color: Colors.orange),
                  ),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class OrgRoleCardItem extends StatefulWidget {
  final RoleModel role;
  final List<PermissionModel> allPermissions;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const OrgRoleCardItem({
    super.key,
    required this.role,
    required this.allPermissions,
    required this.isDark,
    this.onTap,
    this.onDelete,
  });

  @override
  State<OrgRoleCardItem> createState() => _OrgRoleCardItemState();
}

class _OrgRoleCardItemState extends State<OrgRoleCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
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
                    Icon(Icons.security, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.role.displayName ?? widget.role.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.onDelete != null)
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'حذف الدور',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.role.description ?? "لا يوجد وصف",
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        widget.role.permissions.take(5).map((permKey) {
                          final perm = widget.allPermissions
                              .cast<dynamic>()
                              .firstWhere(
                                (p) => p.permissionKey == permKey,
                                orElse: () => null,
                              );
                          final displayName = perm != null
                              ? perm.name
                              : (permKey.contains(':')
                                    ? permKey.split(':').last
                                    : permKey);
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
                              displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList()..addAll([
                          if (widget.role.permissions.length > 5)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "+${widget.role.permissions.length - 5}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ]),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.role.permissions.length} صلاحية",
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.role.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "نشط",
                          style: TextStyle(color: Colors.green, fontSize: 10),
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
