import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';

class WebsiteFooterTab extends StatefulWidget {
  final OrganizationConfig config;
  final String organizationId;
  final bool isDark;

  const WebsiteFooterTab({
    super.key,
    required this.config,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<WebsiteFooterTab> createState() => _WebsiteFooterTabState();
}

class _WebsiteFooterTabState extends State<WebsiteFooterTab> {
  bool _isEditingFooter = false;
  bool _isEditingSocial = false;

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
    final footer = widget.config.website?['footer'] ?? {};
    final social = widget.config.website?['socialMedia'] ?? {};

    _descriptionController = TextEditingController(text: footer['description'] ?? '');
    _addressController = TextEditingController(text: footer['address'] ?? '');
    _phoneController = TextEditingController(text: footer['phone'] ?? '');
    _emailController = TextEditingController(text: footer['email'] ?? '');
    _trustBadgeController = TextEditingController(text: footer['trustBadge'] ?? '');
    _copyrightController = TextEditingController(text: footer['copyright'] ?? '');

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

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: "إعدادات تذييل الصفحة (Footer)",
            icon: Icons.info_outline,
            isEditing: _isEditingFooter,
            onEditPressed: () => setState(() => _isEditingFooter = true),
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
          const SizedBox(height: 16),
          _buildFormCard(
            title: "روابط التواصل الاجتماعي (Social Media)",
            icon: Icons.share_outlined,
            isEditing: _isEditingSocial,
            onEditPressed: () => setState(() => _isEditingSocial = true),
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
}
