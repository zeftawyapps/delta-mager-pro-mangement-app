import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:matger_pro_core_logic/models/localized_string.dart';
import 'package:JoDija_tamplites/util/widgits/images_widgets/image_picker_widget.dart';


/// زر مخصص لفتح مدراء الخصائص المتقدمة للمنتج
Widget buildCustomPropertyManagerButton({
  required BuildContext context,
  required String title,
  required IconData icon,
  required int count,
  required VoidCallback onPressed,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.02),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08),
      ),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: count > 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count عناصر",
              style: TextStyle(
                color: count > 0 ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
      onTap: onPressed,
    ),
  );
}

// ==========================================
// 1. مدير المتغيرات (Variants Manager Dialog)
// ==========================================
class VariantsManagerDialog extends StatefulWidget {
  final List<ProductVariant> initialVariants;
  final List<dynamic> productImages;
  const VariantsManagerDialog({
    super.key,
    required this.initialVariants,
    required this.productImages,
  });

  @override
  State<VariantsManagerDialog> createState() => _VariantsManagerDialogState();
}

class _VariantsManagerDialogState extends State<VariantsManagerDialog> {
  late List<ProductVariant> _variants;

  // الحقول لإضافة متغير جديد (مثل اللون، الحجم)
  final _newVariantArController = TextEditingController();
  final _newVariantEnController = TextEditingController();

  // خريطة لتخزين حقول إدخال الخيارات لكل متغير بناءً على الـ index
  final Map<int, TextEditingController> _optionValueArControllers = {};
  final Map<int, TextEditingController> _optionValueEnControllers = {};
  final Map<int, TextEditingController> _optionPriceControllers = {};

