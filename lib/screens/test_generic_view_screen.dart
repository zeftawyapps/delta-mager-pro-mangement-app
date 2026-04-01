import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/items.dart';
import 'package:JoDija_tamplites/util/widgits/pob_up_menues/pubUpmenu.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/product_input_form.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestGenericProductsScreen extends StatefulWidget
    with AppShellRouterMixin {
  TestGenericProductsScreen({super.key});

  @override
  State<TestGenericProductsScreen> createState() =>
      _TestGenericProductsScreenState();
}

class _TestGenericProductsScreenState extends State<TestGenericProductsScreen> {
  String? selectedCategoryId;

  String get organizationId {
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  @override
  void initState() {
    super.initState();
    selectedCategoryId = context.read<AppChangesValues>().selectedCategoryId;
  }

  void _addProduct() {
    showCustomInputDialog(
      context: context,
      content: ProductInputForm(initialCategoryId: selectedCategoryId),
      height: 600,
      width: 500,
      onResult: (result) {
        context.read<ProductsBloc>().loadProducts();
      },
    );
  }

  void _editProduct(ProductModel product) {
    showCustomInputDialog(
      context: context,
      content: ProductInputForm(product: product),
      height: 600,
      width: 500,
      onResult: (result) {
        context.read<ProductsBloc>().loadProducts();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: "تجربة الويدجت المشتركة (منتجات)",
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child: MasterGrid<ProductModel, ProductsBloc>(
          title: AppStrings.products,

          childAspectRatio: 0.7,
          onAdd: _addProduct,
          onSearch: (bloc, query) {
            bloc.searchProducts(query: query, organizationId: organizationId);
          },
          searchHint: "البحث عن منتج...",
          onLoad: (bloc) {
            bloc.loadProducts();
            context.read<CategoriesBloc>().loadCategories(
              shopId: organizationId,
            );
          },
          filterToolbar: _buildCategoryFilterSection(isDark),
          itemBuilder: (context, product) => _buildProductCard(product, isDark),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterSection(bool isDark) {
    return BlocBuilder<CategoriesBloc, FeaturDataSourceState<CategoryModel>>(
      builder: (context, state) {
        return state.listState.when(
          init: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (categories) {
            return Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(AppStrings.all, null, isDark),
                  const SizedBox(width: 8),
                  ...(categories ?? [])
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            c.name,
                            c.categoryId,
                            isDark,
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            );
          },
          failure: (err, cb) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, bool isDark) {
    final isSelected = selectedCategoryId == categoryId;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        final id = selected ? categoryId : null;
        setState(() => selectedCategoryId = id);
        context.read<AppChangesValues>().setSelectedCategoryId(id);
      },
      backgroundColor: isDark ? DarkColors.surface : LightColors.surface,
      selectedColor: isDark ? DarkColors.primary : LightColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? DarkColors.textPrimary : LightColors.textPrimary),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: InkWell(
        onTap: () => _editProduct(product),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: product.images.isNotEmpty
                      ? Image.network(product.mainImage, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.ar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price} ج.م',
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: PopUpMenu(
                items: [
                  pubMenuItems(
                    title: AppStrings.edit,
                    icon: Icons.edit,
                    value: 1,
                    onTap: () => _editProduct(product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
