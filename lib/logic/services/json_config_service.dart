import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class JsonConfigService {
  static final JsonConfigService _instance = JsonConfigService._internal();
  factory JsonConfigService() => _instance;
  JsonConfigService._internal();

  Map<String, dynamic> _config = {};

  Future<void> init() async {
    try {
      // 1. تحميل الإعدادات الرئيسية العامة لتحديد العميل النشط
      final String response = await rootBundle.loadString(
        'assets/json_config/config.yaml',
      );
      final YamlMap yamlMap = loadYaml(response);
      final String activeClient = yamlMap['activeClient'] ?? 'domansy';

      // 2. تحميل ملف العميل النشط مباشرة كإعداد أساسي وحيد للتطبيق
      final String clientResponse = await rootBundle.loadString(
        'assets/json_config/clients/$activeClient.yaml',
      );
      final YamlMap clientYamlMap = loadYaml(clientResponse);
      _config = _yamlToMap(clientYamlMap);
      
      // حفظ اسم العميل النشط في الإعدادات للاستخدام البرمجي
      _config['activeClient'] = activeClient;
    } catch (e) {
      // print('Error loading configuration: $e');
      _config = {};
    }
  }

  // دالة مساعدة لتحويل YamlMap المعقد ديناميكياً إلى Map قياسي
  Map<String, dynamic> _yamlToMap(YamlMap yamlMap) {
    final Map<String, dynamic> map = {};
    for (final key in yamlMap.keys) {
      final value = yamlMap[key];
      if (value is YamlMap) {
        map[key.toString()] = _yamlToMap(value);
      } else if (value is YamlList) {
        map[key.toString()] = value.map((item) {
          if (item is YamlMap) {
            return _yamlToMap(item);
          }
          return item;
        }).toList();
      } else {
        map[key.toString()] = value;
      }
    }
    return map;
  }

  Map<String, dynamic> get productInput => _config['productInput'] ?? {};
  Map<String, dynamic> get b2bHomeLayout => _config['b2bHomeLayout'] ?? {};
  Map<String, dynamic> get appBranding => _config['appBranding'] ?? {};
  Map<String, dynamic> get branding => appBranding;
  String get appTitle => appBranding['appTitle'] ?? 'Domancy';
  String get defaultOrgName => appBranding['defaultOrgName'] ?? 'domansy';
  String get appVersion => _config['appVersion'] ?? '1.0.0';
  int get appBuildIndex => _config['appBuildIndex'] ?? 100;
  String get activeClient => _config['activeClient'] ?? 'domansy';
  String get clientBaseUrl => _config['baseUrl'] ?? '';
  String get clientImageUrl => _config['imageUrl'] ?? '';

  // 🟢 تحديث الإعدادات برمجياً لمزامنتها مع الـ Bloc فور التحميل أو الحفظ
  void updateProductInput(Map<String, dynamic>? data) {
    if (data != null) {
      _config['productInput'] = data;
    }
  }

  void updateB2bHomeLayout(Map<String, dynamic>? data) {
    if (data != null) {
      _config['b2bHomeLayout'] = data;
    }
  }
}
