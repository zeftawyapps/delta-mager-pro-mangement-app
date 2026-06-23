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
  bool _isEditingHeader = false;
  String _appMode = WebsiteConfig.appModeHybrid;
  String _logoStyle = WebsiteConfig.logoStyleSolid;
  List<String> _navbarOrder = List.from(WebsiteConfig.defaultNavbarOrder);

  // Sections (body)
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
    _initHeaderData();
  }

  void _initHeaderData() {
    final website = widget.config.website ?? {};
    _appMode =
        (website[WebsiteConfig.keyAppMode] as String?) ??
        WebsiteConfig.appModeHybrid;
    _logoStyle =
        (website[WebsiteConfig.keyLogoStyle] as String?) ??
        WebsiteConfig.logoStyleSolid;
    final savedOrder = website[WebsiteConfig.keyNavbarOrder];
    if (savedOrder is List) {
      _navbarOrder = List<String>.from(savedOrder);
    } else {
      _navbarOrder = List.from(WebsiteConfig.defaultNavbarOrder);
    }
  }

  Future<void> _saveHeader() async {
    final websiteData = Map<String, dynamic>.from(widget.config.website ?? {});
    websiteData[WebsiteConfig.keyAppMode] = _appMode;
    websiteData[WebsiteConfig.keyLogoStyle] = _logoStyle;
    websiteData[WebsiteConfig.keyNavbarOrder] = _navbarOrder;

    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "website",
      sectionData: websiteData,
    );
    setState(() => _isEditingHeader = false);
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
      if (!_isEditingHeader) _initHeaderData();
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
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── وضع التطبيق ─────────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "وضع الموقع (App Mode)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton.icon(
                                icon: Icon(
                                  _isEditingHeader ? Icons.save : Icons.edit,
                                  size: 18,
                                  color: _isEditingHeader
                                      ? Colors.green
                                      : primaryColor,
                                ),
                                label: Text(
                                  _isEditingHeader ? "حفظ" : "تعديل",
                                  style: TextStyle(
                                    color: _isEditingHeader
                                        ? Colors.green
                                        : primaryColor,
                                  ),
                                ),
                                onPressed: _isEditingHeader
                                    ? _saveHeader
                                    : () => setState(
                                        () => _isEditingHeader = true,
                                      ),
                              ),
                            ],
                          ),
                          const Text(
                            "حدد ما إذا كان الموقع يعرض مدونة، متجراً، أم الاثنين معاً",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: primaryColor,
                              selectedForegroundColor: Colors.white,
                            ),
                            segments: const [
                              ButtonSegment(
                                value: WebsiteConfig.appModeBlog,
                                label: Text("🗞️ مدونة فقط"),
                                icon: Icon(Icons.article_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: WebsiteConfig.appModeHybrid,
                                label: Text("🔀 الهجين"),
                                icon: Icon(Icons.join_full, size: 16),
                              ),
                              ButtonSegment(
                                value: WebsiteConfig.appModeStore,
                                label: Text("🛍️ متجر فقط"),
                                icon: Icon(Icons.storefront_outlined, size: 16),
                              ),
                            ],
                            selected: {_appMode},
                            onSelectionChanged: _isEditingHeader
                                ? (val) => setState(() => _appMode = val.first)
                                : null,
                          ),

                          const Divider(height: 28),

                          // ── تنسيق اللوجو ────────────────────────────────────
                          const Text(
                            "تنسيق الشعار في النافبار (Logo Style)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "هل لون الشعار يكون صريحاً أم بتدرج لوني؟",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _LogoStyleChip(
                                label: "لون صريح (Solid)",
                                icon: Icons.format_color_fill,
                                value: WebsiteConfig.logoStyleSolid,
                                selected:
                                    _logoStyle == WebsiteConfig.logoStyleSolid,
                                enabled: _isEditingHeader,
                                primaryColor: primaryColor,
                                onTap: () => setState(
                                  () =>
                                      _logoStyle = WebsiteConfig.logoStyleSolid,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _LogoStyleChip(
                                label: "تدرج (Gradient)",
                                icon: Icons.gradient,
                                value: WebsiteConfig.logoStyleGradient,
                                selected:
                                    _logoStyle ==
                                    WebsiteConfig.logoStyleGradient,
                                enabled: _isEditingHeader,
                                primaryColor: primaryColor,
                                onTap: () => setState(
                                  () => _logoStyle =
                                      WebsiteConfig.logoStyleGradient,
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 28),

                          // ── ترتيب عناصر النافبار ────────────────────────────
                          const Text(
                            "ترتيب عناصر شريط التنقل (Navbar Order)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "اسحب العناصر لإعادة ترتيبها في شريط التنقل",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _navbarOrder.length,
                            onReorder: _isEditingHeader
                                ? (oldIdx, newIdx) {
                                    setState(() {
                                      if (newIdx > oldIdx) newIdx -= 1;
                                      final item = _navbarOrder.removeAt(
                                        oldIdx,
                                      );
                                      _navbarOrder.insert(newIdx, item);
                                    });
                                  }
                                : (_, __) {},
                            itemBuilder: (ctx, idx) {
                              final key = _navbarOrder[idx];
                              final label =
                                  WebsiteConfig.navbarOrderLabels[key] ?? key;
                              return ListTile(
                                key: ValueKey(key),
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: primaryColor.withOpacity(
                                    0.15,
                                  ),
                                  child: Text(
                                    "${idx + 1}",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  label,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: _isEditingHeader
                                    ? Icon(
                                        Icons.drag_handle,
                                        color: Colors.grey.shade400,
                                      )
                                    : null,
                              );
                            },
                          ),
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

// ─── Helper Widget: Logo Style Chip ────────────────────────────────────────
class _LogoStyleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final bool enabled;
  final Color primaryColor;
  final VoidCallback onTap;

  const _LogoStyleChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.enabled,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? primaryColor : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            color: selected
                ? primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? primaryColor : Colors.grey,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? primaryColor : Colors.grey,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
