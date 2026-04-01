import 'package:delta_mager_pro_mangement_app/screens/admin/tabs/general/users_tab.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

// ignore: must_be_immutable
class UserManagementScreen extends StatelessWidget with AppShellRouterMixin {
  UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (getMainPath() != null) {
      var changvalue = context.read<AppChangesValues>();
      String path = getMainPath()!;
      changvalue.setLastRoute(path);
    }
    final authWidget = AppChangesValues.checkAuth(context, this);
    if (authWidget != null) return authWidget;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: AppStrings.users,
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child: UsersTab(isDark: isDark),
      ),
    );
  }
}
