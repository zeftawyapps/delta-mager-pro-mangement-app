import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/grid_view_model.dart';
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
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'inputs/category_input_form.dart';

// ignore: must_be_immutable
class CategoryScreen extends StatefulWidget with AppShellRouterMixin {
  CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late List<CategoryModel> localCategories;

  String get organizationId {
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1'; // Default to shop1 if not logged in
  }

  @override
  void initState() {
    super.initState();
    localCategories = ControlPanelDataProvider.categories;
    // تحميل الأصناف عند البدء باستخدام organizationId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesBloc>().loadCategories(shopId: organizationId);
    });
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
    int productCount = ControlPanelDataProvider.getProductCountInCategory(
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
              const Text('لا يمكن الحذف'),
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
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف: ${category.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CategoriesBloc>().deleteCategory(
                category.categoryId,
                shopId: organizationId,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف: ${category.name}')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        currentTilte: 'الفئات',
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<CategoriesBloc, FeaturDataSourceState<CategoryModel>>(
          builder: (context, state) {
            return state.listState.when(
              init: () => const Center(child: CircularProgressIndicator()),
              loading: () {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: isDark
                            ? DarkColors.primary
                            : LightColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'جاري تحميل الفئات...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
              success: (categories) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final layoutWidth = constraints.maxWidth;
                    final crossAxisCount = layoutWidth < 650
                        ? 2
                        : layoutWidth < 900
                        ? 3
                        : 4;

                    return GridViewModel<CategoryModel>(
                      data: categories ?? [],
                      canAdd: true,
                      onAdd: _addCategory,
                      listItem: (index, category) {
                        return _buildCategoryCard(category, isDark);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                    );
                  },
                );
              },
              failure: (error, callback) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final layoutWidth = constraints.maxWidth;
                    final crossAxisCount = layoutWidth < 650
                        ? 2
                        : layoutWidth < 900
                        ? 3
                        : 4;

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'تعذر تحميل البيانات من الخادم. يتم عرض بيانات نموذجية.',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context
                                    .read<CategoriesBloc>()
                                    .loadCategories(shopId: organizationId),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridViewModel<CategoryModel>(
                            data: localCategories,
                            canAdd: true,
                            onAdd: _addCategory,
                            listItem: (index, category) {
                              return _buildCategoryCard(category, isDark);
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.1,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, bool isDark) {
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
                        '${ControlPanelDataProvider.getProductCountInCategory(category.categoryId)} منتج',
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
              Positioned(
                top: 4,
                right: 4,
                child: PopUpMenu(
                  iconSize: 18,
                  iconColor: isDark ? Colors.white70 : Colors.black87,
                  items: [
                    pubMenuItems(
                      title: 'تعديل',
                      icon: Icons.edit,
                      value: 1,
                      onTap: () => _editCategory(category),
                    ),
                    pubMenuItems(
                      title: 'حذف',
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
