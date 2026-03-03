import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';

import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
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

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget with AppShellRouterMixin {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailContrall = TextEditingController(
    text: !AppShellConfigs.isProduction ? 'new55owne5r' : '',
  );
  final passContrall = TextEditingController(
    text: !AppShellConfigs.isProduction ? 'Password@123' : '',
  );
  bool isPass = true;
  ValidationsForm form = ValidationsForm();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().checkSavedUser(
        onUserFound: (user) {
          widget.goRoute(context, AppRoutes.welcome, replace: true);
        },
        onUserNotFound: () {},
      );
    });
  }

  @override
  void dispose() {
    emailContrall.dispose();
    passContrall.dispose();
    super.dispose();
  }

  void onSubmitted() {
    if (form.form.currentState!.validate()) {
      form.form.currentState!.save();
      var data = form.getInputData();
      context.read<AuthBloc>().signeIn(map: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkAccent,
                  AppColors.darkBackground,
                  AppColors.decorativeDark,
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.decorative.withValues(alpha: 0.30),
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
                color: AppColors.decorative.withValues(alpha: 0.40),
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
                          Image.asset(
                                AppAsset.imgplaceholder,
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
                          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Card(
                        elevation: 20,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.2),
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
                                    AppRoutes.welcome,
                                    replace: true,
                                  );
                                }
                              },
                              failure: (error, reload) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "فشل في تسجيل الدخول: ${error.message}",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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
                                    const SizedBox(height: 8),
                                    Text(
                                      'مرحباً بك مرة أخرى',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                      textAlign: TextAlign.center,
                                    ).animate().fadeIn(delay: 300.ms),
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
                                            )
                                            .animate()
                                            .fadeIn(delay: 400.ms)
                                            .slideX(begin: -0.2, end: 0),
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
                                                  onPressed: () {
                                                    setState(() {
                                                      isPass = !isPass;
                                                    });
                                                  },
                                                ),
                                              ),
                                              labalText: 'كلمة المرور',
                                              keyData: "pass",
                                              isPssword: isPass,
                                            )
                                            .animate()
                                            .fadeIn(delay: 500.ms)
                                            .slideX(begin: -0.2, end: 0),
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
                                                      AppColors.secondary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                                child: isLoading
                                                    ? const SizedBox(
                                                        height: 24,
                                                        width: 24,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
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
                                            )
                                            .animate()
                                            .fadeIn(delay: 600.ms)
                                            .slideY(begin: 0.2, end: 0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(),
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
