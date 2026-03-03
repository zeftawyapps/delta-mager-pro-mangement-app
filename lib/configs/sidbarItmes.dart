import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/screens/analytics_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/category_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/screens/content/custom_content_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/screens/content/dashboard_screen.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/screens/content/profile_screen.dart';
import 'package:delta_mager_pro_mangement_app/screens/logIn.dart';
import 'package:delta_mager_pro_mangement_app/screens/welcom_screen.dart';
import 'package:flutter/material.dart' show Icons;

class SidebarItemsConfig {
  List<RouteItem> items = [
    RouteItem(
      id: 'analytics',
      path: AppRoutes.analyses,
      label: 'Analytics',
      icon: Icons.home,
      content: AnalyticsScreen(),
    ),
    RouteItem(
      id: 'categories',
      path: AppRoutes.cpCategory,
      label: 'الفئات',
      icon: Icons.category,
      parentName: "منتجات",
      parentIcon: Icons.shopping_basket,
      content: CategoryScreen(),
    ),
    RouteItem(
      id: 'users',
      path: '/users',
      label: 'Users',
      icon: Icons.person_2_outlined,
      content: DashboardScreen(),
    ),
    RouteItem(
      id: 'profile',
      path: AppRoutes.settings,
      label: 'profile',
      icon: Icons.person,
      content: ProfileScreen(),
    ),
    RouteItem(
      id: "login",
      path: AppRoutes.login,
      label: "login",
      icon: Icons.login,
      content: LoginScreen(),
      isSideBarRouted: false,
    ),
    RouteItem(
      id: "welcom",
      path: AppRoutes.welcome,
      label: "welcom",
      icon: Icons.home,
      content: WelcomScreen(),
      isSideBarRouted: false,
    ),
  ];
}
