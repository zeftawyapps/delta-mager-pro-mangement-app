import 'package:delta_mager_pro_mangement_app/app-louncher.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/logic/services/json_config_service.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/localization/loclization/laoclization.inits.dart';
import 'package:matger_pro_core_logic/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🛡️ حماية محرك Flutter الفراغي من الكراش عند مواجهة أي بايت UTF-8 مكسور في الـ Inspector/DevTools
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('InvalidInputError') ||
        details.exception.toString().contains('FormatException')) {
      debugPrint('⚠️ Warning caught: ${details.exception}');
      return;
    }
    FlutterError.presentError(details);
  };

  await initCoreLocator();

  // ⚙️ تحميل ملف الإعدادات الاستاتيكي JSON أولاً لتمكين الـ Whitelabeling ديناميكياً لكل عميل
  final configService = JsonConfigService();
  await configService.init();

  // ⚙️ إعدادات النظام - يتم ضبطها ديناميكياً بناءً على ملف config.json للعميل
  AppShellConfigs.isAdminMode =
      configService.isAdminMode; // true لوضع المسؤول، false لوضع المنظمة
  AppShellConfigs.titleApp = configService.appTitle;
  AppShellConfigs.defaultOrgName = configService.defaultOrgName;
  // 🌐 اللغة الافتراضية من إعدادات العميل (مصدر واحد للواجهة + الـ API)
  AppShellConfigs.languageCode = configService.defaultLanguage;
  AppShellLocalConfigs.appVersion = configService.appVersion;
  AppShellLocalConfigs.appBuildIndex = configService.appBuildIndex;

  // 🌍 تحديد بيئة التشغيل للاتصال بالسيرفر ديناميكياً من ملف الـ YAML
  final envType = AppEnvType.values.firstWhere(
    (e) => e.name == configService.env,
    orElse: () => AppEnvType.local,
  );
  AppBackendEnv().initConfigration(envType);

  // 🌐 تهيئة الترجمة مبكراً قبل بناء الواجهة حتى تكون متاحة عند تقييم
  // عناصر الـ Sidebar (التي تُقيَّم قبل بناء AdaptiveAppShell)
  LocalizationInit(
    LocalizationConfigs.buildLocalizations(),
  ).setAppLocal(AppShellConfigs.languageCode);

  runApp(const AppLouncher());
}
