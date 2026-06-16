import 'package:flutter/material.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/website_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';

import 'widgets/website_section_card.dart';

class WebsiteConfigTab extends StatefulWidget {
  final OrganizationConfig config;
  final String organizationId;
  final bool isDark;

  const WebsiteConfigTab({
    super.key,
    required this.config,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<WebsiteConfigTab> createState() => _WebsiteConfigTabState();
}

class _WebsiteConfigTabState extends State<WebsiteConfigTab> {
  List<Map<String, dynamic>> _sections = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final layout = widget.config.website;
    if (layout != null && layout[WebsiteConfig.keySections] != null) {
      setState(() {
        _sections = List<Map<String, dynamic>>.from(
          (layout[WebsiteConfig.keySections] as List).map((e) {
            final map = Map<String, dynamic>.from(e);
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
          WebsiteConfig.defaultValues[WebsiteConfig.keySections].map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant WebsiteConfigTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config && !_isEditing) {
      _loadData();
    }
  }

  Future<void> _saveConfig() async {
    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "website",
      sectionData: {
        WebsiteConfig.keySections: _sections,
      },
    );
    setState(() => _isEditing = false);
  }

  void _addSection() {
    setState(() {
      _sections.add({
        "id": "web_sec_${DateTime.now().millisecondsSinceEpoch}",
        "type": WebsiteConfig.typeNewProducts,
        "displayMode": WebsiteConfig.modeGrid,
        "title": "قسم جديد على الويب",
        "isActive": true,
        "config": {},
      });
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "تخطيط الصفحة الرئيسية للموقع (Next.js Storefront)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    if (_isEditing) ...[
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: _addSection,
                        tooltip: "إضافة قسم جديد",
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
                  "قم بسحب العناصر لإعادة ترتيبها في الصفحة الرئيسية لموقع الويب",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const Divider(height: 20),
          ],
        ),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return WebsiteSectionCard(
            key: ValueKey(section['id']),
            index: index,
            section: section,
            isEditing: _isEditing,
            isDark: widget.isDark,
            primaryColor: primaryColor,
            onRemove: () => _removeSection(index),
            onSectionChanged: (newSection) {
              setState(() {
                _sections[index] = newSection;
              });
            },
          );
        },
      ),
    );
  }
}
