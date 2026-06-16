import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/laaunser.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/sidebar_header_config.dart';
import 'package:delta_mager_pro_mangement_app/configs/sidbarItmes.dart'
    show SidebarItemsConfig;
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/offers_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/cart_provider.dart';
import 'package:matger_pro_core_logic/core/auth/repos/auth_repo.dart';
import 'package:matger_pro_core_logic/core/auth/repos/test_repo.dart';
import 'package:matger_pro_core_logic/core/di/injection_container.dart';
import 'package:matger_pro_core_logic/core/orgnization/repo/organization_repo.dart';
import 'package:matger_pro_core_logic/core/system/repo/system_repo.dart';
import 'package:matger_pro_core_logic/features/commrec/repo/category_repo.dart';
import 'package:matger_pro_core_logic/features/commrec/repo/offer_repo.dart';
import 'package:matger_pro_core_logic/features/commrec/repo/product_repo.dart';
import 'package:matger_pro_core_logic/features/locations/repo/location_repo.dart';
import 'package:matger_pro_core_logic/features/roles/repo/role_repo.dart';
import 'package:matger_pro_core_logic/features/users/repo/user_repo.dart';
import 'package:provider/provider.dart';

import 'configs/app_shell_config.dart';
import 'configs/ui_configs.dart';
import 'consts/constants/theme/app_theme.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_policy_bloc.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/orders_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/order_path_bloc.dart';
import 'package:matger_pro_core_logic/features/workflow/repo/workflow_repo.dart';
import 'package:matger_pro_core_logic/features/commrec/repo/order_repo.dart';
import 'package:matger_pro_core_logic/features/order_path/repo/order_path_repo.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/blog_posts_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/blog_categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/analytics_bloc.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart' show BlogRepo, AnalyticsRepo;

class AppLouncher extends StatefulWidget {
  const AppLouncher({super.key});

  @override
  State<AppLouncher> createState() => _AppLouncherState();
}

class _AppLouncherState extends State<AppLouncher> {
  @override
  void initState() {
    super.initState();
    // تحميل بيانات المستخدم من الكاش عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppChangesValues>().loadUserFromCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppChangesValues()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        BlocProvider(
          create: (context) =>
              OrganizationConfigBloc(repo: sl<OrganizationRepo>()),
        ),
        BlocProvider(create: (context) => SystemBloc(repo: sl<SystemRepo>())),
        BlocProvider(
          create: (context) => AuthBloc(
            authRepo: sl<AuthRepo>(),
            appChangesValues: context.read<AppChangesValues>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<
            OrganizationConfigBloc,
            FeaturDataSourceState<OrganizationConfigModel>
          >(
            builder: (context, state) {
              // استخراج الإعدادات لتكون متاحة لبناء الواجهة والـ Sidebar
              final config = state.itemState.maybeWhen(
                success: (data) => data,
                orElse: () =>
                    context.read<OrganizationConfigBloc>().organizationConfig,
              );

              state.itemState.maybeWhen(
                success: (configData) {
                  if (configData != null && configData.themes != null) {
                    final themes = configData.themes!;
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
                        lightColors['error'] = ColorUtils.fromHex(
                          l.error,
                          LightColors.error,
                        );
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

                    AppColors.setDynamicColors(
                      light: lightColors,
                      dark: darkColors,
                    );
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
                    create: (context) => UsersBloc(
                      repo: sl<UserRepo>(),
                      appChangesValues: context.read<AppChangesValues>(),
                    ),
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
                  BlocProvider(
                    create: (context) => TestBloc(testRep: sl<TestRepo>()),
                  ),
                  BlocProvider(
                    create: (context) => OffersBloc(repo: sl<OfferRepo>()),
                  ),
                  BlocProvider(
                    create: (context) => LocationsBloc(
                      repo: sl<LocationRepo>(),
                      systemRepo: sl<SystemRepo>(),
                    ),
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
                  BlocProvider(
                    create: (context) =>
                        WorkflowManagementBloc(repo: sl<WorkflowRepo>()),
                  ),
                  BlocProvider(
                    create: (context) => OrdersBloc(repo: sl<OrderRepo>()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        OrderPathBloc(repo: sl<OrderPathRepo>()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        BlogPostsBloc(repo: sl<BlogRepo>()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        BlogCategoriesBloc(repo: sl<BlogRepo>()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        AnalyticsBloc(repo: sl<AnalyticsRepo>()),
                  ),
                ],
                titleApp: AppStrings.appName,
                sidebarBackgroundColor: AppColors.primary,
                sidebarTextColor: Colors.white,
                sidebarHoverColor:
                    (AppShellConfigs.isDarkMode
                            ? AppColors.darkBackground
                            : AppColors.background)
                        .withValues(alpha: 0.7),
                sidebarHoverTextColor: AppColors.lightText.withValues(
                  alpha: 0.7,
                ),
                sidebarSelectedColor: AppShellConfigs.isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.background,
                sidebarSelectedIconColor: AppColors.primary,
                sidebarSelectedTextColor: AppColors.primary,

                sidebarIconColor: Colors.white,

                // إضافة الشعار والاسم الديناميكي في الـ Sidebar
                sidebarHeader: SidebarHeaderConfig(
                  backgroundColor: Colors.transparent,
                  // استخدام لوجو المنظمة من الرابط إذا وجد، وإلا اللوجو الافتراضي
                  logoAssetPath: AppAsset.logo,
                  direction: Axis.horizontal,
                  title:
                      config?.layout?.appTitle ??
                      context.read<SystemBloc>().systemInfo?.appName ??
                      AppStrings.appName,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                  logoHight: 50,
                  logoWidth: 50,
                  height: 100,
                  logoFit: BoxFit.contain,
                ),
                sidebarFontSize: 15,
                sidebarExpandedArrowColor: Colors.white70,
                sidebarExpandedBackgroundColor: Colors.transparent,
                sidebarExpandedIconColor: Colors.white,
                sidebarExpandedTextColor: Colors.white,

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
          );
        },
      ),
    );
  }
}
