import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/website_config.dart';

class WebsiteSectionCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> section;
  final bool isEditing;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onRemove;
  final void Function(Map<String, dynamic>) onSectionChanged;

  const WebsiteSectionCard({
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
  State<WebsiteSectionCard> createState() => _WebsiteSectionCardState();
}

class _WebsiteSectionCardState extends State<WebsiteSectionCard> {
  final Map<String, String> _typeOptions = {
    WebsiteConfig.typeCategories: "الأصناف",
    WebsiteConfig.typeOffers: "العروض",
    WebsiteConfig.typeNewProducts: "المنتجات الجديدة",
    WebsiteConfig.typeBestSellerProducts: "الأكثر مبيعاً",
    WebsiteConfig.typeBlogPosts: "أحدث المقالات",
    WebsiteConfig.typeCustomBanner: "بانر إعلاني مخصص",
    WebsiteConfig.typeIntroSlides: "الشرائح التعريفية (Intro Slides)",
    WebsiteConfig.typeMostReadBlogPosts: "المقالات الأكثر قراءة/رواجاً",
  };

  final Map<String, String> _modeOptions = {
    WebsiteConfig.modeHorizontalList: "قائمة عرضية (Scroll)",
    WebsiteConfig.modeGrid: "شبكة (Grid)",
    WebsiteConfig.modeSlider: "بانر متحرك (Slider)",
  };

  IconData _getIconForType(String type) {
    switch (type) {
      case WebsiteConfig.typeCategories:
        return Icons.category;
      case WebsiteConfig.typeOffers:
        return Icons.local_offer;
      case WebsiteConfig.typeNewProducts:
        return Icons.new_releases;
      case WebsiteConfig.typeBestSellerProducts:
        return Icons.star;
      case WebsiteConfig.typeBlogPosts:
        return Icons.article;
      case WebsiteConfig.typeCustomBanner:
        return Icons.image;
      case WebsiteConfig.typeIntroSlides:
        return Icons.slideshow;
      case WebsiteConfig.typeMostReadBlogPosts:
        return Icons.trending_up;
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
    final options = [2, 3, 4];
    if (section['config'] == null) section['config'] = {};
    final currentCount = section['config']['crossAxisCount'] ?? 4;

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
                  label: Text("$count أعمدة"),
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

  Widget _buildBlogLimitSelector(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final currentLimit = section['config']['limit'] ?? 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "عدد المقالات المعروضة (Limit)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 3, label: Text("3 مقالات")),
            ButtonSegment(value: 6, label: Text("6 مقالات")),
            ButtonSegment(value: 9, label: Text("9 مقالات")),
          ],
          selected: {currentLimit},
          onSelectionChanged: widget.isEditing
              ? (newSelection) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config']['limit'] = newSelection.first;
                  widget.onSectionChanged(newSection);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildAutoPlayToggle(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final autoPlay = section['config']['autoPlay'] ?? true;

    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text("تدوير تلقائي (Auto Play)", style: TextStyle(fontSize: 13)),
      value: autoPlay,
      onChanged: widget.isEditing
          ? (val) {
              final newSection = Map<String, dynamic>.from(widget.section);
              if (newSection['config'] == null) newSection['config'] = {};
              newSection['config']['autoPlay'] = val;
              widget.onSectionChanged(newSection);
            }
          : null,
    );
  }

  Widget _buildCustomBannerConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    
    return Column(
      children: [
        _buildTextField(
          "رابط الصورة (Image URL)",
          section['config']['imageUrl'],
          (val) {
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['imageUrl'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          "رابط التوجيه (Link URL)",
          section['config']['linkUrl'],
          (val) {
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['linkUrl'] = val;
            widget.onSectionChanged(newSection);
          },
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

                    if (val == WebsiteConfig.typeNewProducts ||
                        val == WebsiteConfig.typeBestSellerProducts) {
                      newSection['config']['crossAxisCount'] = 4;
                    } else if (val == WebsiteConfig.typeBlogPosts ||
                        val == WebsiteConfig.typeMostReadBlogPosts ||
                        val == WebsiteConfig.typeIntroSlides) {
                      newSection['config']['limit'] = 3;
                    }
                    widget.onSectionChanged(newSection);
                  },
                ),
                const SizedBox(height: 12),
                if (section['type'] == WebsiteConfig.typeNewProducts ||
                    section['type'] == WebsiteConfig.typeBestSellerProducts) ...[
                  _buildColumnCountSelector(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeBlogPosts ||
                    section['type'] == WebsiteConfig.typeMostReadBlogPosts ||
                    section['type'] == WebsiteConfig.typeIntroSlides) ...[
                  _buildBlogLimitSelector(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeCustomBanner) ...[
                  _buildCustomBannerConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeOffers ||
                    section['type'] == WebsiteConfig.typeIntroSlides ||
                    section['displayMode'] == WebsiteConfig.modeSlider) ...[
                  _buildAutoPlayToggle(section),
                  const SizedBox(height: 12),
                ],
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
