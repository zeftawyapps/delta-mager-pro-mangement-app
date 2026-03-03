import 'dart:async';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

// ignore: must_be_immutable
class WelcomScreen extends StatefulWidget with AppShellRouterMixin {
  WelcomScreen({super.key});

  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      // المهمة حالياً هي الانتقال لشاشة التحليلات
      widget.goRoute(context, AppRoutes.analyses, replace: true);
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
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAsset.imgplaceholder,
                    width: size.width > 600 ? 300 : 250,
                    height: size.width > 600 ? 200 : 150,
                    fit: BoxFit.contain,
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  const SizedBox(height: 24),
                  Text(
                    'مرحباً بك',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
