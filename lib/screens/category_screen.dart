import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/org_lifecycle_manager.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
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
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'inputs/category_input_form.dart';
import 'package:delta_mager_pro_mangement_app/catalog/categories/category_card.dart';

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

class _CategoryScreenState extends State<CategoryScreen>
    with SystemManager, OrgLifecycleManager {
  @override
  void initState() {
    super.initState();
    print(widget.getPrams());
    initOrgListener(
      onOrgChanged: (orgId) {
        context.read<CategoriesBloc>().loadCategories(shopId: orgId);
        setState(() {});
      },
    );
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
        onItemTap: (category) {
          final appChanges = context.read<AppChangesValues>();
          widget.goRoute(context, AppRoutes.products);

          Future.delayed(Duration.zero, () {
            appChanges.setSelectedCategoryId(category.id);
          });
        },
        canAdd: canAdd,
        canMultiSelect: true,
        itemBuilder: (context, category, isSelected) => CategoryCard(
          category: category,
          isDark: isDark,
          canUpdate: canUpdate,
          canDelete: canDelete,
          onEdit: () => _editCategory(category),
          onDelete: () => _deleteCategory(category),
        ),
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
}
