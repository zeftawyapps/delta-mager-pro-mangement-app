import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_policy_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

// Import Tabs
import 'tabs/organization_detail/general/general_info_tab.dart';
import 'tabs/organization_detail/settings/config/config_tab.dart';
import 'tabs/organization_detail/settings/product_config/product_config_tab.dart';
import 'tabs/organization_detail/operations/policies/policies_tab.dart';
import 'tabs/organization_detail/operations/workflow/workflow_tab.dart';
import 'tabs/organization_detail/operations/roles/roles_tab.dart';
import 'tabs/organization_detail/settings/features_tab.dart';
import 'tabs/organization_detail/settings/b2b_home/b2b_home_tab.dart';
import 'tabs/organization_detail/settings/website_config/website_config_tab.dart';
import 'tabs/organization_detail/operations/order_paths/order_paths_tab.dart';
import 'tabs/organization_detail/operations/order_screen_config/order_screen_config_tab.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final OrganizationModel organization;

  const OrganizationDetailScreen({super.key, required this.organization});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _SidebarItem {
  final String title;
  final IconData icon;

  const _SidebarItem({required this.title, required this.icon});
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  int _selectedIndex = 0;

  static const List<_SidebarItem> _sidebarItems = [
    _SidebarItem(title: "البيانات الأساسية والترخيص", icon: Icons.info_outline),
    _SidebarItem(title: "الإعدادات العامة (Config)", icon: Icons.settings_outlined),
    _SidebarItem(title: "إعدادات المنتجات", icon: Icons.inventory_2_outlined),
    _SidebarItem(title: "إعدادات B2B Home", icon: Icons.home_outlined),
    _SidebarItem(title: "إعدادات Website", icon: Icons.web_outlined),
    _SidebarItem(title: "المزايا Features", icon: Icons.star_outline),
    _SidebarItem(title: "السياسات Policies", icon: Icons.gavel_outlined),
    _SidebarItem(title: "الأدوار Roles", icon: Icons.security_outlined),
    _SidebarItem(title: "مسارات العمل Workflow", icon: Icons.account_tree_outlined),
    _SidebarItem(title: "خطوط السير Paths", icon: Icons.alt_route_outlined),
    _SidebarItem(title: "إعدادات الطلبات Orders Config", icon: Icons.tune_outlined),
  ];

  @override
  void initState() {
    super.initState();
    final orgId = widget.organization.organizationId;
    context.read<AdminOrganizationConfigBloc>().loadConfig(orgId);
    context.read<OrganizationPolicyBloc>().loadPolicy(orgId);
  }

  Widget _buildDetailContent(bool isDark) {
    switch (_selectedIndex) {
      case 0:
        return BlocBuilder<
          AdminOrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          builder: (context, state) {
            final config = state.itemState.maybeWhen(
              success: (c) => c,
              orElse: () => null,
            );
            return GeneralInfoTab(
              organization: widget.organization,
              systemLicense: config?.systemLicense,
              isDark: isDark,
            );
          },
        );
      case 1:
        return BlocBuilder<
          AdminOrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          builder: (context, state) {
            return state.itemState.maybeWhen(
              success: (config) => ConfigSectionTab(
                config: config!,
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              failure: (error, reload) => _buildErrorCard(
                error.message ?? 'خطأ في التحميل',
                reload,
              ),
              orElse: () => const SizedBox(),
            );
          },
        );
      case 2:
        return BlocBuilder<
          AdminOrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          builder: (context, state) {
            return state.itemState.maybeWhen(
              success: (config) => ProductConfigSectionTab(
                config: config!,
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              failure: (error, reload) => _buildErrorCard(
                error.message ?? 'خطأ في التحميل',
                reload,
              ),
              orElse: () => const SizedBox(),
            );
          },
        );
      case 3:
        return BlocBuilder<
          AdminOrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          builder: (context, state) {
            return state.itemState.maybeWhen(
              success: (config) => B2BHomeConfigTab(
                config: config!,
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              failure: (error, reload) => _buildErrorCard(
                error.message ?? 'خطأ في التحميل',
                reload,
              ),
              orElse: () => const SizedBox(),
            );
          },
        );
      case 4:
        return BlocBuilder<
          AdminOrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          builder: (context, state) {
            return state.itemState.maybeWhen(
              success: (config) => WebsiteConfigTab(
                config: config!,
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              failure: (error, reload) => _buildErrorCard(
                error.message ?? 'خطأ في التحميل',
                reload,
              ),
              orElse: () => const SizedBox(),
            );
          },
        );
      case 5:
        return BlocBuilder<
          AdminOrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          builder: (context, state) {
            return state.itemState.maybeWhen(
              success: (config) => FeaturesSectionTab(
                config: config!,
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              failure: (error, reload) => _buildErrorCard(
                error.message ?? 'خطأ في التحميل',
                reload,
              ),
              orElse: () => const SizedBox(),
            );
          },
        );
      case 6:
        return BlocBuilder<
          OrganizationPolicyBloc,
          FeaturDataSourceState<OrganizationPolicyModel>
        >(
          builder: (context, state) {
            return state.itemState.maybeWhen(
              success: (policy) => PoliciesSectionTab(
                policy: policy!,
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              failure: (error, reload) => _buildErrorCard(
                error.message ?? 'خطأ في التحميل',
                reload,
              ),
              orElse: () => const SizedBox(),
            );
          },
        );
      case 7:
        return RolesSectionTab(
          organizationId: widget.organization.organizationId,
          isDark: isDark,
        );
      case 8:
        return WorkflowSectionTab(
          organizationId: widget.organization.organizationId,
          isDark: isDark,
        );
      case 9:
        return OrderPathsSectionTab(
          organizationId: widget.organization.organizationId,
          isDark: isDark,
        );
      case 10:
        return BlocBuilder<
          AdminOrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          builder: (context, state) {
            return state.itemState.maybeWhen(
              success: (config) => OrderScreenConfigTab(
                config: config!,
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              failure: (error, reload) => _buildErrorCard(
                error.message ?? 'خطأ في التحميل',
                reload,
              ),
              orElse: () => const SizedBox(),
            );
          },
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;
    final sidebarColor = isDark ? DarkColors.surface : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organization.name),
        backgroundColor: isDark ? DarkColors.surface : LightColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Sidebar Column
          Container(
            width: 260,
            color: sidebarColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                final isSelected = _selectedIndex == index;
                return _buildSidebarItem(index, item, isSelected, isDark, primaryColor);
              },
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Content Detail Pane
          Expanded(
            child: Container(
              color: isDark ? DarkColors.background : LightColors.background,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedIndex),
                  child: _buildDetailContent(isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    _SidebarItem item,
    bool isSelected,
    bool isDark,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: primaryColor.withOpacity(0.12), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _selectedIndex = index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: isSelected ? primaryColor : (isDark ? Colors.white60 : Colors.black54),
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                  if (isSelected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, VoidCallback reload) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.red.withOpacity(0.1),
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.red),
          onPressed: reload,
        ),
      ),
    );
  }
}
