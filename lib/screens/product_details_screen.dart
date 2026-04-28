import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/ui_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProductDetailsScreen extends StatefulWidget with AppShellRouterMixin {
  final ProductModel product;
  ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final product = widget.product;
    final appBarConfig = AppBarConfigs.buildLargeScreenAppBar(context);

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: '${AppStrings.productDetailsTitle}: ${product.name.ar}',
        isDesplayTitle: true,
      ),
      body: Container(
        color: isDark ? DarkColors.background : LightColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Images and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery Section
                  Expanded(flex: 1, child: _buildImageGallery(product, isDark)),
                  const SizedBox(width: 32),
                  // Basic Info Section
                  Expanded(
                    flex: 2,
                    child: _buildBasicInfo(product, isDark, theme),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Pricing and Stock Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildPriceOptionsTable(product, isDark),
                  ),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildStatusFlags(product, isDark)),
                ],
              ),

              const SizedBox(height: 32),
              // Meta Data and Created At
              _buildMetaDataSection(product, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(ProductModel product, bool isDark) {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? DarkColors.surface : LightColors.surface,
            border: Border.all(
              color: isDark ? DarkColors.divider : LightColors.divider,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: product.images.isNotEmpty
                ? Image.network(
                    product.mainImage,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported, size: 64),
                    ),
                  )
                : const Center(child: Icon(Icons.image, size: 64)),
          ),
        ),
        if (product.images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBasicInfo(ProductModel product, bool isDark, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? DarkColors.divider : LightColors.divider,
        ),
      ),
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name.ar,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                ),
                _buildBadge(
                  product.isActive ? AppStrings.active : AppStrings.inactive,
                  product.isActive ? Colors.green : Colors.red,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.name.en,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  Icons.category,
                  '${AppStrings.categoryLabel}: ${product.categoryId}',
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.inventory,
                  '${AppStrings.stockLabel}: ${product.stockQuantity}',
                  isDark,
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              AppStrings.description,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description.ar,
              style: TextStyle(
                height: 1.5,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.currentPrice,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${product.price} ج.م',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? DarkColors.primary
                            : LightColors.primary,
                      ),
                    ),
                  ],
                ),
                if (product.hasDiscount) ...[
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.oldPrice,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${product.oldPrice ?? 0} ج.م',
                        style: const TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
                const Spacer(),
                if (product.cost != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        AppStrings.cost,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${product.cost} ج.م',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOptionsTable(ProductModel product, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? DarkColors.divider : LightColors.divider,
        ),
      ),
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.priceOptionsTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة خيار'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (product.priceOptions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('لا توجد خيارات أسعار إضافية لهذا المنتج'),
                ),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: IntrinsicColumnWidth(),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: isDark
                        ? DarkColors.divider.withValues(alpha: 0.5)
                        : LightColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                children: [
                  _buildTableHeader(isDark),
                  ...product.priceOptions
                      .map((opt) => _buildTableRow(opt, isDark))
                      .toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader(bool isDark) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
    return const TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(AppStrings.priceOptionsSubtitle, style: style),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(AppStrings.quantity, style: style),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(AppStrings.unit, style: style),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(AppStrings.currentPrice, style: style),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(AppStrings.actions, style: style),
        ),
      ],
    );
  }

  TableRow _buildTableRow(PriceOption opt, bool isDark) {
    return TableRow(
      decoration: BoxDecoration(
        color: opt.isDefault
            ? (isDark
                  ? Colors.blue.withValues(alpha: 0.05)
                  : Colors.blue.withValues(alpha: 0.02))
            : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(opt.sizeDisplay?.ar ?? AppStrings.defaultOption),
              if (opt.isDefault)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.star, size: 14, color: Colors.amber),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(opt.quantity.toString()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(opt.unit),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${opt.price} ج.م',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFlags(ProductModel product, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? DarkColors.divider : LightColors.divider,
        ),
      ),
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.productStatus,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFlagToggle(
              AppStrings.available,
              product.isAvailable,
              Icons.check_circle_outline,
              Colors.green,
            ),
            _buildFlagToggle(
              AppStrings.isNew,
              product.isNew,
              Icons.new_releases_outlined,
              Colors.blue,
            ),
            _buildFlagToggle(
              AppStrings.bestSeller,
              product.isBestSeller,
              Icons.trending_up,
              Colors.orange,
            ),
            _buildFlagToggle(
              AppStrings.onSale,
              product.isOnSale,
              Icons.local_offer_outlined,
              Colors.red,
            ),
            _buildFlagToggle(
              'Joker',
              product.isJoker,
              Icons.bolt,
              Colors.purple,
            ),
            _buildFlagToggle(
              'Super Joker',
              product.isSuperJoker,
              Icons.workspace_premium,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagToggle(
    String label,
    bool value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: value ? color : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Switch(value: value, onChanged: (v) {}, activeColor: color),
        ],
      ),
    );
  }

  Widget _buildMetaDataSection(ProductModel product, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? DarkColors.divider : LightColors.divider,
        ),
      ),
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildMetaInfo(
              Icons.calendar_today,
              AppStrings.createdAt,
              product.createdAt?.toLocal().toString().split('.')[0] ??
                  'غير متوفر',
            ),
            const Spacer(),
            _buildMetaInfo(
              Icons.fingerprint,
              AppStrings.productId,
              product.productId,
            ),
            const Spacer(),
            _buildMetaInfo(
              Icons.star,
              AppStrings.rating,
              product.rating.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? DarkColors.primary : LightColors.primary,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
