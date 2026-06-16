import 'dart:typed_data';
import 'package:JoDija_reposatory/constes/api_urls.dart';

import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/validators/numper_validator.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/drobdaown_validation.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:JoDija_tamplites/util/widgits/images_widgets/image_picker_widget.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart'
    hide ProductUnit, PriceOption;
import 'package:matger_pro_core_logic/features/commrec/data/product_model.dart'
    as core_m
    show PriceOption;
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_unit.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'price_options_widget.dart';
import 'product_custom_properties_widgets.dart';
import 'package:matger_pro_core_logic/utls/type_parser.dart';

class ProductInputForm extends StatefulWidget {
  final ProductModel? product;
  final String? initialCategoryId;
  final bool autoOpenImagePicker;

  ProductInputForm({
    super.key,
    this.product,
    this.initialCategoryId,
    this.autoOpenImagePicker = false,
  });

  @override
  State<ProductInputForm> createState() => _ProductInputFormState();
}

class _ProductInputFormState extends State<ProductInputForm> {
  late final TextEditingController nameArController;
  late final TextEditingController nameEnController;
  late final TextEditingController descriptionController;
  late final TextEditingController detailedDescriptionController;
  late final TextEditingController usageController;
  late final TextEditingController priceController;
  late final TextEditingController oldPriceController;
  late final TextEditingController benefitsController;
  late final TextEditingController ingredientsController;
  late final TextEditingController discountController;

  ImageFileModel? selectedImage;
  String? selectedCategoryId;
  bool isNew = false;
  bool isBestSeller = false;
  bool isOnSale = false;
  bool isJoker = false;
  bool isSuperJoker = false;
  bool isInsideOffer = false;
  bool isAvailable = true; // متاح
  bool isMultiSize = false;
  ProductUnit singlePriceUnit = ProductUnit.piece;
  late TextEditingController singlePriceQuantityController;

  // ============ نظام التسعير المتعدد ============
  List<PriceOption> priceOptions = [];
  bool _isDialogShowing = false;
  final GlobalKey _imagePickerKey = GlobalKey();
  List<dynamic> additionalImages =
      []; // Contains ImageFileModel (local) or String (network URLs)

  // ============ الخصائص الجديدة المخصصة ============
  List<ProductVariant> variants = [];
  List<ProductAddonGroup> addons = [];
  List<ProductCustomOptionGroup> options = [];

  bool isDetailedDescriptionHtml = false;
  late final QuillController _quillDetailedDescriptionController;

