import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/core/system/data/language_model.dart';

// Re-exporting core data structures for application-wide use
export 'package:matger_pro_core_logic/core/system/data/language_model.dart' show Language;

class LanguageModel extends Language implements BaseViewDataModel {
  LanguageModel({
    required super.code,
    required super.name,
    required super.nativeName,
    super.isDefault = false,
    super.isActive = true,
    super.direction = 'ltr',
    super.createdAt,
  });

  factory LanguageModel.fromData(Language data) {
    return LanguageModel(
      code: data.code,
      name: data.name,
      nativeName: data.nativeName,
      isDefault: data.isDefault,
      isActive: data.isActive,
      direction: data.direction,
      createdAt: data.createdAt,
    );
  }

  @override
  String get id => code;

  @override
  set id(String? value) {
    // code is usually immutable for existing instances
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
