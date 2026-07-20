import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_policy_bloc.dart';

import 'widgets/units_field_editor.dart';
import 'widgets/governorate_fees_editor.dart';
import 'widgets/invoice_slices_editor.dart';
import 'widgets/app_links_editor.dart';
import 'widgets/rewards_policy_editor.dart';

class PoliciesSectionTab extends StatefulWidget {
  final OrganizationPolicyModel policy;
  final String organizationId;
  final bool isDark;

  const PoliciesSectionTab({
    super.key,
    required this.policy,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<PoliciesSectionTab> createState() => _PoliciesSectionTabState();
}

class _PoliciesSectionTabState extends State<PoliciesSectionTab> {
  late OrganizationPolicyModel _editingPolicy;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editingPolicy = widget.policy;
    // Load governorates systematically on start
    context.read<LocationsBloc>().loadGovernorates('EG');
  }

  @override
  void didUpdateWidget(PoliciesSectionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.policy != widget.policy && !_isEditing) {
      _editingPolicy = widget.policy;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<OrganizationPolicyBloc>().updatePolicy(
        widget.organizationId,
        _editingPolicy,
      );
      setState(() => _isEditing = false);
    }
  }

  void _updateLogistics({
    String? currency,
    bool? enableVat,
    num? taxPercentage,
    bool? enableStockManagement,
    String? defaultUnit,
    List<String>? allowedUnits,
  }) {
    setState(() {
      final current = _editingPolicy.logistics ?? LogisticsPolicy();
      _editingPolicy = OrganizationPolicyModel(
        id: _editingPolicy.id,
        shipping: _editingPolicy.shipping,
        salesRules: _editingPolicy.salesRules,
        appLinks: _editingPolicy.appLinks,
        rewards: _editingPolicy.rewards,
        logistics: LogisticsPolicy(
          currency: currency ?? current.currency,
          enableVat: enableVat ?? current.enableVat,
          taxPercentage: taxPercentage ?? current.taxPercentage,
          enableStockManagement:
              enableStockManagement ?? current.enableStockManagement,
          defaultUnit: defaultUnit ?? current.defaultUnit,
          allowedUnits: allowedUnits ?? current.allowedUnits,
        ),
      );
    });
  }

  void _updateShipping({
    num? defaultFee,
    bool? freeShippingEnabled,
    Map<String, num>? feesByGovernorate,
  }) {
    setState(() {
      final current = _editingPolicy.shipping ?? ShippingPolicy();
      _editingPolicy = OrganizationPolicyModel(
        id: _editingPolicy.id,
        logistics: _editingPolicy.logistics,
        salesRules: _editingPolicy.salesRules,
        appLinks: _editingPolicy.appLinks,
        rewards: _editingPolicy.rewards,
        shipping: ShippingPolicy(
          defaultFee: defaultFee ?? current.defaultFee,
          freeShippingEnabled:
              freeShippingEnabled ?? current.freeShippingEnabled,
          feesByGovernorate: feesByGovernorate ?? current.feesByGovernorate,
        ),
      );
    });
  }

  void _updateSalesRules({
    bool? autoDiscount,
    num? wholesaleDiscount,
    num? agentDiscount,
    List<InvoiceSlice>? invoiceSlices,
  }) {
    setState(() {
      final current = _editingPolicy.salesRules ?? SalesRulesPolicy();
      _editingPolicy = OrganizationPolicyModel(
        id: _editingPolicy.id,
        logistics: _editingPolicy.logistics,
        shipping: _editingPolicy.shipping,
        salesRules: SalesRulesPolicy(
          autoDiscount: autoDiscount ?? current.autoDiscount,
          wholesaleDiscount: wholesaleDiscount ?? current.wholesaleDiscount,
          agentDiscount: agentDiscount ?? current.agentDiscount,
          invoiceSlices: invoiceSlices ?? current.invoiceSlices,
        ),
        appLinks: _editingPolicy.appLinks,
        rewards: _editingPolicy.rewards,
      );
    });
  }

  void _updateAppLinks(List<AppLinkItem> links) {
    setState(() {
      _editingPolicy = OrganizationPolicyModel(
        id: _editingPolicy.id,
        logistics: _editingPolicy.logistics,
        shipping: _editingPolicy.shipping,
        salesRules: _editingPolicy.salesRules,
        rewards: _editingPolicy.rewards,
        appLinks: AppLinksPolicy(links: links),
      );
    });
  }

  void _updateRewards({
    bool? isEnabled,
    num? pointsPerCurrency,
    List<RewardTier>? tiers,
  }) {
    setState(() {
      final current = _editingPolicy.rewards ?? RewardsPolicy();
      _editingPolicy = OrganizationPolicyModel(
        id: _editingPolicy.id,
        logistics: _editingPolicy.logistics,
        shipping: _editingPolicy.shipping,
        salesRules: _editingPolicy.salesRules,
        appLinks: _editingPolicy.appLinks,
        rewards: RewardsPolicy(
          isEnabled: isEnabled ?? current.isEnabled,
          pointsPerCurrency: pointsPerCurrency ?? current.pointsPerCurrency,
          tiers: tiers ?? current.tiers,
        ),
      );
    });
  }

