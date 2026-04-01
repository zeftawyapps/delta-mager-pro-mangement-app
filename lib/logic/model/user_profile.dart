import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_core_logic/core/auth/data/user_profile_model.dart';

class UserViewProfileModel extends UserProfileModel implements BaseViewDataModel {
  UserViewProfileModel({
    required super.userId,
    required super.username,
    required super.email,
    required super.phone,
    super.roles,
    super.address,
    super.organizationId,
    super.dateOfBirth,
    super.bio,
    super.avatarUrl,
    super.additionalInfo,
    super.meta,
    super.website,
    super.socialLinks,
    super.location,
    super.isActiveProfile,
  });

  factory UserViewProfileModel.fromData(UserProfileModel data) {
    return UserViewProfileModel(
      userId: data.userId,
      username: data.username,
      email: data.email,
      phone: data.phone,
      roles: data.roles,
      address: data.address,
      organizationId: data.organizationId,
      dateOfBirth: data.dateOfBirth,
      bio: data.bio,
      avatarUrl: data.avatarUrl,
      additionalInfo: data.additionalInfo,
      meta: data.meta,
      website: data.website,
      socialLinks: data.socialLinks,
      location: data.location,
      isActiveProfile: data.isActiveProfile,
    );
  }

  @override
  String? get id => userId;

  @override
  set id(String? value) {
    // userId is final
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // implementation if needed
  }
}
