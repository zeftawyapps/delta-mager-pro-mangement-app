import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';

import 'widgets/json_import_card.dart';
import 'widgets/theme_subsection.dart';

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

  late final TextEditingController _fontFamilyController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _appTitleController;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          JsonImportCard(
            isDark: widget.isDark,
            onImportSuccess: (light, dark, website, fixed) {
              setState(() {
                _lightThemeMap = light;
                _darkThemeMap = dark;
                _websiteThemeMap = website;
                _fixedThemeMap = fixed;
                _isEditingThemes = true;
              });
            },
          ),
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
                  ThemeSubsection(
                    title: "الثيم المضيء (Light)",
                    themeMap: _lightThemeMap!,
                    isEditing: _isEditingThemes,
                    onColorChanged: (key, newColor) {
                      setState(() {
                        _lightThemeMap![key] = newColor;
                      });
                    },
                  ),
                if (_darkThemeMap != null)
                  ThemeSubsection(
                    title: "الثيم الداكن (Dark)",
                    themeMap: _darkThemeMap!,
                    isEditing: _isEditingThemes,
                    onColorChanged: (key, newColor) {
                      setState(() {
                        _darkThemeMap![key] = newColor;
                      });
                    },
                  ),
                if (_websiteThemeMap != null)
                  ThemeSubsection(
                    title: "ثيم الموقع (Website)",
                    themeMap: _websiteThemeMap!,
                    isEditing: _isEditingThemes,
                    onColorChanged: (key, newColor) {
                      setState(() {
                        _websiteThemeMap![key] = newColor;
                      });
                    },
                  ),
                if (_fixedThemeMap != null)
                  ThemeSubsection(
                    title: "الثيم الثابت (Fixed)",
                    themeMap: _fixedThemeMap!,
                    isEditing: _isEditingThemes,
                    onColorChanged: (key, newColor) {
                      setState(() {
                        _fixedThemeMap![key] = newColor;
                      });
                    },
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
        ],
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
