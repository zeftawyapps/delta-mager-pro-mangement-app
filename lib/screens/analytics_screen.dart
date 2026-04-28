import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AnalyticsScreen extends StatefulWidget with AppShellRouterMixin {
  AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SystemManager {
  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature:
          SystemFeatures.screenDashboard, // Using screenDashboard for Analytics
      mainPath: widget.getMainPath(),
    );

    if (sys.authWidget != null) return sys.authWidget!;

    final appBarConfig = sys.appBarConfig;

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: 'التحليلات',
        isDesplayTitle: true,
      ),
      body: const Center(
        child: Text('التحليلات (قريباً)', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
