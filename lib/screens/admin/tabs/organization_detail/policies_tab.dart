import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';

class PoliciesSectionTab extends StatelessWidget {
  final OrganizationPolicyModel policy;
  final bool isDark;

  const PoliciesSectionTab({
    super.key,
    required this.policy,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPolicyCard(
            title: "إعدادات اللوجستيات (Logistics)",
            icon: Icons.local_shipping_outlined,
            children: [
              _buildInfoTile("العملة", policy.logistics?.currency ?? "غير محدد"),
              _buildInfoTile("ضريبة القيمة المضافة", policy.logistics?.enableVat == true ? "مفعلة (${policy.logistics?.taxPercentage}%)" : "معطلة"),
              _buildInfoTile("إدارة المخزون", policy.logistics?.enableStockManagement == true ? "مفعلة" : "معطلة"),
              _buildInfoTile("الوحدة الافتراضية", policy.logistics?.defaultUnit ?? "غير محدد"),
            ],
          ),
          const SizedBox(height: 16),
          _buildPolicyCard(
            title: "سياسة الشحن (Shipping)",
            icon: Icons.delivery_dining_outlined,
            children: [
              _buildInfoTile("تكلفة الشحن الافتراضية", "${policy.shipping?.defaultFee ?? 0} ${policy.logistics?.currency ?? ''}"),
              _buildInfoTile("الشحن المجاني", policy.shipping?.freeShippingEnabled == true ? "مفعل" : "معطل"),
              if (policy.shipping?.feesByGovernorate.isNotEmpty ?? false)
                ...policy.shipping!.feesByGovernorate.entries.map((e) => _buildInfoTile("شحن إلى ${e.key}", "${e.value}")),
            ],
          ),
          const SizedBox(height: 16),
          _buildPolicyCard(
            title: "قواعد المبيعات (Sales Rules)",
            icon: Icons.sell_outlined,
            children: [
              _buildInfoTile("الخصم التلقائي", policy.salesRules?.autoDiscount == true ? "مفعل" : "معطل"),
              _buildInfoTile("خصم الجملة", "${policy.salesRules?.wholesaleDiscount ?? 0}%"),
              _buildInfoTile("خصم الوكلاء", "${policy.salesRules?.agentDiscount ?? 0}%"),
              if (policy.salesRules?.invoiceSlices.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("شرائح الفواتير:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ...policy.salesRules!.invoiceSlices.map((s) => Text("- أكثر من ${s.minAmount}: خصم ${s.discountAmount}", style: const TextStyle(fontSize: 11))),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: children,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
    );
  }
}
