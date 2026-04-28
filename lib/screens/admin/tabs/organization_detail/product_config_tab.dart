import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_unit.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_config_model.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';

class ProductConfigSectionTab extends StatefulWidget {
  final OrganizationConfig config;
  final String organizationId;
  final bool isDark;

  const ProductConfigSectionTab({
    super.key,
    required this.config,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<ProductConfigSectionTab> createState() =>
      _ProductConfigSectionTabState();
}

class _ProductConfigSectionTabState extends State<ProductConfigSectionTab> {
  bool _isEditing = false;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ProductConfigSectionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _loadData();
    }
  }

  void _loadData() {
    final defaultValues = ProductInputConfig.defaultValues;
    final existingData = widget.config.productInput;

    if (existingData != null && existingData is Map) {
      setState(() {
        _data = {...defaultValues, ...Map<String, dynamic>.from(existingData)};
      });
    } else {
      setState(() {
        _data = Map<String, dynamic>.from(defaultValues);
      });
    }
  }

  void _updateField(String key, dynamic value) {
    setState(() {
      _data[key] = value;

      // 🚀 Side Effects: If image is required, we MUST show images
      if (key == ProductInputConfig.keyProductImageIsRequired &&
          value == true) {
        _data[ProductInputConfig.keyShowImages] = true;
      }
    });
  }

