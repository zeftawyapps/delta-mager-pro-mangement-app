import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';

class RewardsPolicyEditor extends StatelessWidget {
  final RewardsPolicy? rewards;
  final bool isEditing;
  final ValueChanged<RewardsPolicy> onRewardsChanged;
  final bool isDark;

  const RewardsPolicyEditor({
    super.key,
    required this.rewards,
    required this.isEditing,
    required this.onRewardsChanged,
    required this.isDark,
  });

  void _updateRewards({
    bool? isEnabled,
    num? pointsPerCurrency,
    List<RewardTier>? tiers,
  }) {
    onRewardsChanged(RewardsPolicy(
      isEnabled: isEnabled ?? rewards?.isEnabled ?? false,
      pointsPerCurrency: pointsPerCurrency ?? rewards?.pointsPerCurrency ?? 1.0,
      tiers: tiers ?? rewards?.tiers ?? [],
    ));
  }

  void _showAddTierDialog(BuildContext context, {RewardTier? editingTier, int? index}) {
    final nameController = TextEditingController(text: editingTier?.name ?? '');
    final minPointsController = TextEditingController(text: editingTier?.minPoints?.toString() ?? '');
    final discountController = TextEditingController(text: editingTier?.discountPercentage?.toString() ?? '');
    bool eligibleForDraw = editingTier?.eligibleForDraw ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(editingTier == null ? "إضافة شريحة مكافآت جديدة" : "تعديل الشريحة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "اسم الشريحة (مثال: الذهبية، الماسية)"),
              ),
              TextField(
                controller: minPointsController,
                decoration: const InputDecoration(labelText: "الحد الأدنى للنقاط للتأهل"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: discountController,
                decoration: const InputDecoration(labelText: "نسبة الخصم الإضافية (%)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("السماح بالانضمام للسحب الدوري"),
                value: eligibleForDraw,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => eligibleForDraw = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newTiers = List<RewardTier>.from(rewards?.tiers ?? []);
                  final item = RewardTier(
                    name: nameController.text,
                    minPoints: num.tryParse(minPointsController.text) ?? 0,
                    discountPercentage: num.tryParse(discountController.text) ?? 0.0,
                    eligibleForDraw: eligibleForDraw,
                  );
                  if (index != null) {
                    newTiers[index] = item;
                  } else {
                    newTiers.add(item);
                  }
                  _updateRewards(tiers: newTiers);
                }
                Navigator.pop(dialogContext);
              },
              child: Text(editingTier == null ? "إضافة" : "حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white70 : Colors.grey[800];
    final isEnabled = rewards?.isEnabled ?? false;
    final pointsPerCurrency = rewards?.pointsPerCurrency ?? 1.0;
    final tiers = rewards?.tiers ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text("تفعيل نظام النقاط والمكافآت للمنظمة"),
          value: isEnabled,
          contentPadding: EdgeInsets.zero,
          onChanged: isEditing ? (val) => _updateRewards(isEnabled: val) : null,
        ),
        if (isEnabled) ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: pointsPerCurrency.toString(),
            enabled: isEditing,
            decoration: const InputDecoration(
              labelText: "معدل النقاط (عدد النقاط لكل 1 جنيه / عملة)",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => _updateRewards(pointsPerCurrency: num.tryParse(val)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "شرائح العملاء والمكافآت",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: titleColor),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                  onPressed: () => _showAddTierDialog(context),
                  tooltip: "إضافة شريحة جديدة",
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (tiers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "لا توجد شرائح مضافة حالياً. (يمكن إضافة شريحة ذهبية أو ماسية).",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? Colors.grey : Colors.grey[600]),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiers.length,
              itemBuilder: (context, idx) {
                final tier = tiers[idx];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  child: ListTile(
                    dense: true,
                    title: Text(
                      tier.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "النقاط: ${tier.minPoints} • الخصم الإضافي: ${tier.discountPercentage}% • مؤهل للسحب: ${tier.eligibleForDraw == true ? 'نعم' : 'لا'}",
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isEditing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange, size: 16),
                                onPressed: () => _showAddTierDialog(context, editingTier: tier, index: idx),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                onPressed: () {
                                  final newTiers = List<RewardTier>.from(tiers)..removeAt(idx);
                                  _updateRewards(tiers: newTiers);
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}
