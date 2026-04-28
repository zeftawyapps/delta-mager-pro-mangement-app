import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/commrec/data/category_model.dart';
import 'package:matger_pro_core_logic/models/localized_string.dart';

class CategoryModel extends CategoryData implements BaseViewDataModel {
  CategoryModel({
    required super.id,
    required super.name,
    required super.organizationId,
    super.description,
    super.imageUrl,
    super.isActive = true,
    super.meta,
    super.displayOrder,
    super.productCount,
  });

  factory CategoryModel.fromData(CategoryData data) {
    return CategoryModel(
      id: data.id,
      name: data.name,
      organizationId: data.organizationId,
      description: data.description,
      imageUrl: data.imageUrl,
      isActive: data.isActive,
      meta: data.meta,
      displayOrder: data.displayOrder,
      productCount: data.productCount,
    );
  }

  // To maintain compatibility with previous usage if any
  String get nameAr => name.ar;
  String get descriptionAr => description?.ar ?? '';
  String get image => imageUrl ?? '';
  String? get icon => null; // CategoryData doesn't have an icon field currently

  @override
  String get categoryId => id;

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }

  @override
  set id(String? value) {
    // TODO: implement id
  }
}
