import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart' hide ProductUnit, PriceOption;
import 'package:matger_pro_core_logic/features/commrec/data/product_model.dart' as core_m show PriceOption;
import 'package:delta_mager_pro_mangement_app/logic/model/product_unit.dart';
import 'inputs/price_options_widget.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';

import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';

import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'inputs/product_input_form.dart';
import 'inputs/shared_data_product_form.dart';

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

class _ProductsScreenState extends State<ProductsScreen> with SystemManager {
  String? selectedCategoryId;

  String get organizationId {
    final params = widget.getPrams();
    final orgName = params?['orgName'];
    if (orgName != null && orgName != "" && orgName != ":orgName") {
      AppRoutes.activeOrgName = orgName;
      return orgName;
    }
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  @override
  void initState() {
    super.initState();
    final changesValue = context.read<AppChangesValues>();
    selectedCategoryId = changesValue.selectedCategoryId;

    final categoriesBloc = context.read<CategoriesBloc>();

    // التحقق من وجود بيانات مسبقاً لمنع إعادة التحميل غير الضروري
    final hasData = categoriesBloc.state.listState.maybeWhen(
      success: (list) => list != null && list.isNotEmpty,
      orElse: () => false,
    );

    if (!hasData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        categoriesBloc.loadCategories(shopId: organizationId);
      });
    }
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

  void _addSharedDataProducts() {
    showCustomInputDialog(
      context: context,
      content: SharedDataProductForm(organizationId: organizationId),
      height: 700,
      width: 500,
      onResult: (result) {
        context.read<ProductsBloc>().loadProducts();
      },
    );
  }

