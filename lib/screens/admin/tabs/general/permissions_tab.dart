import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/core/auth/data/permission_model.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';

class PermissionsTab extends StatefulWidget {
  final bool isDark;

  const PermissionsTab({super.key, required this.isDark});

  @override
  State<PermissionsTab> createState() => _PermissionsTabState();
}

class _PermissionsTabState extends State<PermissionsTab> {
  List<PermissionModel> _permissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final rolesBloc = context.read<RolesBloc>();
    final result = await rolesBloc.repo.getAllPermissions();
    if (mounted) {
      setState(() {
        _permissions = result.data ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissions.isEmpty) {
      return const Center(child: Text("لا توجد صلاحيات معرفة في النظام"));
    }

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
          child: GridView.builder(
            itemCount: _permissions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
            ),
            itemBuilder: (context, index) {
              final perm = _permissions[index];
              return PermissionCardItem(
                permission: perm,
                isDark: widget.isDark,
              );
            },
          ),
        );
      },
    );
  }
}

class PermissionCardItem extends StatelessWidget {
  final PermissionModel permission;
  final bool isDark;

  const PermissionCardItem({
    super.key,
    required this.permission,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;

    // Get localized names from SystemFeatures and SystemJobs
    final resourceKey = permission.resource.toRawString();
    final jobKey = permission.type.name;

    final resourceName =
        resourceKey == 'screen.policies' || resourceKey == 'policies'
        ? 'سياسات المتجر'
        : (SystemFeatures.translations[resourceKey]?['ar'] ?? resourceKey);
    final jobName = SystemJobs.translations[jobKey]?['ar'] ?? jobKey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? DarkColors.surface : LightColors.surface,
        border: Border.all(
          color: isDark
              ? DarkColors.divider.withOpacity(0.1)
              : LightColors.divider.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  permission.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            permission.permissionKey,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildTag(context, resourceName, primaryColor),
              const SizedBox(width: 4),
              _buildTag(context, jobName, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
