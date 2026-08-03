import 'package:flutter/material.dart';
import 'package:JoDija_reposatory/constes/api_urls.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_aggregation_dialog.dart';

class OrderFilterToolbar extends StatelessWidget {
  final bool showDateFilter;
  final bool showDistanceSort;
  final bool showAggregation;
  final int selectedDateFilter;
  final bool sortByDistance;
  final List<OrderModel> filteredOrders;
  final String currentStepName;
  final String? selectedFilterPathId;
  final dynamic orgConfig;
  final String? organizationId;
  final ValueChanged<int> onDateFilterChanged;
  final ValueChanged<bool> onSortByDistanceChanged;

  const OrderFilterToolbar({
    super.key,
    required this.showDateFilter,
    required this.showDistanceSort,
    required this.showAggregation,
    required this.selectedDateFilter,
    required this.sortByDistance,
    required this.filteredOrders,
    required this.currentStepName,
    required this.selectedFilterPathId,
    required this.orgConfig,
    required this.organizationId,
    required this.onDateFilterChanged,
    required this.onSortByDistanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!showDateFilter && !showDistanceSort && !showAggregation) {
      return const SizedBox.shrink();
    }

    final primaryColor = Theme.of(context).primaryColor;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // 1. Segmented Date Filter (Today / Tomorrow)
            if (showDateFilter) ...[
              Container(
                height: 36,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDateChip(
                      context: context,
                      label: "طلبات اليوم",
                      isSelected: selectedDateFilter == 0,
                      onTap: () {
                        if (selectedDateFilter != 0) {
                          onDateFilterChanged(0);
                        }
                      },
                    ),
                    _buildDateChip(
                      context: context,
                      label: "طلبات الغد",
                      isSelected: selectedDateFilter == 1,
                      onTap: () {
                        if (selectedDateFilter != 1) {
                          onDateFilterChanged(1);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],

            // 2. Compact Distance Sort Chip
            if (showDistanceSort) ...[
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sortByDistance ? Icons.location_on : Icons.near_me_outlined,
                      size: 15,
                      color: sortByDistance ? Colors.white : primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "الأقرب",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: sortByDistance ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                ),
                selected: sortByDistance,
                onSelected: onSortByDistanceChanged,
                selectedColor: primaryColor,
                backgroundColor: primaryColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: sortByDistance
                        ? Colors.transparent
                        : primaryColor.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              ),
              const SizedBox(width: 8),
            ],

            // 3. Compact Order Aggregation Action Button
            if (showAggregation && filteredOrders.isNotEmpty) ...[
              ActionChip(
                avatar: const Icon(
                  Icons.inventory_2_outlined,
                  size: 15,
                  color: Colors.white,
                ),
                label: Text(
                  "تجميعة المخزن (${filteredOrders.length})",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  final rawLogoUrl = orgConfig?.visual?.logoUrl;
                  final resolvedLogoUrl = (rawLogoUrl != null &&
                          rawLogoUrl.trim().isNotEmpty)
                      ? (rawLogoUrl.startsWith('http')
                          ? rawLogoUrl
                          : '${ApiUrls.IMAGE_BASE_URL}$rawLogoUrl')
                      : null;

                  final displayOrgName = orgConfig?.layout?.appTitle ??
                      organizationId ??
                      'المتجر';

                  showDialog(
                    context: context,
                    builder: (dialogCtx) => OrderAggregationDialog(
                      orders: filteredOrders,
                      stepName: currentStepName,
                      pathName: selectedFilterPathId,
                      orgName: displayOrgName,
                      orgLogoUrl: resolvedLogoUrl,
                      brandColor: primaryColor,
                      isDark: isDarkTheme,
                    ),
                  );
                },
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : primaryColor,
          ),
        ),
      ),
    );
  }
}