  void _unifyPrice(List<ProductModel> products) {
    List<PriceOption> priceOptions = [];
    final controller = TextEditingController(); // For single base price fallback or simple entry if needed, but we'll use PriceOptionsWidget

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            title: const Text("توحيد السعر"),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("سيتم تطبيق الأسعار الجديدة على ${products.length} منتج", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    PriceOptionsWidget(
                      initialPriceOptions: priceOptions,
                      onPriceOptionsChanged: (newOptions) {
                        setState(() {
                          priceOptions = newOptions;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (priceOptions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يجب إضافة سعر واحد على الأقل')),
                    );
                    return;
                  }

                  // Find default base price
                  double basePrice = priceOptions.firstWhere((o) => o.isDefault, orElse: () => priceOptions.first).price;

                  // Map to core_m.PriceOption
                  final List<core_m.PriceOption> priceOptionsList = priceOptions.map((e) => core_m.PriceOption(
                    quantity: e.quantity,
                    unit: e.unit.name,
                    price: e.price,
                    oldPrice: e.oldPrice,
                    isDefault: e.isDefault,
                  )).toList();

                  Navigator.pop(context);
                  context.read<ProductsBloc>().unifyProductsPrice(
                    productIds: products.map((e) => e.productId).toList(),
                    organizationId: organizationId,
                    basePrice: basePrice,
                    priceOptions: priceOptionsList,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? DarkColors.primary : LightColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("تطبيق"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _deleteBulkProducts(List<ProductModel> products) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text("هل أنت متأكد من حذف ${products.length} منتج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductsBloc>().bulkDeleteProducts(
                productIds: products.map((e) => e.productId).toList(),
                organizationId: organizationId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
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
                    'oldPrice':
                        product.price, // Move current price to old price
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
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.product,
      mainPath: widget.getMainPath(),
      widgetCanAdd: widget.canAdd,
    );

    if (sys.authWidget != null) return sys.authWidget!;

    final canAdd = sys.canAdd;
    final canUpdate = sys.canUpdate;
    final canDelete = sys.canDelete;
    final featureConfig = sys.featureConfig;
    final isDark = sys.isDark;
    final appBarConfig = sys.appBarConfig;

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
            canMultiSelect: true,
            filterToolbar: _buildCategoryFilterSection(isDark),
            where: (product) {
              if (selectedCategoryId == null) return true;
              return product.categoryId == selectedCategoryId;
            },
            onAdd: _addProduct,
            onLoad: (bloc) => bloc.loadProducts(),
            onItemTap: _editProduct,
            canAdd: canAdd,
            itemBuilder: (context, product, isSelected) =>
                _buildProductCard(product, isDark, canUpdate, canDelete),
            multiSelectActions: (selectedItems) => [
              PopupMenuButton<int>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? DarkColors.primary : LightColors.primary,
                ),
                onSelected: (value) {
                  // سنقوم ببرمجة هذه العمليات لاحقاً
                  if (value == 1) {
                    _unifyPrice(selectedItems.toList());
                  } else if (value == 2) {
                    print("تعديل ${selectedItems.length} منتج");
                  } else if (value == 3) {
                    _deleteBulkProducts(selectedItems.toList());
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.price_change, color: Colors.green),
                      title: Text("توحيد السعر"),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.edit_note, color: Colors.blue),
                      title: Text("تعديل منتجات"),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 3,
                    child: ListTile(
                      leading: Icon(Icons.delete_sweep, color: Colors.red),
                      title: Text("حذف منتجات"),
                    ),
                  ),
                ],
              ),
            ],
            extraActions: [
              PopupMenuButton<int>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DarkColors.primary.withOpacity(0.1)
                        : LightColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? DarkColors.primary : LightColors.primary,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "الإضافة المتعددة",
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDark
                            ? DarkColors.primary
                            : LightColors.primary,
                      ),
                    ],
                  ),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    print("إضافة مصفوفة منتجات");
                  } else if (value == 2) {
                    _addSharedDataProducts();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.grid_on),
                      title: Text("إضافة مصفوفة منتجات"),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.copy_all),
                      title: Text("إضافة منتجات ببيانات مشتركة"),
                    ),
                  ),
                ],
              ),
            ],
            showAddInGrid:
                featureConfig?.showAddInGrid ??
                ProductInputConfig.showAddProductInGrid,
            childAspectRatio:
                featureConfig?.childAspectRatio ?? widget.childAspectRatio,
            crossAxisCountSmall:
                featureConfig?.crossAxisCountSmall ??
                widget.crossAxisCountSmall,
            crossAxisCountMedium:
                featureConfig?.crossAxisCountMedium ??
                widget.crossAxisCountMedium,
            crossAxisCountLarge:
                featureConfig?.crossAxisCountLarge ??
                widget.crossAxisCountLarge,
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
                          child: _buildCategoryChip(c.nameAr, c.id, isDark),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.images.isNotEmpty
                        ? Image.network(
                            product.mainImage,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
                    if (!product.isAvailable)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
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
              // Product Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name.ar,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${product.price} ج.م',
                            style: TextStyle(
                              color: isDark
                                  ? DarkColors.primary
                                  : LightColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.stockQuantity < 10 && product.isAvailable)
                            Text(
                              '${AppStrings.remaining}${product.stockQuantity} فقط!',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action Menu Button
          if (canUpdate || canDelete)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? DarkColors.surface : LightColors.surface)
                      .withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onPressed: () =>
                      _showProductActions(product, canUpdate, canDelete),
                ),
              ),
            ),

          // Badges (New, Joker, etc.)
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

          // Missing Image Warning
          if (ProductInputConfig.showImages && product.images.isEmpty)
            Positioned(
              bottom: 60,
              right: 4,
              child: GestureDetector(
                onTap: () => _editProduct(product),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (product.isNew ||
                            product.isJoker ||
                            product.isOnSale ||
                            product.isBestSeller)
                        ? Colors.red.withValues(alpha: 0.9)
                        : Colors.orange.withValues(alpha: 0.9),
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
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          (product.isNew ||
                                  product.isJoker ||
                                  product.isOnSale ||
                                  product.isBestSeller)
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
      builder: (context) =>
          _buildProductActionsSheet(product, isDark, canUpdate, canDelete),
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
              color: Colors.grey.withValues(alpha: 0.3),
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
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
            color: Colors.black.withValues(alpha: 0.2),
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
