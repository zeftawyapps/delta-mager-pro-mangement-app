import 'package:delta_mager_pro_mangement_app/app-louncher.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/services/json_config_service.dart';
import 'package:flutter/material.dart';
import 'package:matger_pro_core_logic/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initCoreLocator();
  
  // ⚙️ تحميل ملف الإعدادات الاستاتيكي JSON لتمكين الـ Whitelabeling ديناميكياً لكل عميل
  final configService = JsonConfigService();
  await configService.init();

  // 🏢 تفعيل وضع العميل وتطبيق الطلبات المخصص (Client App Mode)
  AppShellConfigs.isAdminMode = false; 
  AppShellConfigs.isClientAppMode = true; 
  AppShellConfigs.titleApp = configService.appTitle;
  AppShellConfigs.defaultOrgName = configService.defaultOrgName;
  AppShellLocalConfigs.appVersion = configService.appVersion;
  AppShellLocalConfigs.appBuildIndex = configService.appBuildIndex;

  // 🌍 تحديد بيئة التشغيل للاتصال بالسيرفر
  AppBackendEnv().initConfigration(AppEnvType.prod);

  runApp(const AppLouncher());
}
