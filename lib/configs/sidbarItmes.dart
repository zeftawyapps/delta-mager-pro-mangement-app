import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/route_ids.dart';
import 'package:delta_mager_pro_mangement_app/screens/analytics_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/category_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/products_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/user_management_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/screens/content/custom_content_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/screens/content/dashboard_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/screens/content/profile_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/logIn.dart';
import 'package:delta_mager_pro_mangement_app/screens/welcom_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/login_admin_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/admin_operations_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/splash_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/test_generic_view_screen.dart';
import 'package:flutter/material.dart' show Icons;

class SidebarItemsConfig {
  List<RouteItem> items = [
    RouteItem(
      id: AppRouteIds.analytics,
      path: AppRoutes.analyses,
      label: AppStrings.analytics,
      icon: Icons.home,
      content: AnalyticsScreen(),
    ),
    RouteItem(
      id: AppRouteIds.categories,
      path: AppRoutes.cpCategory,
      label: AppStrings.categories,
      icon: Icons.category,
      parentName: AppStrings.store,
      parentIcon: Icons.shopping_basket,
      content: CategoryScreen(),
    ),
    RouteItem(
      id: AppRouteIds.products,
      path: AppRoutes.products,
      label: AppStrings.products,
      icon: Icons.production_quantity_limits,
      parentName: AppStrings.store,
      parentIcon: Icons.shopping_basket,
      content: ProductsScreen(),
    ),
    RouteItem(
      id: AppRouteIds.users,
      path: '/users',
      label: AppStrings.users,
      icon: Icons.person_2_outlined,
      content: UserManagementScreen(),
    ),
    RouteItem(
      id: AppRouteIds.profile,
      path: AppRoutes.settings,
      label: AppStrings.profile,
      icon: Icons.person,
      content: ProfileScreen(),
    ),
    RouteItem(
      id: AppRouteIds.login,
      path: AppRoutes.logIn,
      label: AppStrings.login,
      icon: Icons.login,
      content: LoginScreen(),
      isSideBarRouted: false,
      prams: {"orgName": "dsaf"},
    ),
    RouteItem(
      id: AppRouteIds.welcome,
      path: AppRoutes.welcome,
      label: AppStrings.welcome,
      icon: Icons.home,
      content: WelcomScreen(),
      isSideBarRouted: false,
    ),
    RouteItem(
      id: AppRouteIds.loginAdmin,
      path: AppRoutes.loginAdmin,
      label: AppStrings.loginAdmin,
      icon: Icons.admin_panel_settings,
      content: LoginAdminScreen(),
      isSideBarRouted: false,
    ),
    RouteItem(
      id: AppRouteIds.adminOperations,
      path: AppRoutes.adminOperations,
      label: AppStrings.adminOperations,
      icon: Icons.settings_suggest,
      content: AdminOperationsScreen(),
      isSideBarRouted: false,
    ),
    RouteItem(
      id: AppRouteIds.splash,
      path: AppRoutes.splash,
      label: "تحميل الإعدادات",
      icon: Icons.flash_on,
      content: SplashScreen(),
      isSideBarRouted: false,
    ),
    RouteItem(
      id: AppRouteIds.testMasterGrid,
      path: AppRoutes.testMasterGrid,
      label: "تجربة MasterGrid",
      icon: Icons.grid_view_rounded,
      content: TestGenericProductsScreen(),
    ),
  ];
}
