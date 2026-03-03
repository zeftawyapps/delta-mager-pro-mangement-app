import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/laaunser.dart';
import 'package:delta_mager_pro_mangement_app/configs/sidbarItmes.dart'
    show SidebarItemsConfig;
import 'package:delta_mager_pro_mangement_app/logic/bloc/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_core_logic/core/auth/repos/test_repo.dart';
import 'package:matger_core_logic/core/di/injection_container.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:matger_core_logic/core/auth/repos/auth_repo.dart';

import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:matger_core_logic/features/commrec/repo/category_repo.dart';
import 'package:provider/provider.dart';

import 'configs/app_shell_config.dart';
import 'configs/ui_configs.dart';
import 'consts/constants/theme/app_theme.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AppLouncher extends StatefulWidget {
  const AppLouncher({super.key});

  @override
  State<AppLouncher> createState() => _AppLouncherState();
}

class _AppLouncherState extends State<AppLouncher> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveAppShell(
      extraProvidersAndBlocs: [
        ChangeNotifierProvider(create: (context) => AppChangesValues()),
        BlocProvider(
          create: (context) => AuthBloc(
            authRepo: sl<AuthRepo>(),
            appChangesValues: context.read<AppChangesValues>(),
          ),
        ),
        BlocProvider(create: (context) => TestBloc(testRep: sl<TestRepo>())),
        BlocProvider(
          create: (context) => CategoriesBloc(repo: sl<CategoryRepo>()),
        ),
      ],
      titleApp: "Delta Mager Pro",
      // Sidebar Colors from Config
      sidebarBackgroundColor: AppShellConfigs.sidebarBackgroundColor,
      sidebarTextColor: AppShellConfigs.sidebarTextColor,
      sidebarHoverColor: AppShellConfigs.sidebarHoverColor,
      sidebarHoverTextColor: AppShellConfigs.sidebarHoverTextColor,
      sidebarSelectedColor: AppShellConfigs.sidebarSelectedColor,
      sidebarSelectedIconColor: AppShellConfigs.sidebarSelectedIconColor,
      sidebarSelectedTextColor: AppShellConfigs.sidebarSelectedTextColor,
      sidebarIconColor: AppShellConfigs.sidebarIconColor,
      sidebarExpandedArrowColor: AppShellConfigs.sidebarExpandedArrowColor,
      sidebarExpandedBackgroundColor:
          AppShellConfigs.sidebarExpandedBackgroundColor,
      sidebarExpandedIconColor: AppShellConfigs.sidebarExpandedIconColor,
      sidebarExpandedTextColor: AppShellConfigs.sidebarExpandedTextColor,

      animationDuration: AppShellConfigs.animationDuration,
      languageCode: AppShellConfigs.languageCode,
      loclizationLangs: LocalizationConfigs.buildLocalizations(),
      extraLocalizationsDelegates: [FlutterQuillLocalizations.delegate],
      animationType: AppShellConfigs.animationType,

      showAppBarOnSmallScreen: AppShellConfigs.showAppBarOnSmallScreen,
      debugShowCheckedModeBanner: AppShellConfigs.debugShowCheckedModeBanner,
      initRouter: AppShellConfigs.initRouter,
      // initRouter: "/analytics",
      showAppBarOnLargeScreen: AppShellConfigs.showAppBarOnLargeScreen,
      errorScreen: ErrorsScreen(),
      darkTheme: AppTheme.darkTheme,
      lightTheme: AppTheme.lightTheme,
      isDarkMode: AppShellConfigs.isDarkMode,
      smallScreenAppBar: AppBarConfigs.buildSmallScreenAppBar(context),
      largeScreenAppBar: AppBarConfigs.buildLargeScreenAppBar(context),
      sidebarItems: SidebarItemsConfig().items,
    );
  }
}
