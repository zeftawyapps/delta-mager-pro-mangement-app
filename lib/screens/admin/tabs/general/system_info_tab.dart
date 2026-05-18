import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/system_models.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class SystemInfoTab extends StatefulWidget {
  final bool isDark;

  const SystemInfoTab({super.key, required this.isDark});

  @override
  State<SystemInfoTab> createState() => _SystemInfoTabState();
}

class _SystemInfoTabState extends State<SystemInfoTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemBloc>().loadSystemInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;
    final surfaceColor = isDark ? DarkColors.surface : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return BlocBuilder<SystemBloc, FeaturDataSourceState<SystemInfoModel>>(
      builder: (context, state) {
        return state.itemState.when(
          init: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (systemInfo) {
            if (systemInfo == null) {
              return const Center(child: Text("لا توجد بيانات متاحة للنظام"));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Section ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "معلومات وبيانات النظام",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                          ),
                          Text(
                            "تفاصيل التشغيل، الترخيص وحالة التهيئة الخاصة بالنظام",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: subtitleColor),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<SystemBloc>().loadSystemInfo();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("تحديث البيانات"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- Warning for License Expiry if applicable ---
                  if (systemInfo.licenseExpiryDate != null)
                    _buildLicenseWarningIfNeeded(
                      systemInfo.licenseExpiryDate!,
                      isDark,
                    ),

                  // --- Main Metadata Grid ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width < 600
                          ? 1
                          : (width < 950 ? 2 : 3);

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.2,
                        children: [
                          _buildInfoCard(
                            title: "اسم التطبيق",
                            value: systemInfo.appName,
                            icon: Icons.apps_rounded,
                            color: Colors.blue,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                          ),
                          _buildInfoCard(
                            title: "اسم المنظمة الافتراضية",
                            value: systemInfo.orgName,
                            icon: Icons.business_rounded,
                            color: Colors.teal,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                          ),
                          _buildInfoCard(
                            title: "كود الترخيص (License Key)",
                            value: systemInfo.licenseKey.isEmpty
                                ? "غير مرخص"
                                : systemInfo.licenseKey,
                            icon: Icons.verified_user_rounded,
                            color: Colors.orange,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                            isCode: true,
                          ),
                          _buildInfoCard(
                            title: "تاريخ انتهاء الترخيص",
                            value: systemInfo.licenseExpiryDate != null
                                ? "${systemInfo.licenseExpiryDate!.toLocal().year}-${systemInfo.licenseExpiryDate!.toLocal().month}-${systemInfo.licenseExpiryDate!.toLocal().day}"
                                : "لا يوجد تاريخ انتهاء",
                            icon: Icons.date_range_rounded,
                            color: Colors.red,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                          ),
                          _buildInfoCard(
                            title: "اللغة الافتراضية للنظام",
                            value: systemInfo.defaultLanguage.toUpperCase(),
                            icon: Icons.language_rounded,
                            color: Colors.indigo,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  ),
                  
                  // --- Versions & Compatibility Section ---
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(Icons.layers_rounded, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "بيانات توافق إصدارات النظام (Front-to-Back)",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width < 750 ? 1 : 3;
                      
                      final backendVersion = _getBackendVersionOnly(systemInfo.version);
                      final backendBuild = _getBackendBuildOnly(systemInfo.version);

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: width < 750 ? 4.5 : 2.0,
                        children: [
                          _buildVersionCard(
                            title: "إصدار الباك اند",
                            value: backendVersion,
                            subtitle: "الإصدار الرئيسي للسيرفر",
                            icon: Icons.dns_rounded,
                            color: Colors.purple,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                          ),
                          _buildVersionCard(
                            title: "رقم بناء الباك اند",
                            value: backendBuild,
                            subtitle: "رقم بناء السيرفر (Build)",
                            icon: Icons.terminal_rounded,
                            color: Colors.deepPurple,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                          ),
                          _buildVersionCard(
                            title: "رقم بناء الفرونت اند",
                            value: AppShellLocalConfigs.appBuildIndex.toString(),
                            subtitle: "رقم بناء التطبيق (Build)",
                            icon: Icons.integration_instructions_rounded,
                            color: Colors.teal,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- Status Cards (Bootstrap & Maintenance Mode) ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusTile(
                          title: "حالة تهيئة النظام (Bootstrap)",
                          subtitle: systemInfo.isBootstrapped
                              ? "تم تهيئة النظام وتشغيله بالكامل بنجاح"
                              : "النظام بانتظار التهيئة والتشغيل",
                          isActive: systemInfo.isBootstrapped,
                          activeColor: Colors.green,
                          inactiveColor: Colors.amber,
                          icon: Icons.rocket_launch_rounded,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusTile(
                          title: "وضع الصيانة (Maintenance Mode)",
                          subtitle: systemInfo.maintenanceMode
                              ? "النظام متوقف حالياً للصيانة والترقيات"
                              : "النظام نشط ويعمل بشكل طبيعي للجميع",
                          isActive: !systemInfo.maintenanceMode,
                          activeColor: Colors.green,
                          inactiveColor: Colors.red,
                          icon: Icons.construction_rounded,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          failure: (error, reload) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  error.message ?? "حدث خطأ أثناء تحميل بيانات النظام",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: reload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("إعادة المحاولة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getBackendVersionOnly(String fullVersion) {
    if (fullVersion.contains(" (Build ")) {
      return fullVersion.split(" (Build ")[0];
    }
    return fullVersion;
  }

  String _getBackendBuildOnly(String fullVersion) {
    if (fullVersion.contains(" (Build ")) {
      final parts = fullVersion.split(" (Build ");
      if (parts.length > 1) {
        return parts[1].replaceAll(")", "").trim();
      }
    }
    return "غير متوفر";
  }

  Widget _buildVersionCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: subtitleColor.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
    bool isCode = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: isCode ? 'monospace' : null,
                    letterSpacing: isCode ? 1.0 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required String title,
    required String subtitle,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required IconData icon,
    required Color surfaceColor,
    required Color textColor,
    required Color subtitleColor,
  }) {
    final statusColor = isActive ? activeColor : inactiveColor;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? "نشط / مؤكد" : "متوقف / معطل",
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseWarningIfNeeded(DateTime expiryDate, bool isDark) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;

    if (difference < 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "تنبيه هام: لقد انتهى ترخيص النظام الحالي! يرجى تجديد الترخيص فوراً لضمان استمرارية تشغيل الخدمات والمبيعات.",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (difference <= 30) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "تنبيه: سينتهي ترخيص النظام خلال $difference يوم! يرجى تجديد الترخيص لتجنب انقطاع الخدمات.",
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
