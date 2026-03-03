import 'package:matger_core_logic/config/paoject_config.dart';

class AppBackendEnv {
  final String baseUrl = 'http://localhost:3000/api/v1';
  final String imageUrl = 'http://localhost:3000';
  initConfigration() {
    projectConfig(myBaseUrl: baseUrl, myImageUrl: imageUrl);
  }
}
