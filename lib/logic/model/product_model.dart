import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/commrec/data/product_model.dart';
import 'package:matger_pro_core_logic/models/localized_string.dart';

// Re-exporting core data structures for application-wide use
export 'package:matger_pro_core_logic/features/commrec/data/product_model.dart'
    show LocalizedString, PriceOption, ProductUnit, ProductData;

class ProductModel extends ProductData implements BaseViewDataModel {
  ProductModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.organizationId,
    required super.price,
    super.oldPrice,
    super.cost,
    super.images = const [],
    super.isActive = true,
    super.stockQuantity = 0,
    super.isNew = false,
    super.isBestSeller = false,
    super.isAvailable = true,
    super.discount,
    super.rating = 0.0,
    super.priceOptions = const [],
    super.isJoker = false,
    super.isSuperJoker = false,
    super.isOnSale = false,
    super.additionalData = const {},
    super.meta,
    super.createdAt,
  });

  factory ProductModel.fromData(ProductData data) {
    return ProductModel(
      id: data.id,
      name: data.name,
      categoryId: data.categoryId,
      organizationId: data.organizationId,
      price: data.price,
      oldPrice: data.oldPrice,
      cost: data.cost,
      images: data.images,
      isActive: data.isActive,
      stockQuantity: data.stockQuantity,
      isNew: data.isNew,
      isBestSeller: data.isBestSeller,
      isAvailable: data.isAvailable,
      discount: data.discount,
      rating: data.rating,
      priceOptions: data.priceOptions,
      isJoker: data.isJoker,
      isSuperJoker: data.isSuperJoker,
      isOnSale: data.isOnSale,
      additionalData: data.additionalData,
      meta: data.meta,
      createdAt: data.createdAt,
    );
  }

  // Convenience getters for UI
  String get nameAr => name.ar;
  String get descriptionAr => description.ar;

  /// Localized summary from additionalData (compatible with previous UI usage)
  LocalizedString get summary {
    if (additionalData['summary'] != null) {
      return LocalizedString.fromJson(additionalData['summary']);
    }
    return description;
  }

  @override
  String get id => super.id;

  @override
  set id(String? value) {
    // id is final in ProductData
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
