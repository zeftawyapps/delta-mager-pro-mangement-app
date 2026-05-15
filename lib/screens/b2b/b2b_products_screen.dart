import 'package:delta_mager_pro_mangement_app/screens/b2b/widgets/b2b_cart_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/offer.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/cart_provider.dart';
import 'package:delta_mager_pro_mangement_app/screens/b2b/widgets/b2b_product_card.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class B2BProductsScreen extends StatefulWidget {
  final String organizationId;
  final CategoryModel? categoryFilter;
  final OfferModel? offerFilter;
  final String? searchQuery;

  const B2BProductsScreen({
    super.key,
    required this.organizationId,
    this.categoryFilter,
    this.offerFilter,
    this.searchQuery,
  });

  @override
  State<B2BProductsScreen> createState() => _B2BProductsScreenState();
}

class _B2BProductsScreenState extends State<B2BProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.offerFilter != null) {
        // Here you might need a specific call if the backend supports getting products by offer
        // For now, load all products, or load discounted products
        context.read<ProductsBloc>().loadDiscountedProducts();
      } else {
        context.read<ProductsBloc>().loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title =
        widget.categoryFilter?.nameAr ??
        widget.offerFilter?.name.ar ??
        'المنتجات';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button and Category Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  if (widget.categoryFilter != null) ...[
                    Hero(
                      tag: 'category_${widget.categoryFilter!.id}',
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.categoryFilter!.imageUrl != null &&
                                  widget.categoryFilter!.imageUrl!.isNotEmpty
                              ? Image.network(
                                  widget.categoryFilter!.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: isDark ? DarkColors.surface : Colors.white,
                                  child: Icon(Icons.category_outlined, 
                                    color: isDark ? DarkColors.primary : LightColors.primary,
                                    size: 20,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.categoryFilter != null && widget.categoryFilter!.descriptionAr.isNotEmpty)
                          Text(
                            widget.categoryFilter!.descriptionAr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                  B2BCartBadge(organizationId: widget.organizationId),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductsBloc, FeaturDataSourceState<ProductModel>>(
                builder: (context, state) {
                  return state.listState.when(
                    init: () => const Center(child: CircularProgressIndicator()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    success: (products) {
                      var filteredProducts = products ?? [];

                      if (widget.categoryFilter != null) {
                        filteredProducts = filteredProducts
                            .where((p) => p.categoryId == widget.categoryFilter!.id)
                            .toList();
                      }

                      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
                        final query = widget.searchQuery!.toLowerCase();
                        filteredProducts = filteredProducts.where((p) {
                          return p.name.ar.toLowerCase().contains(query) ||
                              p.name.en.toLowerCase().contains(query);
                        }).toList();
                      }

                      if (filteredProducts.isEmpty) {
                        return const Center(child: Text('لا توجد منتجات'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(context, product, isDark);
                        },
                      );
                    },
                    failure: (error, retry) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('حدث خطأ في تحميل المنتجات'),
                          TextButton(
                            onPressed: retry,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    bool isDark,
  ) {
    return B2BProductCard(product: product, isDark: isDark);
  }
}