  @override
  void initState() {
    super.initState();

    if (widget.autoOpenImagePicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          (_imagePickerKey.currentState as dynamic)?.pickImage();
        } catch (e) {
          debugPrint("Could not auto-open image picker: $e");
        }
      });
    }
    // التأكد من اختيار وحدة متاحة افتراضياً
    final visibleUnits = ProductUnit.values.where((u) => u.isVisible).toList();
    if (visibleUnits.isNotEmpty && !visibleUnits.contains(singlePriceUnit)) {
      singlePriceUnit = visibleUnits.first;
    }

    form = ValidationsForm();
    nameArController = TextEditingController(
      text: widget.product?.name.ar ?? '',
    );
    nameEnController = TextEditingController(
      text: widget.product?.name.en ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.product?.descriptionAr ?? '',
    );

    isDetailedDescriptionHtml = widget.product?.additionalData['isDetailedDescriptionHtml'] == true ||
        widget.product?.additionalData['isDetailedDescriptionHtml']?.toString().toLowerCase() == 'true';

    final detailedDesc = widget.product?.additionalData['detailedDescription'] ?? '';
    _quillDetailedDescriptionController = _initQuillController(isDetailedDescriptionHtml ? detailedDesc : '');

    detailedDescriptionController = TextEditingController(
      text: isDetailedDescriptionHtml ? '' : detailedDesc,
    );

    usageController = TextEditingController(
      text: widget.product?.additionalData['usage'] ?? '',
    );
    priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    oldPriceController = TextEditingController(
      text: widget.product?.oldPrice?.toString() ?? '',
    );
    benefitsController = TextEditingController(
      text:
          (widget.product?.additionalData['benefits'] as List<dynamic>?)?.join(
            ', ',
          ) ??
          '',
    );
    ingredientsController = TextEditingController(
      text:
          (widget.product?.additionalData['ingredients'] as List<dynamic>?)
              ?.join(', ') ??
          '',
    );
    discountController = TextEditingController(
      text: widget.product?.discount?.toString() ?? '',
    );
    singlePriceQuantityController = TextEditingController(text: '1');

    if (widget.product != null) {
      if (widget.product!.priceOptions.isNotEmpty) {
        final first = widget.product!.priceOptions.first;
        singlePriceUnit = ProductUnit.values.firstWhere(
          (u) => u.name == first.unit,
          orElse: () => ProductUnit.piece,
        );
        singlePriceQuantityController.text = first.quantity.toString();
      }
      selectedCategoryId = widget.product!.categoryId;
      isNew = widget.product!.isNew;
      isBestSeller = widget.product!.isBestSeller;
      isOnSale = widget.product!.isOnSale;
      isJoker = widget.product!.isJoker;
      isSuperJoker = widget.product!.isSuperJoker;
      isInsideOffer = TypeParser.parseBool(
        widget.product!.additionalData['isInsideOffer'],
      );
      isAvailable = widget.product!.isAvailable;

      priceOptions = widget.product!.priceOptions
          .map(
            (e) => PriceOption(
              quantity: e.quantity,
              unit: ProductUnit.values.firstWhere(
                (u) => u.name == e.unit,
                orElse: () => ProductUnit.piece,
              ),
              price: e.price,
              oldPrice: e.oldPrice,
              isDefault: e.isDefault,
            ),
          )
          .toList();

      // تفعيل التسعير المتعدد تلقائياً إذا كان المنتج يحتوي على أكثر من سعر
      isMultiSize = widget.product!.priceOptions.length > 1;
      variants = List<ProductVariant>.from(widget.product!.variants);
      addons = List<ProductAddonGroup>.from(widget.product!.addons);
      options = List<ProductCustomOptionGroup>.from(widget.product!.options);

      if (widget.product!.images.isNotEmpty) {
        if (widget.product!.images.length > 1) {
          additionalImages = List.from(widget.product!.images.sublist(1));
        }
      }
    } else if (widget.initialCategoryId != null) {
      selectedCategoryId = widget.initialCategoryId;
    }
  }

  bool get _shouldShowImagePicker {
    return widget.autoOpenImagePicker ||
        ProductInputConfig.showImages ||
        ProductInputConfig.isProductImageRequired ||
        isNew ||
        isBestSeller ||
        isOnSale ||
        isJoker ||
        isSuperJoker ||
        isInsideOffer;
  }

  void _onFeatureToggle(String property, bool value) {
    // الخصائص التي تتطلب وجود صورة
    final featuredProperties = [
      'isNew',
      'isBestSeller',
      'isOnSale',
      'isJoker',
      'isSuperJoker',
      'isInsideOffer',
    ];

    final hasImage =
        selectedImage != null ||
        (widget.product?.images.isNotEmpty ?? false) ||
        additionalImages.isNotEmpty;

    if (value == true && featuredProperties.contains(property) && !hasImage) {
      // تفعيل الخاصية مؤقتاً في الـ State ليظهر الـ ImagePecker في الواجهة
      setState(() {
        switch (property) {
          case 'isNew':
            isNew = true;
            break;
          case 'isBestSeller':
            isBestSeller = true;
            break;
          case 'isOnSale':
            isOnSale = true;
            break;
          case 'isJoker':
            isJoker = true;
            break;
          case 'isSuperJoker':
            isSuperJoker = true;
            break;
          case 'isInsideOffer':
            isInsideOffer = true;
            break;
        }
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'تنبيه: الصورة مطلوبة',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'لا يمكن تفعيل هذه الخاصية لمنتج بدون صورة. سيتم فتح اختيار الصور الآن.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // استخدام PostFrameCallback لضمان أن الـ ImagePecker قد تم بناؤه بعد الـ setState
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    (_imagePickerKey.currentState as dynamic)?.pickImage();
                  } catch (e) {
                    debugPrint("Could not open image picker: $e");
                  }
                });
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      switch (property) {
        case 'isNew':
          isNew = value;
          break;
        case 'isBestSeller':
          isBestSeller = value;
          break;
        case 'isOnSale':
          isOnSale = value;
          break;
        case 'isJoker':
          isJoker = value;
          break;
        case 'isSuperJoker':
          isSuperJoker = value;
          break;
        case 'isInsideOffer':
          isInsideOffer = value;
          break;
      }
    });
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    descriptionController.dispose();
    detailedDescriptionController.dispose();
    usageController.dispose();
    priceController.dispose();
    oldPriceController.dispose();
    benefitsController.dispose();
    ingredientsController.dispose();
    discountController.dispose();
    singlePriceQuantityController.dispose();
    _quillDetailedDescriptionController.dispose();
    super.dispose();
  }
  late final ValidationsForm form;

  QuillController _initQuillController(String htmlContent) {
    Delta delta;
    try {
      if (htmlContent.isNotEmpty) {
        delta = HtmlToDelta().convert(htmlContent);
        if (delta.isEmpty) {
          delta = Delta()..insert('\n');
        }
      } else {
        delta = Delta()..insert('\n');
      }
    } catch (_) {
      delta = Delta()..insert('\n');
    }
    return QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  String _quillToHtml(QuillController controller) {
    try {
      final deltaJson = controller.document.toDelta().toJson();
      final converter = QuillDeltaToHtmlConverter(
        List<Map<String, dynamic>>.from(deltaJson),
      );
      return converter.convert();
    } catch (_) {
      return '';
    }
  }

  String _quillToPlainText(QuillController controller) {
    try {
      return controller.document.toPlainText().trim();
    } catch (_) {
      return '';
    }
  }

  QuillController _initQuillControllerFromPlainText(String plainText) {
    final delta = Delta()..insert(plainText.endsWith('\n') ? plainText : '$plainText\n');
    return QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }
  void _saveProduct() {
    // 1️⃣ إظهار تنبيهات قبل الفحص
    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'تنبيه',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: const Text('⚠️ يرجى اختيار الفئة'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    final isFeatured =
        isNew || isBestSeller || isOnSale || isJoker || isSuperJoker;

    final List<String> existingUrls = [];
    if (selectedImage == null &&
        widget.product != null &&
        widget.product!.images.isNotEmpty) {
      final firstImage = widget.product!.images.first;
      existingUrls.add(firstImage.startsWith(ApiUrls.IMAGE_BASE_URL)
          ? firstImage.substring(ApiUrls.IMAGE_BASE_URL.length)
          : firstImage);
    }
    for (final img in additionalImages) {
      if (img is String) {
        existingUrls.add(img.startsWith(ApiUrls.IMAGE_BASE_URL)
            ? img.substring(ApiUrls.IMAGE_BASE_URL.length)
            : img);
      }
    }

    final List<Uint8List> newImages = [];
    if (selectedImage != null && selectedImage!.bytes != null) {
      newImages.add(selectedImage!.bytes!);
    }
    for (final img in additionalImages) {
      if (img is ImageFileModel && img.bytes != null) {
        newImages.add(img.bytes!);
      }
    }

    final hasImage = newImages.isNotEmpty || existingUrls.isNotEmpty;

    // التحقق من المنتج المميز
    if (isFeatured && !hasImage) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'تنبيه',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '⚠️ بما أن المنتج "مميز" (جديد، عرض، جوكر..)، يجب إضافة صورة ليظهر بشكل صحيح في الشاشة الرئيسية للموقع.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    // التحقق من متطلبات الحفظ العامة
    bool isImagerequred = ProductInputConfig.isProductImageRequired;
    if (isImagerequred && !hasImage) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'تنبيه',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: const Text('⚠️ صورة المنتج مطلوبة بناءً على إعدادات الفرع.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    // 1️⃣ مراجعة نظام الأسعار عند التفعيل
    if (isMultiSize && priceOptions.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'تنبيه',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '⚠️ يجب إضافة سعر واحد على الأقل عند تفعيل التسعير المتعدد.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    // 2️⃣ التحقق من صحة النموذج

    // 3️⃣ جمع القوائم الإضافية
    List<String> benefitsList = benefitsController.text.isNotEmpty
        ? benefitsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : [];
    List<String> ingredientsList = ingredientsController.text.isNotEmpty
        ? ingredientsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : [];

    final changesValue = context.read<AppChangesValues>();
    final organizationId = changesValue.user?.organizationId ?? '';

    final localizedName = {
      'ar': nameArController.text.trim(),
      'en': nameEnController.text.trim(),
    };

    final additionalData = {
      'description': descriptionController.text.trim(),
      'detailedDescription': isDetailedDescriptionHtml
          ? _quillToHtml(_quillDetailedDescriptionController)
          : detailedDescriptionController.text.trim(),
      'isDetailedDescriptionHtml': isDetailedDescriptionHtml,
      'usage': usageController.text.trim(),
      'benefits': benefitsList,
      'ingredients': ingredientsList,
      'isInsideOffer': isInsideOffer,
      'variants': variants.map((e) => e.toJson()).toList(),
      'addons': addons.map((e) => e.toJson()).toList(),
      'options': options.map((e) => e.toJson()).toList(),
    };

    final List<core_m.PriceOption> priceOptionsList = isMultiSize
        ? priceOptions
              .map(
                (e) => core_m.PriceOption(
                  quantity: e.quantity,
                  unit: e.unit.name,
                  price: e.price,
                  oldPrice: e.oldPrice,
                  isDefault: e.isDefault,
                  customPrices: e.customPrices,
                ),
              )
              .toList()
        : [
            core_m.PriceOption(
              quantity:
                  double.tryParse(singlePriceQuantityController.text) ?? 1.0,
              unit: singlePriceUnit.name,
              price: double.tryParse(priceController.text) ?? 0.0,
              oldPrice: double.tryParse(oldPriceController.text),
              isDefault: true,
            ),
          ];

    final double currentPrice = isMultiSize && priceOptions.isNotEmpty
        ? priceOptions.first.price
        : (double.tryParse(priceController.text) ?? 0.0);
    final double? currentOldPrice =
        isMultiSize &&
            priceOptions.isNotEmpty &&
            priceOptions.first.oldPrice != null
        ? priceOptions.first.oldPrice
        : double.tryParse(oldPriceController.text);
    final double? currentDiscount = discountController.text.isNotEmpty
        ? double.tryParse(discountController.text)
        : null;

    final bloc = context.read<ProductsBloc>();

    // 4️⃣ حفظ/تحديث المنتج
    if (widget.product != null) {
      final Map<String, dynamic> updateData = {
        'name': localizedName,
        'categoryId': selectedCategoryId,
        'organizationId': organizationId,
        'price': currentPrice,
        'oldPrice': currentOldPrice,
        'discount': currentDiscount,
        'isNew': isNew,
        'isBestSeller': isBestSeller,
        'isOnSale': isOnSale,
        'isJoker': isJoker,
        'isSuperJoker': isSuperJoker,
        'isAvailable': isAvailable,
        'additionalData': additionalData,
        'priceOptions': priceOptionsList.map((e) => e.toJson()).toList(),
        'variants': variants.map((e) => e.toJson()).toList(),
        'addons': addons.map((e) => e.toJson()).toList(),
        'options': options.map((e) => e.toJson()).toList(),
        'images': existingUrls,
      };
      bloc.updateProduct(
        productId: widget.product!.productId,
        data: updateData,
        images: newImages,
      );
    } else {
      bloc.createProduct(
        name: localizedName,
        categoryId: selectedCategoryId!,
        organizationId: organizationId,
        price: currentPrice,
        oldPrice: currentOldPrice,
        discount: currentDiscount,
        isNew: isNew,
        isBestSeller: isBestSeller,
        isOnSale: isOnSale,
        isJoker: isJoker,
        isSuperJoker: isSuperJoker,
        isAvailable: isAvailable,
        additionalData: additionalData,
        priceOptions: priceOptionsList,
        images: newImages,
      );
    }
  }

  void _openVariantsManager() async {
    final List<dynamic> productImages = [];
    if (selectedImage != null) {
      productImages.add(selectedImage!);
    } else if (widget.product != null && widget.product!.images.isNotEmpty) {
      productImages.add(widget.product!.images.first);
    }
    productImages.addAll(additionalImages);

    final result = await showDialog<List<ProductVariant>>(
      context: context,
      builder: (ctx) => VariantsManagerDialog(
        initialVariants: variants,
        productImages: productImages,
      ),
    );
    if (result != null) {
      setState(() {
        variants = result;
      });
    }
  }

  void _openAddonsManager() async {
    final result = await showDialog<List<ProductAddonGroup>>(
      context: context,
      builder: (ctx) => AddonsManagerDialog(initialAddons: addons),
    );
    if (result != null) {
      setState(() {
        addons = result;
      });
    }
  }

  void _openOptionsManager() async {
    final result = await showDialog<List<ProductCustomOptionGroup>>(
      context: context,
      builder: (ctx) => OptionsManagerDialog(initialOptions: options),
    );
    if (result != null) {
      setState(() {
        options = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, FeaturDataSourceState<ProductModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (data) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          failure: (error, callback) {
            if (_isDialogShowing) return;
            _isDialogShowing = true;

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  'خطأ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  error.message ?? '❌ خطأ في الإدخال راجع الدعم الفني',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('حسناً'),
                  ),
                ],
              ),
            ).then((_) => _isDialogShowing = false);
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoad = state.itemState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  form.buildChildrenWithColumn(
                    context: context,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CloseButton(color: AppColors.primary),
                          Text(
                            widget.product == null
                                ? 'إضافة منتج جديد'
                                : 'تعديل المنتج',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      SizedBox(height: 20),

                      if (_shouldShowImagePicker) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DarkColors.surfaceVariant.withOpacity(0.4)
                                : LightColors.surfaceVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? DarkColors.divider.withOpacity(0.3)
                                  : LightColors.divider.withOpacity(0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    color: isDark
                                        ? DarkColors.primary
                                        : LightColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'معرض صور المنتج',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark
                                          ? DarkColors.textPrimary
                                          : LightColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'قم بإضافة صور المنتج وتحديد الصورة الرئيسية. يمكنك ربط الصور بالمتغيرات لاحقاً.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'الصورة الأساسية (الرئيسية)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: isDark
                                            ? DarkColors.textPrimary
                                            : LightColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.08,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: ImagePecker(
                                              key: _imagePickerKey,
                                              placeholderAsset:
                                                  AppAsset.imgplaceholder,
                                              networkImage:
                                                  widget
                                                          .product
                                                          ?.images
                                                          .isNotEmpty ==
                                                      true
                                                  ? widget.product!.images.first
                                                  : null,
                                              height: 180,
                                              width: 180,
                                              backgroundColor: isDark
                                                  ? DarkColors.inputBackground
                                                  : LightColors.inputBackground,
                                              iconColor: isDark
                                                  ? DarkColors.primary
                                                  : LightColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              requiredHeight: ProductInputConfig
                                                  .productImageHeight
                                                  .toInt(),
                                              requiredWidth: ProductInputConfig
                                                  .productImageWidth
                                                  .toInt(),
                                              shape: BoxShape.rectangle,
                                              helperText: '',
                                              enableCrop: ProductInputConfig
                                                  .isProductImageRatioEnforced,
                                              cropAspectRatio:
                                                  ProductInputConfig
                                                      .productImageWidth /
                                                  ProductInputConfig
                                                      .productImageHeight,
                                              isStrict: true,
                                              maxFileSizeMB: ProductInputConfig
                                                  .maxProductImageSizeMB
                                                  .toDouble(),
                                              showFileSize: false,
                                              onImageSelected: (imageModel) {
                                                setState(() {
                                                  selectedImage = imageModel;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (isDark
                                                          ? DarkColors.primary
                                                          : LightColors.primary)
                                                      .withOpacity(0.95),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'الأساسية',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Divider(
                                color: isDark
                                    ? DarkColors.divider.withOpacity(0.2)
                                    : LightColors.divider.withOpacity(0.2),
                                height: 1,
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.collections_outlined,
                                        size: 16,
                                        color: isDark
                                            ? DarkColors.textSecondary
                                            : LightColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'الصور الإضافية والمعرض',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isDark
                                              ? DarkColors.textPrimary
                                              : LightColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (isDark
                                                  ? DarkColors.primary
                                                  : LightColors.primary)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${additionalImages.length + (selectedImage != null || (widget.product?.images.isNotEmpty ?? false) ? 1 : 0)} / ${ProductInputConfig.maxProductImages}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? DarkColors.primary
                                            : LightColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ...List.generate(additionalImages.length, (
                                    idx,
                                  ) {
                                    final img = additionalImages[idx];
                                    final int imageSeq =
                                        idx +
                                        2; // sequence starts at #2 because primary image is #1
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? DarkColors.inputBackground
                                                : LightColors.inputBackground,
                                            border: Border.all(
                                              color: isDark
                                                  ? DarkColors.divider
                                                        .withOpacity(0.3)
                                                  : LightColors.divider
                                                        .withOpacity(0.5),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.04,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10.5,
                                            ),
                                            child: img is String
                                                ? Image.network(
                                                    img,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            size: 24,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                  )
                                                : img is ImageFileModel &&
                                                      img.bytes != null
                                                ? Image.memory(
                                                    img.bytes!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      size: 24,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        Positioned(
                                          bottom: -6,
                                          right: -6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? DarkColors.surfaceVariant
                                                  : LightColors.surfaceVariant,
                                              border: Border.all(
                                                color: isDark
                                                    ? DarkColors.divider
                                                    : LightColors.divider,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '#$imageSeq',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? DarkColors.textPrimary
                                                    : LightColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          top: -6,
                                          left: -6,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  additionalImages.removeAt(
                                                    idx,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade600,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.delete_forever_outlined,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),

                                  if ((additionalImages.length +
                                          (selectedImage != null ||
                                                  (widget
                                                          .product
                                                          ?.images
                                                          .isNotEmpty ??
                                                      false)
                                              ? 1
                                              : 0)) <
                                      ProductInputConfig.maxProductImages)
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ImagePecker(
                                          key: ValueKey(
                                            'add_img_${additionalImages.length}',
                                          ),
                                          placeholderAsset:
                                              AppAsset.imgplaceholder,
                                          height: 90,
                                          width: 90,
                                          requiredHeight: ProductInputConfig
                                              .productImageHeight
                                              .toInt(),
                                          requiredWidth: ProductInputConfig
                                              .productImageWidth
                                              .toInt(),
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          helperText: '',
                                          enableCrop: ProductInputConfig
                                              .isProductImageRatioEnforced,
                                          cropAspectRatio:
                                              ProductInputConfig
                                                  .productImageWidth /
                                              ProductInputConfig
                                                  .productImageHeight,
                                          isStrict: true,
                                          maxFileSizeMB: ProductInputConfig
                                              .maxProductImageSizeMB
                                              .toDouble(),
                                          showFileSize: false,
                                          onImageSelected: (imageModel) {
                                            setState(() {
                                              additionalImages.add(imageModel);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 20),

                      TextFomrFildValidtion(
                        controller: nameArController,
                        keyData: 'nameAr',
                        baseValidation: [RequiredValidator()],
                        labalText: 'اسم المنتج (عربي)',
                        padding: EdgeInsets.only(bottom: 30),
                        form: form,
                      ),

                      TextFomrFildValidtion(
                        controller: nameEnController,
                        keyData: 'nameEn',
                        baseValidation: [RequiredValidator()],
                        labalText: 'اسم المنتج (إنجليزي)',
                        padding: EdgeInsets.only(bottom: 30),
                        form: form,
                      ),

                      // Category Dropdown - استخدام CategoriesBloc
                      BlocBuilder<
                        CategoriesBloc,
                        FeaturDataSourceState<CategoryModel>
                      >(
                        builder: (context, catState) {
                          final categories = catState.listState.maybeWhen(
                            success: (list) => list ?? [],
                            orElse: () => <CategoryModel>[],
                          );
                          final itemsNames = [
                            'اختر الفئة',
                            ...categories.map((c) => c.nameAr),
                          ];
                          int currentIndex = 0;
                          if (selectedCategoryId != null) {
                            final idx = categories.indexWhere(
                              (c) => c.id == selectedCategoryId,
                            );
                            if (idx >= 0) currentIndex = idx + 1;
                          }

                          return DrobDaownValidation(
                            itemslsit: itemsNames.isEmpty
                                ? ['لا توجد أصناف']
                                : itemsNames,
                            index: currentIndex,
                            decoration: InputDecoration(
                              labelText: 'الفئة',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.category,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            textStyle: TextStyle(fontSize: 14),
                            keyData: 'category',
                            baseValidation: [RequiredValidator()],
                            form: form,
                            labalText: 'اختر الفئة',
                            onChange: (value) {
                              if (value == 'اختر الفئة' ||
                                  value == 'لا توجد أصناف') {
                                setState(() => selectedCategoryId = null);
                                return;
                              }
                              final category = categories.firstWhere(
                                (c) => c.nameAr == value,
                                orElse: () => categories.first,
                              );
                              setState(() => selectedCategoryId = category.id);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // ============ قسم الأسعار ============
                      if (ProductInputConfig.enableMultiSizePricing)
                        SwitchListTile(
                          title: Text('تسعير متعدد (أحجام مختلفة)'),
                          subtitle: Text(
                            'تفعيل إضافة أكثر من حجم وسعر للمنتج الواحد',
                          ),
                          value: isMultiSize,
                          activeThumbColor: Theme.of(context).primaryColor,
                          onChanged: (value) {
                            setState(() {
                              isMultiSize = value;
                            });
                          },
                        ),

                      if (isMultiSize)
                        _buildPriceOptionsSection()
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFomrFildValidtion(
                                textInputType: TextInputType.number,
                                controller: singlePriceQuantityController,
                                keyData: 'single_quantity',
                                baseValidation: [
                                  NumperValidator(
                                    message: 'يرجى إدخال كمية صحيحة',
                                  ),
                                ],
                                labalText: 'الكمية',
                                form: form,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: DropdownButtonFormField<ProductUnit>(
                                value: singlePriceUnit,
                                decoration: InputDecoration(
                                  labelText: 'الوحدة',
                                  border: OutlineInputBorder(),
                                ),
                                items: ProductUnit.values
                                    .where(
                                      (u) =>
                                          u.isVisible || u == singlePriceUnit,
                                    )
                                    .map(
                                      (u) => DropdownMenuItem(
                                        value: u,
                                        child: Text(u.nameAr),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => singlePriceUnit = val);
                                },
                              ),
                            ),
                            SizedBox(width: 4),
                          ],
                        ),
                        if (singlePriceUnit.quickSizes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: singlePriceUnit.quickSizes.map((qs) {
                              final isSelected =
                                  singlePriceQuantityController.text ==
                                  (qs.quantity == qs.quantity.toInt()
                                          ? qs.quantity.toInt()
                                          : qs.quantity)
                                      .toString();
                              return ActionChip(
                                avatar: Icon(
                                  Icons.straighten,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                ),
                                label: Text(
                                  qs.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white : null,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                backgroundColor: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.1),
                                onPressed: () {
                                  setState(() {
                                    singlePriceQuantityController.text =
                                        (qs.quantity == qs.quantity.toInt()
                                                ? qs.quantity.toInt()
                                                : qs.quantity)
                                            .toString();
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        SizedBox(height: 15),
                        TextFomrFildValidtion(
                          textInputType: TextInputType.number,
                          controller: priceController,
                          keyData: 'price',
                          baseValidation: [
                            NumperValidator(message: 'يرجى إدخال سعر صالح'),
                          ],
                          labalText: 'السعر الحالي',
                          padding: EdgeInsets.only(bottom: 20),
                          form: form,
                        ),
                        TextFomrFildValidtion(
                          textInputType: TextInputType.number,
                          controller: oldPriceController,
                          keyData: 'oldPrice',
                          baseValidation: const [],
                          labalText: 'السعر القديم (اختياري)',
                          padding: EdgeInsets.only(bottom: 20),
                          form: form,
                        ),
                      ],

                      if (ProductInputConfig.showDescription &&
                          !ProductInputConfig.enableQuickAdd) ...[
                        SizedBox(height: 20),
                        TextFomrFildValidtion(
                          controller: descriptionController,
                          keyData: 'description',
                          baseValidation: const [],
                          labalText: 'الوصف المختصر',
                          padding: EdgeInsets.only(bottom: 30),
                          form: form,
                        ),
                      ],

                      if (ProductInputConfig.showDetailedDescription) ...[
                        SizedBox(height: 20),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('تنسيق متقدم (HTML)'),
                          subtitle: Text('تفعيل خيار تنسيق الخطوط والقوائم في الوصف التفصيلي'),
                          value: isDetailedDescriptionHtml,
                          activeThumbColor: Theme.of(context).primaryColor,
                          onChanged: (value) {
                            setState(() {
                              isDetailedDescriptionHtml = value;
                              if (value) {
                                final currentText = detailedDescriptionController.text.trim();
                                _quillDetailedDescriptionController = _initQuillControllerFromPlainText(currentText);
                              } else {
                                detailedDescriptionController.text = _quillToPlainText(_quillDetailedDescriptionController);
                              }
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        if (isDetailedDescriptionHtml) ...[
                          Container(
                            height: 280,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[350]!,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 44,
                                  child: QuillSimpleToolbar(
                                    controller: _quillDetailedDescriptionController,
                                    config: const QuillSimpleToolbarConfig(
                                      showFontFamily: false,
                                      showFontSize: false,
                                      showInlineCode: false,
                                      showSubscript: false,
                                      showSuperscript: false,
                                      showSearchButton: false,
                                      showListCheck: false,
                                      showIndent: false,
                                      multiRowsDisplay: false,
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: QuillEditor.basic(
                                      controller: _quillDetailedDescriptionController,
                                      config: const QuillEditorConfig(
                                        placeholder: "ابدأ بكتابة الوصف التفصيلي المنسق هنا...",
                                        expands: true,
                                        scrollable: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ] else ...[
                          TextFomrFildValidtion(
                            controller: detailedDescriptionController,
                            keyData: 'detailedDescription',
                            baseValidation: const [],
                            labalText: 'الوصف التفصيلي',
                            mulitLine: 5,
                            padding: const EdgeInsets.only(bottom: 30),
                            form: form,
                          ),
                        ],
                      ],

                      if (ProductInputConfig.showUsage &&
                          !ProductInputConfig.enableQuickAdd) ...[
                        SizedBox(height: 20),
                        TextFomrFildValidtion(
                          controller: usageController,
                          keyData: 'usage',
                          baseValidation: const [],
                          labalText: 'طريقة الاستخدام',
                          padding: EdgeInsets.only(bottom: 30),
                          form: form,
                        ),
                      ],

                      if (ProductInputConfig.showBenefits &&
                          !ProductInputConfig.enableQuickAdd) ...[
                        SizedBox(height: 20),
                        TextFomrFildValidtion(
                          controller: benefitsController,
                          keyData: 'benefits',
                          baseValidation: const [],
                          labalText: 'الفوائد (مفصولة بفواصل)',
                          padding: EdgeInsets.only(bottom: 30),
                          form: form,
                        ),
                      ],

                      if (ProductInputConfig.showIngredients &&
                          !ProductInputConfig.enableQuickAdd) ...[
                        SizedBox(height: 20),
                        TextFomrFildValidtion(
                          controller: ingredientsController,
                          keyData: 'ingredients',
                          baseValidation: const [],
                          labalText: 'المكونات (مفصولة بفواصل)',
                          padding: EdgeInsets.only(bottom: 30),
                          form: form,
                        ),
                      ],

                      if (ProductInputConfig.showDiscount ||
                          ProductInputConfig.showDiscountPercentage) ...[
                        SizedBox(height: 20),
                        TextFomrFildValidtion(
                          textInputType: TextInputType.number,
                          controller: discountController,
                          keyData: 'discount',
                          baseValidation: [
                            NumperValidator(
                              message: 'يرجى إدخال رقم صالح للخصم',
                            ),
                          ],
                          labalText: 'نسبة الخصم (%)',
                          padding: EdgeInsets.only(bottom: 30),
                          form: form,
                        ),
                      ],

                      SizedBox(height: 20),

                      // Checkboxes
                      if (ProductInputConfig.showIsNew)
                        CheckboxListTile(
                          title: Text('منتج جديد ✨'),
                          value: isNew,
                          onChanged: (v) =>
                              _onFeatureToggle('isNew', v ?? false),
                        ),
                      if (ProductInputConfig.showIsBestSeller)
                        CheckboxListTile(
                          title: Text('الأكثر مبيعاً 🔥'),
                          value: isBestSeller,
                          onChanged: (v) =>
                              _onFeatureToggle('isBestSeller', v ?? false),
                        ),
                      if (ProductInputConfig.showIsOnSale)
                        CheckboxListTile(
                          title: Text('عرض خاص 🎁'),
                          value: isOnSale,
                          onChanged: (v) =>
                              _onFeatureToggle('isOnSale', v ?? false),
                        ),
                      if (ProductInputConfig.showIsJoker)
                        CheckboxListTile(
                          title: Text('جوكر 🃏'),
                          value: isJoker,
                          onChanged: (v) =>
                              _onFeatureToggle('isJoker', v ?? false),
                        ),
                      if (ProductInputConfig.showIsSuperJoker)
                        CheckboxListTile(
                          title: Text('سوبر جوكر 🌟'),
                          value: isSuperJoker,
                          onChanged: (v) =>
                              _onFeatureToggle('isSuperJoker', v ?? false),
                        ),
                      if (ProductInputConfig.showIsInsideOffer)
                        CheckboxListTile(
                          title: Text('داخل العروض 🔥'),
                          value: isInsideOffer,
                          onChanged: (v) =>
                              _onFeatureToggle('isInsideOffer', v ?? false),
                        ),
                      CheckboxListTile(
                        title: Text('متوفر 📦'),
                        value: isAvailable,
                        onChanged: (v) =>
                            setState(() => isAvailable = v ?? true),
                      ),

                      // ============ الأزرار الخاصة بالخصائص المتقدمة ============
                      if (ProductInputConfig.showVariants) ...[
                        const SizedBox(height: 15),
                        buildCustomPropertyManagerButton(
                          context: context,
                          title: "إدارة المتغيرات (Variants)",
                          icon: Icons.difference_outlined,
                          count: variants.length,
                          onPressed: _openVariantsManager,
                        ),
                      ],
                      if (ProductInputConfig.showAddons) ...[
                        const SizedBox(height: 15),
                        buildCustomPropertyManagerButton(
                          context: context,
                          title: "إدارة الإضافات (Add-ons)",
                          icon: Icons.add_circle_outline,
                          count: addons.length,
                          onPressed: _openAddonsManager,
                        ),
                      ],
                      if (ProductInputConfig.showOptions) ...[
                        const SizedBox(height: 15),
                        buildCustomPropertyManagerButton(
                          context: context,
                          title: "إدارة الخيارات المخصصة (Options)",
                          icon: Icons.settings_outlined,
                          count: options.length,
                          onPressed: _openOptionsManager,
                        ),
                      ],

                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: isLoad ? null : _saveProduct,
                          icon: isLoad
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.save),
                          label: Text(
                            widget.product != null
                                ? 'حفظ التعديلات'
                                : 'إضافة المنتج',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceOptionsSection() {
    return PriceOptionsWidget(
      initialPriceOptions: priceOptions,
      onPriceOptionsChanged: (options) {
        setState(() {
          priceOptions = options;
        });
      },
    );
  }
}
