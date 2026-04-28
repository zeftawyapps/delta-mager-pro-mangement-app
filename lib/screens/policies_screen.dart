import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_policy_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'admin/tabs/organization_detail/policies_tab.dart';

class PoliciesScreen extends StatefulWidget with AppShellRouterMixin {
  PoliciesScreen({super.key});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  String get organizationId {
    final params = widget.getPrams();
    final orgName = params?['orgName'];
    if (orgName != null && orgName != "" && orgName != ":orgName") {
      return orgName;
    }
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizationPolicyBloc>().loadPolicy(organizationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = widget.getPrams();
    final orgNameFromRoute = params?['orgName'];
    if (orgNameFromRoute != null &&
        orgNameFromRoute != "" &&
        orgNameFromRoute != ":orgName") {
      AppRoutes.activeOrgName = orgNameFromRoute;
    }

    if (widget.getMainPath() != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppChangesValues>().setLastRoute(widget.getMainPath()!);
      });
    }
    final authWidget = AppChangesValues.checkAuth(context, widget);
    if (authWidget != null) return authWidget;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: AppStrings.policies,
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child:
            BlocBuilder<
              OrganizationPolicyBloc,
              FeaturDataSourceState<OrganizationPolicyModel>
            >(
              builder: (context, state) {
                return state.itemState.when(
                  init: () => const Center(child: CircularProgressIndicator()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  success: (policy) => PoliciesSectionTab(
                    policy: policy!,
                    organizationId: organizationId,
                    isDark: isDark,
                  ),
                  failure: (error, reload) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          error.message ?? AppStrings.error,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: reload,
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
