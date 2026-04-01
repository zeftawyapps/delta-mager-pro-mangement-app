import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/laaunser.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/sidebar_header_config.dart';
import 'package:delta_mager_pro_mangement_app/configs/sidbarItmes.dart'
    show SidebarItemsConfig;
import 'package:delta_mager_pro_mangement_app/logic/bloc/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_core_logic/features/users/repo/user_repo.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:matger_core_logic/core/auth/repos/test_repo.dart';
import 'package:matger_core_logic/core/di/injection_container.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:matger_core_logic/core/auth/repos/auth_repo.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:matger_core_logic/core/orgnization/repo/organization_repo.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:matger_core_logic/features/commrec/repo/category_repo.dart';
import 'package:matger_core_logic/features/commrec/repo/product_repo.dart';
import 'package:matger_core_logic/features/roles/repo/role_repo.dart';
import 'package:provider/provider.dart';

import 'configs/app_shell_config.dart';
import 'configs/ui_configs.dart';
import 'consts/constants/theme/app_theme.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_policy_bloc.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';

class AppLouncher extends StatefulWidget {
  const AppLouncher({super.key});

  @override
  State<AppLouncher> createState() => _AppLouncherState();
}

class _AppLouncherState extends State<AppLouncher> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              OrganizationConfigBloc(repo: sl<OrganizationRepo>()),
        ),
      ],
      child:
          BlocBuilder<
            OrganizationConfigBloc,
            FeaturDataSourceState<OrganizationConfigModel>
          >(
            builder: (context, state) {
              state.itemState.maybeWhen(
                success: (config) {
                  if (config != null && config.themes != null) {
                    final themes = config.themes!;
                    final Map<String, Color> lightColors = {};
                    final Map<String, Color> darkColors = {};

                    if (themes.light != null) {
                      final l = themes.light!;
                      if (l.primary != null) lightColors['primary'] = ColorUtils.fromHex(l.primary, LightColors.primary);
                      if (l.secondary != null) lightColors['secondary'] = ColorUtils.fromHex(l.secondary, LightColors.secondary);
                      if (l.background != null) lightColors['background'] = ColorUtils.fromHex(l.background, LightColors.background);
                      if (l.surface != null) lightColors['surface'] = ColorUtils.fromHex(l.surface, LightColors.surface);
                      if (l.onPrimary != null) lightColors['textOnPrimary'] = ColorUtils.fromHex(l.onPrimary, LightColors.textOnPrimary);
                      if (l.error != null) lightColors['error'] = ColorUtils.fromHex(l.error, LightColors.error);
                      if (l.success != null) lightColors['success'] = ColorUtils.fromHex(l.success, LightColors.success);
                      if (l.warning != null) lightColors['warning'] = ColorUtils.fromHex(l.warning, LightColors.warning);
                    }

                    if (themes.dark != null) {
                      final d = themes.dark!;
                      if (d.primary != null) darkColors['primary'] = ColorUtils.fromHex(d.primary, DarkColors.primary);
                      if (d.secondary != null) darkColors['secondary'] = ColorUtils.fromHex(d.secondary, DarkColors.secondary);
                      if (d.background != null) darkColors['background'] = ColorUtils.fromHex(d.background, DarkColors.background);
                      if (d.surface != null) darkColors['surface'] = ColorUtils.fromHex(d.surface, DarkColors.surface);
                    }

                    AppColors.setDynamicColors(light: lightColors, dark: darkColors);
                  }
                },
                orElse: () {},
              );

              return AdaptiveAppShell(
                initRouter: AppShellConfigs.initRouter,
                extraProvidersAndBlocs: [
                  BlocProvider(
                    create: (context) => RolesBloc(repo: sl<RoleRepo>()),
                  ),
                  BlocProvider(
                    create: (context) => UsersBloc(repo: sl<UserRepo>()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        OrganizationsBloc(repo: sl<OrganizationRepo>()),
                  ),
                  BlocProvider(
                    create: (context) => AdminOrganizationConfigBloc(
                      repo: sl<OrganizationRepo>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) =>
                        AdminOrganizationsBloc(repo: sl<OrganizationRepo>()),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => AppChangesValues(),
                  ),
                  BlocProvider(
                    create: (context) => AuthBloc(
                      authRepo: sl<AuthRepo>(),
                      appChangesValues: context.read<AppChangesValues>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => TestBloc(testRep: sl<TestRepo>()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        CategoriesBloc(repo: sl<CategoryRepo>()),
                  ),
                  BlocProvider(
                    create: (context) => ProductsBloc(repo: sl<ProductRepo>()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        OrganizationPolicyBloc(repo: sl<OrganizationRepo>()),
                  ),
                ],
                titleApp: AppStrings.appName,
                sidebarBackgroundColor: AppShellConfigs.isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.background,
                sidebarTextColor: AppShellConfigs.isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.darkText,
                sidebarHoverColor: AppShellConfigs.isDarkMode
                    ? AppColors.darkSurface
                    : AppColors.surface,
                sidebarHoverTextColor: AppShellConfigs.isDarkMode
                    ? AppColors.primary
                    : AppColors.secondary,
                sidebarSelectedColor: AppColors.primary,
                sidebarSelectedIconColor: AppColors.secondary,
                sidebarSelectedTextColor: AppColors.secondary,
                sidebarIconColor: AppColors.primary,

                // إضافة الشعار في الـ Sidebar
                sidebarHeader: SidebarHeaderConfig(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  logoAssetPath: AppAsset.logo,
                  title: AppStrings.appName,
                  titleStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  logoHight: 70,
                  logoWidth: 120,
                  height: 150,
                  logoFit: BoxFit.contain,
                ),

                sidebarExpandedArrowColor: AppShellConfigs.isDarkMode
                    ? Colors.white70
                    : Colors.black87,
                sidebarExpandedBackgroundColor: AppShellConfigs.isDarkMode
                    ? AppColors.darkSurface
                    : AppColors.surfaceVariant,
                sidebarExpandedIconColor: AppColors.primary,
                sidebarExpandedTextColor: AppShellConfigs.isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.darkText,

                animationDuration: AppShellConfigs.animationDuration,
                languageCode: AppShellConfigs.languageCode,
                loclizationLangs: LocalizationConfigs.buildLocalizations(),
                extraLocalizationsDelegates: [
                  FlutterQuillLocalizations.delegate,
                ],
                animationType: AppShellConfigs.animationType,

                showAppBarOnSmallScreen:
                    AppShellConfigs.showAppBarOnSmallScreen,
                debugShowCheckedModeBanner:
                    AppShellConfigs.debugShowCheckedModeBanner,
                showAppBarOnLargeScreen:
                    AppShellConfigs.showAppBarOnLargeScreen,
                errorScreen: ErrorsScreen(),
                darkTheme: AppTheme.darkTheme,
                lightTheme: AppTheme.lightTheme,
                isDarkMode: AppShellConfigs.isDarkMode,
                smallScreenAppBar: AppBarConfigs.buildSmallScreenAppBar(
                  context,
                ),
                largeScreenAppBar: AppBarConfigs.buildLargeScreenAppBar(
                  context,
                ),
                sidebarItems: SidebarItemsConfig().items,
              );
            },
          ),
    );
  }
}
