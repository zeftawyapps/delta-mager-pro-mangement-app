import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';

class BlogCategoryModel extends BlogCategory implements BaseViewDataModel {
  BlogCategoryModel({
    required super.id,
    required super.name,
    required super.organizationId,
    super.isActive = true,
  });

  factory BlogCategoryModel.fromData(BlogCategory data) {
    return BlogCategoryModel(
      id: data.id,
      name: data.name,
      organizationId: data.organizationId,
      isActive: data.isActive,
    );
  }

  String get nameAr => name.ar;
  String get nameEn => name.en;

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only
  }

  @override
  set id(String? value) {
    // read-only
  }
}
