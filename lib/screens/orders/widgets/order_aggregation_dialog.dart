import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:matger_pro_core_logic/features/commrec/data/order_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'dart:html' as html;

class AggregatedItem {
  final String id;
  final String name;
  final String description;
  final int totalQuantity;
  final double unitPrice;
  final double totalPrice;
  bool isChecked;

  AggregatedItem({
    required this.id,
    required this.name,
    required this.description,
    required this.totalQuantity,
    required this.unitPrice,
    required this.totalPrice,
    this.isChecked = false,
  });

  String get compositeKey => '${id}_$description';
}

class OrderAggregationDialog extends StatefulWidget {
  final List<OrderModel> orders;
  final String stepName;
  final String? pathName;
  final String orgName;
  final String? orgLogoUrl;
  final Color? brandColor;
  final bool isDark;

  const OrderAggregationDialog({
    super.key,
    required this.orders,
    required this.stepName,
    this.pathName,
    required this.orgName,
    this.orgLogoUrl,
    this.brandColor,
    required this.isDark,
  });

  @override
  State<OrderAggregationDialog> createState() => _OrderAggregationDialogState();
}

class _OrderAggregationDialogState extends State<OrderAggregationDialog> {
  final List<AggregatedItem> _aggregatedItems = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _processOrdersData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _processOrdersData() {
    final Map<String, AggregatedItem> map = {};

    for (final order in widget.orders) {
      final items = order.items;
      for (final item in items) {
        final id = item.id;
        final name = item.name ?? 'منتج بدون اسم';
        final desc = item.description ?? '';
        final key = '${id}_$desc';
        final qty = item.quantity;
        final price = item.unitPrice;
        final totalP = item.totalPrice;

        if (map.containsKey(key)) {
          final existing = map[key]!;
          map[key] = AggregatedItem(
            id: id,
            name: name,
            description: desc,
            totalQuantity: existing.totalQuantity + qty,
            unitPrice: price,
            totalPrice: existing.totalPrice + totalP,
            isChecked: existing.isChecked,
          );
        } else {
          map[key] = AggregatedItem(
            id: id,
            name: name,
            description: desc,
            totalQuantity: qty,
            unitPrice: price,
            totalPrice: totalP,
          );
        }
      }
    }

    _aggregatedItems.addAll(map.values);
  }

