import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';

class RoleUpgradeRequest implements BaseViewDataModel {
  @override
  String? id;
  
  final String userId;
  final String? organizationId;
  final String requestedRoleName;
  final String status;
  final String? phone;
  final String? email;
  final String? otpCode;
  final DateTime? otpExpiresAt;
  final String? rejectedReason;

  // Extra user details if populated from DB (or we will merge them later)
  final String? username;
  final String? shopName;
  final String? taxId;

  RoleUpgradeRequest({
    this.id,
    required this.userId,
    this.organizationId,
    required this.requestedRoleName,
    required this.status,
    this.phone,
    this.email,
    this.otpCode,
    this.otpExpiresAt,
    this.rejectedReason,
    this.username,
    this.shopName,
    this.taxId,
  });

  factory RoleUpgradeRequest.fromJson(Map<String, dynamic> json) {
    // Check nested or flat user profile data
    final userProfile = json['userProfile'] is Map ? json['userProfile'] as Map : null;
    final additionalInfo = userProfile != null && userProfile['additionalInfo'] is Map 
        ? userProfile['additionalInfo'] as Map 
        : null;

    return RoleUpgradeRequest(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      organizationId: json['organizationId']?.toString(),
      requestedRoleName: json['requestedRoleName']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      phone: json['phone']?.toString() ?? userProfile?['phone']?.toString(),
      email: json['email']?.toString() ?? userProfile?['email']?.toString(),
      otpCode: json['otpCode']?.toString(),
      otpExpiresAt: json['otpExpiresAt'] != null
          ? DateTime.tryParse(json['otpExpiresAt'].toString())
          : null,
      rejectedReason: json['rejectedReason']?.toString(),
      username: userProfile?['username']?.toString(),
      shopName: additionalInfo?['wholesalerShopName']?.toString(),
      taxId: additionalInfo?['wholesalerTaxId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'organizationId': organizationId,
      'requestedRoleName': requestedRoleName,
      'status': status,
      'phone': phone,
      'email': email,
      'otpCode': otpCode,
      'otpExpiresAt': otpExpiresAt?.toIso8601String(),
      'rejectedReason': rejectedReason,
      'username': username,
      'shopName': shopName,
      'taxId': taxId,
    };
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // Not needed for read-only mapping
  }
}