  Widget _buildPolicyCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required void Function(String?) onSaved,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          filled: !enabled,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
        keyboardType: keyboardType,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: LightColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "سياسات المنظمة (Policies)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_isEditing) {
                      _save();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white, size: 18),
                  label: Text(
                    _isEditing ? "حفظ التغييرات" : "تعديل السياسات",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? Colors.green : LightColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        "أنت الآن في وضع التعديل",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() {
                          _isEditing = false;
                          _editingPolicy = widget.policy;
                        }),
                        child: const Text("إلغاء"),
                      ),
                    ],
                  ),
                ),

              // --- Logistics Section ---
              _buildPolicyCard(
                title: "إعدادات اللوجستيات (Logistics)",
                icon: Icons.local_shipping_outlined,
                color: Colors.blue,
                children: [
                  _buildTextField(
                    label: "العملة",
                    initialValue: _editingPolicy.logistics?.currency,
                    onSaved: (val) => _updateLogistics(currency: val),
                    enabled: _isEditing,
                  ),
                  _buildSwitchTile(
                    label: "ضريبة القيمة المضافة",
                    value: _editingPolicy.logistics?.enableVat ?? false,
                    onChanged: (val) => _updateLogistics(enableVat: val),
                    enabled: _isEditing,
                  ),
                  if (_editingPolicy.logistics?.enableVat ?? false)
                    _buildTextField(
                      label: "نسبة الضريبة (%)",
                      initialValue: _editingPolicy.logistics?.taxPercentage
                          ?.toString(),
                      onSaved: (val) => _updateLogistics(
                        taxPercentage: num.tryParse(val ?? ''),
                      ),
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                  _buildSwitchTile(
                    label: "إدارة المخزون",
                    value:
                        _editingPolicy.logistics?.enableStockManagement ??
                        false,
                    onChanged: (val) =>
                        _updateLogistics(enableStockManagement: val),
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "الوحدة الافتراضية",
                    initialValue: _editingPolicy.logistics?.defaultUnit,
                    onSaved: (val) => _updateLogistics(defaultUnit: val),
                    enabled: _isEditing,
                  ),
                  UnitsFieldEditor(
                    allowedUnits: _editingPolicy.logistics?.allowedUnits ?? [],
                    isEditing: _isEditing,
                    onUnitsChanged: (units) =>
                        _updateLogistics(allowedUnits: units),
                    isDark: widget.isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Shipping Section ---
              _buildPolicyCard(
                title: "سياسة الشحن (Shipping)",
                icon: Icons.delivery_dining_outlined,
                color: Colors.green,
                children: [
                  _buildTextField(
                    label: "تكلفة الشحن الافتراضية",
                    initialValue: _editingPolicy.shipping?.defaultFee
                        ?.toString(),
                    onSaved: (val) =>
                        _updateShipping(defaultFee: num.tryParse(val ?? '')),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSwitchTile(
                    label: "تفعيل الشحن المجاني",
                    value:
                        _editingPolicy.shipping?.freeShippingEnabled ?? false,
                    onChanged: (val) =>
                        _updateShipping(freeShippingEnabled: val),
                    enabled: _isEditing,
                  ),
                  GovernorateFeesEditor(
                    feesByGovernorate:
                        _editingPolicy.shipping?.feesByGovernorate ?? {},
                    currency: _editingPolicy.logistics?.currency ?? '',
                    isEditing: _isEditing,
                    onFeesChanged: (fees) =>
                        _updateShipping(feesByGovernorate: fees),
                    isDark: widget.isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Sales Rules Section ---
              _buildPolicyCard(
                title: "قواعد المبيعات (Sales Rules)",
                icon: Icons.sell_outlined,
                color: Colors.orange,
                children: [
                  _buildSwitchTile(
                    label: "الخصم التلقائي",
                    value: _editingPolicy.salesRules?.autoDiscount ?? false,
                    onChanged: (val) => _updateSalesRules(autoDiscount: val),
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "نسبة خصم الجملة (%)",
                    initialValue: _editingPolicy.salesRules?.wholesaleDiscount
                        ?.toString(),
                    onSaved: (val) => _updateSalesRules(
                      wholesaleDiscount: num.tryParse(val ?? ''),
                    ),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    label: "نسبة خصم الوكلاء (%)",
                    initialValue: _editingPolicy.salesRules?.agentDiscount
                        ?.toString(),
                    onSaved: (val) => _updateSalesRules(
                      agentDiscount: num.tryParse(val ?? ''),
                    ),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                  InvoiceSlicesEditor(
                    invoiceSlices:
                        _editingPolicy.salesRules?.invoiceSlices ?? [],
                    isEditing: _isEditing,
                    onSlicesChanged: (slices) =>
                        _updateSalesRules(invoiceSlices: slices),
                    isDark: widget.isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- App Links Section ---
              _buildPolicyCard(
                title: "روابط التطبيق والسياسات (App Links)",
                icon: Icons.link_outlined,
                color: Colors.purple,
                children: [
                  AppLinksEditor(
                    links: _editingPolicy.appLinks?.links ?? [],
                    isEditing: _isEditing,
                    onLinksChanged: (links) => _updateAppLinks(links),
                    isDark: widget.isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Rewards Policy Section ---
              _buildPolicyCard(
                title: "سياسة المكافآت والنقاط (Rewards Policy)",
                icon: Icons.card_giftcard_outlined,
                color: Colors.teal,
                children: [
                  RewardsPolicyEditor(
                    rewards: _editingPolicy.rewards,
                    isEditing: _isEditing,
                    onRewardsChanged: (rewardsVal) => _updateRewards(
                      isEnabled: rewardsVal.isEnabled,
                      pointsPerCurrency: rewardsVal.pointsPerCurrency,
                      tiers: rewardsVal.tiers,
                    ),
                    isDark: widget.isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
  }
}
