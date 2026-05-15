import 'dart:convert';
import 'package:flutter/services.dart';

class JsonConfigService {
  static final JsonConfigService _instance = JsonConfigService._internal();
  factory JsonConfigService() => _instance;
  JsonConfigService._internal();

  Map<String, dynamic> _config = {};

  Future<void> init() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json_config/config.json',
      );
      _config = json.decode(response);
    } catch (e) {
       // print('Error loading config.json, using empty config: $e');
      _config = {};
    }
  }

  Map<String, dynamic> get productInput => _config['productInput'] ?? {};
  Map<String, dynamic> get b2bHomeLayout => _config['b2bHomeLayout'] ?? {};

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
