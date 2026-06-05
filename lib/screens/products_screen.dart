import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart'
    hide ProductUnit, PriceOption;
import 'package:matger_pro_core_logic/features/commrec/data/product_model.dart'
    as core_m
    show PriceOption;
import 'package:delta_mager_pro_mangement_app/logic/model/product_unit.dart';
import 'inputs/price_options_widget.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';

import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';

import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'inputs/product_input_form.dart';
import 'inputs/shared_data_product_form.dart';
import 'package:delta_mager_pro_mangement_app/catalog/products/category_filter_section.dart';
import 'package:delta_mager_pro_mangement_app/catalog/products/product_card.dart';
import 'package:delta_mager_pro_mangement_app/catalog/products/product_actions_sheet.dart';

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
    final controller =
        TextEditingController(); // For single base price fallback or simple entry if needed, but we'll use PriceOptionsWidget

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
                    Text(
                      "سيتم تطبيق الأسعار الجديدة على ${products.length} منتج",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                      const SnackBar(
                        content: Text('يجب إضافة سعر واحد على الأقل'),
                      ),
                    );
                    return;
                  }

                  // Find default base price
                  double basePrice = priceOptions
                      .firstWhere(
                        (o) => o.isDefault,
                        orElse: () => priceOptions.first,
                      )
                      .price;

                  // Map to core_m.PriceOption
                  final List<core_m.PriceOption> priceOptionsList = priceOptions
                      .map(
                        (e) => core_m.PriceOption(
                          quantity: e.quantity,
                          unit: e.unit.name,
                          price: e.price,
                          oldPrice: e.oldPrice,
                          isDefault: e.isDefault,
                        ),
                      )
                      .toList();

                  Navigator.pop(context);
                  context.read<ProductsBloc>().unifyProductsPrice(
                    productIds: products.map((e) => e.productId).toList(),
                    organizationId: organizationId,
                    basePrice: basePrice,
                    priceOptions: priceOptionsList,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? DarkColors.primary
                      : LightColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("تطبيق"),
              ),
            ],
          );
        },
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

  void _editProduct(ProductModel product, {bool autoOpenImagePicker = false}) {
    showCustomInputDialog(
      context: context,
      content: ProductInputForm(
        product: product,
        autoOpenImagePicker: autoOpenImagePicker,
      ),
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

  void _safeToggleProperty(ProductModel product, String property, bool value) {
    // الخصائص التي تتطلب وجود صورة
    final featuredProperties = [
      'isNew',
      'isBestSeller',
      'isOnSale',
      'isJoker',
      'isSuperJoker',
      'isInsideOffer',
    ];

    if (value == true &&
        featuredProperties.contains(property) &&
        product.images.isEmpty) {
      // إظهار مربع حوار تنبيهي بدلاً من SnackBar
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('تنبيه: الصورة مطلوبة'),
            ],
          ),
          content: const Text(
            'عذراً، لا يمكن تفعيل هذه الخاصية لمنتج بدون صورة. يرجى إضافة صورة للمنتج من شاشة التعديل أولاً.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // إغلاق التنبيه
                Navigator.pop(context); // إغلاق القائمة السفلية
                // فتح شاشة التعديل فوراً مع تفعيل اختيار الصورة آلياً
                _editProduct(product, autoOpenImagePicker: true);
              },
              child: const Text('موافق (إضافة صورة)'),
            ),
          ],
        ),
      );
      return;
    }

    _toggleProductProperty(product, property, value);
    // إغلاق القائمة في حالة النجاح فقط
    Navigator.pop(context);
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
            filterToolbar: CategoryFilterSection(
              selectedCategoryId: selectedCategoryId,
              isDark: isDark,
              onCategorySelected: (id) {
                setState(() => selectedCategoryId = id);
                context.read<AppChangesValues>().setSelectedCategoryId(id);
              },
            ),
            where: (product) {
              if (selectedCategoryId == null) return true;
              return product.categoryId == selectedCategoryId;
            },
            onAdd: _addProduct,
            onLoad: (bloc) => bloc.loadProducts(),
            onSearch: (bloc, query) => bloc.searchProducts(
              query: query,
              organizationId: organizationId,
            ),
            onItemTap: _editProduct,
            canAdd: canAdd,
            itemBuilder: (context, product, isSelected) => ProductCard(
              product: product,
              isDark: isDark,
              canUpdate: canUpdate,
              canDelete: canDelete,
              onEdit: () => _editProduct(product),
              onShowActions: () =>
                  _showProductActions(product, canUpdate, canDelete),
            ),
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
      builder: (context) => ProductActionsSheet(
        product: product,
        isDark: isDark,
        canUpdate: canUpdate,
        canDelete: canDelete,
        onDelete: () {
          Navigator.pop(context);
          _deleteProduct(product);
        },
        onEdit: () {
          Navigator.pop(context);
          _editProduct(product);
        },
        onQuickChangePrice: () {
          _quickChangePrice(product);
        },
        onToggleProperty: (property, value) {
          if (property == 'isAvailable') {
            _toggleProductProperty(product, property, value);
          } else {
            if (property == 'isSuperJoker') {
              Navigator.pop(context);
            }
            _safeToggleProperty(product, property, value);
          }
        },
      ),
    );
  }
}