  Future<void> _saveConfig() async {
    context.read<AdminOrganizationConfigBloc>().updateConfigSection(
          organizationId: widget.organizationId,
          section: "productInput",
          sectionData: _data,
        );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "إعدادات إدخال البيانات للفرع",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isEditing
                    ? _saveConfig
                    : () => setState(() => _isEditing = true),
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                label: Text(_isEditing ? "حفظ التغييرات" : "تعديل"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing ? Colors.green : primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroupCard(
            title: "خيارات العرض (UI Visibility)",
            icon: Icons.visibility_outlined,
            children: [
              _buildSwitch(
                "عرض الصور",
                ProductInputConfig.keyShowImages,
                defaultValue: true,
                subtitle: "إظهار أو إخفاء قسم الصور في واجهة المنتج",
                enabled: !(_data[ProductInputConfig.keyProductImageIsRequired] ??
                    false),
              ),
              _buildSwitch(
                "عرض الوصف المختصر",
                ProductInputConfig.keyShowDescription,
                defaultValue: true,
                subtitle: "عرض حقل الوصف المختصر للمنتج",
              ),
              _buildSwitch(
                "عرض الوصف التفصيلي",
                ProductInputConfig.keyShowDetailedDescription,
                subtitle: "إظهار حقل الوصف المطول الذي يدعم تفاصيل أكثر",
              ),
              _buildSwitch(
                "عرض كيفية الاستخدام",
                ProductInputConfig.keyShowUsage,
                subtitle: "إضافة قسم لشرح كيفية استخدام المنتج للمستهلك",
              ),
              _buildSwitch(
                "عرض الفوائد",
                ProductInputConfig.keyShowBenefits,
                defaultValue: true,
                subtitle: "عرض قائمة بفوائد المنتج المميزة",
              ),
              _buildSwitch(
                "عرض المكونات",
                ProductInputConfig.keyShowIngredients,
                subtitle: "إظهار قائمة مكونات المنتج (مفيد للمنتجات الغذائية)",
              ),
            ],
          ),
          _buildGroupCard(
            title: "الحالات والعلامات (Tags & Status)",
            icon: Icons.tag_outlined,
            children: [
              _buildSwitch(
                "عرض 'جديد'",
                ProductInputConfig.keyShowIsNew,
                defaultValue: true,
                subtitle: "إظهار علامة 'جديد' على المنتجات المضافة حديثاً",
              ),
              _buildSwitch(
                "عرض 'الأكثر مبيعاً'",
                ProductInputConfig.keyShowIsBestSeller,
                defaultValue: true,
                subtitle: "تمييز المنتجات الأكثر طلباً في الواجهة",
              ),
              _buildSwitch(
                "عرض 'في العرض'",
                ProductInputConfig.keyShowIsOnSale,
                subtitle: "إضافة ملصق 'Sale' أو 'عروض' للمنتج",
              ),
              _buildSwitch(
                "عرض 'جوكر'",
                ProductInputConfig.keyShowIsJoker,
                defaultValue: true,
                subtitle: "علامة تمييز خاصة (Joker)",
              ),
              _buildSwitch(
                "عرض 'سوبر جوكر'",
                ProductInputConfig.keyShowIsSuperJoker,
                subtitle: "علامة تمييز ممتازة (Super Joker)",
              ),
            ],
          ),
          _buildGroupCard(
            title: "التسعير والوحدات (Pricing & Units)",
            icon: Icons.payments_outlined,
            children: [
              _buildSwitch(
                "تفعيل الخصم",
                ProductInputConfig.keyShowDiscount,
                defaultValue: true,
                subtitle: "السماح بإضافة نسبة خصم تظهر بجانب السعر الحالي",
              ),
              _buildSwitch(
                "تفعيل التسعير المتعدد الأحجام",
                ProductInputConfig.keyEnableMultiSizePricing,
                defaultValue: true,
                subtitle:
                    "يسمح بإضافة أكثر من حجم وسعر لنفس المنتج (مثال: 50مل، 100مل)",
              ),
              _buildSwitch(
                "الافتراضي هو سعر واحد",
                ProductInputConfig.keyDefaultToSinglePrice,
                subtitle:
                    "عند تفعيل 'التسعير المتعدد'، اجعل خيار السعر الواحد هو المختار افتراضياً",
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "الوحدات المتاحة:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 8,
                children: ProductUnit.values.map((unit) {
                  final allowedUnits = List<String>.from(
                    _data[ProductInputConfig.keyAllowedUnits] ?? [],
                  );
                  final isSelected = allowedUnits.contains(unit.name);
                  return FilterChip(
                    label: Text(unit.nameAr),
                    selected: isSelected,
                    onSelected: (val) {
                      if (_isEditing) {
                        if (val) {
                          allowedUnits.add(unit.name);
                        } else {
                          allowedUnits.remove(unit.name);
                        }
                        _updateField(
                            ProductInputConfig.keyAllowedUnits, allowedUnits);
                      }
                    },
                    selectedColor: _isEditing
                        ? primaryColor
                        : primaryColor.withOpacity(0.7),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (widget.isDark ? Colors.white70 : Colors.black87),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          _buildGroupCard(
            title: "العمليات والإضافة (Operations)",
            icon: Icons.add_business_outlined,
            children: [
              _buildSwitch(
                "تفعيل إضافة المنتجات",
                ProductInputConfig.keyEnableAddProduct,
                defaultValue: true,
                subtitle: "السماح بإضافة منتجات جديدة من خلال لوحة التحكم",
              ),
              _buildSwitch(
                "إظهار زر الإضافة السريع (منتجات)",
                ProductInputConfig.keyShowAddProductInGrid,
                subtitle:
                    "إظهار مربع 'إضافة جديد' مباشرة داخل شبكة عرض المنتجات",
                enabled:
                    _data[ProductInputConfig.keyEnableAddProduct] ?? true,
              ),
              _buildSwitch(
                "تفعيل إضافة التصنيفات",
                ProductInputConfig.keyEnableAddCategory,
                defaultValue: true,
                subtitle: "السماح بإدارة وإضافة فئات جديدة",
              ),
              _buildSwitch(
                "إظهار زر الإضافة السريع (تصنيفات)",
                ProductInputConfig.keyShowAddCategoryInGrid,
                subtitle: "إظهار مربع 'إضافة جديد' داخل شبكة عرض الفئات",
                enabled:
                    _data[ProductInputConfig.keyEnableAddCategory] ?? true,
              ),
              _buildSwitch(
                "تفعيل إضافة العروض",
                ProductInputConfig.keyEnableAddOffer,
                defaultValue: true,
                subtitle: "السماح بإضافة عروض ترويجية",
              ),
              _buildSwitch(
                "إظهار زر الإضافة السريع (عرض)",
                ProductInputConfig.keyShowAddOfferInGrid,
                subtitle: "إظهار مربع الإضافة داخل شبكة العروض",
                enabled: _data[ProductInputConfig.keyEnableAddOffer] ?? true,
              ),
              _buildSwitch(
                "تفعيل الإضافة السريعة (مود الـ Turbo)",
                ProductInputConfig.keyEnableQuickAdd,
                defaultValue: true,
                subtitle:
                    "تبسيط واجهة الإضافة بإخفاء الحقول غير الضرورية لإنجاز الإدخال بسرعة",
              ),
              _buildSwitch(
                "تعديل السعر السريع",
                ProductInputConfig.keyShowChangePriceInPopup,
                defaultValue: true,
                subtitle:
                    "إظهار خيار تعديل السعر المباشر في القائمة المنبثقة للمنتج",
              ),
              _buildSwitch(
                "حذف المنتج في القائمة",
                ProductInputConfig.keyShowDeleteInPopup,
                defaultValue: true,
                subtitle: "إظهار خيار الحذف السريع في القائمة المنبثقة",
              ),
              _buildSwitch(
                "محرّر النصوص المتقدم (Rich Text)",
                ProductInputConfig.keyEnableRichTextEditor,
                subtitle:
                    "توفير أدوات تنسيق نصوص (Bold, Lists) للوصف التفصيلي",
              ),
            ],
          ),
          _buildGroupCard(
            title: "إعدادات الصور (Image Config)",
            icon: Icons.image_outlined,
            children: [
              _buildImageConfigSection(
                  "صور المنتجات",
                  ProductInputConfig.keyProductImageIsRequired.split('_')[0]),
              const Divider(),
              _buildImageConfigSection(
                  "صور التصنيفات",
                  ProductInputConfig.keyCategoryImageIsRequired.split('_')[0]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(
    String label,
    String key, {
    bool defaultValue = false,
    String? subtitle,
    bool enabled = true,
  }) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;
    final textColor = (widget.isDark ? Colors.white : Colors.black87)
        .withOpacity(enabled ? 1.0 : 0.4);
    final subColor = (widget.isDark ? Colors.white60 : Colors.black54)
        .withOpacity(enabled ? 1.0 : 0.4);

    return Column(
      children: [
        SwitchListTile(
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, style: TextStyle(fontSize: 12, color: subColor))
              : null,
          value: enabled ? (_data[key] ?? defaultValue) : false,
          onChanged: (_isEditing && enabled)
              ? (val) => _updateField(key, val)
              : null,
          activeColor: primaryColor,
          dense: false,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildImageConfigSection(String title, String groupPrefix) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: primaryColor,
          ),
        ),
        _buildSwitch(
          "الصورة مطلوبة",
          "${groupPrefix}_isRequired",
          subtitle: "جعل رفع الصورة شرطاً أساسياً لحفظ المنتج",
        ),
        _buildSwitch(
          "فرض نسبة العرض للارتفاع",
          "${groupPrefix}_enforceRatio",
          defaultValue: true,
          subtitle: "إجبار المستخدم على قص الصورة لتناسب الأبعاد المذكورة",
        ),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput(
                "الارتفاع",
                "${groupPrefix}_height",
                _data["${groupPrefix}_height"] ?? 200,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNumberInput(
                "العرض",
                "${groupPrefix}_width",
                _data["${groupPrefix}_width"] ?? 200,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNumberInput(
                "الحد الأقصى (MB)",
                "${groupPrefix}_maxSizeMB",
                _data["${groupPrefix}_maxSizeMB"] ?? 5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberInput(String label, String key, dynamic value) {
    return TextFormField(
      initialValue: value.toString(),
      key: ValueKey("${key}_${_isEditing}"),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: widget.isDark ? Colors.white70 : Colors.black54,
        ),
        isDense: true,
        border: const OutlineInputBorder(),
        filled: !_isEditing,
        fillColor: _isEditing
            ? null
            : (widget.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05)),
      ),
      keyboardType: TextInputType.number,
      readOnly: !_isEditing,
      onChanged: (val) {
        final numVal = num.tryParse(val);
        if (numVal != null) {
          _updateField(key, numVal);
        }
      },
      style: TextStyle(
        fontSize: 13,
        color: widget.isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}
