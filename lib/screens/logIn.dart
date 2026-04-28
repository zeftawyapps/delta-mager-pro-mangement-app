import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/conslol-logs/conslot-log.dart';
import 'package:JoDija_tamplites/util/shardeprefrance/shard_check.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_bloc.dart';

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget with AppShellRouterMixin {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? orgName;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // AppRoutes.activeOrgName = widget.params!['orgName']!;
    // orgName = widget.params!['orgName']!;
    // final config = context.read<OrganizationConfigBloc>().organizationConfig;
    // if (config == null) {
    //   widget.goRoute(context, AppRoutes.splash, replace: true);
    // }
    AppRoutes.activeOrgName = widget.getPrams()!['orgName']!;
    orgName = widget.getPrams()!['orgName']!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().checkSavedUser(
        onUserFound: (user) {
          widget.goRoute(context, AppRoutes.welcome, replace: true);
        },
        onUserNotFound: () {},
      );
    });

    final config = context.read<OrganizationConfigBloc>().organizationConfig;
    if (config == null) {
      context.read<OrganizationConfigBloc>().getOrganizationConfigByName(
        AppRoutes.activeOrgName,
      );
    } else {
      _updateTheme(config);
    }
  }

  final _formKey = GlobalKey<FormState>();
  final emailContrall = TextEditingController();
  final passContrall = TextEditingController();
  bool isPass = true;
  ValidationsForm form = ValidationsForm();

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

  void onSubmitted() {
    if (form.form.currentState!.validate()) {
      form.form.currentState!.save();
      var data = form.getInputData();
      final activeOrg = AppRoutes.activeOrgName;

      JDTamplitesConsoleLog.info(
        "LoginScreen: Submitting login for org: $activeOrg",
      );

      context.read<AuthBloc>().loginOrg(
        orgName: orgName!,
        username: data['email'],
        password: data['pass'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppRoutes.activeOrgName = widget.getPrams()!['orgName']!;
    orgName = widget.getPrams()!['orgName']!;

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocListener<
      OrganizationConfigBloc,
      FeaturDataSourceState<OrganizationConfigModel>
    >(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (config) {
            if (config != null) {
              _updateTheme(config);
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
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
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          children: [
                            context.read<SystemBloc>().systemInfo?.logo !=
                                        null &&
                                    context
                                        .read<SystemBloc>()
                                        .systemInfo!
                                        .logo!
                                        .isNotEmpty
                                ? Image.network(
                                    context
                                        .read<SystemBloc>()
                                        .systemInfo!
                                        .logo!,
                                    width: size.width > 600 ? 300 : 250,
                                    height: size.width > 600 ? 200 : 150,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Image.asset(
                                          AppAsset.logo,
                                          width: size.width > 600 ? 300 : 250,
                                          height: size.width > 600 ? 200 : 150,
                                          fit: BoxFit.contain,
                                        ),
                                  )
                                : Image.asset(
                                        AppAsset.logo,
                                        width: size.width > 600 ? 300 : 250,
                                        height: size.width > 600 ? 200 : 150,
                                        fit: BoxFit.contain,
                                      )
                                      .animate()
                                      .fadeIn(duration: 600.ms)
                                      .scale(
                                        begin: const Offset(0.8, 0.8),
                                        end: const Offset(1.0, 1.0),
                                        duration: 600.ms,
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
                      Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Card(
                          elevation: 20,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: BlocConsumer<AuthBloc, FeaturDataSourceState<Users>>(
                            listener: (context, state) {
                              state.itemState.maybeWhen(
                                success: (user) {
                                  if (user != null) {
                                    widget.goRoute(
                                      context,
                                      AppRoutes.welcomWithOrgName(
                                        AppRoutes.activeOrgName,
                                      ),
                                      replace: true,
                                    );
                                  }
                                },
                                failure: (error, reload) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error.message ?? "خطأ في تسجيل الدخول",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  AppRoutes.defaultOrgName =
                                      AppRoutes.activeOrgName;

                                  // مسح البيانات المخزنة في SharedPreferences عند حدوث خطأ
                                  SharedPrefranceChecking()
                                      .clearDataInShardRefrace();
                                },
                                orElse: () {},
                              );
                            },
                            builder: (context, state) {
                              final isLoading = state.itemState.maybeWhen(
                                loading: () => true,
                                orElse: () => false,
                              );

                              return Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'تسجيل الدخول',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                        textAlign: TextAlign.center,
                                      ).animate().fadeIn(delay: 200.ms),
                                      const SizedBox(height: 32),
                                      form.buildChildrenWithColumn(
                                        context: context,
                                        children: [
                                          TextFomrFildValidtion(
                                            controller: emailContrall,
                                            form: form,
                                            baseValidation: [
                                              RequiredValidator(),
                                            ],
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.email,
                                                color: AppColors.primary,
                                              ),
                                              labelText: 'البريد الإلكتروني',
                                            ),
                                            labalText: 'البريد الإلكتروني',
                                            keyData: "email",
                                          ).animate().fadeIn(delay: 400.ms),
                                          const SizedBox(height: 20),
                                          TextFomrFildValidtion(
                                            controller: passContrall,
                                            form: form,
                                            onFieldSubmitted: (v) =>
                                                onSubmitted(),
                                            baseValidation: [
                                              RequiredValidator(),
                                            ],
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.lock,
                                                color: AppColors.primary,
                                              ),
                                              labelText: 'كلمة المرور',
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  isPass
                                                      ? Icons
                                                            .visibility_outlined
                                                      : Icons
                                                            .visibility_off_outlined,
                                                  color: AppColors.primary,
                                                ),
                                                onPressed: () => setState(
                                                  () => isPass = !isPass,
                                                ),
                                              ),
                                            ),
                                            labalText: 'كلمة المرور',
                                            keyData: "pass",
                                            isPssword: isPass,
                                          ).animate().fadeIn(delay: 500.ms),
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            height: 56,
                                            child: ElevatedButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : onSubmitted,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor:
                                                    AppColors.textOnPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: isLoading
                                                  ? SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: AppColors
                                                                .textOnPrimary,
                                                            strokeWidth: 2.5,
                                                          ),
                                                    )
                                                  : const Text(
                                                      'تسجيل الدخول',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                          ).animate().fadeIn(delay: 600.ms),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailContrall.dispose();
    passContrall.dispose();
    super.dispose();
  }
}