  void _printAggregatedInvoice() {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الطباعة متاحة في تطبيق المتصفح")),
      );
      return;
    }

    final nowStr = DateTime.now().toString().split('.').first;
    final primaryColor = widget.brandColor ?? (widget.isDark ? DarkColors.primary : LightColors.primary);
    final themeHex = '#${primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    final logoHtml = (widget.orgLogoUrl != null && widget.orgLogoUrl!.trim().isNotEmpty)
        ? '<img src="${widget.orgLogoUrl}" style="max-height: 55px; max-width: 160px; object-fit: contain; margin-left: 14px;" />'
        : '';

    final rowsHtml = _aggregatedItems.map((item) {
      final checkSymbol = item.isChecked ? '✓' : '';
      return '''
        <tr>
          <td style="text-align:center; padding:8px; border:1px solid #ddd; font-weight:bold; color:green;">$checkSymbol</td>
          <td style="padding:8px; border:1px solid #ddd; font-weight:bold;">${item.name}</td>
          <td style="padding:8px; border:1px solid #ddd; color:#555;">${item.description.isNotEmpty ? item.description : '-'}</td>
          <td style="text-align:center; padding:8px; border:1px solid #ddd; font-weight:bold; font-size:15px; color:$themeHex;">${item.totalQuantity}</td>
        </tr>
      ''';
    }).join('');

    final htmlContent = '''
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
      <meta charset="utf-8">
      <title>فاتورة تجميع طلبات المخزن - ${widget.orgName}</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 25px; color: #333; background: #fff; }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid $themeHex; padding-bottom: 12px; margin-bottom: 20px; }
        .title-box { display: flex; align-items: center; }
        .title { font-size: 24px; font-weight: bold; color: $themeHex; }
        .meta-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; background: #f4f6f9; padding: 14px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; border: 1px solid #e0e0e0; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        th { background-color: $themeHex; color: white; padding: 10px; border: 1px solid $themeHex; font-size: 14px; }
        td { font-size: 13px; }
        .signatures { display: flex; justify-content: space-between; margin-top: 50px; padding-top: 20px; border-top: 1px dashed #ccc; }
        .sig-box { text-align: center; width: 220px; }
        .sig-line { margin-top: 50px; border-bottom: 1px solid #000; }
        @media print {
          body { padding: 0; }
        }
      </style>
    </head>
    <body>
      <div class="header">
        <div class="title-box">
          $logoHtml
          <div>
            <div class="title">📦 فاتورة تجميع طلبات المخزن</div>
            <div style="font-size: 13px; color: #555; margin-top: 2px;">${widget.orgName}</div>
          </div>
        </div>
        <div style="text-align: left;"><strong>المؤسسة:</strong> ${widget.orgName}<br><small style="color:#777;">التاريخ: $nowStr</small></div>
      </div>
      <div class="meta-grid">
        <div><strong>خط السير:</strong> ${widget.pathName ?? 'جميع الخطوط النشطة'}</div>
        <div><strong>مرحلة سير العمل:</strong> ${widget.stepName}</div>
        <div><strong>عدد الطلبات المجمعة:</strong> ${widget.orders.length} طلب</div>
        <div><strong>إجمالي أصناف المنتجات:</strong> ${_aggregatedItems.length} صنف</div>
      </div>
      <table>
        <thead>
          <tr>
            <th style="width: 45px;">تفقيد</th>
            <th>اسم المنتج</th>
            <th>الوصف الفرعي / المواصفات والعبوات</th>
            <th style="width: 130px;">الكمية الكلية المطلوب صرفها</th>
          </tr>
        </thead>
        <tbody>
          $rowsHtml
        </tbody>
      </table>
      <div class="signatures">
        <div class="sig-box">
          <div>توقيع وتعميد أمين المخزن</div>
          <div class="sig-line"></div>
        </div>
        <div class="sig-box">
          <div>توقيع المستلم / السائق</div>
          <div class="sig-line"></div>
        </div>
      </div>
      <script>
        window.onload = function() {
          setTimeout(function() {
            window.print();
          }, 300);
        };
      </script>
    </body>
    </html>
    ''';

    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');

    Future.delayed(const Duration(seconds: 10), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.brandColor ?? (widget.isDark
        ? DarkColors.primary
        : LightColors.primary);

    final filteredList = _aggregatedItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();

    final checkedCount = _aggregatedItems.where((i) => i.isChecked).length;
    final totalUnits = _aggregatedItems.fold<int>(
      0,
      (sum, i) => sum + i.totalQuantity,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 750,
        height: 650,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "تجميعة طلبات المخزن (Warehouse Pick List)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "تجميع ${widget.orders.length} طلب | ${widget.pathName ?? 'جميع الخطوط'} (${widget.stepName})",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _printAggregatedInvoice,
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text("طباعة الفاتورة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary Stats Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    "إجمالي الطلبات",
                    "${widget.orders.length}",
                    Icons.receipt_long,
                    primaryColor,
                  ),
                  _buildStatItem(
                    "الأصناف المختلفة",
                    "${_aggregatedItems.length}",
                    Icons.category,
                    primaryColor,
                  ),
                  _buildStatItem(
                    "إجمالي القطع الكلي",
                    "$totalUnits",
                    Icons.widgets,
                    primaryColor,
                  ),
                  _buildStatItem(
                    "تم تجميعها",
                    "$checkedCount من ${_aggregatedItems.length}",
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "بحث عن منتج أو وصف فرعي...",
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
            const SizedBox(height: 12),

            // Items List
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text("لا توجد منتجات مطابقة"))
                  : ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return CheckboxListTile(
                          value: item.isChecked,
                          activeColor: Colors.green,
                          onChanged: (val) {
                            setState(() {
                              item.isChecked = val ?? false;
                            });
                          },
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    decoration: item.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  "${item.totalQuantity} قطعة",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: item.description.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      "المواصفات والعبوة: ${item.description}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.isDark
                                            ? Colors.orange.shade200
                                            : Colors.orange.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إغلاق"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
