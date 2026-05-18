import 'package:delta_mager_pro_mangement_app/logic/services/json_config_service.dart';
import 'package:matger_pro_core_logic/config/paoject_config.dart';

enum AppEnvType { local, dev, prod }

class AppBackendEnv {
  // ⚙️ يتم تحديد بيئة التشغيل من خلال تمريرها في main.dart
  static AppEnvType _currentEnv = AppEnvType.prod;

  static AppEnvType get currentEnv => _currentEnv;

  String get baseUrl {
    final customUrl = JsonConfigService().clientBaseUrl;
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    switch (_currentEnv) {
      case AppEnvType.local:
        return 'http://localhost:8080/api/v1';
      case AppEnvType.dev:
        return 'https://deltamatger-dev-804546043960.europe-west1.run.app/api/v1'; // رابط التطوير
      case AppEnvType.prod:
        return 'https://deltamatger-804546043960.europe-west1.run.app/api/v1';
    }
  }

  String get imageUrl {
    final customImageUrl = JsonConfigService().clientImageUrl;
    if (customImageUrl.isNotEmpty) {
      return customImageUrl;
    }

    switch (_currentEnv) {
      case AppEnvType.local:
        return 'http://localhost:8080';
      case AppEnvType.dev:
        return 'https://deltamatger-dev-804546043960.europe-west1.run.app'; // رابط صور التطوير
      case AppEnvType.prod:
        return 'https://deltamatger-804546043960.europe-west1.run.app';
    }
  }

  initConfigration(AppEnvType env) {
    _currentEnv = env;
    projectConfig(myBaseUrl: baseUrl, myImageUrl: imageUrl);
    ProjectAPIHeader.setLanguage("ar");
  }
}

