import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/providers/sidebar_provider.dart';
import 'package:provider/provider.dart';

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
  })  : aspectRatio = TextEditingController(text: initialAspectRatio ?? "1.0"),
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

class ConfigSectionTab extends StatefulWidget {
  final OrganizationConfig config;
  final String organizationId;
  final bool isDark;

  const ConfigSectionTab({
    super.key,
    required this.config,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<ConfigSectionTab> createState() => _ConfigSectionTabState();
}

class _ConfigSectionTabState extends State<ConfigSectionTab> {
  bool _isEditingVisual = false;
  bool _isEditingThemes = false;
  bool _isEditingLayout = false;
  bool _isEditingFeature = false;

  late TextEditingController _fontFamilyController;
  late TextEditingController _logoUrlController;
  late TextEditingController _appTitleController;
  late TextEditingController _jsonImportController;
  
  // 🟢 Dynamic management of feature sections
  final Map<String, FeatureGridState> _gridStates = {};
  
  final List<Map<String, String>> _sectionsDefinition = [
    {'key': 'categories', 'label': 'شبكة الأصناف (Categories)'},
    {'key': 'products', 'label': 'شبكة المنتجات (Products)'},
    {'key': 'users', 'label': 'شبكة المستخدمين (Users)'},
    {'key': 'offers', 'label': 'شبكة العروض (Offers)'},
  ];

  bool _showCartLocal = false;
  bool _showSearchLocal = false;

  Map<String, dynamic>? _lightThemeMap;
  Map<String, dynamic>? _darkThemeMap;
  Map<String, dynamic>? _websiteThemeMap;
  Map<String, dynamic>? _fixedThemeMap;

  static const Map<String, String> _colorLabels = {
    "primary": "اللون الأساسي",
    "secondary": "اللون الثانوي",
    "accent": "اللون التمييزي",
    "background": "لون الخلفية",
    "surface": "لون الأسطح (البطاقات)",
    "surfaceVariant": "لون الأسطح البديل (خلفيات الشبكة)",
    "textPrimary": "النص الأساسي",
    "textSecondary": "النص الفرعي",
    "textHint": "نص التلميح (Hint)",
    "textOnPrimary": "النص فوق اللون الأساسي",
    "buttonPrimary": "اللون الأساسي للأزرار",
    "buttonSecondary": "اللون الثانوي للأزرار",
    "buttonText": "لون نص الأزرار",
    "divider": "لون الفواصل",
    "icon": "لون الأيقونات",
    "inputBackground": "خلفية حقول الإدخال",
    "inputBorder": "حدود حقول الإدخال",
    "inputFocus": "لون التركيز في الحقول",
    "herbGreen": "لون سير العمل (أخضر عشبي)",
    "success": "لون النجاح",
    "error": "لون الخطأ",
    "warning": "لون التحذير",
    "info": "لون المعلومات"
  };

  @override
  void initState() {
    super.initState();
    _fontFamilyController = TextEditingController(
      text: widget.config.visual?.fontFamily ?? "",
    );
    _logoUrlController = TextEditingController(
      text: widget.config.visual?.logoUrl ?? "",
    );
    _appTitleController = TextEditingController(
      text: widget.config.layout?.appTitle ?? "",
    );
    _jsonImportController = TextEditingController();
    
    final featureConfig = widget.config.feature;
    
    // Initialize grid states dynamically
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

    _showCartLocal = widget.config.layout?.showCart ?? false;
    _showSearchLocal = widget.config.layout?.showSearch ?? false;

    if (widget.config.themes != null) {
      _lightThemeMap = widget.config.themes!.light?.toJson();
      _darkThemeMap = widget.config.themes!.dark?.toJson();
      _websiteThemeMap = widget.config.themes!.website?.toJson();
      try {
        final Map<String, dynamic> rawThemes = widget.config.themes!.toJson();
        _fixedThemeMap = rawThemes['fixed'] as Map<String, dynamic>?;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _fontFamilyController.dispose();
    _logoUrlController.dispose();
    _appTitleController.dispose();
    _jsonImportController.dispose();
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
          _buildJsonImportCard(),
          const SizedBox(height: 16),
          _buildFormCard(
            title: "الإعدادات المرئية (Visual)",
            icon: Icons.palette_outlined,
            isEditing: _isEditingVisual,
            onEditPressed: () => setState(() => _isEditingVisual = true),
            onSavePressed: () async {
              final payload = {
                "fontFamily": _fontFamilyController.text,
                "logoUrl": _logoUrlController.text,
              };
              context.read<AdminOrganizationConfigBloc>().updateConfigSection(
                organizationId: widget.organizationId,
                section: "visual",
                sectionData: payload,
              );
              setState(() => _isEditingVisual = false);
            },
            children: [
              _buildEditableTile(
                "الخط الفرعي",
                _fontFamilyController,
                Icons.font_download_outlined,
                _isEditingVisual,
              ),
              _buildEditableTile(
                "رابط الشعار URL",
                _logoUrlController,
                Icons.link,
                _isEditingVisual,
              ),
            ],
          ),

          const SizedBox(height: 16),
          if (widget.config.themes != null)
            _buildFormCard(
              title: "الثيمات والألوان (Themes)",
              icon: Icons.color_lens_outlined,
              isEditing: _isEditingThemes,
              onEditPressed: () => setState(() => _isEditingThemes = true),
              onSavePressed: () async {
                final payload = {
                  "light": _lightThemeMap,
                  "dark": _darkThemeMap,
                  "website": _websiteThemeMap,
                  "fixed": _fixedThemeMap,
                };
                context.read<AdminOrganizationConfigBloc>().updateConfigSection(
                  organizationId: widget.organizationId,
                  section: "themes",
                  sectionData: payload,
                );
                setState(() => _isEditingThemes = false);
              },
              children: [
                if (_lightThemeMap != null)
                  _buildThemeSubSection(
                    "الثيم المضيء (Light)",
                    _lightThemeMap!,
                    _isEditingThemes,
                  ),
                if (_darkThemeMap != null)
                  _buildThemeSubSection(
                    "الثيم الداكن (Dark)",
                    _darkThemeMap!,
                    _isEditingThemes,
                  ),
                if (_websiteThemeMap != null)
                  _buildThemeSubSection(
                    "ثيم الموقع (Website)",
                    _websiteThemeMap!,
                    _isEditingThemes,
                  ),
                if (_fixedThemeMap != null)
                  _buildThemeSubSection(
                    "الثيم الثابت (Fixed)",
                    _fixedThemeMap!,
                    _isEditingThemes,
                  ),
              ],
            ),

          const SizedBox(height: 16),
          _buildFormCard(
            title: "تخطيط الصفحة (Layout)",
            icon: Icons.layers_outlined,
            isEditing: _isEditingLayout,
            onEditPressed: () => setState(() => _isEditingLayout = true),
            onSavePressed: () async {
              final payload = {
                "appTitle": _appTitleController.text,
                "showCart": _showCartLocal,
                "showSearch": _showSearchLocal,
              };
              context.read<AdminOrganizationConfigBloc>().updateConfigSection(
                organizationId: widget.organizationId,
                section: "layout",
                sectionData: payload,
              );
              setState(() => _isEditingLayout = false);
            },
            children: [
              _buildEditableTile(
                "عنوان التطبيق",
                _appTitleController,
                Icons.title,
                _isEditingLayout,
              ),
              _buildToggleTile(
                "إظهار سلة المشتريات",
                _showCartLocal,
                _isEditingLayout,
                (val) => setState(() => _showCartLocal = val),
              ),
              _buildToggleTile(
                "إظهار محرك البحث",
                _showSearchLocal,
                _isEditingLayout,
                (val) => setState(() => _showSearchLocal = val),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildFormCard(
            title: "المزايا الإضافية (Features)",
            icon: Icons.star_outline,
            isEditing: _isEditingFeature,
            onEditPressed: () => setState(() => _isEditingFeature = true),
            onSavePressed: () async {
              final currentFeatures = Map<String, dynamic>.from(widget.config.features ?? {});
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
        _buildEditableTile("نسبة العرض للارتفاع", state.aspectRatio, Icons.aspect_ratio, _isEditingFeature, defaultValue: "1.0"),
        _buildEditableTile("المسافة العرضية (Spacing)", state.spacing, Icons.space_bar, _isEditingFeature, defaultValue: "16.0"),
        _buildEditableTile("عدد العمدة (شاشة صغيرة)", state.countSmall, Icons.grid_view, _isEditingFeature, defaultValue: "2"),
        _buildEditableTile("عدد العمدة (شاشة متوسطة)", state.countMedium, Icons.grid_view, _isEditingFeature, defaultValue: "3"),
        _buildEditableTile("عدد العمدة (شاشة كبيرة)", state.countLarge, Icons.grid_view, _isEditingFeature, defaultValue: "4"),
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
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;
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
                hintText: defaultValue != null ? "الافتراضي: $defaultValue" : null,
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
                    ? (defaultValue != null ? "$defaultValue (افتراضي)" : "لا يوجد")
                    : controller.text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
    );
  }

  Widget _buildJsonImportCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.code_rounded, color: Colors.blue),
        title: const Text(
          "استيراد الإعدادات من JSON (Quick Import)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ضع كود الـ JSON هنا لتحديث الألوان بشكل فوري:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _jsonImportController,
                  maxLines: 8,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText:
                        '{\n  "light": { "primary": "0xFF..." },\n  "dark": { ... }\n}',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _importJsonData,
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: const Text(
                      "تطبيق كود الـ JSON فوراَ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _importJsonData() {
    final text = _jsonImportController.text.trim();
    if (text.isEmpty) return;

    try {
      final decoded = jsonDecode(text) as Map<String, dynamic>;

      Map<String, dynamic>? light;
      Map<String, dynamic>? dark;
      Map<String, dynamic>? website;
      Map<String, dynamic>? fixed;

      if (decoded.containsKey('themes')) {
        final themes = decoded['themes'] as Map<String, dynamic>;
        if (themes['light'] != null)
          light = Map<String, dynamic>.from(themes['light']);
        if (themes['dark'] != null)
          dark = Map<String, dynamic>.from(themes['dark']);
        if (themes['website'] != null)
          website = Map<String, dynamic>.from(themes['website']);
        if (themes['fixed'] != null)
          fixed = Map<String, dynamic>.from(themes['fixed']);
      } else {
        if (decoded['light'] != null)
          light = Map<String, dynamic>.from(decoded['light']);
        if (decoded['dark'] != null)
          dark = Map<String, dynamic>.from(decoded['dark']);
        if (decoded['website'] != null)
          website = Map<String, dynamic>.from(decoded['website']);
        if (decoded['fixed'] != null)
          fixed = Map<String, dynamic>.from(decoded['fixed']);
      }

      setState(() {
        if (light != null) _lightThemeMap = light;
        if (dark != null) _darkThemeMap = dark;
        if (website != null) _websiteThemeMap = website;
        if (fixed != null) _fixedThemeMap = fixed;
        _isEditingThemes = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم استيراد الـ JSON وتغطية المربعات بنجاح!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ خطأ في ترميز الـ JSON: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Widget _buildThemeSubSection(
    String title,
    Map<String, dynamic> themeMap,
    bool isEditing,
  ) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      children: themeMap.entries.map((entry) {
        return _buildColorPickerTile(entry.key, entry.value, isEditing, (newColor) {
           setState(() {
             themeMap[entry.key] = newColor;
           });
        });
      }).toList(),
    );
  }

  Color _parseSafeColor(String value) {
    try {
      String hexColor = value.replaceAll('#', '').replaceAll('0x', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (_) {
      return Colors.transparent;
    }
  }

  Widget _buildColorPickerTile(String label, String value, bool isEditing, Function(String) onColorChanged) {
     final displayLabel = _colorLabels[label] ?? label;
     return ListTile(
       title: Text(displayLabel, style: const TextStyle(fontSize: 12)),
       trailing: Container(
         width: 40,
         height: 30,
         decoration: BoxDecoration(
           color: _parseSafeColor(value),
           border: Border.all(color: Colors.grey),
           borderRadius: BorderRadius.circular(4),
         ),
       ),
       onTap: isEditing ? () => _showColorPicker(label, value, onColorChanged) : null,
     );
  }

  void _showColorPicker(String label, String initialValue, Function(String) onColorChanged) {
     Color selectedColor = _parseSafeColor(initialValue);

     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: Text("اختيار لون ${(_colorLabels[label] ?? label)}"),
           content: SingleChildScrollView(
             child: ColorPicker(
               pickerColor: selectedColor,
               onColorChanged: (color) => selectedColor = color,
             ),
           ),
           actions: [
             TextButton(
               child: const Text("الغاء"),
               onPressed: () => Navigator.of(context).pop(),
             ),
             TextButton(
               child: const Text("حفظ"),
               onPressed: () {
                 onColorChanged("0x${selectedColor.toFormatString(Format.hex).toUpperCase()}");
                 Navigator.of(context).pop();
               },
             ),
           ],
         );
       },
     );
  }
}

extension ColorExtension on Color {
  String toFormatString(Format format) {
    return value.toRadixString(16).padLeft(8, '0');
  }
}

enum Format { hex }
