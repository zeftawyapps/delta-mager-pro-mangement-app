import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/locations/data/location_models.dart';

// Re-exporting core data structures
export 'package:matger_pro_core_logic/features/locations/data/location_models.dart'
    show Governorate, City, Country, Name;

class CountryModel extends Country implements BaseViewDataModel {
  CountryModel({
    required super.id,
    required super.name,
    super.currency = '',
    super.phoneCode = '',
    super.isActive = true,
  });

  factory CountryModel.fromData(Country data) {
    return CountryModel(
      id: data.id,
      name: data.name,
      currency: data.currency,
      phoneCode: data.phoneCode,
      isActive: data.isActive,
    );
  }

  String get nameAr => name.ar;

  @override
  set id(String? value) {}

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {}
}

class GovernorateModel extends Governorate implements BaseViewDataModel {
  GovernorateModel({
    required super.id,
    required super.countryId,
    required super.name,
    super.code,
    super.defaultShippingFee = 0.0,
    super.isActive = true,
  });

  factory GovernorateModel.fromData(Governorate data) {
    return GovernorateModel(
      id: data.id,
      countryId: data.countryId,
      name: data.name,
      code: data.code,
      defaultShippingFee: data.defaultShippingFee,
      isActive: data.isActive,
    );
  }

  String get nameAr => name.ar;

  @override
  set id(String? value) {}

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {}
}

class CityModel extends City implements BaseViewDataModel {
  CityModel({
    required super.id,
    required super.governorateId,
    required super.name,
    super.defaultShippingFee,
    super.isActive = true,
  });

  factory CityModel.fromData(City data) {
    return CityModel(
      id: data.id,
      governorateId: data.governorateId,
      name: data.name,
      defaultShippingFee: data.defaultShippingFee,
      isActive: data.isActive,
    );
  }

  String get nameAr => name.ar;

  @override
  set id(String? value) {}

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {}
}
