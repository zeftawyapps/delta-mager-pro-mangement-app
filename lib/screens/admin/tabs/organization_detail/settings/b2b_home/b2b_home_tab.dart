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

class _B2BHomeConfigTabState extends State<B2BHomeConfigTab>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _sections = [];
  Map<String, dynamic> _orderSettings = {};
  bool _isEditing = false;

  // Animate edit‑mode banner
  late AnimationController _editBannerController;
  late Animation<double> _editBannerAnimation;

  // Header config
  String _logoStyle = 'solid';
  String _navbarLayout = 'classic';
  String _navbarTheme = 'glass';
  bool _navbarSticky = true;

  // Footer & Social controllers
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _facebookController;
  late TextEditingController _telegramController;
  late TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    _editBannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _editBannerAnimation = CurvedAnimation(
      parent: _editBannerController,
      curve: Curves.easeOut,
    );
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _facebookController = TextEditingController();
    _telegramController = TextEditingController();
    _whatsappController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _editBannerController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _facebookController.dispose();
    _telegramController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _setEditing(bool value) {
    setState(() => _isEditing = value);
    if (value) {
      _editBannerController.forward();
    } else {
      _editBannerController.reverse();
    }
  }

  void _loadData() {
    final layout = widget.config.b2bHomeLayout ?? {};
    final header =
        layout['header'] is Map ? Map<String, dynamic>.from(layout['header']) : {};
    final footer =
        layout['footer'] is Map ? Map<String, dynamic>.from(layout['footer']) : {};
    final social = footer['socialMedia'] is Map
        ? Map<String, dynamic>.from(footer['socialMedia'])
        : {};

    setState(() {
      if (layout[B2bHomeConfig.keySections] != null) {
        _sections = List<Map<String, dynamic>>.from(
          (layout[B2bHomeConfig.keySections] as List).map((e) {
            final map = Map<String, dynamic>.from(e);
            map['config'] =
                map['config'] != null ? Map<String, dynamic>.from(map['config']) : {};
            return map;
          }),
        );
      } else {
        _sections = List<Map<String, dynamic>>.from(
          B2bHomeConfig.defaultValues[B2bHomeConfig.keySections]
              .map((e) => Map<String, dynamic>.from(e)),
        );
      }

      final orderSettings = layout[B2bHomeConfig.keyOrderSettings];
      _orderSettings = orderSettings != null
          ? Map<String, dynamic>.from(orderSettings)
          : Map<String, dynamic>.from(
              B2bHomeConfig.defaultValues[B2bHomeConfig.keyOrderSettings]);

      _logoStyle = header['logoStyle']?.toString() ?? 'solid';
      _navbarLayout = header['navbarLayout']?.toString() ?? 'classic';
      _navbarTheme = header['navbarTheme']?.toString() ?? 'glass';
      _navbarSticky = header['navbarSticky'] != false;

      _descriptionController.text = footer['description']?.toString() ?? '';
      _addressController.text = footer['address']?.toString() ?? '';
      _phoneController.text = footer['phone']?.toString() ?? '';
      _emailController.text = footer['email']?.toString() ?? '';
      _facebookController.text = social['facebook']?.toString() ?? '';
      _telegramController.text = social['telegram']?.toString() ?? '';
      _whatsappController.text = social['whatsapp']?.toString() ?? '';
    });
  }

  @override
  void didUpdateWidget(covariant B2BHomeConfigTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config && !_isEditing) _loadData();
  }

  Future<void> _saveConfig() async {
    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "b2bHomeLayout",
      sectionData: {
        B2bHomeConfig.keySections: _sections,
        B2bHomeConfig.keyOrderSettings: _orderSettings,
        'header': {
          'logoStyle': _logoStyle,
          'navbarLayout': _navbarLayout,
          'navbarTheme': _navbarTheme,
          'navbarSticky': _navbarSticky,
        },
        'footer': {
          'description': _descriptionController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'socialMedia': {
            'facebook': _facebookController.text,
            'telegram': _telegramController.text,
            'whatsapp': _whatsappController.text,
          },
        },
      },
    );
    _setEditing(false);
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
        const SnackBar(content: Text("تم إضافة الأقسام المفقودة بناءً على إعدادات المزايا")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("جميع المزايا المفعلة مضافة بالفعل في التخطيط")),
      );
    }
  }

  void _removeSection(int index) {
    setState(() => _sections.removeAt(index));
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;

    return Column(
      children: [
        // ── 1. Sticky Top Action Bar ──────────────────────────────────
        _buildTopBar(primaryColor),

        // ── 2. Edit‑mode hint banner (animated) ──────────────────────
        SizeTransition(
          sizeFactor: _editBannerAnimation,
          axisAlignment: -1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.orange.withOpacity(0.12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "وضع التعديل نشط — اسحب البطاقات لإعادة ترتيبها، ثم احفظ عند الانتهاء.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── 3. Scrollable Content ─────────────────────────────────────
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Settings Card
                OrderSettingsCard(
                  orderSettings: _orderSettings,
                  isEditing: _isEditing,
                  isDark: widget.isDark,
                  primaryColor: primaryColor,
                  organizationId: widget.organizationId,
                  onSettingsChanged: (newSettings) =>
                      setState(() => _orderSettings = newSettings),
                ),
                const SizedBox(height: 12),

                // Header / Footer Card
                _buildHeaderFooterCard(primaryColor),
                const SizedBox(height: 20),

                // Sections label + add/sync buttons
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "أقسام الصفحة الرئيسية",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            "${_sections.length} قسم مُضاف",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (_isEditing) ...[
                      _ActionIconBtn(
                        icon: Icons.sync_alt_rounded,
                        label: "مزامنة",
                        color: Colors.orange,
                        onTap: _syncWithProductConfig,
                      ),
                      const SizedBox(width: 8),
                      _ActionIconBtn(
                        icon: Icons.add_rounded,
                        label: "إضافة",
                        color: Colors.blue,
                        onTap: _addSection,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
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
                onSectionChanged: (newSection) =>
                    setState(() => _sections[index] = newSection),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Top Bar
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildTopBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: primaryColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon + Title
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.dashboard_customize_rounded,
                color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إعدادات واجهة B2B",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  _isEditing ? "تعديل نشط — لا تنسَ الحفظ" : "عرض الإعدادات الحالية",
                  style: TextStyle(
                    fontSize: 11,
                    color: _isEditing ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Cancel button (only in edit mode)
          if (_isEditing) ...[
            OutlinedButton.icon(
              onPressed: () {
                _loadData();
                _setEditing(false);
              },
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text("إلغاء"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Main Action Button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isEditing
                ? ElevatedButton.icon(
                    key: const ValueKey('save'),
                    onPressed: _saveConfig,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text("حفظ التغييرات"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : ElevatedButton.icon(
                    key: const ValueKey('edit'),
                    onPressed: () => _setEditing(true),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text("تعديل"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Header / Footer Card
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeaderFooterCard(Color primaryColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor.withOpacity(0.18), width: 1),
      ),
      color: primaryColor.withOpacity(0.03),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.design_services_rounded, color: primaryColor),
          title: Text(
            "إعدادات الهيدر والفوتر",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: const Text(
            "شريط التنقل، وصف المتجر، روابط التواصل",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            // Header
            _sectionLabel("شريط التنقل (Header)", primaryColor),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownTile<String>(
                    label: "تنسيق اللوجو",
                    value: _logoStyle,
                    items: const [
                      DropdownMenuItem(value: 'solid', child: Text('سادة (Solid)')),
                      DropdownMenuItem(
                          value: 'gradient', child: Text('تدرج لوني')),
                    ],
                    onChanged:
                        _isEditing ? (v) => setState(() => _logoStyle = v!) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownTile<String>(
                    label: "تخطيط شريط التنقل",
                    value: _navbarLayout,
                    items: const [
                      DropdownMenuItem(
                          value: 'classic', child: Text('كلاسيكي')),
                      DropdownMenuItem(
                          value: 'centered', child: Text('متوسط')),
                      DropdownMenuItem(value: 'minimal', child: Text('مبسط')),
                    ],
                    onChanged: _isEditing
                        ? (v) => setState(() => _navbarLayout = v!)
                        : null,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownTile<String>(
                    label: "ثيم شريط التنقل",
                    value: _navbarTheme,
                    items: const [
                      DropdownMenuItem(
                          value: 'glass', child: Text('زجاجي (Glass)')),
                      DropdownMenuItem(
                          value: 'solid', child: Text('سادة (Solid)')),
                      DropdownMenuItem(
                          value: 'colored', child: Text('ملون (Colored)')),
                    ],
                    onChanged: _isEditing
                        ? (v) => setState(() => _navbarTheme = v!)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SwitchListTile(
                    title: const Text("ثبّت الهيدر",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle:
                        const Text("Sticky Navbar", style: TextStyle(fontSize: 10)),
                    value: _navbarSticky,
                    onChanged:
                        _isEditing ? (v) => setState(() => _navbarSticky = v) : null,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: primaryColor,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Footer
            _sectionLabel("الفوتر (Footer)", primaryColor),
            const SizedBox(height: 8),
            _buildEditableTile("وصف المتجر", _descriptionController,
                Icons.description_outlined, _isEditing,
                maxLines: 3),
            Row(
              children: [
                Expanded(
                  child: _buildEditableTile("البريد الإلكتروني", _emailController,
                      Icons.email_outlined, _isEditing),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEditableTile("رقم الهاتف", _phoneController,
                      Icons.phone_outlined, _isEditing),
                ),
              ],
            ),
            _buildEditableTile("العنوان", _addressController,
                Icons.location_on_outlined, _isEditing),

            const Divider(height: 24),

            // Social
            _sectionLabel("التواصل الاجتماعي", primaryColor),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildEditableTile("فيسبوك", _facebookController,
                      Icons.facebook_outlined, _isEditing),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEditableTile("تيليجرام", _telegramController,
                      Icons.telegram_outlined, _isEditing),
                ),
              ],
            ),
            _buildEditableTile("واتساب (رابط أو رقم)", _whatsappController,
                Icons.chat_outlined, _isEditing),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
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
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: isEditing
          ? TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                prefixIcon: Icon(icon, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            )
          : ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, size: 20, color: Colors.grey),
              title: Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              subtitle: Text(
                controller.text.isEmpty ? "—" : controller.text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widget for icon + label action buttons
// ─────────────────────────────────────────────────────────────────────────────
class _ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
