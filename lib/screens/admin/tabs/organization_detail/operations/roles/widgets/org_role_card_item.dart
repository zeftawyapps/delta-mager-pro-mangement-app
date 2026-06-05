import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';
import 'package:matger_pro_core_logic/core/auth/data/permission_model.dart';

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
