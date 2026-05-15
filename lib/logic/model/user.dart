import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/core/auth/data/user_model.dart';
import 'package:matger_pro_core_logic/core/auth/data/user_profile_model.dart';

class Users extends UserModel implements BaseViewDataModel {
  Users({
    required super.id,
    required super.username,
    required super.email,
    required super.name,
    required super.phone,
    super.token,
    super.roles,
    super.isActive,
    super.isEmailVerified,
    super.meta,
    super.organizationId,
    super.permissions,
    super.otherData,
  });

  factory Users.fromUserModel(UserModel model) {
    return Users(
      id: model.id,
      username: model.username,
      email: model.email,
      name: model.name,
      phone: model.phone,
      roles: model.roles,
      isActive: model.isActive,
      isEmailVerified: model.isEmailVerified,
      meta: model.meta,
      token: model.token,
      organizationId: model.organizationId,
      permissions: model.permissions,
      otherData: model.otherData,
    );
  }

  factory Users.fromProfileModel(UserProfileModel profile, {String? token, List<String>? permissions}) {
    return Users(
      id: profile.userId,
      username: profile.username,
      email: profile.email,
      name: profile.username, // نستخدم username كاسم في حال عدم وجود حقل name منفصل
      phone: profile.phone,
      roles: profile.roles,
      isActive: profile.isActiveProfile,
      token: token,
      organizationId: profile.organizationId,
      permissions: permissions,
      otherData: profile,
    );
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set id(String? value) {}

  @override
  set map(Map<String, dynamic>? value) {}
}
