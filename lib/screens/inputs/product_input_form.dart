import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/validators/numper_validator.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/drobdaown_validation.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class ProductInputForm extends StatefulWidget {
  final ProductModel? product;
  final String? initialCategoryId;

  ProductInputForm({super.key, this.product, this.initialCategoryId});

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
  bool isAvailable = true; // متاح
  bool isMultiSize = false;
  ProductUnit singlePriceUnit = ProductUnit.piece;
  late TextEditingController singlePriceQuantityController;

  // ============ نظام التسعير المتعدد ============
  List<PriceOption> priceOptions = [];
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
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
    detailedDescriptionController = TextEditingController(
      text: widget.product?.additionalData['detailedDescription'] ?? '',
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
    } else if (widget.initialCategoryId != null) {
      selectedCategoryId = widget.initialCategoryId;
    }
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
    super.dispose();
  }

  late final ValidationsForm form;

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
    final hasNewImage = selectedImage != null;
    final hasExistingImage =
        widget.product != null && widget.product!.images.isNotEmpty;
    final hasImage = hasNewImage || hasExistingImage;

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
      'detailedDescription': detailedDescriptionController.text.trim(),
      'usage': usageController.text.trim(),
      'benefits': benefitsList,
      'ingredients': ingredientsList,
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
    final String? imageName = selectedImage?.file?.path.split('/').last;

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
        'images': selectedImage != null ? [] : (widget.product?.images ?? []),
      };
      bloc.updateProduct(
        productId: widget.product!.productId,
        data: updateData,
        imageBytes: selectedImage?.bytes,
        imageName: imageName,
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
        imageBytes: selectedImage?.bytes,
        imageName: imageName,
      );
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

                      if (ProductInputConfig.showImages ||
                          ProductInputConfig.isProductImageRequired)
                        ImagePecker(
                          placeholderAsset: AppAsset.imgplaceholder,
                          networkImage:
                              widget.product?.images.isNotEmpty == true
                              ? widget.product!.images.first
                              : null,
                          height: 200,
                          width: 200,
                          requiredHeight: ProductInputConfig.productImageHeight
                              .toInt(),
                          requiredWidth: ProductInputConfig.productImageWidth
                              .toInt(),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          helperText: ProductInputConfig.isProductImageRequired
                              ? 'اضغط لاختيار صورة المنتج (مطلوب)'
                              : 'اضغط لاختيار صورة المنتج',
                          enableCrop:
                              ProductInputConfig.isProductImageRatioEnforced,
                          cropAspectRatio:
                              ProductInputConfig.productImageWidth /
                              ProductInputConfig.productImageHeight,
                          isStrict: true, // فرض القيود بشكل صارم
                          maxFileSizeMB: ProductInputConfig
                              .maxProductImageSizeMB
                              .toDouble(),
                          showFileSize: true,
                          onImageSelected: (imageModel) {
                            setState(() {
                              selectedImage = imageModel;
                            });
                          },
                        ),
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
                        TextFomrFildValidtion(
                          controller: detailedDescriptionController,
                          keyData: 'detailedDescription',
                          baseValidation: const [],
                          labalText: 'الوصف التفصيلي',
                          mulitLine: ProductInputConfig.enableRichTextEditor
                              ? 10
                              : 3,
                          padding: const EdgeInsets.only(bottom: 30),
                          form: form,
                          decoration: ProductInputConfig.enableRichTextEditor
                              ? InputDecoration(
                                  labelText: 'الوصف التفصيلي (محرر نصوص)',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.05),
                                )
                              : const InputDecoration(),
                        ),
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

                      if (ProductInputConfig.showDiscount &&
                          !ProductInputConfig.enableQuickAdd) ...[
                        SizedBox(height: 20),
                        TextFomrFildValidtion(
                          textInputType: TextInputType.number,
                          controller: discountController,
                          initValue: "0",
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
                          title: Text('منتج جديد'),
                          value: isNew,
                          onChanged: (v) => setState(() => isNew = v ?? false),
                        ),
                      if (ProductInputConfig.showIsBestSeller)
                        CheckboxListTile(
                          title: Text('الأكثر مبيعاً'),
                          value: isBestSeller,
                          onChanged: (v) =>
                              setState(() => isBestSeller = v ?? false),
                        ),
                      if (ProductInputConfig.showIsOnSale)
                        CheckboxListTile(
                          title: Text('عرض خاص'),
                          value: isOnSale,
                          onChanged: (v) =>
                              setState(() => isOnSale = v ?? false),
                        ),
                      if (ProductInputConfig.showIsJoker)
                        CheckboxListTile(
                          title: Text('جوكر 🃏'),
                          value: isJoker,
                          onChanged: (v) =>
                              setState(() => isJoker = v ?? false),
                        ),
                      if (ProductInputConfig.showIsSuperJoker)
                        CheckboxListTile(
                          title: Text('سوبر جوكر 🌟'),
                          value: isSuperJoker,
                          onChanged: (v) =>
                              setState(() => isSuperJoker = v ?? false),
                        ),
                      CheckboxListTile(
                        title: Text('متوفر 📦'),
                        value: isAvailable,
                        onChanged: (v) =>
                            setState(() => isAvailable = v ?? true),
                      ),

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
