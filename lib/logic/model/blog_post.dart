import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';

class BlogPostModel extends BlogPost implements BaseViewDataModel {
  BlogPostModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.content,
    required super.postType,
    super.blogCategoryId,
    required super.organizationId,
    super.relatedProducts = const [],
    super.imageUrl,
    super.isActive = true,
    super.coreKey,
    super.seoTitle,
    super.seoDescription,
    super.seoKeywords = const [],
    super.isJoker = false,
    super.isFeatured = false,
    super.isMost = false,
    super.introTitle,
    super.introDescription,
    super.introImageUrl,
    super.showInFooter = false,
    super.showInNavigation = false,
  });

  factory BlogPostModel.fromData(BlogPost data) {
    return BlogPostModel(
      id: data.id,
      title: data.title,
      slug: data.slug,
      content: data.content,
      postType: data.postType,
      blogCategoryId: data.blogCategoryId,
      organizationId: data.organizationId,
      relatedProducts: data.relatedProducts,
      imageUrl: data.imageUrl,
      isActive: data.isActive,
      coreKey: data.coreKey,
      seoTitle: data.seoTitle,
      seoDescription: data.seoDescription,
      seoKeywords: data.seoKeywords,
      isJoker: data.isJoker,
      isFeatured: data.isFeatured,
      isMost: data.isMost,
      introTitle: data.introTitle,
      introDescription: data.introDescription,
      introImageUrl: data.introImageUrl,
      showInFooter: data.showInFooter ?? false,
      showInNavigation: data.showInNavigation ?? false,
    );
  }

  String get titleAr => title.ar;
  String get titleEn => title.en;
  String get contentAr => content.ar;
  String get contentEn => content.en;
  String get seoTitleAr => seoTitle?.ar ?? '';
  String get seoTitleEn => seoTitle?.en ?? '';
  String get seoDescriptionAr => seoDescription?.ar ?? '';
  String get seoDescriptionEn => seoDescription?.en ?? '';
  String get introTitleAr => introTitle?.ar ?? '';
  String get introTitleEn => introTitle?.en ?? '';
  String get introDescriptionAr => introDescription?.ar ?? '';
  String get introDescriptionEn => introDescription?.en ?? '';

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

