import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/items.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/pubUpmenu.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'inputs/category_input_form.dart';

// ignore: must_be_immutable
class CategoryScreen extends StatefulWidget with AppShellRouterMixin {
  final double childAspectRatio;
  final int crossAxisCountSmall;
  final int crossAxisCountMedium;
  final int crossAxisCountLarge;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final String? noDataMessage;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool canAdd;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final String? restorationId;
  final Clip clipBehavior;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final int debounceMs;
  final String? searchHint;

  CategoryScreen({
    super.key,
    this.childAspectRatio = CategoryGridConfigs.childAspectRatio,
    this.crossAxisCountSmall = CategoryGridConfigs.crossAxisCountSmall,
    this.crossAxisCountMedium = CategoryGridConfigs.crossAxisCountMedium,
    this.crossAxisCountLarge = CategoryGridConfigs.crossAxisCountLarge,
    this.crossAxisSpacing = CategoryGridConfigs.crossAxisSpacing,
    this.mainAxisSpacing = CategoryGridConfigs.mainAxisSpacing,
    this.padding = CategoryGridConfigs.padding,
    this.noDataMessage = CategoryGridConfigs.noDataMessage,
    this.physics = CategoryGridConfigs.physics,
    this.shrinkWrap = CategoryGridConfigs.shrinkWrap,
    this.scrollController,
    this.canAdd = CategoryGridConfigs.canAdd,
    this.addAutomaticKeepAlives = CategoryGridConfigs.addAutomaticKeepAlives,
    this.addRepaintBoundaries = CategoryGridConfigs.addRepaintBoundaries,
    this.addSemanticIndexes = CategoryGridConfigs.addSemanticIndexes,
    this.cacheExtent = CategoryGridConfigs.cacheExtent,
    this.restorationId = CategoryGridConfigs.restorationId,
    this.clipBehavior = CategoryGridConfigs.clipBehavior,
    this.scrollDirection = CategoryGridConfigs.scrollDirection,
    this.reverse = CategoryGridConfigs.reverse,
    this.primary = CategoryGridConfigs.primary,
    this.debounceMs = CategoryGridConfigs.debounceMs,
    this.searchHint = CategoryGridConfigs.searchHint,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SystemManager {
  String get organizationId {
    final params = widget.getPrams();
    final orgName = params?['orgName'];
    if (orgName != null && orgName != "" && orgName != ":orgName") {
      return orgName;
    }
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  void _addCategory() {
    showCustomInputDialog(
      context: context,
      content: const CategoryInputForm(),
      height: 500,
      width: 400,
      onResult: (result) {
        context.read<CategoriesBloc>().loadCategories(shopId: organizationId);
      },
    );
  }

  void _editCategory(CategoryModel category) {
    showCustomInputDialog(
      context: context,
      content: CategoryInputForm(category: category),
      height: 500,
      width: 400,
      onResult: (result) {
        context.read<CategoriesBloc>().loadCategories(shopId: organizationId);
      },
    );
  }

  void _deleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text('${AppStrings.deleteMessage}${category.name.ar}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CategoriesBloc>().deleteCategory(
                category.categoryId,
                shopId: organizationId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.category,
      mainPath: widget.getMainPath(),
      widgetCanAdd: widget.canAdd,
    );
    final appBarConfig = sys.appBarConfig;

    if (sys.authWidget != null) return sys.authWidget!;

    final canAdd = sys.canAdd;
    final canUpdate = sys.canUpdate;
    final canDelete = sys.canDelete;
    final featureConfig = sys.featureConfig;
    final isDark = sys.isDark;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: AppStrings.products,
        isDesplayTitle: true,
      ),
      body: MasterGrid<CategoryModel, CategoriesBloc>(
        title: AppStrings.categories,
        searchHint: widget.searchHint,
        onAdd: _addCategory,
        onLoad: (bloc) => bloc.loadCategories(shopId: organizationId),
        onSearch: (bloc, query) =>
            bloc.searchCategories(query, shopId: organizationId),
        onItemTap: _editCategory,
        canAdd: canAdd,
        canMultiSelect: true,
        itemBuilder: (context, category, isSelected) =>
            _buildCategoryCard(category, isDark, canUpdate, canDelete),
        multiSelectActions: (selectedItems) => [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              // منطق الحذف الجماعي
            },
            tooltip: "حذف المختار",
          ),
        ],
        showAddInGrid: featureConfig?.showAddInGrid ?? false,
        childAspectRatio:
            featureConfig?.childAspectRatio ?? widget.childAspectRatio,
        crossAxisCountSmall:
            featureConfig?.crossAxisCountSmall ?? widget.crossAxisCountSmall,
        crossAxisCountMedium:
            featureConfig?.crossAxisCountMedium ?? widget.crossAxisCountMedium,
        crossAxisCountLarge:
            featureConfig?.crossAxisCountLarge ?? widget.crossAxisCountLarge,
        crossAxisSpacing:
            featureConfig?.crossAxisSpacing ?? widget.crossAxisSpacing,
        mainAxisSpacing:
            featureConfig?.mainAxisSpacing ?? widget.mainAxisSpacing,
        padding: widget.padding,
        noDataMessage: widget.noDataMessage ?? "",
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        scrollController: widget.scrollController,
        debounceMs: widget.debounceMs,
      ),
    );
  }

  Widget _buildCategoryCard(
    CategoryModel category,
    bool isDark,
    bool canUpdate,
    bool canDelete,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: category.image != null && category.image != ""
                    ? Image.network(
                        category.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 30),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.category, size: 40),
                      ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name.ar,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.productCount ?? 0} منتج',
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopUpMenu(
              iconSize: 18,
              items: [
                if (canUpdate)
                  pubMenuItems(
                    title: AppStrings.edit,
                    icon: Icons.edit,
                    value: 1,
                    onTap: () => _editCategory(category),
                  ),
                if (canDelete)
                  pubMenuItems(
                    title: AppStrings.delete,
                    icon: Icons.delete,
                    value: 2,
                    onTap: () => _deleteCategory(category),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
