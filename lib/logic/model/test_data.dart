import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_core_logic/models/app_settings.dart';

class TestData extends AppSettings implements BaseViewDataModel {
  TestData({
    required super.success,
    required super.message,
    required super.timestamp,
    required super.environment,
    required super.version,
  });

  @override
  String get id => throw UnimplementedError();

  @override
  Map<String, dynamic> get map => throw UnimplementedError();

  @override
  set id(String? value) {
    // TODO: implement id
  }

  @override
  set map(Map<String, dynamic>? value) {
    // TODO: implement map
  }
}
