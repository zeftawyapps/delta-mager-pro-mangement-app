import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/b2b_home_config.dart';

class B2BSectionCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> section;
  final bool isEditing;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onRemove;
  final void Function(Map<String, dynamic>) onSectionChanged;

  const B2BSectionCard({
    super.key,
    required this.index,
    required this.section,
    required this.isEditing,
    required this.isDark,
    required this.primaryColor,
    required this.onRemove,
    required this.onSectionChanged,
  });

  @override
  State<B2BSectionCard> createState() => _B2BSectionCardState();
}

class _B2BSectionCardState extends State<B2BSectionCard> {
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
  };

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

  Widget _buildTextField(
    String label,
    String? value,
    ValueChanged<String> onChanged,
  ) {
    return TextFormField(
      initialValue: value,
      enabled: widget.isEditing,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: widget.isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isEditing
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
      onChanged: widget.isEditing ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: widget.isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isEditing
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
      options = [2, 3, 4];
    }

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
          onSelectionChanged: widget.isEditing
              ? (newSelection) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config']['crossAxisCount'] = newSelection.first;
                  widget.onSectionChanged(newSection);
                }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;

    return Card(
      key: ValueKey(section['id']),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        leading: Icon(_getIconForType(section['type']), color: widget.primaryColor),
        title: Text(
          section['title'] ?? 'بدون عنوان',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${_getLabelForType(section['type'])} - ${_getLabelForMode(section['displayMode'])}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: widget.isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: section['isActive'] ?? true,
                    onChanged: (val) {
                      final newSection = Map<String, dynamic>.from(section);
                      newSection['isActive'] = val;
                      widget.onSectionChanged(newSection);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onRemove,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  "العنوان",
                  section['title'],
                  (val) {
                    final newSection = Map<String, dynamic>.from(section);
                    newSection['title'] = val;
                    widget.onSectionChanged(newSection);
                  },
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  "نوع المحتوى",
                  section['type'],
                  _typeOptions,
                  (val) {
                    if (val == null) return;
                    final newSection = Map<String, dynamic>.from(section);
                    newSection['type'] = val;
                    if (newSection['config'] == null) {
                      newSection['config'] = <String, dynamic>{};
                    } else {
                      newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    }

                    if (val == B2bHomeConfig.typeJokerProducts ||
                        val == B2bHomeConfig.typeSuperJokerProducts) {
                      newSection['displayMode'] = B2bHomeConfig.modeGrid;
                      newSection['config']['crossAxisCount'] =
                          val == B2bHomeConfig.typeSuperJokerProducts ? 1 : 2;
                    } else if (val == B2bHomeConfig.typeNewProducts ||
                        val == B2bHomeConfig.typeBestSellerProducts ||
                        val == B2bHomeConfig.typeOnSaleProducts) {
                      newSection['config']['crossAxisCount'] = 4;
                    }
                    widget.onSectionChanged(newSection);
                  },
                ),
                const SizedBox(height: 12),
                if (section['type'] == B2bHomeConfig.typeJokerProducts ||
                    section['type'] == B2bHomeConfig.typeSuperJokerProducts ||
                    section['type'] == B2bHomeConfig.typeNewProducts ||
                    section['type'] == B2bHomeConfig.typeBestSellerProducts ||
                    section['type'] == B2bHomeConfig.typeOnSaleProducts) ...[
                  _buildColumnCountSelector(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] != B2bHomeConfig.typeJokerProducts &&
                    section['type'] != B2bHomeConfig.typeSuperJokerProducts)
                  _buildDropdown(
                    "طريقة العرض",
                    section['displayMode'],
                    _modeOptions,
                    (val) {
                      if (val == null) return;
                      final newSection = Map<String, dynamic>.from(section);
                      newSection['displayMode'] = val;
                      widget.onSectionChanged(newSection);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
