import 'package:delta_mager_pro_mangement_app/screens/admin/tabs/general/users_tab.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/tabs/general/customers_tab.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/tabs/general/wholesaler_requests_tab.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

// ignore: must_be_immutable
class UserManagementScreen extends StatefulWidget with AppShellRouterMixin {
  UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SystemManager {
  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.user,
      mainPath: widget.getMainPath(),
    );

    if (sys.authWidget != null) return sys.authWidget!;

    final bool isDark = sys.isDark;
    final appBarConfig = sys.appBarConfig;
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: AppStrings.users,
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.admin_panel_settings),
                    text: "المستخدمين (الإداريين/الموظفين)",
                  ),
                  Tab(icon: Icon(Icons.people), text: "العملاء"),
                  Tab(icon: Icon(Icons.storefront), text: "طلبات الجملة"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    UsersTab(
                      isDark: isDark,
                      searchHint: "بحث في المستخدمين الإداريين...",
                    ),
                    CustomersTab(
                      isDark: isDark,
                      searchHint: "بحث في العملاء...",
                    ),
                    WholesalerRequestsTab(isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
