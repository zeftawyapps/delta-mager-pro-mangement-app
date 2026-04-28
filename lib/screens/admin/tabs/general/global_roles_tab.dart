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

class GlobalRolesTab extends StatefulWidget {
  final bool isDark;

  const GlobalRolesTab({super.key, required this.isDark});

  @override
  State<GlobalRolesTab> createState() => _GlobalRolesTabState();
}

class _GlobalRolesTabState extends State<GlobalRolesTab> {
  List<PermissionModel> _allPermissions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolesBloc>().loadRoles(organizationId: null);
      _loadPermissions();
    });
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
      content: const RoleInputForm(organizationId: null),
      height: 700,
      width: 900,
      onResult: (result) {
        context.read<RolesBloc>().loadRoles(organizationId: null);
      },
    );
  }

  void _editRole(RoleModel role) {
    showCustomInputDialog(
      context: context,
      content: RoleInputForm(organizationId: null, role: role),
      height: 700,
      width: 600,
      onResult: (result) {
        context.read<RolesBloc>().loadRoles(organizationId: null);
      },
    );
  }

  void _copyRole(RoleModel role) {
    showCustomInputDialog(
      context: context,
      content: RoleInputForm(
        organizationId: null,
        role: role,
        isCopy: true,
      ),
      height: 700,
      width: 900,
      onResult: (result) {
        // We might want to reload roles or show success
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
                    organizationId: null,
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
            return LayoutBuilder(
              builder: (context, constraints) {
                final layoutWidth = constraints.maxWidth;
                final crossAxisCount = layoutWidth < 650
                    ? 2
                    : layoutWidth < 900
                    ? 3
                    : 4;

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GridViewModel<RoleModel>(
                    data: roles ?? [],
                    canAdd: false,
                    listItem: (index, role) {
                      final isMainRole = ['admin', 'org_owner', 'customer', 'organization_owner', 'super_admin'].contains(role.name.toLowerCase());
                      return RoleCardItem(
                        role: role,
                        allPermissions: _allPermissions,
                        isDark: widget.isDark,
                        onTap: () => _editRole(role),
                        onDelete: isMainRole ? null : () => _deleteRole(role),
                        onCopy: isMainRole ? null : () => _copyRole(role),
                        isReadOnly: isMainRole,
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
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
                    onPressed: () => context.read<RolesBloc>().loadRoles(
                      organizationId: null,
                    ),
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

class RoleCardItem extends StatefulWidget {
  final RoleModel role;
  final List<PermissionModel> allPermissions;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final bool isReadOnly;

  const RoleCardItem({
    super.key,
    required this.role,
    required this.allPermissions,
    required this.isDark,
    this.onTap,
    this.onDelete,
    this.onCopy,
    this.isReadOnly = false,
  });

  @override
  State<RoleCardItem> createState() => _RoleCardItemState();
}

class _RoleCardItemState extends State<RoleCardItem> {
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
                    Icon(
                      widget.isReadOnly ? Icons.lock_outline : Icons.security,
                      color: widget.isReadOnly ? Colors.orange : primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        role.displayName ?? role.name,
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
                    if (widget.onCopy != null)
                      IconButton(
                        onPressed: widget.onCopy,
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'نسخ الدور لمنظمة',
                      ),
                    const SizedBox(width: 8),
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
                  role.description ?? "لا يوجد وصف",
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
                        role.permissions.take(5).map((permKey) {
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
                          if (role.permissions.length > 5)
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
                                "+${role.permissions.length - 5}",
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
                      "${role.permissions.length} صلاحية",
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (role.isActive)
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

  RoleModel get role => widget.role;
}
