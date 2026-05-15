import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';

// 🟢 Helper class to manage grid state dynamically
class FeatureGridState {
  final TextEditingController aspectRatio;
  final TextEditingController spacing;
  final TextEditingController countSmall;
  final TextEditingController countMedium;
  final TextEditingController countLarge;
  bool showAddInGrid;

  FeatureGridState({
    required String? initialAspectRatio,
    required String? initialSpacing,
    required String? initialCountSmall,
    required String? initialCountMedium,
    required String? initialCountLarge,
    required this.showAddInGrid,
  }) : aspectRatio = TextEditingController(text: initialAspectRatio ?? "1.0"),
       spacing = TextEditingController(text: initialSpacing ?? "16.0"),
       countSmall = TextEditingController(text: initialCountSmall ?? "2"),
       countMedium = TextEditingController(text: initialCountMedium ?? "3"),
       countLarge = TextEditingController(text: initialCountLarge ?? "4");

  void dispose() {
    aspectRatio.dispose();
    spacing.dispose();
    countSmall.dispose();
    countMedium.dispose();
    countLarge.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      "childAspectRatio": double.tryParse(aspectRatio.text) ?? 1.0,
      "crossAxisSpacing": double.tryParse(spacing.text) ?? 16.0,
      "crossAxisCountSmall": int.tryParse(countSmall.text) ?? 2,
      "crossAxisCountMedium": int.tryParse(countMedium.text) ?? 3,
      "crossAxisCountLarge": int.tryParse(countLarge.text) ?? 4,
      "showAddInGrid": showAddInGrid,
    };
  }
}

class FeaturesSectionTab extends StatefulWidget {
  final OrganizationConfig config;
  final String organizationId;
  final bool isDark;

  const FeaturesSectionTab({
    super.key,
    required this.config,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<FeaturesSectionTab> createState() => _FeaturesSectionTabState();
}

class _FeaturesSectionTabState extends State<FeaturesSectionTab> {
  bool _isEditingFeature = false;
  final Map<String, FeatureGridState> _gridStates = {};

  final List<Map<String, String>> _sectionsDefinition = [
    {'key': 'categories', 'label': 'شبكة الأصناف (Categories)'},
    {'key': 'products', 'label': 'شبكة المنتجات (Products)'},
    {'key': 'users', 'label': 'شبكة المستخدمين (Users)'},
    {'key': 'offers', 'label': 'شبكة العروض (Offers)'},
    {'key': 'orderPaths', 'label': 'شبكة مسارات الطلبات (Order Paths)'},
  ];

  @override
  void initState() {
    super.initState();
    final featureConfig = widget.config.feature;

    for (var section in _sectionsDefinition) {
      final key = section['key']!;
      final config = featureConfig?.configs[key];

      _gridStates[key] = FeatureGridState(
        initialAspectRatio: config?.childAspectRatio?.toString(),
        initialSpacing: config?.crossAxisSpacing?.toString(),
        initialCountSmall: config?.crossAxisCountSmall?.toString(),
        initialCountMedium: config?.crossAxisCountMedium?.toString(),
        initialCountLarge: config?.crossAxisCountLarge?.toString(),
        showAddInGrid: config?.showAddInGrid ?? false,
      );
    }
  }

  @override
  void dispose() {
    for (var state in _gridStates.values) {
      state.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: "المزايا الإضافية (Features)",
            icon: Icons.star_outline,
            isEditing: _isEditingFeature,
            onEditPressed: () => setState(() => _isEditingFeature = true),
            onSavePressed: () async {
              final currentFeatures = Map<String, dynamic>.from(
                widget.config.features ?? {},
              );
              final Map<String, dynamic> featureMap = {};

              for (var entry in _gridStates.entries) {
                featureMap[entry.key] = entry.value.toJson();
              }

              currentFeatures['feature'] = featureMap;

              context.read<AdminOrganizationConfigBloc>().updateConfigSection(
                organizationId: widget.organizationId,
                section: "features",
                sectionData: currentFeatures,
              );
              setState(() => _isEditingFeature = false);
            },
            children: [
              for (int i = 0; i < _sectionsDefinition.length; i++) ...[
                _buildFeatureSection(
                  _sectionsDefinition[i]['label']!,
                  _gridStates[_sectionsDefinition[i]['key']]!,
                ),
                if (i < _sectionsDefinition.length - 1) const Divider(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(String title, FeatureGridState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        _buildEditableTile(
          "نسبة العرض للارتفاع",
          state.aspectRatio,
          Icons.aspect_ratio,
          _isEditingFeature,
          defaultValue: "1.0",
        ),
        _buildEditableTile(
          "المسافة العرضية (Spacing)",
          state.spacing,
          Icons.space_bar,
          _isEditingFeature,
          defaultValue: "16.0",
        ),
        _buildEditableTile(
          "عدد العمدة (شاشة صغيرة)",
          state.countSmall,
          Icons.grid_view,
          _isEditingFeature,
          defaultValue: "2",
        ),
        _buildEditableTile(
          "عدد العمدة (شاشة متوسطة)",
          state.countMedium,
          Icons.grid_view,
          _isEditingFeature,
          defaultValue: "3",
        ),
        _buildEditableTile(
          "عدد العمدة (شاشة كبيرة)",
          state.countLarge,
          Icons.grid_view,
          _isEditingFeature,
          defaultValue: "4",
        ),
        _buildToggleTile(
          "إظهار زر الإضافة داخل الشبكة",
          state.showAddInGrid,
          _isEditingFeature,
          (val) => setState(() => state.showAddInGrid = val),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEditPressed,
    required VoidCallback onSavePressed,
    required List<Widget> children,
  }) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: Icon(icon, color: primaryColor),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            trailing: TextButton.icon(
              icon: Icon(
                isEditing ? Icons.save : Icons.edit,
                size: 18,
                color: isEditing ? Colors.green : primaryColor,
              ),
              label: Text(
                isEditing ? "حفظ" : "تعديل",
                style: TextStyle(
                  color: isEditing ? Colors.green : primaryColor,
                ),
              ),
              onPressed: isEditing ? onSavePressed : onEditPressed,
            ),
          ),
          const Divider(height: 1),
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text(
              "التفاصيل",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTile(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isEditing, {
    String? defaultValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                hintText: defaultValue != null
                    ? "الافتراضي: $defaultValue"
                    : null,
                prefixIcon: Icon(icon, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            )
          : ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              subtitle: Text(
                controller.text.isEmpty
                    ? (defaultValue != null
                          ? "$defaultValue (افتراضي)"
                          : "لا يوجد")
                    : controller.text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
    );
  }

  Widget _buildToggleTile(
    String label,
    bool value,
    bool isEditing,
    ValueChanged<bool>? onChanged,
  ) {
    return SwitchListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: isEditing ? onChanged : null,
    );
  }
}
