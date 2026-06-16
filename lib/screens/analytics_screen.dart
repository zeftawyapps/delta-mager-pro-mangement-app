import 'package:delta_mager_pro_mangement_app/logic/mixins/org_lifecycle_manager.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/analytics_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';

// ignore: must_be_immutable
class AnalyticsScreen extends StatefulWidget with AppShellRouterMixin {
  AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SystemManager, OrgLifecycleManager {
  @override
  void initState() {
    super.initState();
    initOrgListener(
      onOrgChanged: (orgId) {
        _loadData(orgId);
      },
    );

    // Initial load if org is already set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orgId = organizationId;
      _loadData(orgId);
    });
  }

  void _loadData(String orgId) {
    context.read<AnalyticsBloc>().loadSalesReport(organizationId: orgId);
    context.read<AnalyticsBloc>().loadTopSellingProducts(organizationId: orgId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;

    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.screenDashboard,
      mainPath: widget.getMainPath(),
    );

    if (sys.authWidget != null) return sys.authWidget!;

    final appBarConfig = sys.appBarConfig;

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: 'التحليلات والإحصائيات',
        isDesplayTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Summary Section
                  _buildSectionTitle("ملخص الأداء العام", Icons.analytics_outlined, primaryColor),
                  const SizedBox(height: 16),
                  state.salesReportState.when(
                    init: () => const SizedBox.shrink(),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    success: (report) => _buildSummaryCards(report!, primaryColor, isDark),
                    failure: (error, retry) => _buildErrorWidget(error.message ?? "Error", retry),
                  ),

                  const SizedBox(height: 32),

                  // 2. Top Selling Products
                  _buildSectionTitle("المنتجات الأكثر مبيعاً", Icons.star_outline, primaryColor),
                  const SizedBox(height: 16),
                  state.topSellingProductsState.when(
                    init: () => const SizedBox.shrink(),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    success: (products) => _buildTopSellingList(products!, primaryColor, isDark),
                    failure: (error, retry) => _buildErrorWidget(error.message ?? "Error", retry),
                  ),

                  const SizedBox(height: 32),

                  // 3. Recent Sales Records
                  _buildSectionTitle("آخر عمليات البيع", Icons.history, primaryColor),
                  const SizedBox(height: 16),
                  state.salesReportState.maybeWhen(
                    success: (report) => _buildRecentSalesTable(report!.records, isDark),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(SalesReport report, Color primaryColor, bool isDark) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard("إجمالي الإيرادات", report.totalRevenue, Icons.attach_money, Colors.blue, isDark),
        _buildStatCard("إجمالي التكاليف", report.totalCost, Icons.money_off, Colors.red, isDark),
        _buildStatCard("صافي الأرباح", report.totalProfit, Icons.trending_up, Colors.green, isDark),
        _buildStatCard("الكمية المباعة", report.totalQuantity.toDouble(), Icons.shopping_bag_outlined, Colors.orange, isDark, isCurrency: false),
      ],
    );
  }

  Widget _buildStatCard(String title, double value, IconData icon, Color color, bool isDark, {bool isCurrency = true}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCurrency ? "${value.toStringAsFixed(2)} \$" : value.toInt().toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingList(List<TopSellingProduct> products, Color primaryColor, bool isDark) {
    if (products.isEmpty) {
      return const Center(child: Text("لا توجد بيانات متاحة حالياً"));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: p.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(p.imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  ),
            title: Text(p.productName.ar, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("الكمية: ${p.totalQuantity} | الإيرادات: ${p.totalRevenue.toStringAsFixed(2)} \$"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("الأرباح", style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  "${p.totalProfit.toStringAsFixed(2)} \$",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentSalesTable(List<SalesRecord> records, bool isDark) {
    if (records.isEmpty) {
      return const Center(child: Text("لا توجد عمليات بيع مسجلة"));
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("المنتج")),
            DataColumn(label: Text("الكمية")),
            DataColumn(label: Text("سعر البيع")),
            DataColumn(label: Text("الربح")),
            DataColumn(label: Text("التاريخ")),
          ],
          rows: records.take(10).map((r) {
            return DataRow(cells: [
              DataCell(Text(r.productName.ar)),
              DataCell(Text(r.quantity.toString())),
              DataCell(Text("${r.soldPrice.toStringAsFixed(2)} \$")),
              DataCell(Text("${r.profit.toStringAsFixed(2)} \$", style: const TextStyle(color: Colors.green))),
              DataCell(Text("${r.soldAt.day}/${r.soldAt.month}/${r.soldAt.year}")),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        children: [
          Text("❌ $message", style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text("إعادة المحاولة")),
        ],
      ),
    );
  }
}
