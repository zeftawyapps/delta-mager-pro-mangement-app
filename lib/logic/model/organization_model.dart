import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_core_logic/core/orgnization/data/organization_model.dart';

// Re-exporting core data structures for application-wide use
export 'package:matger_core_logic/core/orgnization/data/organization_model.dart'
    show LocationData, OrganizationData;

class OrganizationModel extends OrganizationData implements BaseViewDataModel {
  OrganizationModel({
    required super.organizationId,
    required super.name,
    required super.ownerId,
    required super.address,
    required super.phone,
    required super.email,
    super.location,
    super.isActive = true,
    super.isDataComplete = false,
    super.meta,
  });

  factory OrganizationModel.fromData(OrganizationData data) {
    return OrganizationModel(
      organizationId: data.organizationId,
      name: data.name,
      ownerId: data.ownerId,
      address: data.address,
      phone: data.phone,
      email: data.email,
      location: data.location,
      isActive: data.isActive,
      isDataComplete: data.isDataComplete,
      meta: data.meta,
    );
  }

  @override
  String? get id => organizationId;

  @override
  set id(String? value) {
    // id is final in OrganizationData (organizationId)
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
