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
  bool _isEditingFooter = false;
  bool _isEditingSocial = false;

  // Footer & Social controllers
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _trustBadgeController;
  late TextEditingController _copyrightController;

  late TextEditingController _facebookController;
  late TextEditingController _telegramController;
  late TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initFooterControllers();
  }

  void _initFooterControllers() {
    final footer = widget.config.website?['footer'] ?? {};
    final social = widget.config.website?['socialMedia'] ?? {};

    _descriptionController = TextEditingController(
      text: footer['description'] ?? '',
    );
    _addressController = TextEditingController(text: footer['address'] ?? '');
    _phoneController = TextEditingController(text: footer['phone'] ?? '');
    _emailController = TextEditingController(text: footer['email'] ?? '');
    _trustBadgeController = TextEditingController(
      text: footer['trustBadge'] ?? '',
    );
    _copyrightController = TextEditingController(
      text: footer['copyright'] ?? '',
    );

    _facebookController = TextEditingController(text: social['facebook'] ?? '');
    _telegramController = TextEditingController(text: social['telegram'] ?? '');
    _whatsappController = TextEditingController(text: social['whatsapp'] ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _trustBadgeController.dispose();
    _copyrightController.dispose();
    _facebookController.dispose();
    _telegramController.dispose();
    _whatsappController.dispose();
    super.dispose();
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
      sectionData: {WebsiteConfig.keySections: _sections},
    );
    setState(() => _isEditing = false);
  }

  Future<void> _saveFooter() async {
    final footerData = {
      'description': _descriptionController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'trustBadge': _trustBadgeController.text.trim(),
      'copyright': _copyrightController.text.trim(),
    };

    final websiteData = Map<String, dynamic>.from(widget.config.website ?? {});
    websiteData['footer'] = footerData;

    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "website",
      sectionData: websiteData,
    );
  }

  Future<void> _saveSocial() async {
    final socialData = {
      'facebook': _facebookController.text.trim(),
      'telegram': _telegramController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
    };

    final websiteData = Map<String, dynamic>.from(widget.config.website ?? {});
    websiteData['socialMedia'] = socialData;

    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "website",
      sectionData: websiteData,
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
      child: ExpansionTile(
        initiallyExpanded: false,
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
            style: TextStyle(color: isEditing ? Colors.green : primaryColor),
          ),
          onPressed: isEditing ? onSavePressed : onEditPressed,
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: children),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: Icon(Icons.vertical_align_top, color: primaryColor),
                  title: const Text("إعدادات  (header)"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                                                ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: widget.isDark ? DarkColors.surface : Colors.white,
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: Icon(Icons.vertical_align_center, color: primaryColor),
                title: const Text(
                  "   اعدادات محتوى الموقع  websit body",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  // Upper part: header + reorderable sections list (inside its own card)
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    elevation: 0,
                    color: widget.isDark
                        ? DarkColors.surfaceVariant
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "تخطيط الصفحة الرئيسية للموقع (Next.js Storefront)",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_isEditing) ...[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: Colors.blue,
                                      ),
                                      onPressed: _addSection,
                                      tooltip: "إضافة قسم جديد",
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _isEditing
                                        ? _saveConfig
                                        : () =>
                                              setState(() => _isEditing = true),
                                    icon: Icon(
                                      _isEditing ? Icons.save : Icons.edit,
                                    ),
                                    label: Text(
                                      _isEditing
                                          ? "حفظ التغييرات"
                                          : "تعديل الإعدادات",
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
                          const SizedBox(height: 12),
                          if (_isEditing)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                "قم بسحب العناصر لإعادة ترتيبها في الصفحة الرئيسية لموقع الويب",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _sections.length,
                            onReorder: (oldIndex, newIndex) {
                              if (!_isEditing) return;
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final item = _sections.removeAt(oldIndex);
                                _sections.insert(newIndex, item);
                              });
                            },
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
                        ],
                      ),
                    ),
                  ),

                  // Footer settings grouped inside ExpansionTile within the parent card
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.vertical_align_bottom,
                    color: primaryColor,
                  ),
                  title: const Text("إعدادات التذييل (Footer)"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildFormCard(
                            title: "محتوى التذييل",
                            icon: Icons.info_outline,
                            isEditing: _isEditingFooter,
                            onEditPressed: () =>
                                setState(() => _isEditingFooter = true),
                            onSavePressed: _saveFooter,
                            children: [
                              _buildEditableTile(
                                "وصف المتجر في الفوتر",
                                _descriptionController,
                                Icons.description_outlined,
                                _isEditingFooter,
                                maxLines: 3,
                              ),
                              _buildEditableTile(
                                "العنوان",
                                _addressController,
                                Icons.location_on_outlined,
                                _isEditingFooter,
                              ),
                              _buildEditableTile(
                                "رقم الهاتف",
                                _phoneController,
                                Icons.phone_outlined,
                                _isEditingFooter,
                              ),
                              _buildEditableTile(
                                "البريد الإلكتروني",
                                _emailController,
                                Icons.email_outlined,
                                _isEditingFooter,
                              ),
                              _buildEditableTile(
                                "نص شارة الثقة (Trust Badge)",
                                _trustBadgeController,
                                Icons.verified_user_outlined,
                                _isEditingFooter,
                                hint: "مثال: مرخص وآمن بنسبة 100%",
                              ),
                              _buildEditableTile(
                                "نص حقوق الطبع والنشر (Copyright)",
                                _copyrightController,
                                Icons.copyright_outlined,
                                _isEditingFooter,
                                hint: "مثال: جميع الحقوق محفوظة.",
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildFormCard(
                            title: "روابط التواصل الاجتماعي",
                            icon: Icons.share_outlined,
                            isEditing: _isEditingSocial,
                            onEditPressed: () =>
                                setState(() => _isEditingSocial = true),
                            onSavePressed: _saveSocial,
                            children: [
                              _buildEditableTile(
                                "رابط فيسبوك",
                                _facebookController,
                                Icons.facebook_outlined,
                                _isEditingSocial,
                              ),
                              _buildEditableTile(
                                "رابط تيليجرام",
                                _telegramController,
                                Icons.telegram_outlined,
                                _isEditingSocial,
                              ),
                              _buildEditableTile(
                                "رقم واتساب",
                                _whatsappController,
                                Icons.chat_outlined,
                                _isEditingSocial,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