  @override
  void initState() {
    super.initState();
    // عمل نسخة من القائمة لتعديلها
    _variants = widget.initialVariants.map((v) {
      return ProductVariant(
        name: LocalizedString({'ar': v.name.ar, 'en': v.name.en}),
        options: v.options.map((o) {
          return VariantOption(
            value: LocalizedString({'ar': o.value.ar, 'en': o.value.en}),
            priceModifier: o.priceModifier,
            imageUrls: List<String>.from(o.imageUrls),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _newVariantArController.dispose();
    _newVariantEnController.dispose();
    for (var c in _optionValueArControllers.values) {
      c.dispose();
    }
    for (var c in _optionValueEnControllers.values) {
      c.dispose();
    }
    for (var c in _optionPriceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _addNewVariant() {
    final ar = _newVariantArController.text.trim();
    final en = _newVariantEnController.text.trim();
    if (ar.isEmpty) return;

    setState(() {
      _variants.add(
        ProductVariant(
          name: LocalizedString({'ar': ar, 'en': en.isEmpty ? ar : en}),
          options: [],
        ),
      );
      _newVariantArController.clear();
      _newVariantEnController.clear();
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
      _optionValueArControllers.remove(index)?.dispose();
      _optionValueEnControllers.remove(index)?.dispose();
      _optionPriceControllers.remove(index)?.dispose();
    });
  }

  void _addOptionToVariant(int variantIndex) {
    final arController = _optionValueArControllers.putIfAbsent(
      variantIndex,
      () => TextEditingController(),
    );
    final enController = _optionValueEnControllers.putIfAbsent(
      variantIndex,
      () => TextEditingController(),
    );
    final priceController = _optionPriceControllers.putIfAbsent(
      variantIndex,
      () => TextEditingController(),
    );

    final ar = arController.text.trim();
    final en = enController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (ar.isEmpty) return;

    setState(() {
      _variants[variantIndex].options.add(
        VariantOption(
          value: LocalizedString({'ar': ar, 'en': en.isEmpty ? ar : en}),
          priceModifier: price,
          imageUrls: [],
        ),
      );
      arController.clear();
      enController.clear();
      priceController.clear();
    });
  }

  void _removeOptionFromVariant(int variantIndex, int optionIndex) {
    setState(() {
      _variants[variantIndex].options.removeAt(optionIndex);
    });
  }

  bool _isImageSelected(VariantOption option, int index, List<dynamic> productImages) {
    final indexStr = index.toString();
    if (option.imageUrls.contains(indexStr)) return true;

    if (index < productImages.length) {
      final img = productImages[index];
      if (img is String) {
        if (option.imageUrls.contains(img)) return true;
      }
    }
    return false;
  }

  void _toggleImageSelection(int variantIndex, int optionIndex, int index, List<dynamic> productImages) {
    setState(() {
      final option = _variants[variantIndex].options[optionIndex];
      final imageUrls = List<String>.from(option.imageUrls);

      String imageRef = index.toString();
      if (index < productImages.length) {
        final img = productImages[index];
        if (img is String) {
          imageRef = img;
        }
      }

      if (imageUrls.contains(imageRef)) {
        imageUrls.remove(imageRef);
      } else {
        imageUrls.add(imageRef);
      }

      _variants[variantIndex].options[optionIndex] = VariantOption(
        value: option.value,
        priceModifier: option.priceModifier,
        imageUrls: imageUrls,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "إدارة متغيرات المنتج (Variants)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  // 1. إضافة متغير جديد
                  Card(
                    elevation: 0,
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "إضافة متغير جديد (مثل: اللون، المقاس، الخامة)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newVariantArController,
                                  decoration: const InputDecoration(
                                    labelText: "الاسم (عربي)*",
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _newVariantEnController,
                                  decoration: const InputDecoration(
                                    labelText: "الاسم (إنجليزي)",
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _addNewVariant,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("إضافة"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. قائمة المتغيرات الحالية
                  if (_variants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "لا توجد متغيرات مضافة حالياً لهذا المنتج.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  ...List.generate(_variants.length, (vIdx) {
                    final variant = _variants[vIdx];
                    final optArCtrl = _optionValueArControllers.putIfAbsent(
                      vIdx,
                      () => TextEditingController(),
                    );
                    final optEnCtrl = _optionValueEnControllers.putIfAbsent(
                      vIdx,
                      () => TextEditingController(),
                    );
                    final optPriceCtrl = _optionPriceControllers.putIfAbsent(
                      vIdx,
                      () => TextEditingController(),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${variant.name.ar} / ${variant.name.en}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeVariant(vIdx),
                                ),
                              ],
                            ),
                            const Divider(),

                            // خيارات المتغير
                            if (variant.options.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "لا توجد خيارات بعد (مثل: أحمر، أزرق). أضف خياراً أدناه:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: variant.options.length,
                                itemBuilder: (context, oIdx) {
                                  final option = variant.options[oIdx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${option.value.ar} / ${option.value.en}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              option.priceModifier >= 0
                                                  ? "+${option.priceModifier} ج.م"
                                                  : "${option.priceModifier} ج.م",
                                              style: TextStyle(
                                                color: option.priceModifier > 0
                                                    ? Colors.green
                                                    : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.redAccent,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _removeOptionFromVariant(
                                                    vIdx,
                                                    oIdx,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        if (widget.productImages.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          const Text(
                                            "ربط بالصور:",
                                            style: TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            height: 50,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: widget.productImages.length,
                                              itemBuilder: (context, imgIdx) {
                                                final img = widget.productImages[imgIdx];
                                                final isSelected = _isImageSelected(option, imgIdx, widget.productImages);

                                                Widget imageWidget;
                                                if (img is String) {
                                                  imageWidget = Image.network(
                                                    img,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, _, __) => const Icon(Icons.broken_image, size: 20),
                                                  );
                                                } else if (img is ImageFileModel && img.bytes != null) {
                                                  imageWidget = Image.memory(
                                                    img.bytes!,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  );
                                                } else {
                                                  imageWidget = const Icon(Icons.image, size: 20);
                                                }

                                                return GestureDetector(
                                                  onTap: () => _toggleImageSelection(vIdx, oIdx, imgIdx, widget.productImages),
                                                  child: Container(
                                                    margin: const EdgeInsets.only(left: 8),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? Theme.of(context).primaryColor
                                                            : Colors.transparent,
                                                        width: 2,
                                                      ),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(2),
                                                          child: imageWidget,
                                                        ),
                                                        if (isSelected)
                                                          Positioned(
                                                            right: 0,
                                                            bottom: 0,
                                                            child: Container(
                                                              color: Theme.of(context).primaryColor,
                                                              child: const Icon(
                                                                Icons.check,
                                                                color: Colors.white,
                                                                size: 10,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 8),
                            // إضافة خيار للمتغير الحالي
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: optArCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "الخيار بالعربي*",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: optEnCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "بالإنجليزي",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: optPriceCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "تعديل السعر",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_box,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => _addOptionToVariant(vIdx),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _variants);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("حفظ وتأكيد"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. مدير الإضافات (Addons Manager Dialog)
// ==========================================
class AddonsManagerDialog extends StatefulWidget {
  final List<ProductAddonGroup> initialAddons;
  const AddonsManagerDialog({super.key, required this.initialAddons});

  @override
  State<AddonsManagerDialog> createState() => _AddonsManagerDialogState();
}

class _AddonsManagerDialogState extends State<AddonsManagerDialog> {
  late List<ProductAddonGroup> _addons;

  final _newGroupNameArController = TextEditingController();
  final _newGroupNameEnController = TextEditingController();

  final Map<int, TextEditingController> _optionNameArControllers = {};
  final Map<int, TextEditingController> _optionNameEnControllers = {};
  final Map<int, TextEditingController> _optionPriceControllers = {};

  @override
  void initState() {
    super.initState();
    _addons = widget.initialAddons.map((g) {
      return ProductAddonGroup(
        name: LocalizedString({'ar': g.name.ar, 'en': g.name.en}),
        isMultiSelect: g.isMultiSelect,
        isRequired: g.isRequired,
        options: g.options.map((o) {
          return ProductAddonOption(
            addonId: o.addonId,
            name: LocalizedString({'ar': o.name.ar, 'en': o.name.en}),
            price: o.price,
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _newGroupNameArController.dispose();
    _newGroupNameEnController.dispose();
    for (var c in _optionNameArControllers.values) c.dispose();
    for (var c in _optionNameEnControllers.values) c.dispose();
    for (var c in _optionPriceControllers.values) c.dispose();
    super.dispose();
  }

  void _addNewGroup() {
    final ar = _newGroupNameArController.text.trim();
    final en = _newGroupNameEnController.text.trim();
    if (ar.isEmpty) return;

    setState(() {
      _addons.add(
        ProductAddonGroup(
          name: LocalizedString({'ar': ar, 'en': en.isEmpty ? ar : en}),
          isMultiSelect: true,
          isRequired: false,
          options: [],
        ),
      );
      _newGroupNameArController.clear();
      _newGroupNameEnController.clear();
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _addons.removeAt(index);
      _optionNameArControllers.remove(index)?.dispose();
      _optionNameEnControllers.remove(index)?.dispose();
      _optionPriceControllers.remove(index)?.dispose();
    });
  }

  void _addOptionToGroup(int groupIndex) {
    final arCtrl = _optionNameArControllers.putIfAbsent(
      groupIndex,
      () => TextEditingController(),
    );
    final enCtrl = _optionNameEnControllers.putIfAbsent(
      groupIndex,
      () => TextEditingController(),
    );
    final priceCtrl = _optionPriceControllers.putIfAbsent(
      groupIndex,
      () => TextEditingController(),
    );

    final ar = arCtrl.text.trim();
    final en = enCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

    if (ar.isEmpty) return;

    setState(() {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      _addons[groupIndex].options.add(
        ProductAddonOption(
          addonId: id,
          name: LocalizedString({'ar': ar, 'en': en.isEmpty ? ar : en}),
          price: price,
        ),
      );
      arCtrl.clear();
      enCtrl.clear();
      priceCtrl.clear();
    });
  }

  void _removeOptionFromGroup(int groupIndex, int optionIndex) {
    setState(() {
      _addons[groupIndex].options.removeAt(optionIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "إدارة الإضافات (Add-ons)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 0,
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "إضافة مجموعة إضافات (مثل: صوصات إضافية، قطع إضافية)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newGroupNameArController,
                                  decoration: const InputDecoration(
                                    labelText: "اسم المجموعة (عربي)*",
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _newGroupNameEnController,
                                  decoration: const InputDecoration(
                                    labelText: "الاسم (إنجليزي)",
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _addNewGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("إضافة"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (_addons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "لا توجد إضافات مضافة لهذا المنتج حالياً.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  ...List.generate(_addons.length, (gIdx) {
                    final group = _addons[gIdx];
                    final optArCtrl = _optionNameArControllers.putIfAbsent(
                      gIdx,
                      () => TextEditingController(),
                    );
                    final optEnCtrl = _optionNameEnControllers.putIfAbsent(
                      gIdx,
                      () => TextEditingController(),
                    );
                    final optPriceCtrl = _optionPriceControllers.putIfAbsent(
                      gIdx,
                      () => TextEditingController(),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${group.name.ar} (${group.name.en})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeGroup(gIdx),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text(
                                      "اختيار متعدد",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: group.isMultiSelect,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    onChanged: (val) {
                                      setState(() {
                                        _addons[gIdx] = ProductAddonGroup(
                                          name: group.name,
                                          isMultiSelect: val ?? true,
                                          isRequired: group.isRequired,
                                          options: group.options,
                                        );
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text(
                                      "إجباري",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: group.isRequired,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    onChanged: (val) {
                                      setState(() {
                                        _addons[gIdx] = ProductAddonGroup(
                                          name: group.name,
                                          isMultiSelect: group.isMultiSelect,
                                          isRequired: val ?? false,
                                          options: group.options,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),

                            if (group.options.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "لا توجد خيارات بعد. أضف خياراً أدناه:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: group.options.length,
                                itemBuilder: (context, oIdx) {
                                  final option = group.options[oIdx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${option.name.ar} / ${option.name.en}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "+${option.price} ج.م",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                          onPressed: () =>
                                              _removeOptionFromGroup(
                                                gIdx,
                                                oIdx,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: optArCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "اسم الإضافة*",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: optEnCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "بالإنجليزي",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: optPriceCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "سعر الإضافة",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_box,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => _addOptionToGroup(gIdx),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _addons);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("حفظ وتأكيد"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. مدير الخيارات المخصصة (Options Manager Dialog)
// ==========================================
class OptionsManagerDialog extends StatefulWidget {
  final List<ProductCustomOptionGroup> initialOptions;
  const OptionsManagerDialog({super.key, required this.initialOptions});

  @override
  State<OptionsManagerDialog> createState() => _OptionsManagerDialogState();
}

class _OptionsManagerDialogState extends State<OptionsManagerDialog> {
  late List<ProductCustomOptionGroup> _options;

  final _newGroupNameArController = TextEditingController();
  final _newGroupNameEnController = TextEditingController();

  final Map<int, TextEditingController> _optionNameArControllers = {};
  final Map<int, TextEditingController> _optionNameEnControllers = {};
  final Map<int, TextEditingController> _optionPriceControllers = {};

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions.map((g) {
      return ProductCustomOptionGroup(
        name: LocalizedString({'ar': g.name.ar, 'en': g.name.en}),
        isRequired: g.isRequired,
        options: g.options.map((o) {
          return ProductCustomOption(
            name: LocalizedString({'ar': o.name.ar, 'en': o.name.en}),
            priceModifier: o.priceModifier,
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _newGroupNameArController.dispose();
    _newGroupNameEnController.dispose();
    for (var c in _optionNameArControllers.values) c.dispose();
    for (var c in _optionNameEnControllers.values) c.dispose();
    for (var c in _optionPriceControllers.values) c.dispose();
    super.dispose();
  }

  void _addNewGroup() {
    final ar = _newGroupNameArController.text.trim();
    final en = _newGroupNameEnController.text.trim();
    if (ar.isEmpty) return;

    setState(() {
      _options.add(
        ProductCustomOptionGroup(
          name: LocalizedString({'ar': ar, 'en': en.isEmpty ? ar : en}),
          isRequired: false,
          options: [],
        ),
      );
      _newGroupNameArController.clear();
      _newGroupNameEnController.clear();
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _options.removeAt(index);
      _optionNameArControllers.remove(index)?.dispose();
      _optionNameEnControllers.remove(index)?.dispose();
      _optionPriceControllers.remove(index)?.dispose();
    });
  }

  void _addOptionToGroup(int groupIndex) {
    final arCtrl = _optionNameArControllers.putIfAbsent(
      groupIndex,
      () => TextEditingController(),
    );
    final enCtrl = _optionNameEnControllers.putIfAbsent(
      groupIndex,
      () => TextEditingController(),
    );
    final priceCtrl = _optionPriceControllers.putIfAbsent(
      groupIndex,
      () => TextEditingController(),
    );

    final ar = arCtrl.text.trim();
    final en = enCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

    if (ar.isEmpty) return;

    setState(() {
      _options[groupIndex].options.add(
        ProductCustomOption(
          name: LocalizedString({'ar': ar, 'en': en.isEmpty ? ar : en}),
          priceModifier: price,
        ),
      );
      arCtrl.clear();
      enCtrl.clear();
      priceCtrl.clear();
    });
  }

  void _removeOptionFromGroup(int groupIndex, int optionIndex) {
    setState(() {
      _options[groupIndex].options.removeAt(optionIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "إدارة الخيارات المخصصة (Options)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 0,
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "إضافة مجموعة خيارات (مثل: درجة الطهي، مستوى الحار)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newGroupNameArController,
                                  decoration: const InputDecoration(
                                    labelText: "اسم المجموعة (عربي)*",
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _newGroupNameEnController,
                                  decoration: const InputDecoration(
                                    labelText: "الاسم (إنجليزي)",
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _addNewGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("إضافة"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (_options.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "لا توجد خيارات مخصصة مضافة لهذا المنتج حالياً.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  ...List.generate(_options.length, (gIdx) {
                    final group = _options[gIdx];
                    final optArCtrl = _optionNameArControllers.putIfAbsent(
                      gIdx,
                      () => TextEditingController(),
                    );
                    final optEnCtrl = _optionNameEnControllers.putIfAbsent(
                      gIdx,
                      () => TextEditingController(),
                    );
                    final optPriceCtrl = _optionPriceControllers.putIfAbsent(
                      gIdx,
                      () => TextEditingController(),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${group.name.ar} (${group.name.en})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeGroup(gIdx),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "إجباري في الطلب",
                                style: TextStyle(fontSize: 12),
                              ),
                              value: group.isRequired,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              onChanged: (val) {
                                setState(() {
                                  _options[gIdx] = ProductCustomOptionGroup(
                                    name: group.name,
                                    isRequired: val ?? false,
                                    options: group.options,
                                  );
                                });
                              },
                            ),
                            const Divider(),

                            if (group.options.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "لا توجد خيارات بعد. أضف خياراً أدناه:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: group.options.length,
                                itemBuilder: (context, oIdx) {
                                  final option = group.options[oIdx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${option.name.ar} / ${option.name.en}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          option.priceModifier >= 0
                                              ? "+${option.priceModifier} ج.م"
                                              : "${option.priceModifier} ج.م",
                                          style: TextStyle(
                                            color: option.priceModifier > 0
                                                ? Colors.green
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                          onPressed: () =>
                                              _removeOptionFromGroup(
                                                gIdx,
                                                oIdx,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: optArCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "الاسم بالعربي*",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: optEnCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "بالإنجليزي",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: optPriceCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "تعديل السعر",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_box,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => _addOptionToGroup(gIdx),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _options);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("حفظ وتأكيد"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
