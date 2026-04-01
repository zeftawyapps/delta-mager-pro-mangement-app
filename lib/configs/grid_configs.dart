import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:matger_core_logic/core/orgnization/data/organization_config.dart';

class CategoryGridConfigs {
  static const double childAspectRatio = 1.1;
  static const int crossAxisCountSmall = 2;
  static const int crossAxisCountMedium = 3;
  static const int crossAxisCountLarge = 4;
  static const double crossAxisSpacing = 16.0;
  static const double mainAxisSpacing = 16.0;
  static const EdgeInsets padding = EdgeInsets.all(16.0);
  static const String? noDataMessage = null;
  static const int debounceMs = 500;
  static const String? searchHint = "بحث في الأصناف...";
  static const ScrollPhysics? physics = null;
  static const bool shrinkWrap = false;
  static const bool canAdd = true;
  static const bool addAutomaticKeepAlives = true;
  static const bool addRepaintBoundaries = true;
  static const bool addSemanticIndexes = true;
  static const double? cacheExtent = null;
  static const String? restorationId = null;
  static const Clip clipBehavior = Clip.hardEdge;
  static const Axis scrollDirection = Axis.vertical;
  static const bool reverse = false;
  static const bool? primary = null;
}

class ProductGridConfigs {
  static const double childAspectRatio = 0.7;
  static const int crossAxisCountSmall = 2;
  static const int crossAxisCountMedium = 3;
  static const int crossAxisCountLarge = 4;
  static const double crossAxisSpacing = 16.0;
  static const double mainAxisSpacing = 16.0;
  static const EdgeInsets padding = EdgeInsets.all(16.0);
  static const String? noDataMessage = null;
  static const int debounceMs = 500;
  static const String? searchHint = "بحث في المنتجات...";
  static const ScrollPhysics? physics = null;
  static const bool shrinkWrap = false;
  static const bool canAdd = true;
  static const bool addAutomaticKeepAlives = true;
  static const bool addRepaintBoundaries = true;
  static const bool addSemanticIndexes = true;
  static const double? cacheExtent = null;
  static const String? restorationId = null;
  static const Clip clipBehavior = Clip.hardEdge;
  static const Axis scrollDirection = Axis.vertical;
  static const bool reverse = false;
  static const bool? primary = null;
}

class UserGridConfigs {
  static const double childAspectRatio = 1.2;
  static const int crossAxisCountSmall = 2;
  static const int crossAxisCountMedium = 3;
  static const int crossAxisCountLarge = 4;
  static const double crossAxisSpacing = 16.0;
  static const double mainAxisSpacing = 16.0;
  static const EdgeInsets padding = EdgeInsets.all(16.0);
  static const String? noDataMessage = null;
  static const int debounceMs = 500;
  static const String? searchHint = "بحث في المستخدمين...";
  static const ScrollPhysics? physics = null;
  static const bool shrinkWrap = false;
  static const bool canAdd = true;
  static const bool addAutomaticKeepAlives = true;
  static const bool addRepaintBoundaries = true;
  static const bool addSemanticIndexes = true;
  static const double? cacheExtent = null;
  static const String? restorationId = null;
  static const Clip clipBehavior = Clip.hardEdge;
  static const Axis scrollDirection = Axis.vertical;
  static const bool reverse = false;
  static const bool? primary = null;
}

class GridFeatureResolver {
  static ScreenFeatureConfig? getFeatureConfig<T>(BuildContext context) {
    final configBloc = context.watch<OrganizationConfigBloc>();
    final features = configBloc.state.itemState.maybeWhen(
      success: (data) => data?.feature,
      orElse: () => null,
    );
    
    if (features == null) return null;

    if (T == CategoryModel) return features.categories;
    if (T == ProductModel) return features.products;
    if (T == UserViewProfileModel) return features.users;
    
    return null;
  }
}
