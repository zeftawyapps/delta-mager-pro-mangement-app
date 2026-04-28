import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/core/system/data/system_models.dart';

// Re-exporting core data structures for application-wide use
export 'package:matger_pro_core_logic/core/system/data/system_models.dart'
    show SystemInfo, BootstrapRequest;

class SystemInfoModel extends SystemInfo implements BaseViewDataModel {
  SystemInfoModel({
    required super.appName,
    required super.orgName,
    required super.orgId,
    required super.version,
    required super.isBootstrapped,
    required super.defaultLanguage,
    required super.licenseKey,
    super.licenseExpiryDate,
    super.maintenanceMode = false,
    super.logo,
  });

  factory SystemInfoModel.fromData(SystemInfo data) {
    return SystemInfoModel(
      appName: data.appName,
      orgName: data.orgName,
      orgId: data.orgId,
      version: data.version,
      isBootstrapped: data.isBootstrapped,
      defaultLanguage: data.defaultLanguage,
      licenseKey: data.licenseKey,
      licenseExpiryDate: data.licenseExpiryDate,
      maintenanceMode: data.maintenanceMode,
      logo: data.logo,
    );
  }

  @override
  String get id => orgId;

  @override
  set id(String? value) {
    // orgId is usually immutable in SystemInfo context
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
