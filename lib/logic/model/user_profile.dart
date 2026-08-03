import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/core/auth/data/user_profile_model.dart';

class UserViewProfileModel extends UserProfileModel
    implements BaseViewDataModel {
  UserViewProfileModel({
    required super.userId,
    required super.username,
    super.name,
    required super.email,
    required super.phone,
    super.roles,
    super.address,
    super.organizationId,
    super.dateOfBirth,
    super.bio,
    super.avatarUrl,
    super.countryId,
    super.governorateId,
    super.cityId,
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
      name: data.name,
      email: data.email,
      phone: data.phone,
      roles: data.roles,
      address: data.address,
      organizationId: data.organizationId,
      dateOfBirth: data.dateOfBirth,
      bio: data.bio,
      avatarUrl: data.avatarUrl,
      countryId: data.countryId,
      governorateId: data.governorateId,
      cityId: data.cityId,
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

  /// 🛡️ هل هذا المستخدم زبون؟
  /// يعتمد على وجود دور 'customer' أو 'wholesaler'
  bool get isCustomer {
    if (roles == null || roles!.isEmpty) return false;
    return roles!.any((role) {
      final r = role.toLowerCase();
      return r == 'customer' || r == 'wholesaler';
    });
  }

  @override
  set map(Map<String, dynamic>? value) {
    // implementation if needed
  }
}
