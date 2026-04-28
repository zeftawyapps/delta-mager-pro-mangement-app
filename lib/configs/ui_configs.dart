import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/app_bar_config.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/localization/loaclized_init.dart';
import 'package:JoDija_tamplites/util/localization/loclization/app_localizations.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/user_input_form.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/organization_input_form.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/change_password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class DefaultAppLocal extends AppLocal {
  @override
  Map<String, String> get values => {};
}

class LocalizationConfigs {
  static Map<String, AppLocalizationsInit> buildLocalizations() {
    return {'ar': DefaultAppLocal(), 'en': DefaultAppLocal()};
  }
}

class AppBarConfigs {
  static AppBarConfig buildSmallScreenAppBar(BuildContext context) {
    // جلب بيانات المنظمة والنظام
    final config = context
        .read<OrganizationConfigBloc>()
        .state
        .itemState
        .maybeWhen(success: (data) => data, orElse: () => null);

    final systemInfo = context.read<SystemBloc>().state.itemState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );

    final String title =
        config?.layout?.appTitle ?? systemInfo?.appName ?? 'Domancy';

    return AppBarConfig(title: title, actions: [_buildUserMenu(context)]);
  }

  static AppBarConfig buildLargeScreenAppBar(BuildContext context) {
    final config = context
        .read<OrganizationConfigBloc>()
        .state
        .itemState
        .maybeWhen(success: (data) => data, orElse: () => null);

    final systemInfo = context.read<SystemBloc>().state.itemState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );

    final String title = config?.layout?.appTitle != null
        ? "${config!.layout!.appTitle} - نظام الإدارة"
        : systemInfo?.appName ?? 'Domancy Management System';

    return AppBarConfig(title: title, actions: [_buildUserMenu(context)]);
  }

  /// زر المستخدم والقائمة المنسدلة (الخيارات الأساسية)
  static Widget _buildUserMenu(BuildContext context) {
    return Consumer<AppChangesValues>(
      builder: (context, appChanges, child) {
        final user = appChanges.user;
        if (user == null) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final canUpdateOrg =
            user.permissions?.contains('organization:update') ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 8,
            tooltip: 'قائمة المستخدم',
            onSelected: (value) => _handleMenuSelection(context, value, user),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'الملف الشخصي',
                  iconColor: Colors.blue,
                ),
              ),
              if (canUpdateOrg)
                PopupMenuItem<String>(
                  value: 'organization',
                  child: _buildMenuItem(
                    icon: Icons.business_outlined,
                    title: 'بيانات المنظمة',
                    iconColor: Colors.green,
                  ),
                ),
              PopupMenuItem<String>(
                value: 'change_password',
                child: _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'تغيير كلمة المرور',
                  iconColor: Colors.orange,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: _buildMenuItem(
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  iconColor: Colors.red,
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFF1A2332),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: isDark ? Colors.white : const Color(0xFFD4AF37),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.roles?.join(', ') ?? 'مستخدم',
                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// معالجة اختيار العناصر من القائمة
  static void _handleMenuSelection(
    BuildContext context,
    String value,
    Users user,
  ) {
    switch (value) {
      case 'profile':
        _showProfileDialog(context, user);
        break;
      case 'organization':
        _showOrganizationDialog(context);
        break;
      case 'change_password':
        _showChangePasswordDialog(context);
        break;
      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  /// إظهار نافذة الملف الشخصي
  static void _showProfileDialog(BuildContext context, Users user) {
    final profile = UserViewProfileModel(
      userId: user.username,
      username: user.username,
      email: user.email,
      phone: user.phone,
      roles: user.roles,
      organizationId: user.organizationId,
      isActiveProfile: user.isActive ?? true,
    );

    showCustomInputDialog(
      context: context,
      content: UserInputForm(
        user: profile,
        organizationId: user.organizationId,
        isMe: true,
      ),
      width: 600,
      height: 500,
    );
  }

  /// إظهار نافذة بيانات المنظمة
  static void _showOrganizationDialog(BuildContext context) {
    showCustomInputDialog(
      context: context,
      content: const OrganizationInputForm(),
      width: 800,
      height: 850,
    );
  }

  /// إظهار نافذة تغيير كلمة المرور
  static void _showChangePasswordDialog(BuildContext context) {
    showCustomInputDialog(
      context: context,
      content: const ChangePasswordForm(),
      width: 500,
      height: 450,
    );
  }

  /// تنفيذ عملية تسجيل الخروج
  static void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().signOut();
              AppShellRoutes().goRoute(
                context,
                AppRoutes.welcome,
                replace: true,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  /// مساعد بناء عناصر القائمة
  static Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class ErrorsScreen extends StatelessWidget {
  const ErrorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Error Screen')));
  }
}
