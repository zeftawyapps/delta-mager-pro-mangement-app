import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import '../models/role_orders_config.dart';

class ConfiguredRoleChip extends StatelessWidget {
  final String roleName;
  final String roleId;
  final RoleOrdersConfig config;
  final VoidCallback onTap;
  final bool isDark;

  const ConfiguredRoleChip({
    super.key,
    required this.roleName,
    required this.roleId,
    required this.config,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;
    final features = <String>[
      if (config.showSenderInfo) "مرسل",
      if (config.showRecipientInfo) "مستلم",
      if (config.showItems) "منتجات",
      if (config.showPrice) "سعر",
      if (config.canEditOrder) "تعديل",
      if (config.canCancelOrder) "إلغاء",
      if (config.canAssignOrder) "تعيين",
      if (config.selectedWorkflowId != null) "سير عمل",
      if (config.allowedSteps.isNotEmpty) "${config.allowedSteps.length} خطوة",
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 18, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  features.isEmpty 
                      ? "بدون صلاحيات محددة" 
                      : features.join(' · '),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
            onPressed: onTap,
            tooltip: "عرض التفاصيل والتعديل",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
