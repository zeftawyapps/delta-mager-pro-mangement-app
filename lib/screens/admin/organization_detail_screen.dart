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
import 'tabs/organization_detail/general_info_tab.dart';
import 'tabs/organization_detail/config_tab.dart';
import 'tabs/organization_detail/product_config_tab.dart';
import 'tabs/organization_detail/policies_tab.dart';
import 'tabs/organization_detail/license_tab.dart';
import 'tabs/organization_detail/workflow_tab.dart';
import 'tabs/organization_detail/roles_tab.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final OrganizationModel organization;

  const OrganizationDetailScreen({super.key, required this.organization});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  @override
  void initState() {
    super.initState();
    final orgId = widget.organization.organizationId;
    context.read<AdminOrganizationConfigBloc>().loadConfig(orgId);
    context.read<OrganizationPolicyBloc>().loadPolicy(orgId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.organization.name),
          backgroundColor: isDark ? DarkColors.surface : LightColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true, // Added for mobile support if many tabs
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.info), text: "البيانات الأساسية"),
              Tab(icon: Icon(Icons.settings), text: "الإعدادات Config"),
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: "إعدادات المنتجات",
              ),
              Tab(icon: Icon(Icons.gavel), text: "السياسات Policies"),
              Tab(icon: Icon(Icons.security), text: "الأدوار Roles"),
              Tab(
                icon: Icon(Icons.account_tree_outlined),
                text: "مسارات العمل Workflow",
              ),
              Tab(icon: Icon(Icons.verified), text: "الترخيص License"),
            ],
          ),
        ),
        body: Container(
          color: isDark ? DarkColors.background : LightColors.background,
          child: TabBarView(
            children: [
              // --- Tab 1: General Info ---
              GeneralInfoTab(organization: widget.organization, isDark: isDark),

              // --- Tab 2: Configuration ---
              BlocBuilder<
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
                    loading: () {
                      final prevData = state.itemState.maybeWhen(
                        success: (d) => d,
                        orElse: () => null,
                      );
                      if (prevData != null) {
                        return Stack(
                          children: [
                            ConfigSectionTab(
                              config: prevData,
                              organizationId:
                                  widget.organization.organizationId,
                              isDark: isDark,
                            ),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                    failure: (error, reload) => Center(
                      child: _buildErrorCard(
                        error.message ?? 'خطأ في التحميل',
                        reload,
                      ),
                    ),
                    orElse: () => const SizedBox(),
                  );
                },
              ),

              // --- Tab 3: Product Configuration ---
              BlocBuilder<
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
                    loading: () {
                      final prevData = state.itemState.maybeWhen(
                        success: (d) => d,
                        orElse: () => null,
                      );
                      if (prevData != null) {
                        return Stack(
                          children: [
                            ProductConfigSectionTab(
                              config: prevData,
                              organizationId:
                                  widget.organization.organizationId,
                              isDark: isDark,
                            ),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                    failure: (error, reload) => Center(
                      child: _buildErrorCard(
                        error.message ?? 'خطأ في التحميل',
                        reload,
                      ),
                    ),
                    orElse: () => const SizedBox(),
                  );
                },
              ),

              // --- Tab 4: Policies ---
              BlocBuilder<
                OrganizationPolicyBloc,
                FeaturDataSourceState<OrganizationPolicyModel>
              >(
                builder: (context, state) {
                  return state.itemState.when(
                    init: () => const SizedBox(),
                    loading: () {
                      final prevData = state.itemState.maybeWhen(
                        success: (d) => d,
                        orElse: () => null,
                      );
                      if (prevData != null) {
                        return Stack(
                          children: [
                            PoliciesSectionTab(
                              policy: prevData,
                              organizationId:
                                  widget.organization.organizationId,
                              isDark: isDark,
                            ),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                    success: (policy) => PoliciesSectionTab(
                      policy: policy!,
                      organizationId: widget.organization.organizationId,
                      isDark: isDark,
                    ),
                    failure: (error, reload) => Center(
                      child: _buildErrorCard(
                        error.message ?? 'خطأ في التحميل',
                        reload,
                      ),
                    ),
                  );
                },
              ),

              // --- Tab 5: Roles ---
              RolesSectionTab(
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),

              // --- Tab 6: Workflow ---
              WorkflowSectionTab(
                organizationId: widget.organization.organizationId,
                isDark: isDark,
              ),

              // --- Tab 7: License ---
              BlocBuilder<
                AdminOrganizationConfigBloc,
                FeaturDataSourceState<OrganizationConfigModel>
              >(
                builder: (context, state) {
                  return state.itemState.maybeWhen(
                    success: (config) => LicenseSectionTab(
                      systemLicense: config?.systemLicense,
                      isDark: isDark,
                    ),
                    loading: () {
                      final prevData = state.itemState.maybeWhen(
                        success: (d) => d,
                        orElse: () => null,
                      );
                      if (prevData != null) {
                        return Stack(
                          children: [
                            LicenseSectionTab(
                              systemLicense: prevData.systemLicense,
                              isDark: isDark,
                            ),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                    failure: (error, reload) => Center(
                      child: _buildErrorCard(
                        error.message ?? 'خطأ في التحميل',
                        reload,
                      ),
                    ),
                    orElse: () => const SizedBox(),
                  );
                },
              ),
            ],
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
