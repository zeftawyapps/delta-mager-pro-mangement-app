import 'package:flutter/material.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/b2b_home_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';

import 'widgets/order_settings_card.dart';
import 'widgets/b2b_section_card.dart';

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
  }

  void _loadData() {
    final layout = widget.config.b2bHomeLayout;

    // دمج كل التحديثات في setState واحدة لتجنب الـ rebuild المزدوج
    setState(() {
      if (layout != null && layout[B2bHomeConfig.keySections] != null) {
        _sections = List<Map<String, dynamic>>.from(
          (layout[B2bHomeConfig.keySections] as List).map((e) {
            final map = Map<String, dynamic>.from(e);
            map['config'] = map['config'] != null
                ? Map<String, dynamic>.from(map['config'])
                : {};
            return map;
          }),
        );
      } else {
        _sections = List<Map<String, dynamic>>.from(
          B2bHomeConfig.defaultValues[B2bHomeConfig.keySections].map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
      }

      final orderSettings =
          widget.config.b2bHomeLayout?[B2bHomeConfig.keyOrderSettings];
      if (orderSettings != null) {
        _orderSettings = Map<String, dynamic>.from(orderSettings);
      } else {
        _orderSettings = Map<String, dynamic>.from(
          B2bHomeConfig.defaultValues[B2bHomeConfig.keyOrderSettings],
        );
      }
    });
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
            OrderSettingsCard(
              orderSettings: _orderSettings,
              isEditing: _isEditing,
              isDark: widget.isDark,
              primaryColor: primaryColor,
              organizationId: widget.organizationId,
              onSettingsChanged: (newSettings) {
                setState(() {
                  _orderSettings = newSettings;
                });
              },
            ),
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
          return B2BSectionCard(
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
