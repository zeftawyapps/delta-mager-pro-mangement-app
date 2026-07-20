import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/route_ids.dart';
import 'package:delta_mager_pro_mangement_app/screens/analytics_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/category_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/products_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/offers_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/testWidget/OrgLoginScreen.dart';
import 'package:delta_mager_pro_mangement_app/screens/user_management_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/blogs_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/logIn.dart';
import 'package:delta_mager_pro_mangement_app/screens/welcom_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/login_admin_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/admin/admin_operations_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/splash_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/policies_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/order_paths_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';
import 'package:JoDija_tamplites/util/localization/loclization/app_localizations.dart';
import 'package:flutter/material.dart' show Icons;

class SidebarItemsConfig {
  List<RouteItem> get items {
    final tr = Translation().appLocal.values;
    return [
      RouteItem(
        id: AppRouteIds.analytics,
        path: AppRoutes.analyses,
        label: tr['nav_analytics']!,
        icon: Icons.home,
        content: AnalyticsScreen(),
        isSideBarRouted: true,
        isVisableInSideBar: true,
        prams: {"orgName": AppRoutes.activeOrgName},
      ),

      RouteItem(
        id: "blog",
        path: AppRoutes.cpBlogs,
        label: tr['nav_blog']!,
        icon: Icons.article_outlined,
        parentName: tr['nav_blog_parent']!,
        parentIcon: Icons.language,
        content: BlogsScreen(),
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.categories,
        path: AppRoutes.cpCategory,
        label: tr['nav_categories']!,
        icon: Icons.category,
        parentName: tr['nav_catalog']!,
        parentIcon: Icons.shopping_basket,
        content: CategoryScreen(),
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.products,
        path: AppRoutes.products,
        label: tr['nav_products']!,
        icon: Icons.production_quantity_limits,
        parentName: tr['nav_catalog']!,
        parentIcon: Icons.shopping_basket,
        content: ProductsScreen(),
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.offers,
        path: AppRoutes.offers,
        label: tr['nav_offers']!,
        icon: Icons.local_offer,
        parentName: tr['nav_catalog']!,
        parentIcon: Icons.shopping_basket,
        content: OffersScreen(),
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.orders,
        path: AppRoutes.cpOrders,
        label: tr['nav_orders']!,
        icon: Icons.shopping_cart,
        content: OrdersScreen(),
        parentName: tr['nav_orders_parent']!,
        parentIcon: Icons.shopping_bag,
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.users,
        path: AppRoutes.cpUsers,
        label: tr['nav_users']!,
        icon: Icons.person_2_outlined,
        parentName: tr['nav_system_management']!,
        parentIcon: Icons.settings_suggest_outlined,
        content: UserManagementScreen(),
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.policies,
        path: AppRoutes.policies,
        label: tr['nav_policies']!,
        icon: Icons.gavel,
        parentName: tr['nav_system_management']!,
        parentIcon: Icons.settings_suggest_outlined,
        content: PoliciesScreen(),
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.orderPaths,
        path: AppRoutes.orderPaths,
        label: tr['nav_order_paths']!,
        icon: Icons.route,
        parentName: tr['nav_system_management']!,
        parentIcon: Icons.settings_suggest_outlined,
        content: OrderPathsScreen(),
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      // RouteItem(
      //   id: AppRouteIds.profile,
      //   path: AppRoutes.settings,
      //   label: AppStrings.profile,
      //   icon: Icons.person,
      //   content: ProfileScreen(),
      //   prams: {"orgName": AppRoutes.activeOrgName},
      // ),
      RouteItem(
        id: AppRouteIds.login,
        path: AppRoutes.logIn,
        label: tr['nav_login']!,
        icon: Icons.login,
        content: LoginScreen(),
        isSideBarRouted: false,
        prams: {"orgName": AppRoutes.activeOrgName},
      ),
      RouteItem(
        id: AppRouteIds.welcome,
        path: AppRoutes.welcome,
        label: tr['nav_welcome']!,
        icon: Icons.home,
        content: WelcomScreen(),
        isSideBarRouted: false,
      ),
      RouteItem(
        id: AppRouteIds.loginAdmin,
        path: AppRoutes.loginAdmin,
        label: tr['nav_login_admin']!,
        icon: Icons.admin_panel_settings,
        content: LoginAdminScreen(),
        isSideBarRouted: false,
      ),
      RouteItem(
        id: AppRouteIds.adminOperations,
        path: AppRoutes.adminOperations,
        label: tr['nav_admin_operations']!,
        icon: Icons.settings_suggest,
        content: AdminOperationsScreen(),
        isSideBarRouted: false,
      ),
      RouteItem(
        id: AppRouteIds.splash,
        path: AppRoutes.splash,
        label: tr['nav_splash']!,
        icon: Icons.route,
        content: SplashScreen(),
        isSideBarRouted: false,
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
}
