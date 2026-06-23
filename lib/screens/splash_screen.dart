import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/system_models.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/version_check_result.dart';
import 'package:delta_mager_pro_mangement_app/logic/services/version_check_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:JoDija_reposatory/constes/api_urls.dart';

class SplashScreen extends StatefulWidget with AppShellRouterMixin {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isCheckingVersion = false;

  @override
  void initState() {
    super.initState();
    // جلب البيانات عند بدء التشغيل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final systemBloc = context.read<SystemBloc>();
    final configBloc = context.read<OrganizationConfigBloc>();

    // التحقق من الحالة الحالية لكل Bloc لمنع التحميل المتكرر عند إعادة بناء الشاشة (Remount)
    // أو في حالة وجود خطأ سابق (حتى لا يتم الدخول في حلقة مفرغة من الطلبات)

    bool canLoadSystem = true;
    systemBloc.state.itemState.maybeWhen(
      loading: () => canLoadSystem = false,
      success: (_) => canLoadSystem = false,
      failure: (_, __) => canLoadSystem = false,
      orElse: () {},
    );

    if (canLoadSystem) {
      systemBloc.loadSystemInfo();
    }

    bool canLoadConfig = true;
    configBloc.state.itemState.maybeWhen(
      loading: () => canLoadConfig = false,
      success: (_) => canLoadConfig = false,
      failure: (_, __) => canLoadConfig = false,
      orElse: () {},
    );

    if (canLoadConfig) {
      configBloc.getOrganizationConfigByName(AppRoutes.activeOrgName);
    }

    // التحقق الفوري: إذا كانت البيانات محملة مسبقاً، ننتقل مباشرة
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    if (!mounted) return;

    final systemState = context.read<SystemBloc>().state.itemState;
    final configState = context.read<OrganizationConfigBloc>().state.itemState;

    bool systemSuccess = false;
    bool configSuccess = false;

    systemState.maybeWhen(
      success: (data) => systemSuccess = true,
      orElse: () {},
    );

    configState.maybeWhen(
      success: (data) => configSuccess = true,
      orElse: () {},
    );

    // ننتقل فقط إذا نجحت العمليتان معاً
    if (systemSuccess && configSuccess && !_isCheckingVersion) {
      _isCheckingVersion = true;
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _checkAppVersionFlow();
        }
      });
    }
  }

  Future<void> _checkAppVersionFlow() async {
    String platform = 'web';
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        platform = 'android';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        platform = 'ios';
      }
    } catch (_) {}

    final versionCheckResult = await VersionCheckService().checkAppVersion(
      currentVersion: AppShellLocalConfigs.appVersion,
      buildIndex: AppShellLocalConfigs.appBuildIndex,
      appType: 'management_app',
      platform: platform,
      orgId: AppRoutes.activeOrgName,
    );

    if (!mounted) return;

    if (versionCheckResult != null && versionCheckResult.updateAvailable) {
      _showUpdateDialog(versionCheckResult);
    } else {
      _proceedToLogin();
    }
  }

  void _proceedToLogin() {
    if (!mounted) return;

    // Check for saved user first before redirecting to login screen
    context.read<AuthBloc>().checkSavedUser(
      onUserFound: (user) {
        if (mounted) {
          final appChanges = context.read<AppChangesValues>();
          final laseRoute = appChanges.laseRoute;

          // If we reloaded a protected page, navigate back to it
          if (laseRoute != null &&
              laseRoute != AppRoutes.welcome &&
              laseRoute != AppRoutes.splash &&
              !laseRoute.contains('/login') &&
              !laseRoute.contains('/welcom')) {
            widget.goRoute(context, laseRoute, replace: true);
          } else {
            widget.goRoute(context, AppRoutes.welcome, replace: true);
          }
        }
      },
      onUserNotFound: () {
        if (mounted) {
          widget.goRoute(
            context,
            AppRoutes.loginWithOrgName(AppRoutes.activeOrgName),
            replace: true,
          );
        }
      },
    );
  }

  void _showUpdateDialog(VersionCheckResult result) {
    showDialog(
      context: context,
      barrierDismissible:
          !result.forceUpdate, // منع الإغلاق إذا كان التحديث إجبارياً
      builder: (BuildContext context) {
        final primaryColor = AppColors.primary;
        return WillPopScope(
          onWillPop: () async =>
              !result.forceUpdate, // منع زر الرجوع في الأندرويد
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Icon
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            result.forceUpdate
                                ? Icons.system_update_rounded
                                : Icons.new_releases_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result.forceUpdate
                                ? "تحديث إجباري جديد"
                                : "يتوفر تحديث جديد",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "إصدار ${result.latestVersion} (بناء ${result.buildIndex})",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content body
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.forceUpdate
                                ? "لضمان استمرارية تشغيل الخدمات والمبيعات، يجب تحديث التطبيق إلى الإصدار الجديد فوراً."
                                : "يسعدنا أن نقدم لكم هذا التحديث الجديد لتحسين الأداء وإضافة مميزات جديدة.",
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          if (result.releaseNotes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              "أبرز التحديثات والمميزات:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 120),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: result.releaseNotes.map((note) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: primaryColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              note,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          if (!result.forceUpdate) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _proceedToLogin();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(color: primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "لاحقاً",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (result.downloadUrl.isNotEmpty) {
                                  final uri = Uri.parse(result.downloadUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "تحديث الآن",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateTheme(OrganizationConfigModel config) {
    if (config.themes == null) return;
    final themes = config.themes!;
    final Map<String, Color> lightColors = {};
    final Map<String, Color> darkColors = {};

    if (themes.light != null) {
      final l = themes.light!;
      if (l.primary != null) {
        lightColors['primary'] = ColorUtils.fromHex(
          l.primary,
          LightColors.primary,
        );
      }
      if (l.secondary != null) {
        lightColors['secondary'] = ColorUtils.fromHex(
          l.secondary,
          LightColors.secondary,
        );
      }
    }

    if (themes.dark != null) {
      final d = themes.dark!;
      if (d.primary != null) {
        darkColors['primary'] = ColorUtils.fromHex(
          d.primary,
          DarkColors.primary,
        );
      }
      if (d.secondary != null) {
        darkColors['secondary'] = ColorUtils.fromHex(
          d.secondary,
          DarkColors.secondary,
        );
      }
    }

    AppColors.setDynamicColors(light: lightColors, dark: darkColors);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SystemBloc, FeaturDataSourceState<SystemInfoModel>>(
          listener: (context, state) {
            state.itemState.maybeWhen(
              success: (_) => _checkAndNavigate(),
              orElse: () {},
            );
          },
        ),
        BlocListener<
          OrganizationConfigBloc,
          FeaturDataSourceState<OrganizationConfigModel>
        >(
          listener: (context, state) {
            state.itemState.maybeWhen(
              success: (config) {
                if (config != null) _updateTheme(config);
                _checkAndNavigate();
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.darkBackground],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
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
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              BlocBuilder<SystemBloc, FeaturDataSourceState<SystemInfoModel>>(
                builder: (context, systemState) {
                  return BlocBuilder<
                    OrganizationConfigBloc,
                    FeaturDataSourceState<OrganizationConfigModel>
                  >(
                    builder: (context, configState) {
                      // التحقق من وجود أخطاء في أي من الـ Blocs
                      String? errorMessage;
                      VoidCallback? onRetry;

                      systemState.itemState.maybeWhen(
                        failure: (error, retry) {
                          errorMessage = error.message;
                          onRetry = retry;
                        },
                        orElse: () {},
                      );

                      // إذا لم يكن هناك خطأ في SystemBloc، نتحقق من OrganizationConfigBloc
                      if (errorMessage == null) {
                        configState.itemState.maybeWhen(
                          failure: (error, retry) {
                            errorMessage = error.message;
                            onRetry = retry;
                          },
                          orElse: () {},
                        );
                      }

                      if (errorMessage != null) {
                        return _buildErrorUI(errorMessage!, onRetry);
                      }

                      // العرض الافتراضي (التحميل)
                      return _buildSplashUI(AppStrings.appName, "جاري البدء...");
                    },
                  );
                },
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "الإصدار ${AppShellLocalConfigs.appVersion} (${AppShellLocalConfigs.appBuildIndex})",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "جميع الحقوق محفوظة © ${DateTime.now().year}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplashUI(String title, String status) {
    final orgLogo = context
        .read<OrganizationConfigBloc>()
        .organizationConfig
        ?.visual
        ?.logoUrl;
    final systemLogo = context.read<SystemBloc>().systemInfo?.logo;
    final rawLogo = (orgLogo != null && orgLogo.isNotEmpty)
        ? orgLogo
        : ((systemLogo != null && systemLogo.isNotEmpty) ? systemLogo : null);

    final activeLogo = (rawLogo != null && rawLogo.isNotEmpty)
        ? (rawLogo.contains('http') ? rawLogo : '${ApiUrls.IMAGE_BASE_URL}$rawLogo')
        : null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          activeLogo != null
              ? Image.network(
                  activeLogo,
                  width: 120,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset(AppAsset.logo, width: 120),
                )
              : Image.asset(
                  AppAsset.logo,
                  width: 120,
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 40),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: Colors.white,
              backgroundColor: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              minHeight: 6,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildErrorUI(String message, VoidCallback? onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 70,
                  ),
                )
                .animate()
                .shake(duration: 600.ms)
                .scale(duration: 400.ms, curve: Curves.easeOut),
            const SizedBox(height: 32),
            const Text(
              "حدث خطأ أثناء التشغيل",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  "إعادة المحاولة",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
