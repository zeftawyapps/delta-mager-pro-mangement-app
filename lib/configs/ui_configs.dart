import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/app_bar_config.dart';
import 'package:JoDija_tamplites/util/localization/loaclized_init.dart';
import 'package:JoDija_tamplites/util/localization/loclization/app_localizations.dart';
import 'package:flutter/material.dart';

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
    return AppBarConfig(
      title: 'Domancy',
      actions: [_buildUserMenu(context)],
    );
  }

  static AppBarConfig buildLargeScreenAppBar(BuildContext context) {
    return AppBarConfig(
      title: 'Domancy Management System',
      actions: [_buildUserMenu(context)],
    );
  }

  /// زر المستخدم والقائمة المنسدلة (الخيارات الثلاثة الأساسية)
  static Widget _buildUserMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        tooltip: 'قائمة المستخدم',
        onSelected: (value) {
          // جاري إضافة منطق الضغطة لكل خيار هنا
          debugPrint('تم اختيار: $value');
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'profile',
            child: _buildMenuItem(
              icon: Icons.person_outline,
              title: 'الملف الشخصي',
              iconColor: Colors.blue,
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
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar Circle
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF1A2332),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: isDark ? Colors.white : const Color(0xFFD4AF37),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              // User Info Placeholder
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اسم المستخدم',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'مسؤول النظام',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey,
                    ),
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
