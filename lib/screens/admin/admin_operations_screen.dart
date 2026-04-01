import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'tabs/general/organizations_tab.dart';
import 'tabs/general/global_roles_tab.dart';
import 'tabs/general/permissions_tab.dart';
import 'tabs/general/users_tab.dart';

class AdminOperationsScreen extends StatefulWidget with AppShellRouterMixin {
  AdminOperationsScreen({super.key});

  @override
  State<AdminOperationsScreen> createState() => _AdminOperationsScreenState();
}

class _AdminOperationsScreenState extends State<AdminOperationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrganizationsBloc>().loadActiveOrganizations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.getMainPath() != null) {
      var changvalue = context.read<AppChangesValues>();
      changvalue.setLastRoute(widget.getMainPath()!);
    }
    final authWidget = AppChangesValues.checkAuth(context, widget);
    if (authWidget != null) return authWidget;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: "إدارة النظام",
        isDesplayTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? DarkColors.surface : LightColors.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "المنظمات المتاجر", icon: Icon(Icons.store)),
                Tab(text: "الأدوار العامة", icon: Icon(Icons.security)),
                Tab(text: "المستخدمين", icon: Icon(Icons.people)),
                Tab(text: "الصلاحيات", icon: Icon(Icons.key)),
              ],
              labelColor: isDark ? DarkColors.primary : LightColors.primary,
              unselectedLabelColor: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              indicatorColor: isDark ? DarkColors.primary : LightColors.primary,
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? DarkColors.background : LightColors.background,
              child: TabBarView(
                controller: _tabController,
                children: [
                  OrganizationsTab(isDark: isDark),
                  GlobalRolesTab(isDark: isDark),
                  UsersTab(isDark: isDark),
                  PermissionsTab(isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
