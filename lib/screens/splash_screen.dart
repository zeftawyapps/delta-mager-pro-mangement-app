import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/system_models.dart';

class SplashScreen extends StatefulWidget with AppShellRouterMixin {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    if (systemSuccess && configSuccess) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          widget.goRoute(
            context,
            AppRoutes.loginWithOrgName(AppRoutes.activeOrgName),
            replace: true,
          );
        }
      });
    }
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
          child: BlocBuilder<SystemBloc, FeaturDataSourceState<SystemInfoModel>>(
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
        ),
      ),
    );
  }

  Widget _buildSplashUI(String title, String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          context.read<SystemBloc>().systemInfo?.logo != null &&
                  context.read<SystemBloc>().systemInfo!.logo!.isNotEmpty
              ? Image.network(
                  context.read<SystemBloc>().systemInfo!.logo!,
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
