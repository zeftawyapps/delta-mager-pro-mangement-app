import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/route_ids.dart';
import 'package:delta_mager_pro_mangement_app/screens/analytics_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/category_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/products_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/offers_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/testWidget/OrgLoginScreen.dart';
import 'package:delta_mager_pro_mangement_app/screens/user_management_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/logIn.dart';
import 'package:delta_mager_pro_mangement_app/screens/welcom_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/login_admin_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/admin_operations_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/splash_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/policies_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/screens/content/profile_screen.dart';
import 'package:flutter/material.dart' show Icons;

class SidebarItemsConfig {
  List<RouteItem> get items => [
    RouteItem(
      id: AppRouteIds.analytics,
      path: AppRoutes.analyses,
      label: AppStrings.analytics,
      icon: Icons.home,
      content: AnalyticsScreen(),
      prams: {"orgName": AppRoutes.activeOrgName},
    ),
    RouteItem(
      id: AppRouteIds.categories,
      path: AppRoutes.cpCategory,
      label: AppStrings.categories,
      icon: Icons.category,
      parentName: AppStrings.catalog,
      parentIcon: Icons.shopping_basket,
      content: CategoryScreen(),
      prams: {"orgName": AppRoutes.activeOrgName},
    ),
    RouteItem(
      id: AppRouteIds.products,
      path: AppRoutes.products,
      label: AppStrings.products,
      icon: Icons.production_quantity_limits,
      parentName: AppStrings.catalog,
      parentIcon: Icons.shopping_basket,
      content: ProductsScreen(),
      prams: {"orgName": AppRoutes.activeOrgName},
    ),
    RouteItem(
      id: AppRouteIds.offers,
      path: AppRoutes.offers,
      label: AppStrings.offers,
      icon: Icons.local_offer,
      parentName: AppStrings.catalog,
      parentIcon: Icons.shopping_basket,
      content: OffersScreen(),
      prams: {"orgName": AppRoutes.activeOrgName},
    ),
    RouteItem(
      id: AppRouteIds.users,
      path: AppRoutes.cpUsers,
      label: AppStrings.users,
      icon: Icons.person_2_outlined,
      content: UserManagementScreen(),
      prams: {"orgName": AppRoutes.activeOrgName},
    ),
    RouteItem(
      id: AppRouteIds.profile,
      path: AppRoutes.settings,
      label: AppStrings.profile,
      icon: Icons.person,
      content: ProfileScreen(),
      prams: {"orgName": AppRoutes.activeOrgName},
    ),
    RouteItem(
      id: AppRouteIds.login,
      path: AppRoutes.logIn,
      label: AppStrings.login,
      icon: Icons.login,
      content: LoginScreen(),
      isSideBarRouted: false,
      prams: {"orgName": AppRoutes.activeOrgName},
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
      id: AppRouteIds.policies,
      path: AppRoutes.policies,
      label: AppStrings.policies,
      icon: Icons.gavel,
      content: PoliciesScreen(),
      prams: {"orgName": AppRoutes.activeOrgName},
    ),

    RouteItem(
      id: "custom1",
      path: AppRoutes.customAnalyses,
      label: 'custems',
      icon: Icons.calendar_view_week_outlined,
      content: OrgLoginScreen(),
      isSideBarRouted: false,
      isVisableInSideBar: false,
      isInBottomNavBar: false,
      isAppBar: false,
      isInTopNavBar: false,
      isDesplayTitleInLargScreen: true,
      isDrawerShow: false,
      prams: {"org": "5"},
      // queryParameters: {"qu": "paramter"},
    ),
  ];
}
