import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/website_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:JoDija_tamplites/util/widgits/images_widgets/image_picker_widget.dart';

import 'widgets/website_section_card.dart';
import 'widgets/intro_color_picker_widgets.dart';
import '../b2b_home/widgets/order_settings_card.dart';

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
  String _appMode = WebsiteConfig.appModeBlog;
  String _logoStyle = WebsiteConfig.logoStyleSolid;
  List<String> _navbarOrder = List.from(WebsiteConfig.defaultNavbarOrder);

  // New configuration options
  String _excessLinksMode = WebsiteConfig.excessLinksDropdown;
  bool _showStoreCategoriesInNavbar = false;
  bool _showBlogCategoriesInNavbar = false;
  bool _showStoreCategoriesInFooter = true;
  bool _showBlogCategoriesInFooter = true;

  String _navbarLayout = 'classic';
  String _navbarTheme = 'glass';
  String _footerLayout = 'classic';
  String _footerTheme = 'solid';
  bool _navbarSticky = true;

  // Sections (body)
  List<Map<String, dynamic>> _sections = [];
  bool _isEditing = false;
  bool _isEditingFooter = false;
  bool _isEditingSocial = false;
  bool _isEditingOrderSettings = false;
  Map<String, dynamic> _orderSettings = {};
  final Map<String, Map<int, ImageFileModel?>> _pendingShowcaseImages = {};

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

  String _customNavbarBg = '';
  String _customNavbarTextColor = '';

  void _initHeaderData() {
    final website = widget.config.website ?? {};
    _appMode =
        (website[WebsiteConfig.keyAppMode] as String?) ??
        WebsiteConfig.appModeBlog;
    _logoStyle =
        (website[WebsiteConfig.keyLogoStyle] as String?) ??
        WebsiteConfig.logoStyleSolid;
    _customNavbarBg =
        (website['customNavbarBg'] as String?) ?? (website['navbarBg'] as String?) ?? '';
    _customNavbarTextColor =
        (website['customNavbarTextColor'] as String?) ?? (website['navbarTextColor'] as String?) ?? '';
    final savedOrder = website[WebsiteConfig.keyNavbarOrder];
    if (savedOrder is List) {
      _navbarOrder = List<String>.from(savedOrder);
    } else {
      _navbarOrder = List.from(WebsiteConfig.defaultNavbarOrder);
    }

    _excessLinksMode =
        (website[WebsiteConfig.keyExcessLinksMode] as String?) ??
        WebsiteConfig.excessLinksDropdown;
    _showStoreCategoriesInNavbar =
        (website[WebsiteConfig.keyShowStoreCategoriesInNavbar] as bool?) ??
        false;
    _showBlogCategoriesInNavbar =
        (website[WebsiteConfig.keyShowBlogCategoriesInNavbar] as bool?) ??
        false;
    _showStoreCategoriesInFooter =
        (website[WebsiteConfig.keyShowStoreCategoriesInFooter] as bool?) ??
        true;
    _showBlogCategoriesInFooter =
        (website[WebsiteConfig.keyShowBlogCategoriesInFooter] as bool?) ?? true;

    _navbarLayout =
        (website[WebsiteConfig.keyNavbarLayout] as String?) ?? 'classic';
    _navbarTheme =
        (website[WebsiteConfig.keyNavbarTheme] as String?) ?? 'glass';
    _footerLayout =
        (website[WebsiteConfig.keyFooterLayout] as String?) ?? 'classic';
    _footerTheme =
        (website[WebsiteConfig.keyFooterTheme] as String?) ?? 'solid';
    _navbarSticky = (website[WebsiteConfig.keyNavbarSticky] as bool?) ?? true;
  }

  bool get _isGlobalEditing =>
      _isEditingHeader ||
      _isEditing ||
      _isEditingFooter ||
      _isEditingSocial ||
      _isEditingOrderSettings;

  void _enableGlobalEditing() {
    setState(() {
      _isEditingHeader = true;
      _isEditing = true;
      _isEditingFooter = true;
      _isEditingSocial = true;
      _isEditingOrderSettings = true;
    });
  }

  void _cancelGlobalEditing() {
    setState(() {
      _isEditingHeader = false;
      _isEditing = false;
      _isEditingFooter = false;
      _isEditingSocial = false;
      _isEditingOrderSettings = false;
      _loadData();
      _initHeaderData();
      _initFooterControllers();
    });
  }

  Future<void> _saveAll() async {
    await _saveHeader();
    await _saveConfig();
    await _saveFooter();
    await _saveSocial();
    await _saveOrderSettings();

    if (!mounted) return;
    setState(() {
      _isEditingHeader = false;
      _isEditing = false;
      _isEditingFooter = false;
      _isEditingSocial = false;
      _isEditingOrderSettings = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ جميع إعدادات الموقع بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveHeader() async {
    final websiteData = Map<String, dynamic>.from(widget.config.website ?? {});
    websiteData[WebsiteConfig.keyAppMode] = _appMode;
    websiteData[WebsiteConfig.keyLogoStyle] = _logoStyle;
    websiteData[WebsiteConfig.keyNavbarOrder] = _navbarOrder;
    websiteData[WebsiteConfig.keyExcessLinksMode] = _excessLinksMode;
    websiteData[WebsiteConfig.keyShowStoreCategoriesInNavbar] =
        _showStoreCategoriesInNavbar;
    websiteData[WebsiteConfig.keyShowBlogCategoriesInNavbar] =
        _showBlogCategoriesInNavbar;
    websiteData[WebsiteConfig.keyNavbarLayout] = _navbarLayout;
    websiteData[WebsiteConfig.keyNavbarTheme] = _navbarTheme;
    websiteData[WebsiteConfig.keyNavbarSticky] = _navbarSticky;
    websiteData['customNavbarBg'] = _customNavbarBg;
    websiteData['customNavbarTextColor'] = _customNavbarTextColor;

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
            return WebsiteConfig.normalizeSectionFromApi(
              Map<String, dynamic>.from(e),
            );
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

    final orderSettings = layout?[WebsiteConfig.keyOrderSettings];
    setState(() {
      if (orderSettings != null) {
        _orderSettings = Map<String, dynamic>.from(orderSettings);
      } else {
        _orderSettings = Map<String, dynamic>.from(
          WebsiteConfig.defaultValues[WebsiteConfig.keyOrderSettings] ??
              {
                'workflowSlug': null,
                'allowDefaultWorkflow': true,
                'calculationMode': 2,
                'orderMode': 'C2B',
              },
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant WebsiteConfigTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      if (!_isEditing && !_isEditingOrderSettings) _loadData();
      if (!_isEditingHeader) _initHeaderData();
      if (!_isEditingFooter && !_isEditingSocial) _initFooterControllers();
    }
  }

  Future<void> _saveConfig() async {
    final bloc = context.read<AdminOrganizationConfigBloc>();
    var sections = _sections
        .map(
          (section) => WebsiteConfig.sanitizeSectionForSave(
            WebsiteConfig.deepCloneSection(section),
          ),
        )
        .toList();

    final originalVisualPayload = {
      'fontFamily': widget.config.visual?.fontFamily ?? '',
      'logoUrl': widget.config.visual?.logoUrl ?? '',
    };
    final originalLogoUrl = originalVisualPayload['logoUrl'] as String;

    for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
      final section = sections[sectionIndex];
      if (section['type'] != WebsiteConfig.typeShowcase) continue;

      final sectionId = section['id']?.toString();
      if (sectionId == null) continue;

      final pending = _pendingShowcaseImages[sectionId];
      if (pending == null || pending.isEmpty) continue;

      final config = Map<String, dynamic>.from(section['config'] ?? {});
      final tabs = (config['tabs'] as List? ?? [])
          .map((tab) => Map<String, dynamic>.from(tab ?? {}))
          .toList();

      for (final entry in pending.entries) {
        final tabIndex = entry.key;
        final image = entry.value;
        if (image == null || tabIndex >= tabs.length) continue;

        final bytes = await _readImageBytes(image);
        if (bytes == null) continue;

        await bloc.updateConfigSection(
          organizationId: widget.organizationId,
          section: 'visual',
          sectionData: Map<String, dynamic>.from(originalVisualPayload),
          logoBytes: bytes,
          logoName: image.xFile?.name ?? 'showcase_${sectionId}_$tabIndex.png',
        );

        final uploadedUrl = _readVisualLogoUrl(bloc);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          tabs[tabIndex]['imageUrl'] = uploadedUrl;
        }

        if (uploadedUrl != null && uploadedUrl != originalLogoUrl) {
          await bloc.updateConfigSection(
            organizationId: widget.organizationId,
            section: 'visual',
            sectionData: Map<String, dynamic>.from(originalVisualPayload),
          );
        }
      }

      config['tabs'] = tabs;
      section['config'] = config;
      sections[sectionIndex] = section;
      _pendingShowcaseImages.remove(sectionId);
    }

    final websiteData = Map<String, dynamic>.from(widget.config.website ?? {});
    websiteData[WebsiteConfig.keySections] = sections;

    await bloc.updateConfigSection(
      organizationId: widget.organizationId,
      section: "website",
      sectionData: websiteData,
    );

    if (!mounted) return;
    setState(() {
      _sections = sections;
      _isEditing = false;
    });
  }

  Future<Uint8List?> _readImageBytes(ImageFileModel image) async {
    if (image.bytes != null) return image.bytes;
    if (image.file != null) return image.file!.readAsBytes();
    return null;
  }

  String? _readVisualLogoUrl(AdminOrganizationConfigBloc bloc) {
    final model = bloc.state.itemState.maybeWhen(
      success: (config) => config,
      orElse: () => null,
    );
    return model?.visual?.logoUrl;
  }

  void _onShowcaseImageChanged(
    String sectionId,
    int tabIndex,
    ImageFileModel? image,
  ) {
    setState(() {
      final sectionImages =
          _pendingShowcaseImages.putIfAbsent(sectionId, () => {});
      if (image == null || !image.hasImage) {
        sectionImages.remove(tabIndex);
        if (sectionImages.isEmpty) {
          _pendingShowcaseImages.remove(sectionId);
        }
      } else {
        sectionImages[tabIndex] = image;
      }
    });
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
    websiteData[WebsiteConfig.keyShowStoreCategoriesInFooter] =
        _showStoreCategoriesInFooter;
    websiteData[WebsiteConfig.keyShowBlogCategoriesInFooter] =
        _showBlogCategoriesInFooter;
    websiteData[WebsiteConfig.keyFooterLayout] = _footerLayout;
    websiteData[WebsiteConfig.keyFooterTheme] = _footerTheme;

    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "website",
      sectionData: websiteData,
    );
    setState(() => _isEditingFooter = false);
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
    setState(() => _isEditingSocial = false);
  }

  Future<void> _saveOrderSettings() async {
    final websiteData = Map<String, dynamic>.from(widget.config.website ?? {});
    websiteData[WebsiteConfig.keyOrderSettings] = _orderSettings;

    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
      organizationId: widget.organizationId,
      section: "website",
      sectionData: websiteData,
    );
    setState(() => _isEditingOrderSettings = false);
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
        "type": WebsiteConfig.typeBlogPosts,
        "displayMode": WebsiteConfig.modeGrid,
        "title": "قسم مقالات جديد",
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

  Widget _buildTopActionBar(Color primaryColor) {
    final isEditingAny = _isGlobalEditing;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: widget.isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isEditingAny
              ? primaryColor.withOpacity(0.5)
              : (widget.isDark ? Colors.white10 : Colors.grey.shade200),
          width: isEditingAny ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.web_rounded, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "تهيئة وإعدادات الموقع الإلكتروني",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "يمكنك استخدام أزرار التعديل والحفظ المباشرة داخل كل قسم أدناه",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTopActionBar(primaryColor),
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
                                  : () =>
                                        setState(() => _isEditingHeader = true),
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
                            // ⚠️ Temporarily hidden: Store & Hybrid modes disabled for now (Blog mode only)
                            // ButtonSegment(
                            //   value: WebsiteConfig.appModeHybrid,
                            //   label: Text("🔀 الهجين"),
                            //   icon: Icon(Icons.join_full, size: 16),
                            // ),
                            // ButtonSegment(
                            //   value: WebsiteConfig.appModeStore,
                            //   label: Text("🛍️ متجر فقط"),
                            //   icon: Icon(Icons.storefront_outlined, size: 16),
                            // ),
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
                                () => _logoStyle = WebsiteConfig.logoStyleSolid,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _LogoStyleChip(
                              label: "تدرج (Gradient)",
                              icon: Icons.gradient,
                              value: WebsiteConfig.logoStyleGradient,
                              selected:
                                  _logoStyle == WebsiteConfig.logoStyleGradient,
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
                                    final item = _navbarOrder.removeAt(oldIdx);
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
                                backgroundColor: primaryColor.withOpacity(0.15),
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

                        const Divider(height: 28),

                        // ── روابط الملاحة الزائدة ─────────────────────────
                        const Text(
                          "عرض الروابط الزائدة في النافبار (Excess Links)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "كيف يتم عرض الروابط المخصصة الإضافية على الشاشات الكبيرة؟",
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
                              value: WebsiteConfig.excessLinksDropdown,
                              label: Text("قائمة منسدلة (More)"),
                              icon: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                size: 16,
                              ),
                            ),
                            ButtonSegment(
                              value: WebsiteConfig.excessLinksSidebar,
                              label: Text("القائمة الجانبية فقط"),
                              icon: Icon(Icons.menu_open, size: 16),
                            ),
                          ],
                          selected: {_excessLinksMode},
                          onSelectionChanged: _isEditingHeader
                              ? (val) =>
                                    setState(() => _excessLinksMode = val.first)
                              : null,
                        ),

                        const Divider(height: 28),

                        // ── عرض أقسام التصنيفات في الهيدر ───────────────────
                        const Text(
                          "عرض التصنيفات في الهيدر (Navbar Categories)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            "عرض تصنيفات المتجر",
                            style: TextStyle(fontSize: 13),
                          ),
                          subtitle: const Text(
                            "إظهار قائمة منسدلة بأقسام المنتجات في الهيدر",
                            style: TextStyle(fontSize: 11),
                          ),
                          value: _showStoreCategoriesInNavbar,
                          activeColor: primaryColor,
                          onChanged: _isEditingHeader
                              ? (val) => setState(
                                  () => _showStoreCategoriesInNavbar = val,
                                )
                              : null,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            "عرض تصنيفات المدونة",
                            style: TextStyle(fontSize: 13),
                          ),
                          subtitle: const Text(
                            "إظهار قائمة منسدلة بأقسام المقالات في الهيدر",
                            style: TextStyle(fontSize: 11),
                          ),
                          value: _showBlogCategoriesInNavbar,
                          activeColor: primaryColor,
                          onChanged: _isEditingHeader
                              ? (val) => setState(
                                  () => _showBlogCategoriesInNavbar = val,
                                )
                              : null,
                        ),
                        const Divider(height: 28),
                        const Text(
                          "تخطيط ومظهر الهيدر (Navbar Style)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── ثبات الـ Navbar (Sticky) ──────────────────────
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: Icon(
                            _navbarSticky ? Icons.push_pin : Icons.swipe_down,
                            color: _navbarSticky ? primaryColor : Colors.grey,
                          ),
                          title: const Text(
                            "الهيدر ثابت فوق الصفحة (Sticky Navbar)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _navbarSticky
                                ? "الهيدر مثبّت في الأعلى ولا يُسحب مع التمرير — طبقة مستقلة"
                                : "الهيدر يتحرك مع الصفحة عند التمرير للأسفل",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          value: _navbarSticky,
                          activeColor: primaryColor,
                          onChanged: _isEditingHeader
                              ? (val) => setState(() => _navbarSticky = val)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        _buildDropdownField(
                          label: "شكل الهيدر (Navbar Layout)",
                          value: _navbarLayout,
                          options: Map.fromEntries(
                            WebsiteConfig.navbarLayoutOptions.map(
                              (layout) => MapEntry(
                                layout,
                                WebsiteConfig.layoutLabels[layout] ?? layout,
                              ),
                            ),
                          ),
                          isEditing: _isEditingHeader,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _navbarLayout = val);
                            }
                          },
                        ),
                        _buildDropdownField(
                          label: "ألوان الهيدر (Navbar Theme)",
                          value: _navbarTheme,
                          options: Map.fromEntries(
                            WebsiteConfig.navbarThemeOptions.map(
                              (theme) => MapEntry(
                                theme,
                                WebsiteConfig.themeLabels[theme] ?? theme,
                              ),
                            ),
                          ),
                          isEditing: _isEditingHeader,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _navbarTheme = val);
                            }
                          },
                        ),
                        if (_navbarTheme == 'custom') ...[
                          const SizedBox(height: 12),
                          const Text(
                            "لون خلفية بار الهيدر المخصص (Custom Navbar Background)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          IntroBackgroundColorPicker(
                            backgroundType: 'solid',
                            customBg: _customNavbarBg,
                            isEditing: _isEditingHeader,
                            palette: IntroThemePalette.fromOrganizationConfig(widget.config),
                            onChanged: (v) => setState(() => _customNavbarBg = v),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "لون نصوص وعناوين الهيدر المخصص (Custom Navbar Text / Title Color)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          IntroTextColorPicker(
                            textColor: _customNavbarTextColor,
                            isEditing: _isEditingHeader,
                            palette: IntroThemePalette.fromOrganizationConfig(widget.config),
                            onChanged: (v) => setState(() => _customNavbarTextColor = v),
                          ),
                        ],
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
              trailing: TextButton.icon(
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  size: 18,
                  color: _isEditing ? Colors.green : primaryColor,
                ),
                label: Text(
                  _isEditing ? "حفظ" : "تعديل",
                  style: TextStyle(
                    color: _isEditing ? Colors.green : primaryColor,
                  ),
                ),
                onPressed: _isEditing
                    ? _saveConfig
                    : () => setState(() => _isEditing = true),
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
                            if (_isEditing)
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.blue,
                                ),
                                onPressed: _addSection,
                                tooltip: "إضافة قسم جديد",
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
                            final sectionId = section['id']?.toString() ?? '';
                            return WebsiteSectionCard(
                              key: ValueKey(section['id']),
                              index: index,
                              section: section,
                              isEditing: _isEditing,
                              isDark: widget.isDark,
                              primaryColor: primaryColor,
                              appMode: _appMode,
                              organizationConfig: widget.config,
                              onRemove: () => _removeSection(index),
                              pendingShowcaseImages: section['type'] ==
                                      WebsiteConfig.typeShowcase
                                  ? _pendingShowcaseImages[sectionId]
                                  : null,
                              onShowcaseImageChanged: section['type'] ==
                                      WebsiteConfig.typeShowcase
                                  ? (tabIndex, image) => _onShowcaseImageChanged(
                                        sectionId,
                                        tabIndex,
                                        image,
                                      )
                                  : null,
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

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: widget.isDark ? DarkColors.surface : Colors.white,
            child: ExpansionTile(
              initiallyExpanded: false,
              leading: Icon(Icons.shopping_bag_outlined, color: primaryColor),
              title: const Text(
                "   إعدادات الطلبات (Order Settings)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: TextButton.icon(
                icon: Icon(
                  _isEditingOrderSettings ? Icons.save : Icons.edit,
                  size: 18,
                  color: _isEditingOrderSettings ? Colors.green : primaryColor,
                ),
                label: Text(
                  _isEditingOrderSettings ? "حفظ" : "تعديل",
                  style: TextStyle(
                    color: _isEditingOrderSettings
                        ? Colors.green
                        : primaryColor,
                  ),
                ),
                onPressed: _isEditingOrderSettings
                    ? _saveOrderSettings
                    : () => setState(() => _isEditingOrderSettings = true),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: OrderSettingsCard(
                    orderSettings: _orderSettings,
                    isEditing: _isEditingOrderSettings,
                    isDark: widget.isDark,
                    primaryColor: primaryColor,
                    organizationId: widget.organizationId,
                    onSettingsChanged: (newSettings) {
                      setState(() {
                        _orderSettings = newSettings;
                      });
                    },
                  ),
                ),
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
                leading: Icon(Icons.vertical_align_bottom, color: primaryColor),
                title: const Text("إعدادات التذييل (Footer)"),
                trailing: TextButton.icon(
                  icon: Icon(
                    _isEditingFooter ? Icons.save : Icons.edit,
                    size: 18,
                    color: _isEditingFooter ? Colors.green : primaryColor,
                  ),
                  label: Text(
                    _isEditingFooter ? "حفظ" : "تعديل",
                    style: TextStyle(
                      color: _isEditingFooter ? Colors.green : primaryColor,
                    ),
                  ),
                  onPressed: _isEditingFooter
                      ? _saveFooter
                      : () => setState(() => _isEditingFooter = true),
                ),
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
                            const Divider(height: 24),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                "عرض تصنيفات المتجر في الفوتر",
                                style: TextStyle(fontSize: 13),
                              ),
                              value: _showStoreCategoriesInFooter,
                              activeColor: primaryColor,
                              onChanged: _isEditingFooter
                                  ? (val) => setState(
                                      () => _showStoreCategoriesInFooter = val,
                                    )
                                  : null,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                "عرض تصنيفات المدونة في الفوتر",
                                style: TextStyle(fontSize: 13),
                              ),
                              value: _showBlogCategoriesInFooter,
                              activeColor: primaryColor,
                              onChanged: _isEditingFooter
                                  ? (val) => setState(
                                      () => _showBlogCategoriesInFooter = val,
                                    )
                                  : null,
                            ),
                            const Divider(height: 24),
                            _buildDropdownField(
                              label: "شكل الفوتر (Footer Layout)",
                              value: _footerLayout,
                              options: Map.fromEntries(
                                WebsiteConfig.footerLayoutOptions.map(
                                  (layout) => MapEntry(
                                    layout,
                                    WebsiteConfig.layoutLabels[layout] ??
                                        layout,
                                  ),
                                ),
                              ),
                              isEditing: _isEditingFooter,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _footerLayout = val);
                                }
                              },
                            ),
                            _buildDropdownField(
                              label: "ألوان الفوتر (Footer Theme)",
                              value: _footerTheme,
                              options: Map.fromEntries(
                                WebsiteConfig.footerThemeOptions.map(
                                  (theme) => MapEntry(
                                    theme,
                                    WebsiteConfig.themeLabels[theme] ?? theme,
                                  ),
                                ),
                              ),
                              isEditing: _isEditingFooter,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _footerTheme = val);
                                }
                              },
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
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: isEditing
          ? DropdownButtonFormField<String>(
              value: options.containsKey(value) ? value : options.keys.first,
              items: options.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
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
                options[value] ?? value,
                style: const TextStyle(fontWeight: FontWeight.w500),
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
