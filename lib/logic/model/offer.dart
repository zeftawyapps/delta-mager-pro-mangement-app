import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/commrec/data/offer_model.dart';
import 'package:matger_pro_core_logic/models/localized_string.dart';

export 'package:matger_pro_core_logic/features/commrec/data/offer_model.dart'
    show OfferTargetType, OfferData;

class OfferModel extends OfferData implements BaseViewDataModel {
  OfferModel({
    required super.id,
    required super.name,
    required super.description,
    required super.organizationId,
    super.imageUrl,
    required super.targetType,
    required super.targetId,
    super.targetName,
    super.discountPercentage = 0,
    super.startDate,
    super.endDate,
    super.isValid = true,
    super.isActive = true,
    super.sortOrder = 0,
    super.meta,
  });

  factory OfferModel.fromData(OfferData data) {
    return OfferModel(
      id: data.id,
      name: data.name,
      description: data.description,
      organizationId: data.organizationId,
      imageUrl: data.imageUrl,
      targetType: data.targetType,
      targetId: data.targetId,
      targetName: data.targetName,
      discountPercentage: data.discountPercentage,
      startDate: data.startDate,
      endDate: data.endDate,
      isValid: data.isValid,
      isActive: data.isActive,
      sortOrder: data.sortOrder,
      meta: data.meta,
    );
  }

  // Convenience getters for UI
  String get nameAr => name.ar;
  String get descriptionAr => description.ar;

  @override
  String get id => super.id;

  @override
  set id(String? value) {
    // id is final in OfferData
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
