import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/grid_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/role_input_form.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:matger_pro_core_logic/core/auth/data/permission_model.dart';

import 'widgets/org_role_card_item.dart';

class RolesSectionTab extends StatefulWidget {
  final String organizationId;
  final bool isDark;

  const RolesSectionTab({
    key,
    required this.organizationId,
    required this.isDark,
  }) : super(key: key);

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
