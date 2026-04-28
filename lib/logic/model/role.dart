import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/roles/data/role_data_model.dart';

class RoleModel extends RoleDataModel implements BaseViewDataModel {
  RoleModel({
    super.id,
    required super.name,
    super.displayName,
    super.description,
    super.permissions,
    super.isActive,
    super.organizationId,
    super.meta,
  });

  factory RoleModel.fromData(RoleDataModel data) {
    return RoleModel(
      id: data.id,
      name: data.name,
      displayName: data.displayName,
      description: data.description,
      permissions: data.permissions,
      isActive: data.isActive,
      organizationId: data.organizationId,
      meta: data.meta,
    );
  }

  @override
  String? get id => super.id;

  @override
  set id(String? value) {
    // id is final in RoleDataModel via constructor
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // implementation if needed
  }
}
