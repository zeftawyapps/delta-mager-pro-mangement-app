import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:matger_core_logic/core/auth/utils/permission_manager.dart';
import 'package:matger_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'inputs/product_input_form.dart';

// ignore: must_be_immutable
class ProductsScreen extends StatefulWidget with AppShellRouterMixin {
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

  ProductsScreen({
    super.key,
    this.childAspectRatio = ProductGridConfigs.childAspectRatio,
    this.crossAxisCountSmall = ProductGridConfigs.crossAxisCountSmall,
    this.crossAxisCountMedium = ProductGridConfigs.crossAxisCountMedium,
    this.crossAxisCountLarge = ProductGridConfigs.crossAxisCountLarge,
    this.crossAxisSpacing = ProductGridConfigs.crossAxisSpacing,
    this.mainAxisSpacing = ProductGridConfigs.mainAxisSpacing,
    this.padding = ProductGridConfigs.padding,
    this.noDataMessage = ProductGridConfigs.noDataMessage,
    this.physics = ProductGridConfigs.physics,
    this.shrinkWrap = ProductGridConfigs.shrinkWrap,
    this.scrollController,
    this.canAdd = ProductGridConfigs.canAdd,
    this.addAutomaticKeepAlives = ProductGridConfigs.addAutomaticKeepAlives,
    this.addRepaintBoundaries = ProductGridConfigs.addRepaintBoundaries,
    this.addSemanticIndexes = ProductGridConfigs.addSemanticIndexes,
    this.cacheExtent = ProductGridConfigs.cacheExtent,
    this.restorationId = ProductGridConfigs.restorationId,
    this.clipBehavior = ProductGridConfigs.clipBehavior,
    this.scrollDirection = ProductGridConfigs.scrollDirection,
    this.reverse = ProductGridConfigs.reverse,
    this.primary = ProductGridConfigs.primary,
    this.debounceMs = ProductGridConfigs.debounceMs,
    this.searchHint = ProductGridConfigs.searchHint,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? selectedCategoryId;

  String get organizationId {
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  @override
  void initState() {
    super.initState();
    final changesValue = context.read<AppChangesValues>();
    selectedCategoryId = changesValue.selectedCategoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesBloc>().loadCategories(shopId: organizationId);
    });
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

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text('${AppStrings.deleteMessage}${product.name.ar}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductsBloc>().deleteProduct(product.productId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _toggleProductProperty(
    ProductModel product,
    String property,
    bool value,
  ) {
    context.read<ProductsBloc>().updateProduct(
      productId: product.productId,
      data: {property: value},
    );
  }

  void _quickChangePrice(ProductModel product) {
    final controller = TextEditingController(text: product.price.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تغيير السعر: ${product.name.ar}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'السعر الجديد',
            suffixText: 'ج.م',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                Navigator.pop(context);
                context.read<ProductsBloc>().updateProduct(
                  productId: product.productId,
                  data: {
                    'price': newPrice,
                    'oldPrice': product.price, // Move current price to old price
                  },
                );
              }
            },
            child: const Text('حفظ'),
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
        (user?.can(SystemFeatures.product, SystemJobs.add) ?? widget.canAdd) &&
        ProductInputConfig.enableAddProduct;
    final canUpdate =
        user?.can(SystemFeatures.product, SystemJobs.update) ?? true;
    final canDelete =
        user?.can(SystemFeatures.product, SystemJobs.delete) ?? true;

    final configBloc = context.watch<OrganizationConfigBloc>();
    final featureConfig = configBloc.state.itemState.maybeWhen(
      success: (data) => data?.feature?.products,
      orElse: () => null,
    );

    if (widget.getMainPath() != null) {
      context.read<AppChangesValues>().setLastRoute(widget.getMainPath()!);
    }
    final authWidget = AppChangesValues.checkAuth(context, widget);
    if (authWidget != null) return authWidget;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: AppStrings.products,
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child: BlocListener<ProductsBloc, FeaturDataSourceState<ProductModel>>(
          listener: (context, state) {
            state.itemState.maybeWhen(
              failure: (error, onRetry) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: const [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Text('خطأ في العملية'),
                      ],
                    ),
                    content: Text(error.message ?? 'خطأ غير معروف'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('حسنًا'),
                      ),
                    ],
                  ),
                );
              },
              success: (data) {
                // If it was a delete or update operation
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
          child: MasterGrid<ProductModel, ProductsBloc>(
            title: AppStrings.products,
            filterToolbar: _buildCategoryFilterSection(isDark),
            where: (product) {
              if (selectedCategoryId == null) return true;
              return product.categoryId == selectedCategoryId;
            },
            itemBuilder: (context, product) {
              return _buildProductCard(product, isDark, canUpdate, canDelete);
            },
            onAdd: _addProduct,
            onLoad: (bloc) => bloc.loadProducts(),
            canAdd: canAdd,
            showAddInGrid: ProductInputConfig.showAddProductInGrid,
            childAspectRatio:
                featureConfig?.childAspectRatio ?? widget.childAspectRatio,
            crossAxisCountSmall:
                featureConfig?.crossAxisCountSmall ?? widget.crossAxisCountSmall,
            crossAxisCountMedium:
                featureConfig?.crossAxisCountMedium ??
                widget.crossAxisCountMedium,
            crossAxisCountLarge:
                featureConfig?.crossAxisCountLarge ?? widget.crossAxisCountLarge,
            crossAxisSpacing:
                featureConfig?.crossAxisSpacing ?? widget.crossAxisSpacing,
            mainAxisSpacing:
                featureConfig?.mainAxisSpacing ?? widget.mainAxisSpacing,
            padding: featureConfig?.padding != null
                ? EdgeInsets.fromLTRB(
                    featureConfig!.padding![3].toDouble(),
                    featureConfig.padding![0].toDouble(),
                    featureConfig.padding![1].toDouble(),
                    featureConfig.padding![2].toDouble(),
                  )
                : widget.padding,
            noDataMessage: widget.noDataMessage ?? "لا توجد منتجات حالياً",
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

  Widget _buildCategoryFilterSection(bool isDark) {
    return BlocBuilder<CategoriesBloc, FeaturDataSourceState<CategoryModel>>(
      builder: (context, state) {
        return state.listState.maybeWhen(
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
          orElse: () => const SizedBox.shrink(),
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

  Widget _buildProductCard(
    ProductModel product,
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
          InkWell(
            onTap: () => _editProduct(product),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.images.isNotEmpty
                          ? Image.network(
                              product.mainImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50),
                            ),
                      if (!product.isAvailable)
                        Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: Icon(
                              Icons.block,
                              color: Colors.white70,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
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
                      if (product.stockQuantity < 10 && product.isAvailable)
                        Text(
                          '${AppStrings.remaining}${product.stockQuantity} فقط!',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      if (!product.isAvailable)
                        const Text(
                          AppStrings.notAvailable,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (canUpdate || canDelete)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? DarkColors.surface.withOpacity(0.5)
                      : LightColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  onPressed: () =>
                      _showProductActions(product, canUpdate, canDelete),
                ),
              ),
            ),

          // Badges
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.isNew) _buildBadge(AppStrings.isNew, Colors.green),
                if (product.isSuperJoker)
                  _buildBadge(AppStrings.superJoker, Colors.deepPurple),
                if (product.isJoker)
                  _buildBadge(AppStrings.joker, Colors.blueAccent),
                if (product.isBestSeller)
                  _buildBadge(AppStrings.bestSeller, Colors.orange),
                if (product.isOnSale)
                  _buildBadge(AppStrings.onSale, Colors.redAccent),
              ],
            ),
          ),

          // ⚠️ تحذير نقص الصور
          if (product.images.isEmpty)
            Positioned(
              bottom: 60,
              left: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _editProduct(product),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: (product.isNew || product.isJoker || product.isOnSale || product.isBestSeller)
                        ? Colors.red.withOpacity(0.9)
                        : Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          (product.isNew || product.isJoker || product.isOnSale || product.isBestSeller)
                              ? 'إضافة صورة (مطلوب فوراً)'
                              : 'يرجى إضافة صورة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showProductActions(
    ProductModel product,
    bool canUpdate,
    bool canDelete,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductActionsSheet(
        product,
        isDark,
        canUpdate,
        canDelete,
      ),
    );
  }

  Widget _buildProductActionsSheet(
    ProductModel product,
    bool isDark,
    bool canUpdate,
    bool canDelete,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.mainImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.ar,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${product.price} ج.م',
                        style: TextStyle(
                          color:
                              isDark ? DarkColors.primary : LightColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteProduct(product);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Section: Main Actions
          if (canUpdate) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMainActionButton(
                    icon: Icons.edit_outlined,
                    label: 'تعديل',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _editProduct(product);
                    },
                  ),
                  if (ProductInputConfig.enableMultiSizePricing)
                    _buildMainActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'أحجام',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _editProduct(product);
                      },
                    ),
                  if (ProductInputConfig.showChangePriceInPopup)
                    _buildMainActionButton(
                      icon: Icons.price_change_outlined,
                      label: 'السعر',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _quickChangePrice(product);
                      },
                    ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Section: Options (Toggles)
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (canUpdate)
                  _buildToggleOption(
                    title: 'متوفر للبيع',
                    subtitle: 'إظهار المنتج للعملاء في المتجر',
                    icon: Icons.visibility_outlined,
                    value: product.isAvailable,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _toggleProductProperty(product, 'isAvailable', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsNew)
                  _buildToggleOption(
                    title: 'منتج جديد',
                    subtitle: 'إضافة شارة "جديد" على المنتج',
                    icon: Icons.new_releases_outlined,
                    value: product.isNew,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _toggleProductProperty(product, 'isNew', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsBestSeller)
                  _buildToggleOption(
                    title: 'الأكثر مبيعاً',
                    subtitle: 'تمييز المنتج كأكثر طلباً',
                    icon: Icons.star_outline,
                    value: product.isBestSeller,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _toggleProductProperty(product, 'isBestSeller', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsOnSale)
                  _buildToggleOption(
                    title: 'في العروض',
                    subtitle: 'إدراج المنتج في قسم التخفيضات',
                    icon: Icons.local_offer_outlined,
                    value: product.isOnSale,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _toggleProductProperty(product, 'isOnSale', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsJoker)
                  _buildToggleOption(
                    title: 'منتج جوكر',
                    subtitle: 'تمييز كمنتج مميز جداً',
                    icon: Icons.style_outlined,
                    value: product.isJoker,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _toggleProductProperty(product, 'isJoker', val);
                    },
                  ),
                if (canUpdate && ProductInputConfig.showIsSuperJoker)
                  _buildToggleOption(
                    title: 'سوبر جوكر',
                    subtitle: 'أعلى درجة تمييز للمنتج',
                    icon: Icons.workspace_premium_outlined,
                    value: product.isSuperJoker,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _toggleProductProperty(product, 'isSuperJoker', val);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMainActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
