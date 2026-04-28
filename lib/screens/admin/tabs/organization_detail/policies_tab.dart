import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_policy_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_isEditing) {
            _save();
          } else {
            setState(() => _isEditing = true);
          }
        },
        backgroundColor: _isEditing ? Colors.green : LightColors.primary,
        icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
        label: Text(_isEditing ? "حفظ التغييرات" : "تعديل السياسات",
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            fontWeight: FontWeight.bold, color: Colors.orange),
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
                      initialValue:
                          _editingPolicy.logistics?.taxPercentage?.toString(),
                      onSaved: (val) =>
                          _updateLogistics(taxPercentage: num.tryParse(val ?? '')),
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                  _buildSwitchTile(
                    label: "إدارة المخزون",
                    value: _editingPolicy.logistics?.enableStockManagement ?? false,
                    onChanged: (val) => _updateLogistics(enableStockManagement: val),
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "الوحدة الافتراضية",
                    initialValue: _editingPolicy.logistics?.defaultUnit,
                    onSaved: (val) => _updateLogistics(defaultUnit: val),
                    enabled: _isEditing,
                  ),
                  _buildUnitsField(),
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
                    initialValue: _editingPolicy.shipping?.defaultFee?.toString(),
                    onSaved: (val) =>
                        _updateShipping(defaultFee: num.tryParse(val ?? '')),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSwitchTile(
                    label: "تفعيل الشحن المجاني",
                    value: _editingPolicy.shipping?.freeShippingEnabled ?? false,
                    onChanged: (val) => _updateShipping(freeShippingEnabled: val),
                    enabled: _isEditing,
                  ),
                  _buildGovernorateFeesField(),
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
                    initialValue:
                        _editingPolicy.salesRules?.wholesaleDiscount?.toString(),
                    onSaved: (val) =>
                        _updateSalesRules(wholesaleDiscount: num.tryParse(val ?? '')),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    label: "نسبة خصم الوكلاء (%)",
                    initialValue:
                        _editingPolicy.salesRules?.agentDiscount?.toString(),
                    onSaved: (val) =>
                        _updateSalesRules(agentDiscount: num.tryParse(val ?? '')),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInvoiceSlicesField(),
                ],
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
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
        shipping: ShippingPolicy(
          defaultFee: defaultFee ?? current.defaultFee,
          freeShippingEnabled: freeShippingEnabled ?? current.freeShippingEnabled,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildUnitsField() {
    final units = _editingPolicy.logistics?.allowedUnits ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("الوحدات المسموح بها", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ...units.map((u) => Chip(
                  label: Text(u, style: const TextStyle(fontSize: 11)),
                  onDeleted: _isEditing ? () {
                    final newUnits = List<String>.from(units)..remove(u);
                    _updateLogistics(allowedUnits: newUnits);
                  } : null,
                )),
            if (_isEditing)
              ActionChip(
                label: const Icon(Icons.add, size: 16),
                onPressed: () => _showAddUnitDialog(),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showAddUnitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة وحدة"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "اسم الوحدة")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final units = List<String>.from(_editingPolicy.logistics?.allowedUnits ?? []);
                units.add(controller.text);
                _updateLogistics(allowedUnits: units);
              }
              Navigator.pop(context);
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernorateFeesField() {
    final fees = _editingPolicy.shipping?.feesByGovernorate ?? {};
    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, locationsState) {
        final governorates = locationsState.governoratesState.maybeWhen(
          success: (data) => data ?? [],
          orElse: () => [],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("أسعار الشحن للمحافظات", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ...fees.entries.map((e) {
              // البحث عن اسم المحافظة بناءً على الكود المخزن في المفتاح
              final g = governorates.where((item) => item.code == e.key || item.name.ar == e.key).firstOrNull;
              final displayName = g?.name.ar ?? e.key;

              return ListTile(
                dense: true,
                title: Text(displayName, style: const TextStyle(fontSize: 13)),
                subtitle: Text("${e.value} ${_editingPolicy.logistics?.currency ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () {
                          final newFees = Map<String, num>.from(fees)..remove(e.key);
                          _updateShipping(feesByGovernorate: newFees);
                        },
                      )
                    : null,
              );
            }),
            if (_isEditing)
              TextButton.icon(
                onPressed: () => _showAddFeeDialog(),
                icon: const Icon(Icons.add),
                label: const Text("إضافة سعر لمحافظة"),
              ),
          ],
        );
      },
    );
  }

  void _showAddFeeDialog() {
    String? selectedGovCode;
    final feeController = TextEditingController();

    // التأكد من تحميل المحافظات
    context.read<LocationsBloc>().loadGovernorates();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("إضافة سعر شحن لمحافظة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<LocationsBloc, LocationsState>(
                builder: (context, state) {
                  return state.governoratesState.when(
                    init: () => const Text("جاري التهيئة..."),
                    loading: () => const CircularProgressIndicator(),
                    success: (governorates) {
                      final validGovernorates = (governorates ?? []).where((g) => g.code != null && g.code!.isNotEmpty).toList();
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "اختر المحافظة"),
                        items: validGovernorates.map((g) => DropdownMenuItem(
                          value: g.code, 
                          child: Text("${g.name.ar} (${g.code})"),
                        )).toList(),
                        onChanged: (val) => setDialogState(() => selectedGovCode = val),
                      );
                    },
                    failure: (error, reload) => TextButton(
                      onPressed: reload,
                      child: const Text("خطأ في التحميل، اضغط للإعادة"),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(labelText: "قيمة الشحن"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
            TextButton(
              onPressed: () {
                if (selectedGovCode != null && feeController.text.isNotEmpty) {
                  final fees = Map<String, num>.from(_editingPolicy.shipping?.feesByGovernorate ?? {});
                  fees[selectedGovCode!] = num.tryParse(feeController.text) ?? 0;
                  _updateShipping(feesByGovernorate: fees);
                  Navigator.pop(context);
                }
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSlicesField() {
    final slices = _editingPolicy.salesRules?.invoiceSlices ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("شرائح الفواتير والخصومات", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        ...slices.map((s) => ListTile(
              dense: true,
              title: Text("أكثر من ${s.minAmount}", style: const TextStyle(fontSize: 13)),
              subtitle: Text("خصم ${s.discountAmount}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              trailing: _isEditing
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () {
                        final newSlices = List<InvoiceSlice>.from(slices)..remove(s);
                        _updateSalesRules(invoiceSlices: newSlices);
                      },
                    )
                  : null,
            )),
        if (_isEditing)
          TextButton.icon(
            onPressed: () => _showAddSliceDialog(),
            icon: const Icon(Icons.add),
            label: const Text("إضافة شريحة خصم"),
          ),
      ],
    );
  }

  void _showAddSliceDialog() {
    final minController = TextEditingController();
    final discController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة شريحة فواتير"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: minController, decoration: const InputDecoration(hintText: "أكثر من مبلغ..."), keyboardType: TextInputType.number),
            TextField(controller: discController, decoration: const InputDecoration(hintText: "قيمة الخصم"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              if (minController.text.isNotEmpty && discController.text.isNotEmpty) {
                final slices = List<InvoiceSlice>.from(_editingPolicy.salesRules?.invoiceSlices ?? []);
                slices.add(InvoiceSlice(
                  minAmount: num.tryParse(minController.text),
                  discountAmount: num.tryParse(discController.text),
                ));
                _updateSalesRules(invoiceSlices: slices);
              }
              Navigator.pop(context);
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }
}
