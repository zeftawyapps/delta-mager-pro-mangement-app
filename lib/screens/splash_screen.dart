import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/logic/services/json_config_service.dart';
import 'package:JoDija_tamplites/util/conslol-logs/conslot-log.dart';

class SplashScreen extends StatefulWidget with AppShellRouterMixin {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configBloc = context.read<OrganizationConfigBloc>();
      final state = configBloc.state.itemState;
      final config = state.maybeWhen(success: (c) => c, orElse: () => null);

      if (config != null) {
        // إذا رُفعت الصفحة بالـ Success مسبقاً، حدث ووجه فوراً
        _updateTheme(config);
        JsonConfigService().updateProductInput(config.productInput); // 🆕 تحديث إعدادات المدخلات
        Future.delayed(Duration(seconds: 1));
        widget.goRoute(
          context,
          AppRoutes.loginWithOrgName(AppRoutes.activeOrgName),
          replace: false,
        );
      } else {
        // وإلا، ابدأ التحميل من السيرفر
        configBloc.getOrganizationConfigByName(AppRoutes.activeOrgName);
      }
    });
  }

  void _updateTheme(OrganizationConfigModel config) {
    if (config.themes == null) return;
    final themes = config.themes!;

    final Map<String, Color> lightColors = {};
    final Map<String, Color> darkColors = {};

    if (themes.light != null) {
      final l = themes.light!;
      if (l.primary != null)
        lightColors['primary'] = ColorUtils.fromHex(
          l.primary,
          LightColors.primary,
        );
      if (l.secondary != null)
        lightColors['secondary'] = ColorUtils.fromHex(
          l.secondary,
          LightColors.secondary,
        );
      if (l.background != null)
        lightColors['background'] = ColorUtils.fromHex(
          l.background,
          LightColors.background,
        );
      if (l.surface != null)
        lightColors['surface'] = ColorUtils.fromHex(
          l.surface,
          LightColors.surface,
        );
      if (l.onPrimary != null)
        lightColors['textOnPrimary'] = ColorUtils.fromHex(
          l.onPrimary,
          LightColors.textOnPrimary,
        );
      if (l.error != null)
        lightColors['error'] = ColorUtils.fromHex(l.error, LightColors.error);
      if (l.success != null)
        lightColors['success'] = ColorUtils.fromHex(
          l.success,
          LightColors.success,
        );
      if (l.warning != null)
        lightColors['warning'] = ColorUtils.fromHex(
          l.warning,
          LightColors.warning,
        );
    }

    if (themes.dark != null) {
      final d = themes.dark!;
      if (d.primary != null)
        darkColors['primary'] = ColorUtils.fromHex(
          d.primary,
          DarkColors.primary,
        );
      if (d.secondary != null)
        darkColors['secondary'] = ColorUtils.fromHex(
          d.secondary,
          DarkColors.secondary,
        );
      if (d.background != null)
        darkColors['background'] = ColorUtils.fromHex(
          d.background,
          DarkColors.background,
        );
      if (d.surface != null)
        darkColors['surface'] = ColorUtils.fromHex(
          d.surface,
          DarkColors.surface,
        );
    }

    AppColors.setDynamicColors(light: lightColors, dark: darkColors);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      OrganizationConfigBloc,
      FeaturDataSourceState<OrganizationConfigModel>
    >(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (config) {
            JDTamplitesConsoleLog.success(
              "SplashScreen: Config loaded successfully for: ${AppRoutes.activeOrgName}",
            );
            if (config != null) {
              _updateTheme(config);
              JsonConfigService().updateProductInput(config.productInput); // 🆕 تحديث إعدادات المدخلات
            } else {
              JDTamplitesConsoleLog.warn("SplashScreen: Config data is null");
            }
            widget.goRoute(
              context,
              AppRoutes.loginWithOrgName(AppRoutes.activeOrgName),
              replace: true,
            );
          },
          failure: (error, reload) {
            JDTamplitesConsoleLog.error(
              "SplashScreen: Failed to load config: $error",
            );
            widget.goRoute(
              context,
              AppRoutes.loginWithOrgName(AppRoutes.activeOrgName),
              replace: false,
            );
          },
          orElse: () {
            JDTamplitesConsoleLog.info(
              "SplashScreen: Current state is other than success/failure",
            );
          },
        );
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [LightColors.primary, LightColors.darkBackground],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  "جاري تحميل إعدادات ${AppRoutes.activeOrgName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
