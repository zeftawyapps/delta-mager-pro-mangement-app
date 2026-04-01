import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';

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
  
  late TextEditingController _catAspectRatioController;
  late TextEditingController _catSpacingController;
  late TextEditingController _catCountSmallController;
  late TextEditingController _catCountMediumController;
  late TextEditingController _catCountLargeController;

  late TextEditingController _prodAspectRatioController;
  late TextEditingController _prodSpacingController;
  late TextEditingController _prodCountSmallController;
  late TextEditingController _prodCountMediumController;
  late TextEditingController _prodCountLargeController;

  late TextEditingController _userAspectRatioController;
  late TextEditingController _userSpacingController;
  late TextEditingController _userCountSmallController;
  late TextEditingController _userCountMediumController;
  late TextEditingController _userCountLargeController;

  bool _showCartLocal = false;
  bool _showSearchLocal = false;

  Map<String, dynamic>? _lightThemeMap;
  Map<String, dynamic>? _darkThemeMap;
  Map<String, dynamic>? _websiteThemeMap;
  Map<String, dynamic>? _fixedThemeMap;

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
    _catAspectRatioController = TextEditingController(text: featureConfig?.categories?.childAspectRatio?.toString() ?? "");
    _catSpacingController = TextEditingController(text: featureConfig?.categories?.crossAxisSpacing?.toString() ?? "");
    _catCountSmallController = TextEditingController(text: featureConfig?.categories?.crossAxisCountSmall?.toString() ?? "");
    _catCountMediumController = TextEditingController(text: featureConfig?.categories?.crossAxisCountMedium?.toString() ?? "");
    _catCountLargeController = TextEditingController(text: featureConfig?.categories?.crossAxisCountLarge?.toString() ?? "");

    _prodAspectRatioController = TextEditingController(text: featureConfig?.products?.childAspectRatio?.toString() ?? "");
    _prodSpacingController = TextEditingController(text: featureConfig?.products?.crossAxisSpacing?.toString() ?? "");
    _prodCountSmallController = TextEditingController(text: featureConfig?.products?.crossAxisCountSmall?.toString() ?? "");
    _prodCountMediumController = TextEditingController(text: featureConfig?.products?.crossAxisCountMedium?.toString() ?? "");
    _prodCountLargeController = TextEditingController(text: featureConfig?.products?.crossAxisCountLarge?.toString() ?? "");

    _userAspectRatioController = TextEditingController(text: featureConfig?.users?.childAspectRatio?.toString() ?? "");
    _userSpacingController = TextEditingController(text: featureConfig?.users?.crossAxisSpacing?.toString() ?? "");
    _userCountSmallController = TextEditingController(text: featureConfig?.users?.crossAxisCountSmall?.toString() ?? "");
    _userCountMediumController = TextEditingController(text: featureConfig?.users?.crossAxisCountMedium?.toString() ?? "");
    _userCountLargeController = TextEditingController(text: featureConfig?.users?.crossAxisCountLarge?.toString() ?? "");

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
    _catAspectRatioController.dispose();
    _catSpacingController.dispose();
    _catCountSmallController.dispose();
    _catCountMediumController.dispose();
    _catCountLargeController.dispose();
    _prodAspectRatioController.dispose();
    _prodSpacingController.dispose();
    _prodCountSmallController.dispose();
    _prodCountMediumController.dispose();
    _prodCountLargeController.dispose();
    _userAspectRatioController.dispose();
    _userSpacingController.dispose();
    _userCountSmallController.dispose();
    _userCountMediumController.dispose();
    _userCountLargeController.dispose();
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
              
              currentFeatures['feature'] = {
                "categories": {
                  if (_catAspectRatioController.text.isNotEmpty) "childAspectRatio": double.tryParse(_catAspectRatioController.text),
                  if (_catSpacingController.text.isNotEmpty) "crossAxisSpacing": double.tryParse(_catSpacingController.text),
                  if (_catCountSmallController.text.isNotEmpty) "crossAxisCountSmall": int.tryParse(_catCountSmallController.text),
                  if (_catCountMediumController.text.isNotEmpty) "crossAxisCountMedium": int.tryParse(_catCountMediumController.text),
                  if (_catCountLargeController.text.isNotEmpty) "crossAxisCountLarge": int.tryParse(_catCountLargeController.text),
                },
                "products": {
                  if (_prodAspectRatioController.text.isNotEmpty) "childAspectRatio": double.tryParse(_prodAspectRatioController.text),
                  if (_prodSpacingController.text.isNotEmpty) "crossAxisSpacing": double.tryParse(_prodSpacingController.text),
                  if (_prodCountSmallController.text.isNotEmpty) "crossAxisCountSmall": int.tryParse(_prodCountSmallController.text),
                  if (_prodCountMediumController.text.isNotEmpty) "crossAxisCountMedium": int.tryParse(_prodCountMediumController.text),
                  if (_prodCountLargeController.text.isNotEmpty) "crossAxisCountLarge": int.tryParse(_prodCountLargeController.text),
                },
                "users": {
                  if (_userAspectRatioController.text.isNotEmpty) "childAspectRatio": double.tryParse(_userAspectRatioController.text),
                  if (_userSpacingController.text.isNotEmpty) "crossAxisSpacing": double.tryParse(_userSpacingController.text),
                  if (_userCountSmallController.text.isNotEmpty) "crossAxisCountSmall": int.tryParse(_userCountSmallController.text),
                  if (_userCountMediumController.text.isNotEmpty) "crossAxisCountMedium": int.tryParse(_userCountMediumController.text),
                  if (_userCountLargeController.text.isNotEmpty) "crossAxisCountLarge": int.tryParse(_userCountLargeController.text),
                }
              };

              context.read<AdminOrganizationConfigBloc>().updateConfigSection(
                organizationId: widget.organizationId,
                section: "features",
                sectionData: currentFeatures,
              );
              setState(() => _isEditingFeature = false);
            },
            children: [
              _buildSectionTitle("شبكة الأصناف (Categories)"),
              _buildEditableTile("نسبة العرض للارتفاع", _catAspectRatioController, Icons.aspect_ratio, _isEditingFeature),
              _buildEditableTile("المسافة العرضية (Spacing)", _catSpacingController, Icons.space_bar, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة صغيرة)", _catCountSmallController, Icons.grid_view, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة متوسطة)", _catCountMediumController, Icons.grid_view, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة كبيرة)", _catCountLargeController, Icons.grid_view, _isEditingFeature),
              
              const Divider(),
              _buildSectionTitle("شبكة المنتجات (Products)"),
              _buildEditableTile("نسبة العرض للارتفاع", _prodAspectRatioController, Icons.aspect_ratio, _isEditingFeature),
              _buildEditableTile("المسافة العرضية (Spacing)", _prodSpacingController, Icons.space_bar, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة صغيرة)", _prodCountSmallController, Icons.grid_view, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة متوسطة)", _prodCountMediumController, Icons.grid_view, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة كبيرة)", _prodCountLargeController, Icons.grid_view, _isEditingFeature),
              
              const Divider(),
              _buildSectionTitle("شبكة المستخدمين (Users)"),
              _buildEditableTile("نسبة العرض للارتفاع", _userAspectRatioController, Icons.aspect_ratio, _isEditingFeature),
              _buildEditableTile("المسافة العرضية (Spacing)", _userSpacingController, Icons.space_bar, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة صغيرة)", _userCountSmallController, Icons.grid_view, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة متوسطة)", _userCountMediumController, Icons.grid_view, _isEditingFeature),
              _buildEditableTile("عدد العمدة (شاشة كبيرة)", _userCountLargeController, Icons.grid_view, _isEditingFeature),
            ],
          ),
        ],
      ),
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
    bool isEditing,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
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
                controller.text.isEmpty ? "لا يوجد" : controller.text,
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

  Widget _buildColorPickerTile(String label, String value, bool isEditing, Function(String) onColorChanged) {
     return ListTile(
       title: Text(label, style: const TextStyle(fontSize: 12)),
       trailing: Container(
         width: 40,
         height: 30,
         decoration: BoxDecoration(
           color: Color(int.parse(value)),
           border: Border.all(color: Colors.grey),
           borderRadius: BorderRadius.circular(4),
         ),
       ),
       onTap: isEditing ? () => _showColorPicker(label, value, onColorChanged) : null,
     );
  }

  void _showColorPicker(String label, String initialValue, Function(String) onColorChanged) {
     int colorInt = int.parse(initialValue);
     Color selectedColor = Color(colorInt);

     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: Text("اختيار لون $label"),
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
