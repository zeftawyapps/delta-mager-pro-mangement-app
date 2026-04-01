import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/items.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/pubUpmenu.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/logic/data/control_panel_data_provider.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:matger_core_logic/core/auth/utils/permission_manager.dart';
import 'package:matger_core_logic/core/auth/utils/permission_constants.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
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

class _CategoryScreenState extends State<CategoryScreen> {
  String get organizationId {
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1'; // Default to shop1 if not logged in
  }

  @override
  void initState() {
    super.initState();
  }

  void _addCategory() {
    final formKey = GlobalKey<CategoryInputFormState>();

    showCustomInputDialog(
      context: context,
      content: CategoryInputForm(key: formKey),
      height: 500,
      width: 400,
      // onSave: () {
      //   formKey.currentState?.saveCategory();
      // },
      onResult: (result) {
        context.read<CategoriesBloc>().loadCategories(shopId: organizationId);
      },
    );
  }

  void _editCategory(CategoryModel category) {
    final formKey = GlobalKey<CategoryInputFormState>();

    showCustomInputDialog(
      context: context,
      content: CategoryInputForm(key: formKey, category: category),
      height: 500,
      width: 400,

      onResult: (result) {
        context.read<CategoriesBloc>().loadCategories(shopId: organizationId);
      },
    );
  }

  void _deleteCategory(CategoryModel category) {
    int productCount = category.productCount ??
        ControlPanelDataProvider.getProductCountInCategory(
          category.categoryId,
        );

    if (productCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(AppStrings.cannotDelete),
            ],
          ),
          content: Text(
            'فئة "${category.name}" تحتوي على $productCount منتج. يجب حذف المنتجات أو نقلها إلى فئة أخرى أولاً قبل حذف الفئة.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? DarkColors.primary
                    : LightColors.primary,
              ),
              child: const Text(AppStrings.ok),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text('${AppStrings.deleteMessage}${category.name}؟'),
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
    final appConfig = context.watch<AppChangesValues>();
    final user = appConfig.user;
    final canAdd =
        (user?.can(SystemFeatures.category, SystemJobs.add) ?? widget.canAdd) &&
        ProductInputConfig.enableAddCategory;
    final canUpdate =
        user?.can(SystemFeatures.category, SystemJobs.update) ?? true;
    final canDelete =
        user?.can(SystemFeatures.category, SystemJobs.delete) ?? true;

    final configBloc = context.watch<OrganizationConfigBloc>();
    final featureConfig = configBloc.state.itemState.maybeWhen(
      success: (data) => data?.feature?.categories,
      orElse: () => null,
    );

    // Re-enabled AppChangesValues logic
    if (widget.getMainPath() != null) {
      var changvalue = context.read<AppChangesValues>();
      String path = widget.getMainPath()!;
      changvalue.setLastRoute(path);
    }
    final authWidget = AppChangesValues.checkAuth(context, widget);
    if (authWidget != null) return authWidget;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: AppStrings.categories,
        isDesplayTitle: true,
      ),
      body: BlocListener<CategoriesBloc, FeaturDataSourceState<CategoryModel>>(
        listenWhen: (previous, current) =>
            previous.itemState != current.itemState,
        listener: (context, state) {
          state.itemState.maybeWhen(
            failure: (error, reload) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('خطأ'),
                    ],
                  ),
                  content: Text(
                    error.message ?? 'حدث خطأ أثناء تنفيذ العملية',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('حسناً'),
                    ),
                  ],
                ),
              );
            },
            success: (data) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت العملية بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: Container(
          color: isDark ? DarkColors.background : LightColors.background,
          child: MasterGrid<CategoryModel, CategoriesBloc>(
            title: AppStrings.categories,
            itemBuilder: (context, category) =>
                _buildCategoryCard(category, isDark, canUpdate, canDelete),
            onAdd: _addCategory,
            onLoad: (bloc) => bloc.loadCategories(shopId: organizationId),
            canAdd: canAdd,
            showAddInGrid: ProductInputConfig.showAddCategoryInGrid,
            childAspectRatio:
                featureConfig?.childAspectRatio ?? widget.childAspectRatio,
            crossAxisCountSmall: featureConfig?.crossAxisCountSmall ??
                widget.crossAxisCountSmall,
            crossAxisCountMedium: featureConfig?.crossAxisCountMedium ??
                widget.crossAxisCountMedium,
            crossAxisCountLarge: featureConfig?.crossAxisCountLarge ??
                widget.crossAxisCountLarge,
            crossAxisSpacing:
                featureConfig?.crossAxisSpacing ?? widget.crossAxisSpacing,
            mainAxisSpacing:
                featureConfig?.mainAxisSpacing ?? widget.mainAxisSpacing,
            padding: featureConfig?.padding != null
                ? EdgeInsets.fromLTRB(
                    featureConfig!.padding![3],
                    featureConfig.padding![0],
                    featureConfig.padding![1],
                    featureConfig.padding![2],
                  )
                : widget.padding,
            noDataMessage: widget.noDataMessage ?? AppStrings.loadingCategories,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            scrollController: widget.scrollController,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addSemanticIndexes: widget.addSemanticIndexes,
            cacheExtent: widget.cacheExtent,
            restorationId: widget.restorationId,
            clipBehavior: widget.clipBehavior,
            scrollDirection: widget.scrollDirection,
            reverse: widget.reverse,
            primary: widget.primary,
            debounceMs: widget.debounceMs,
            searchHint: widget.searchHint,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    CategoryModel category,
    bool isDark,
    bool canUpdate,
    bool canDelete,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final changesValue = context.read<AppChangesValues>();
          changesValue.setSelectedCategoryId(category.categoryId);
          widget.goRoute(context, AppRoutes.products);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? DarkColors.surface : LightColors.surface,
            border: Border.all(
              color: isDark
                  ? DarkColors.divider.withOpacity(0.3)
                  : LightColors.divider.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            (isDark ? DarkColors.primary : LightColors.primary)
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              (isDark
                                      ? DarkColors.primary
                                      : LightColors.primary)
                                  .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (category.imageUrl?.isNotEmpty ?? false)
                            ? Image.network(
                                category.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(Icons.category, size: 32),
                                    ),
                              )
                            : const Center(
                                child: Icon(Icons.category, size: 32),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? DarkColors.primary : LightColors.primary)
                                .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${category.productCount ?? 0} منتج',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        category.description ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (canUpdate || canDelete)
                Positioned(
                  top: 4,
                  right: 4,
                  child: PopUpMenu(
                    iconSize: 18,
                    iconColor: isDark ? Colors.white70 : Colors.black87,
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
        ),
      ),
    );
  }
}
