import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/tabs/organization_detail/operations/order_paths/order_paths_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class OrderPathsScreen extends StatefulWidget with AppShellRouterMixin {
  OrderPathsScreen({super.key});

  @override
  State<OrderPathsScreen> createState() => _OrderPathsScreenState();
}

class _OrderPathsScreenState extends State<OrderPathsScreen> {
  String get organizationId {
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
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
        currentTilte: 'خطوط السير',
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child: OrderPathsSectionTab(
          organizationId: organizationId,
          isDark: isDark,
        ),
      ),
    );
  }
}
