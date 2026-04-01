import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:matger_core_logic/core/orgnization/data/organization_config.dart';

class LicenseSectionTab extends StatelessWidget {
  final SystemLicenseConfig? systemLicense;
  final bool isDark;

  const LicenseSectionTab({
    super.key,
    this.systemLicense,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (systemLicense == null) {
      return const Center(
        child: Text(
          "⚠️ لم يتم تحديد بيانات الترخيص لهذه المؤسسة.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLicenseHeader(),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "تفاصيل الترخيص",
            icon: Icons.assignment_outlined,
            children: [
              _buildListTile("نوع الترخيص", systemLicense!.licenseType, Icons.card_membership_outlined),
              _buildListTile("تاريخ الانتهاء", systemLicense!.expiryDate?.toIso8601String().split('T').first ?? "دائم", Icons.event_available),
              _buildListTile("الحد الأقصى للمستخدمين", systemLicense!.maxUsersLimit.toString(), Icons.group),
              _buildListTile("اسم العلامة المستعار", systemLicense!.brandNameAlias ?? "افتراضي", Icons.label_important_outline),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "الصلاحيات الخاصة",
            icon: Icons.key_outlined,
            children: [
               if (systemLicense!.specialPermissions.isEmpty)
                const ListTile(title: Text("لا توجد صلاحيات خاصة", style: TextStyle(fontSize: 12, color: Colors.grey)))
               else
                ...systemLicense!.specialPermissions.map((p) => _buildListTile(p, "مفعلة", Icons.check_circle_outline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseHeader() {
    final isExpired = systemLicense?.expiryDate?.isBefore(DateTime.now()) ?? false;
    final statusColor = isExpired ? Colors.red : Colors.green;
    final statusText = isExpired ? "منتهي الصلاحية" : "نشط";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? DarkColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpired ? Icons.error_outline : Icons.verified_user_outlined,
                color: statusColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "حالة الترخيص",
                    style: TextStyle(
                      color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (systemLicense?.isVerified == true)
                        const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        leading: Icon(icon),
        children: children,
      ),
    );
  }

  Widget _buildListTile(String label, String value, IconData icon) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }
}
