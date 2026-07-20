import 'dart:async';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/providers/sidebar_provider.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/configs/sidbarItmes.dart';
import 'package:delta_mager_pro_mangement_app/configs/cp_screens_config.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_bloc.dart';
import 'package:JoDija_reposatory/constes/api_urls.dart';
import 'package:JoDija_tamplites/util/localization/loclization/app_localizations.dart';

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

      // 1️⃣ أولاً: التحقق من وضع الأدمن (لحالات التعديلات في الإعدادات العامة)

      if (currentUser != null) {
        // 1️⃣ أولاً: التحقق من وضع الأدمن (لحالات التعديلات في الإعدادات العامة)
        if (currentUser.roles.contains('admin') ||
            AppShellConfigs.isAdminMode) {
          widget.goRoute(context, AppRoutes.adminOperations, replace: true);
          return;
        }

        // 0️⃣ التحقق من الانتماء لمنظمة (منع دخول المستخدمين غير المرتبطين بمنظمة)
        if (currentUser.organizationId == null ||
            currentUser.organizationId!.isEmpty) {
          widget.goRoute(context, AppRoutes.logIn, replace: true);
          return;
        }

        // 2️⃣ ثانياً: إذا لم يكن أدمن، نطبق نظام صلاحيات الشاشات
        final routeParams = widget.getPrams();
        final orgNameFromRoute = routeParams?['orgName'];
        if (orgNameFromRoute != null &&
            orgNameFromRoute.isNotEmpty &&
            orgNameFromRoute != ":orgName") {
          AppRoutes.activeOrgName = orgNameFromRoute;
        }
        List<RouteItem> routes = SidebarItemsConfig().items;
        assert(() {
          debugPrint(
            '[welcome][debug] before filter: totalRoutes=${routes.length} userPermissions=${currentUser.permissions}',
          );
          return true;
        }());

        // تعديل المتغيرات في الروابط قبل معالجتها
        // for (var route in routes) {
        //   if (route.path.contains(':orgName')) {
        //     route.path = route.path.replaceAll(':orgName', currentUser.organizationId!);
        //   }
        //   if (route.prams != null && route.prams!.containsKey('orgName')) {
        //     route.prams!['orgName'] = currentUser.organizationId!;
        //   }
        // }

        final availableRoutes = CPScreensConfig.getAvailableRoutes(
          currentUser,
          routes: routes,
        );
        final visibleCount = availableRoutes
            .where((r) => r.isVisableInSideBar)
            .length;

        final sidebarProvider = context.read<AppShellRouterProvider>();
        sidebarProvider.setSidebarItems(availableRoutes);
        bool hasVisibleRoutes = availableRoutes.any(
          (r) => r.isVisableInSideBar,
        );
        assert(() {
          debugPrint(
            '[welcome][debug] after filter: visible=$visibleCount totalInProvider=${sidebarProvider.sidebarItems.length}',
          );
          return true;
        }());
        if (hasVisibleRoutes) {
          // نتحقق أن آخر مسار زاره المستخدم لا يزال ضمن الشاشات المسموح بها
          // قبل التحويل إليه، وإلا نوجهه لأول شاشة مسموح بها.
          final lastRoute = changvalue.laseRoute;
          final bool isLastRouteAllowed =
              lastRoute != null && _isRouteAllowed(lastRoute, availableRoutes);

          if (isLastRouteAllowed) {
            widget.goRouterInSidBar(context, lastRoute);
          } else {
            try {
              final firstRoute = availableRoutes.firstWhere(
                (r) => r.isVisableInSideBar && r.isSideBarRouted != false,
              );
              widget.goRouterInSidBar(context, firstRoute.resolvedPath);
            } catch (e) {
              widget.goRouterInSidBar(context, AppRoutes.settings);
            }
          }
        } else {
          // إذا لم تكن هناك شاشات مسموح بها، نكتفي بالملف الشخصي أو تسجيل الخروج
          widget.goRoute(context, AppRoutes.settings, replace: true);
        }
      } else {
        assert(() {
          debugPrint('[welcome][debug] user is null -> redirect to splash');
          return true;
        }());
        widget.goRoute(context, AppRoutes.splash, replace: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// يتحقق مما إذا كان المسار المُعطى ينتمي لشاشة يملك المستخدم صلاحية الوصول إليها.
  ///
  /// يبحث عن أفضل تطابق (الأكثر تحديداً) بين المسار وقوالب مسارات الشاشات المتاحة،
  /// ثم يرجع true فقط إذا كانت تلك الشاشة مسموح بها للمستخدم الحالي
  /// (isVisableInSideBar يُضبط بناءً على الصلاحيات في CPScreensConfig.getAvailableRoutes).
  bool _isRouteAllowed(String path, List<RouteItem> availableRoutes) {
    final normalized = path.split('?').first;

    RouteItem? bestMatch;
    int bestStaticLength = -1;

    for (final route in availableRoutes) {
      if (_matchesTemplate(route.path, normalized)) {
        final staticLength = route.path
            .split('/')
            .where((s) => s.isNotEmpty && !s.startsWith(':'))
            .length;
        if (staticLength > bestStaticLength) {
          bestMatch = route;
          bestStaticLength = staticLength;
        }
      }
    }

    return bestMatch != null && bestMatch.isVisableInSideBar;
  }

  /// يطابق قالب مسار (مثل `/:orgName/products`) مع مسار فعلي (مثل `/tantest/products`).
  /// الأجزاء التي تبدأ بـ `:` تُعتبر متغيرات تطابق أي قيمة. يُسمح بأن يكون المسار
  /// الفعلي أطول (مسار فرعي) طالما تطابقت بادئة القالب.
  bool _matchesTemplate(String template, String actual) {
    final t = template.split('/').where((s) => s.isNotEmpty).toList();
    final a = actual.split('/').where((s) => s.isNotEmpty).toList();

    if (a.length < t.length) return false;

    for (int i = 0; i < t.length; i++) {
      final segment = t[i];
      if (segment.startsWith(':')) continue; // متغير يطابق أي قيمة
      if (segment != a[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final tr = Translation().appLocal.values;

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
                          Builder(
                                builder: (context) {
                                  final orgLogo = context
                                      .read<OrganizationConfigBloc>()
                                      .organizationConfig
                                      ?.visual
                                      ?.logoUrl;
                                  final systemLogo = context
                                      .read<SystemBloc>()
                                      .systemInfo
                                      ?.logo;
                                  final rawLogo =
                                      (orgLogo != null && orgLogo.isNotEmpty)
                                      ? orgLogo
                                      : ((systemLogo != null &&
                                                systemLogo.isNotEmpty)
                                            ? systemLogo
                                            : null);

                                  final activeLogo =
                                      (rawLogo != null && rawLogo.isNotEmpty)
                                      ? (rawLogo.contains('http')
                                            ? rawLogo
                                            : '${ApiUrls.IMAGE_BASE_URL}$rawLogo')
                                      : null;

                                  final double logoSize = size.width > 600
                                      ? 150
                                      : 120;
                                  Widget logoWidget;
                                  if (activeLogo != null) {
                                    logoWidget = Image.network(
                                      activeLogo,
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                AppAsset.logo,
                                                width: logoSize,
                                                height: logoSize,
                                                fit: BoxFit.cover,
                                              ),
                                    );
                                  } else {
                                    logoWidget = Image.asset(
                                      AppAsset.logo,
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return Container(
                                    width: logoSize,
                                    height: logoSize,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: logoWidget,
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.0, 1.0),
                                curve: Curves.easeOutBack,
                              ),
                          const SizedBox(height: 16),
                          Text(
                            tr['admin_dashboard']!,
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
                          tr['welcome_message']!,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 16),
                        Text(
                          tr['welcome_loading']!,
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
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${tr['version']} ${AppShellLocalConfigs.appVersion} (${AppShellLocalConfigs.appBuildIndex})",
                  style: TextStyle(
                    color: Colors.grey.shade600.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${tr['all_rights_reserved']} © ${DateTime.now().year}",
                  style: TextStyle(
                    color: Colors.grey.shade500.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
