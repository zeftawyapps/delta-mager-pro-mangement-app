import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_core_logic/core/orgnization/data/organization_config.dart';

// Re-exporting core data structures for application-wide use
export 'package:matger_core_logic/core/orgnization/data/organization_config.dart'
    show
        OrganizationConfig,
        VisualConfig,
        ThemesConfig,
        LayoutConfig,
        SystemLicenseConfig;

class OrganizationConfigModel extends OrganizationConfig
    implements BaseViewDataModel {
  OrganizationConfigModel({
    required super.id,
    super.visual,
    super.themes,
    super.layout,
    super.systemLicense,
    super.features,
    super.productInput,
  });

  factory OrganizationConfigModel.fromData(OrganizationConfig data) {
    return OrganizationConfigModel(
      id: data.id,
      visual: data.visual,
      themes: data.themes,
      layout: data.layout,
      systemLicense: data.systemLicense,
      features: data.features,
      productInput: data.productInput,
    );
  }

  // The superclass OrganizationConfig already defines a final `id` property,
  // so we only implement the setter for BaseViewDataModel compatibility.
  @override
  set id(String? value) {
    // id is final in OrganizationConfig
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
