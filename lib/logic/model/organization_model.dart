import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_model.dart';

// Re-exporting core data structures for application-wide use
export 'package:matger_pro_core_logic/core/orgnization/data/organization_model.dart'
    show LocationData, OrganizationData;

class OrganizationModel extends OrganizationData implements BaseViewDataModel {
  OrganizationModel({
    required super.id,
    required super.orgName,
    required super.name,
    required super.ownerId,
    required super.address,
    required super.phone,
    required super.email,
    super.countryId,
    super.governorateId,
    super.cityId,
    super.location,
    super.isActive = true,
    super.isDataComplete = false,
    super.isTemplate = false,

    super.meta,
  });

  factory OrganizationModel.fromData(OrganizationData data) {
    return OrganizationModel(
      id: data.id,
      orgName: data.orgName,
      name: data.name,
      ownerId: data.ownerId,
      address: data.address,
      phone: data.phone,
      email: data.email,
      countryId: data.countryId,
      governorateId: data.governorateId,
      cityId: data.cityId,
      location: data.location,
      isActive: data.isActive,
      isDataComplete: data.isDataComplete,
      isTemplate: data.isTemplate,

      meta: data.meta,
    );
  }

  @override
  String get id => super.id;

  @override
  set id(String? value) {
    // id is final in OrganizationData
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
