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
    WebsiteConfig.typeJockerPost: "Jocker Post",
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
      case WebsiteConfig.typeJockerPost:
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

  Widget _buildJockerPostConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final imageCount = section['config']['imageCount'] ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اختيار صورة واحدة أو صورتين
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "عدد الصور",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text("صورة واحدة")),
                ButtonSegment(value: 2, label: Text("صورتين")),
              ],
              selected: {imageCount},
              onSelectionChanged: widget.isEditing
                  ? (newSelection) {
                      final newSection = Map<String, dynamic>.from(widget.section);
                      if (newSection['config'] == null) newSection['config'] = {};
                      newSection['config']['imageCount'] = newSelection.first;
                      widget.onSectionChanged(newSection);
                    }
                  : null,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Full Screen toggle
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "عرض كامل (Full Screen)",
            style: TextStyle(fontSize: 13),
          ),
          subtitle: const Text(
            "عند التفعيل، الصورة تأخذ كامل عرض الشاشة بدون هوامش",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          value: section['config']['fullScreen'] ?? false,
          onChanged: widget.isEditing
              ? (val) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config']['fullScreen'] = val;
                  if (val) {
                    newSection['config']['margin'] = 0;
                  }
                  widget.onSectionChanged(newSection);
                }
              : null,
        ),

        // Margin reduction (فقط لو fullScreen = false)
        if (!(section['config']['fullScreen'] ?? false)) ...[
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "تقليل المسافة (Margin Reduction)",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text("0")),
                  ButtonSegment(value: 8, label: Text("8")),
                  ButtonSegment(value: 16, label: Text("16")),
                  ButtonSegment(value: 24, label: Text("24")),
                  ButtonSegment(value: 32, label: Text("32")),
                ],
                selected: {section['config']['margin'] ?? 16},
                onSelectionChanged: widget.isEditing
                    ? (newSelection) {
                        final newSection = Map<String, dynamic>.from(widget.section);
                        if (newSection['config'] == null) newSection['config'] = {};
                        newSection['config']['margin'] = newSelection.first;
                        widget.onSectionChanged(newSection);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildIntroSlidesConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};

    const tabs = [
      {'key': WebsiteConfig.keyIntroHybrid, 'label': '🔀 الهجين', 'icon': Icons.join_full},
      {'key': WebsiteConfig.keyIntroBlog,   'label': '🗞️ مدونة',   'icon': Icons.article_outlined},
      {'key': WebsiteConfig.keyIntroStore,  'label': '🛍️ متجر',   'icon': Icons.storefront_outlined},
    ];

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "اعدادات السلايدر لكل وضع",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TabBar(
            isScrollable: true,
            labelColor: widget.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: widget.primaryColor,
            tabs: tabs.map((t) => Tab(
              icon: Icon(t['icon'] as IconData, size: 16),
              text: t['label'] as String,
            )).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 360,
            child: TabBarView(
              children: tabs.map((t) {
                final key = t['key'] as String;
                final subConfig = Map<String, dynamic>.from(
                  section['config'][key] ?? {},
                );

                void updateSub(String field, dynamic val) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final sub = Map<String, dynamic>.from(newSection['config'][key] ?? {});
                  sub[field] = val;
                  newSection['config'][key] = sub;
                  widget.onSectionChanged(newSection);
                }

                final currentStyle = subConfig['displayStyle'] ?? WebsiteConfig.introDisplayAppleFullscreen;
                final bgType = subConfig['backgroundType'] ?? WebsiteConfig.bgTypeSolid;
                final autoPlay = subConfig['autoPlay'] ?? true;
                final duration = ((subConfig['duration'] ?? 4000) as num).toDouble();
                final indicator = subConfig['indicatorType'] ?? WebsiteConfig.indicatorDots;

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // displayStyle
                      DropdownButtonFormField<String>(
                        value: WebsiteConfig.introDisplayStyleLabels.containsKey(currentStyle)
                            ? currentStyle
                            : WebsiteConfig.introDisplayAppleFullscreen,
                        items: WebsiteConfig.introDisplayStyleLabels.entries.map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13))),
                        ).toList(),
                        onChanged: widget.isEditing ? (v) => updateSub('displayStyle', v) : null,
                        decoration: const InputDecoration(
                          labelText: "شكل العرض (Display Style)",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // backgroundType
                      const Text("نوع الخلفية", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: WebsiteConfig.bgTypeSolid, label: Text("لون صريح")),
                          ButtonSegment(value: WebsiteConfig.bgTypeGradient, label: Text("تدرج")),
                        ],
                        selected: {bgType},
                        onSelectionChanged: widget.isEditing
                            ? (v) => updateSub('backgroundType', v.first)
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // customBg
                      TextFormField(
                        initialValue: subConfig['customBg'] ?? '',
                        enabled: widget.isEditing,
                        decoration: const InputDecoration(
                          labelText: "لون/تدرج الخلفية (customBg) — hex أو CSS gradient",
                          hintText: "مثال: #1A2332 أو linear-gradient(135deg,#100C1C,#1A2332)",
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.palette_outlined, size: 18),
                        ),
                        onChanged: (v) => updateSub('customBg', v),
                      ),
                      const SizedBox(height: 12),

                      // textColor
                      TextFormField(
                        initialValue: subConfig['textColor'] ?? '',
                        enabled: widget.isEditing,
                        decoration: const InputDecoration(
                          labelText: "لون النص (textColor) — hex",
                          hintText: "مثال: #FFFFFF",
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.text_fields, size: 18),
                        ),
                        onChanged: (v) => updateSub('textColor', v),
                      ),
                      const SizedBox(height: 12),

                      // autoPlay
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("تدوير تلقائي (Auto Play)", style: TextStyle(fontSize: 13)),
                        value: autoPlay,
                        onChanged: widget.isEditing ? (v) => updateSub('autoPlay', v) : null,
                      ),

                      // duration slider
                      if (autoPlay) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("مدة كل شريحة (ms)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("${duration.round()} ms", style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        Slider(
                          value: duration,
                          min: 2000,
                          max: 8000,
                          divisions: 12,
                          activeColor: widget.primaryColor,
                          onChanged: widget.isEditing ? (v) => updateSub('duration', v.round()) : null,
                        ),
                      ],

                      // indicatorType
                      const Text("مؤشر الشرائح (Indicator)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      SegmentedButton<String>(
                        segments: WebsiteConfig.indicatorTypeLabels.entries.map((e) =>
                          ButtonSegment(value: e.key, label: Text(e.value, style: const TextStyle(fontSize: 11))),
                        ).toList(),
                        selected: {indicator},
                        onSelectionChanged: widget.isEditing
                            ? (v) => updateSub('indicatorType', v.first)
                            : null,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
                    section['type'] == WebsiteConfig.typeMostReadBlogPosts) ...[
                  _buildBlogLimitSelector(section),
                  const SizedBox(height: 12),
                ],
                // 🖼️ Intro Slides — 3 تبويبات منفصلة للهجين والمدونة والمتجر
                if (section['type'] == WebsiteConfig.typeIntroSlides) ...[
                  _buildIntroSlidesConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeCustomBanner) ...[
                  _buildCustomBannerConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeJockerPost) ...[
                  _buildJockerPostConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeOffers ||
                    section['displayMode'] == WebsiteConfig.modeSlider) ...[
                  _buildAutoPlayToggle(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] != WebsiteConfig.typeJockerPost) ...[
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
