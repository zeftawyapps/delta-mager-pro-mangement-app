import 'dart:async';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/configs/sidbarItmes.dart';
import 'package:delta_mager_pro_mangement_app/configs/cp_screens_config.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';

// ignore: must_be_immutable
class WelcomScreen extends StatefulWidget with AppShellRouterMixin {
  WelcomScreen({super.key});

  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> with AppShellRouteManager {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      final changvalue = context.read<AppChangesValues>();
      final currentUser = changvalue.user;

      if (currentUser != null) {
        // 1️⃣ أولاً: التحقق من وضع الأدمن (لحالات التعديلات في الإعدادات العامة)
        if (currentUser.roles.contains('admin') || AppShellConfigs.isAdminMode) {
          widget.goRoute(context, AppRoutes.adminOperations, replace: true);
          return;
        }

        // 2️⃣ ثانياً: إذا لم يكن أدمن، نطبق نظام صلاحيات الشاشات
        List<RouteItem> routes = SidebarItemsConfig().items;
        final availableRoutes = CPScreensConfig.getAvailableRoutes(
          currentUser,
          routes: routes,
        );

        bool hasVisibleRoutes = false;
        for (var route in availableRoutes) {
          if (route.isVisableInSideBar) {
            addRouteItem(route);
            hasVisibleRoutes = true;
          }
        }

        if (hasVisibleRoutes) {
          setupAppShellRouteManager(context);
          if (changvalue.laseRoute != null) {
            widget.goRouterInSidBar(context, changvalue.laseRoute!);
          } else {
            try {
              final firstRoute = availableRoutes.firstWhere(
                (r) => r.isVisableInSideBar && r.isSideBarRouted != false,
              );
              widget.goRouterInSidBar(context, firstRoute.path);
            } catch (e) {
              widget.goRouterInSidBar(context, AppRoutes.settings);
            }
          }
        } else {
          // إذا لم تكن هناك شاشات مسموح بها، نكتفي بالملف الشخصي أو تسجيل الخروج
          widget.goRoute(context, AppRoutes.settings, replace: true);
        }
      } else {
        widget.goRoute(context, AppRoutes.analyses, replace: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة فخمة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface,
                  AppColors.background,
                  AppColors.surfaceVariant,
                ],
              ),
            ),
          ),

          // أشكال زخرفية في الخلفية لإضفاء طابع عصري
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الشعار مع حركة أنيميشن
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          Image.asset(
                            AppAsset.imgplaceholder,
                            width: size.width > 600 ? 300 : 250,
                            height: size.width > 600 ? 200 : 150,
                            fit: BoxFit.contain,
                          ).animate().fadeIn(duration: 600.ms).scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.0, 1.0),
                                curve: Curves.easeOutBack,
                              ),
                          const SizedBox(height: 16),
                          Text(
                            'لوحة التحكم الإدارية',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ),

                    // رسائل الترحيب
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.welcomeMessage,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 16),
                        Text(
                          'جاري تحميل البيانات وإعداد الواجهة، يرجى الانتظار...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ).animate().fadeIn(delay: 400.ms).scale(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
