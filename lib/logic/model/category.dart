import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_core_logic/features/commrec/data/category_model.dart';

class CategoryModel extends CategoryData implements BaseViewDataModel {
  CategoryModel({
    required super.categoryId,
    required super.name,
    required super.organizationId,
    super.description,
    super.imageUrl,
    super.isActive = true,
    super.meta,
    super.displayOrder,
  });

  factory CategoryModel.fromData(CategoryData data) {
    return CategoryModel(
      categoryId: data.categoryId,
      name: data.name,
      organizationId: data.organizationId,
      description: data.description,
      imageUrl: data.imageUrl,
      isActive: data.isActive,
      meta: data.meta,
      displayOrder: data.displayOrder,
    );
  }

  // To maintain compatibility with previous usage if any
  String get nameAr => name;
  String get image => imageUrl ?? '';
  String? get icon => null; // CategoryData doesn't have an icon field currently

  @override
  String? get id => categoryId;

  @override
  set id(String? value) {
    // categoryId is final in CategoryData
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // implementation if needed
  }
}
