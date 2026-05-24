import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/b2b_home_config.dart';

class B2BHomeConfigTab extends StatefulWidget {
  final OrganizationConfig config;
  final String organizationId;
  final bool isDark;

  const B2BHomeConfigTab({
    super.key,
    required this.config,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<B2BHomeConfigTab> createState() => _B2BHomeConfigTabState();
}

class _B2BHomeConfigTabState extends State<B2BHomeConfigTab> {
  List<Map<String, dynamic>> _sections = [];
  Map<String, dynamic> _orderSettings = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Load workflows for the organization
    context.read<WorkflowManagementBloc>().loadSpecificConfig(
      widget.organizationId,
    );
  }

  void _loadData() {
    final layout = widget.config.b2bHomeLayout;
    if (layout != null && layout[B2bHomeConfig.keySections] != null) {
      setState(() {
        _sections = List<Map<String, dynamic>>.from(
          (layout[B2bHomeConfig.keySections] as List).map((e) {
            final map = Map<String, dynamic>.from(e);
            // التأكد من أن الـ config ليس null
            map['config'] = map['config'] != null
                ? Map<String, dynamic>.from(map['config'])
                : {};
            return map;
          }),
        );
      });
    } else {
      setState(() {
        _sections = List<Map<String, dynamic>>.from(
          B2bHomeConfig.defaultValues[B2bHomeConfig.keySections].map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
      });
    }

    final orderSettings =
        widget.config.b2bHomeLayout?[B2bHomeConfig.keyOrderSettings];
    if (orderSettings != null) {
      setState(() {
        _orderSettings = Map<String, dynamic>.from(orderSettings);
      });
    } else {
      setState(() {
        _orderSettings = Map<String, dynamic>.from(
          B2bHomeConfig.defaultValues[B2bHomeConfig.keyOrderSettings],
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant B2BHomeConfigTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config && !_isEditing) {
      _loadData();
    }
  }

  Future<void> _saveConfig() async {
    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "b2bHomeLayout",
      sectionData: {
        B2bHomeConfig.keySections: _sections,
        B2bHomeConfig.keyOrderSettings: _orderSettings,
      },
    );
    setState(() => _isEditing = false);
  }

  void _addSection() {
    setState(() {
      _sections.add({
        "id": "sec_${DateTime.now().millisecondsSinceEpoch}",
        "type": B2bHomeConfig.typeNewProducts,
        "displayMode": B2bHomeConfig.modeGrid,
        "title": "قسم جديد",
        "isActive": true,
        "config": {},
      });
    });
  }

  // 🔄 الربط التلقائي بين المزايا المفعلة وتخطيط الصفحة
  void _syncWithProductConfig() {
    final productInput = widget.config.productInput ?? {};
    final existingTypes = _sections.map((s) => s['type']).toSet();

    final featureMapping = {
      "showIsNew": {
        "type": B2bHomeConfig.typeNewProducts,
        "title": "جديدنا",
        "mode": B2bHomeConfig.modeGrid,
      },
      "showIsBestSeller": {
        "type": B2bHomeConfig.typeBestSellerProducts,
        "title": "الأكثر مبيعاً",
        "mode": B2bHomeConfig.modeHorizontalList,
      },
      "showIsJoker": {
        "type": B2bHomeConfig.typeJokerProducts,
        "title": "منتجات الجوكر",
        "mode": B2bHomeConfig.modeGrid,
      },
      "showIsSuperJoker": {
        "type": B2bHomeConfig.typeSuperJokerProducts,
        "title": "سوبر جوكر",
        "mode": B2bHomeConfig.modeSlider,
      },
    };

    bool added = false;
    featureMapping.forEach((key, data) {
      if (productInput[key] == true && !existingTypes.contains(data['type'])) {
        _sections.add({
          "id": "sec_${data['type']}_${DateTime.now().millisecondsSinceEpoch}",
          "type": data['type'],
          "displayMode": data['mode'] as String,
          "title": data['title'] as String,
          "isActive": true,
          "config": {},
        });
        added = true;
      }
    });

    if (added) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم إضافة الأقسام المفقودة بناءً على إعدادات المزايا"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("جميع المزايا المفعلة مضافة بالفعل في التخطيط"),
        ),
      );
    }
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        onReorder: (oldIndex, newIndex) {
          if (!_isEditing) return;
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _sections.removeAt(oldIndex);
            _sections.insert(newIndex, item);
          });
        },
        header: Column(
          children: [
            _buildOrderSettingsCard(primaryColor),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "تخطيط الصفحة الرئيسية (B2B)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    if (_isEditing) ...[
                      IconButton(
                        icon: const Icon(Icons.sync_alt, color: Colors.orange),
                        onPressed: _syncWithProductConfig,
                        tooltip: "إضافة السكاشن المفقودة (مزامنة مع المزايا)",
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: _addSection,
                        tooltip: "إضافة قسم",
                      ),
                    ],
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isEditing
                          ? _saveConfig
                          : () => setState(() => _isEditing = true),
                      icon: Icon(_isEditing ? Icons.save : Icons.edit),
                      label: Text(
                        _isEditing ? "حفظ التغييرات" : "تعديل الإعدادات",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing
                            ? Colors.green
                            : primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  "قم بسحب العناصر لإعادة ترتيبها في الصفحة الرئيسية",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return _buildSectionCard(index, section, primaryColor);
        },
      ),
    );
  }

  Widget _buildOrderSettingsCard(Color primaryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      elevation: 0,
      color: primaryColor.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings_applications, color: primaryColor),
                    const SizedBox(width: 12),
                    const Text(
                      "إعدادات الطلبات الافتراضية",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_isEditing)
                  const Chip(
                    label: Text(
                      "وضع التعديل",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              "نمط الطلب (Order Mode)",
              _orderSettings[B2bHomeConfig.keyOrderMode] ?? "B2B",
              {
                "B2B": "B2B (Business to Business)",
                "C2B": "C2B (Customer to Business)",
              },
              (val) => setState(
                () => _orderSettings[B2bHomeConfig.keyOrderMode] = val,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<
              WorkflowManagementBloc,
              FeaturDataSourceState<WorkflowConfigModel>
            >(
              builder: (context, state) {
                final workflows = state.listState.maybeWhen(
                  success: (data) => data ?? [],
                  orElse: () => [],
                );

                final Map<String, String> workflowOptions = {
                  "": "بدون سير عمل (Default)",
                };
                for (var wf in workflows) {
                  workflowOptions[wf.workflowSlug] = wf.workflowSlug;
                }

                return _buildDropdown(
                  "سير العمل (Workflow)",
                  _orderSettings[B2bHomeConfig.keyWorkflowSlug] ?? "",
                  workflowOptions,
                  (val) => setState(
                    () => _orderSettings[B2bHomeConfig.keyWorkflowSlug] = val,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              "طريقة حساب السعر (Calculation Mode)",
              (_orderSettings[B2bHomeConfig.keyCalculationMode] ?? 2)
                  .toString(),
              {
                "0": "يدوي (Manual) - قبول السعر كما هو",
                "1": "تصحيح (Auto-correction) - تعديل آلي في حال الخطأ",
                "2": "تحقق صارم (Strict Validation) - رفض في حال الخطأ",
              },
              (val) => setState(
                () => _orderSettings[B2bHomeConfig.keyCalculationMode] =
                    int.tryParse(val!) ?? 2,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                "السماح بسير العمل الافتراضي (Allow Default Workflow)",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                "تفعيل هذا الخيار يسمح للنظام باستخدام سير العمل التلقائي في حال عدم توفر المخصص",
                style: TextStyle(fontSize: 12),
              ),
              value:
                  _orderSettings[B2bHomeConfig.keyAllowDefaultWorkflow] ?? true,
              onChanged: _isEditing
                  ? (val) => setState(
                      () =>
                          _orderSettings[B2bHomeConfig
                                  .keyAllowDefaultWorkflow] =
                              val,
                    )
                  : null,
              activeColor: primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    int index,
    Map<String, dynamic> section,
    Color primaryColor,
  ) {
    return Card(
      key: ValueKey(section['id']),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        leading: Icon(_getIconForType(section['type']), color: primaryColor),
        title: Text(
          section['title'] ?? 'بدون عنوان',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${_getLabelForType(section['type'])} - ${_getLabelForMode(section['displayMode'])}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: _isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: section['isActive'] ?? true,
                    onChanged: (val) =>
                        setState(() => section['isActive'] = val),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeSection(index),
                  ),
                  const Icon(Icons.drag_handle),
                ],
              )
            : Icon(
                Icons.circle,
                size: 12,
                color: (section['isActive'] ?? true)
                    ? Colors.green
                    : Colors.grey,
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(
                  "العنوان",
                  section['title'],
                  (val) => section['title'] = val,
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  "نوع المحتوى",
                  section['type'],
                  _typeOptions,
                  (val) => setState(() {
                    section['type'] = val;
                    if (val == B2bHomeConfig.typeJokerProducts ||
                        val == B2bHomeConfig.typeSuperJokerProducts) {
                      section['displayMode'] = B2bHomeConfig.modeGrid;
                      section['config']['crossAxisCount'] =
                          val == B2bHomeConfig.typeSuperJokerProducts ? 1 : 2;
                    } else if (val == B2bHomeConfig.typeNewProducts ||
                        val == B2bHomeConfig.typeBestSellerProducts ||
                        val == B2bHomeConfig.typeOnSaleProducts) {
                      section['config']['crossAxisCount'] = 4;
                    }
                  }),
                ),
                const SizedBox(height: 12),
                if (section['type'] == B2bHomeConfig.typeJokerProducts ||
                    section['type'] == B2bHomeConfig.typeSuperJokerProducts ||
                    section['type'] == B2bHomeConfig.typeNewProducts ||
                    section['type'] == B2bHomeConfig.typeBestSellerProducts ||
                    section['type'] == B2bHomeConfig.typeOnSaleProducts)
                  _buildColumnCountSelector(section),

                if (section['type'] != B2bHomeConfig.typeJokerProducts &&
                    section['type'] != B2bHomeConfig.typeSuperJokerProducts)
                  _buildDropdown(
                    "طريقة العرض",
                    section['displayMode'],
                    _modeOptions,
                    (val) => setState(() => section['displayMode'] = val),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnCountSelector(Map<String, dynamic> section) {
    final type = section['type'];
    final isJoker = type == B2bHomeConfig.typeJokerProducts;
    final isSuper = type == B2bHomeConfig.typeSuperJokerProducts;

    List<int> options;
    if (isSuper) {
      options = [1, 2];
    } else if (isJoker) {
      options = [2, 3];
    } else {
      options = [2, 3, 4]; // جديدنا، الأكثر مبيعاً، إلخ.
    }

    // تأمين الوصول للـ config
    if (section['config'] == null) section['config'] = {};
    final currentCount = section['config']['crossAxisCount'] ?? options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "عدد الأعمدة (Grid Columns)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: options
              .map(
                (count) => ButtonSegment(
                  value: count,
                  label: Text("$count ${count == 1 ? 'عمود' : 'أعمدة'}"),
                ),
              )
              .toList(),
          selected: {currentCount},
          onSelectionChanged: _isEditing
              ? (newSelection) {
                  setState(() {
                    section['config']['crossAxisCount'] = newSelection.first;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String? value,
    ValueChanged<String> onChanged,
  ) {
    return TextFormField(
      initialValue: value,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _isEditing
                ? AppColors.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: options.containsKey(value) ? value : options.keys.first,
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: _isEditing ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _isEditing
                ? AppColors.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        isDense: true,
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case B2bHomeConfig.typeCategories:
        return Icons.category;
      case B2bHomeConfig.typeOffers:
        return Icons.local_offer;
      case B2bHomeConfig.typeNewProducts:
        return Icons.new_releases;
      case B2bHomeConfig.typeCustomBanner:
        return Icons.image;
      default:
        return Icons.grid_view;
    }
  }

  String _getLabelForType(String type) => _typeOptions[type] ?? type;
  String _getLabelForMode(String mode) => _modeOptions[mode] ?? mode;

  final Map<String, String> _typeOptions = {
    B2bHomeConfig.typeCategories: "الأصناف",
    B2bHomeConfig.typeOffers: "العروض",
    B2bHomeConfig.typeNewProducts: "المنتجات الجديدة",
    B2bHomeConfig.typeBestSellerProducts: "الأكثر مبيعاً",
    B2bHomeConfig.typeJokerProducts: "منتجات الجوكر",
    B2bHomeConfig.typeSuperJokerProducts: "سوبر جوكر",
    B2bHomeConfig.typeOnSaleProducts: "تخفيضات",
    B2bHomeConfig.typeCustomBanner: "بانر إعلاني مخصص",
  };

  final Map<String, String> _modeOptions = {
    B2bHomeConfig.modeHorizontalList: "قائمة عرضية (Scroll)",
    B2bHomeConfig.modeGrid: "شبكة (Grid)",
    B2bHomeConfig.modeSlider: "بانر متحرك (Slider)",
    B2bHomeConfig.modeZoomSlider: "سلايدر تكبير وتصغير (Zoom Slider)",
  };
}
