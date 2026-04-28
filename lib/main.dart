import 'package:delta_mager_pro_mangement_app/app-louncher.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/services/json_config_service.dart';
import 'package:flutter/material.dart';
import 'package:matger_pro_core_logic/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚙️ إعدادات النظام - يمكنك التحكم في التطبيق بالكامل من هنا
  AppShellConfigs.isAdminMode = false; // true لوضع المسؤول، false لوضع المنظمة
  AppShellConfigs.titleApp = 'Domancy';
  AppShellConfigs.defaultOrgName = 'domansy';

  AppBackendEnv().initConfigration();
  await initCoreLocator();
  await JsonConfigService().init();

  runApp(const AppLouncher());
}
