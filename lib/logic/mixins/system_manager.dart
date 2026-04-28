import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/providers/sidebar_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/app_bar_config.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_manager.dart';

mixin SystemManager {
  SystemConfig getSystemConfig(
    BuildContext context, {
    required String feature,
    String? mainPath,
    bool? widgetCanAdd,
  }) {
    final appConfig = context.watch<AppChangesValues>();
    final user = appConfig.user;

    final configBloc = context.watch<OrganizationConfigBloc>();
    final orgConfig = configBloc.state.itemState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );

    // الصلاحيات
    bool canAdd = (user?.can(feature, SystemJobs.add) ?? widgetCanAdd ?? true);
    // إضافة شرط خاص بالميزات التي قد تكون معطلة من الإعدادات العامة
    if (feature == SystemFeatures.product) {
      canAdd = canAdd && ProductInputConfig.enableAddProduct;
    } else if (feature == SystemFeatures.category) {
      canAdd = canAdd && ProductInputConfig.enableAddCategory;
    }

    final canUpdate = user?.can(feature, SystemJobs.update) ?? true;
    final canDelete = user?.can(feature, SystemJobs.delete) ?? true;

    // استخراج الإعدادات المحددة للميزة
    dynamic featureConfig;
    if (orgConfig != null && orgConfig.feature != null) {
      final f = orgConfig.feature!;
      
      // الخريطة التي تربط اسم الميزة بمفتاح الإعدادات
      final featureToConfigKey = {
        SystemFeatures.product: 'products',
        SystemFeatures.category: 'categories',
        SystemFeatures.offer: 'offers',
        SystemFeatures.user: 'users',
      };
      
      final configKey = featureToConfigKey[feature];
      if (configKey != null) {
        featureConfig = f.configs[configKey];
      }
    }

    // إدارة الروابط
    final params = (context.widget as dynamic).getPrams();
    final orgNameFromRoute = params?['orgName'];
    if (orgNameFromRoute != null &&
        orgNameFromRoute != "" &&
        orgNameFromRoute != ":orgName") {
      AppRoutes.activeOrgName = orgNameFromRoute;
    }

    if (mainPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // تحديث آخر مسار مسجل
        context.read<AppChangesValues>().setLastRoute(mainPath);
        
        // تحديث العنصر المختار في القائمة الجانبية بشكل آمن
        try {
          // التأكد من وجود الـ Provider قبل الاستخدام لتجنب الـ null error
          final hasSidebarProvider = context.read<AppShellRouterProvider?>() != null;
          if (hasSidebarProvider) {
            final router = context.widget as AppShellRouterMixin;
            router.goRouterInSidBar(context, mainPath);
          }
        } catch (e) {
          debugPrint("Sidebar update skipped: $e");
        }
      });
    }

    // التحقق من المصادقة والبيانات الأساسية
    Widget? authWidget;
    final router = context.widget as AppShellRouterMixin;
    
    if (user == null && orgConfig == null) {
      authWidget = AppChangesValues.checkAuth(context, router) ??
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      authWidget = AppChangesValues.checkAuth(context, router);
    }

    return SystemConfig(
      user: user,
      orgConfig: orgConfig,
      featureConfig: featureConfig,
      canAdd: canAdd,
      canUpdate: canUpdate,
      canDelete: canDelete,
      isDark: Theme.of(context).brightness == Brightness.dark,
      appBarConfig: AppBarConfigs.buildLargeScreenAppBar(context),
      authWidget: authWidget,
    );
  }
}

class SystemConfig {
  final Users? user;
  final OrganizationConfigModel? orgConfig;
  final dynamic featureConfig;
  final bool canAdd;
  final bool canUpdate;
  final bool canDelete;
  final bool isDark;
  final AppBarConfig appBarConfig;
  final Widget? authWidget;

  SystemConfig({
    this.user,
    this.orgConfig,
    this.featureConfig,
    required this.canAdd,
    required this.canUpdate,
    required this.canDelete,
    required this.isDark,
    required this.appBarConfig,
    this.authWidget,
  });
}
