import 'dart:convert';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/images_widgets/image_picker_widget.dart';
import '../../logic/model/category.dart';
import '../../logic/bloc/categories_bloc.dart';
import '../../configs/product_input_config.dart';
import 'package:flutter/material.dart';
import '../../consts/constants/views/assets.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';

class CategoryInputForm extends StatefulWidget {
  final CategoryModel? category;
  const CategoryInputForm({super.key, this.category});

  @override
  State<CategoryInputForm> createState() => CategoryInputFormState();
}

class CategoryInputFormState extends State<CategoryInputForm> {
  late TextEditingController nameArController;
  late TextEditingController nameEnController;
  late TextEditingController descriptionController;
  ImageFileModel? _selectedImage;
  ValidationsForm form = ValidationsForm();
  bool _isDialogShowing = false;
  bool _isActive = true;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    nameArController = TextEditingController(
      text: widget.category?.nameAr ?? '',
    );
    nameEnController = TextEditingController(
      text: widget.category?.name.en ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.category?.descriptionAr ?? '',
    );
    _isActive = widget.category?.isActive ?? true;
    _isPublic = widget.category != null ? (widget.category!.sharingLevel == 'public') : true;
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveCategory() {
    // 1️⃣ إظهار التنبيهات قبل الفحص
    if (ProductInputConfig.isCategoryImageRequired &&
        _selectedImage == null &&
        widget.category?.image == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'تنبيه',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: const Text('⚠️ صورة الفئة مطلوبة بناءً على إعدادات الفرع.'),
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
    if (!form.form.currentState!.validate()) return;
    form.form.currentState!.save();

    final bloc = context.read<CategoriesBloc>();
    final nameAr = nameArController.text.trim();
    final nameEn = nameEnController.text.trim();
    final desc = descriptionController.text.trim();

    // ترميز الأسماء والوصف كـ JSON لدعم اللغتين في الباك اند بشكل مثالي
    final nameMap = {
      'ar': nameAr,
      'en': nameEn.isNotEmpty ? nameEn : nameAr,
    };
    final descMap = {
      'ar': desc,
      'en': nameEn.isNotEmpty ? nameEn : nameAr,
    };
    
    final nameParam = jsonEncode(nameMap);
    final descParam = jsonEncode(descMap);

    if (widget.category != null) {
      bloc.updateCategory(
        categoryId: widget.category!.categoryId,
        name: nameParam,
        isActive: _isActive,
        isMasterProduct: _isPublic ? true : widget.category?.isMasterProduct,
        sharingLevel: _isPublic ? 'public' : 'private',
        imageBytes: _selectedImage?.bytes,
        imageName: _selectedImage?.file?.path.split('/').last,
      );
    } else {
      bloc.createCategory(
        name: nameParam,
        shopId: context.read<AppChangesValues>().user!.organizationId!,
        description: descParam,
        isMasterProduct: _isPublic ? true : true,
        sharingLevel: _isPublic ? 'public' : 'private',
        imageBytes: _selectedImage?.bytes,
        imageName: _selectedImage?.file?.path.split('/').last,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoriesBloc, FeaturDataSourceState<CategoryModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          orElse: () {},
          success: (data) {
            if (Navigator.canPop(context)) {
              Navigator.of(context).maybePop(data);
            }
          },
          failure: (error, reload) {
            if (_isDialogShowing) return;
            _isDialogShowing = true;

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('خطأ في الإدخال'),
                  ],
                ),
                content: Text(
                  error.message ?? 'حدث خطأ غير متوقع، راجع الدعم الفني',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            ).then((_) => _isDialogShowing = false);
          },
        );
      },
      builder: (context, state) {
        final isLoad = state.itemState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CloseButton(),
                  Text(
                    widget.category != null ? "تعديل الفئة" : "اضافة فئة جديدة",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 48), // التوازن مع زر الإغلاق
                ],
              ),
              const SizedBox(height: 20),

              // ImagePicker الجديد المحسّن مع ميزات متقدمة
              ImagePecker(
                placeholderAsset: AppAsset.imgplaceholder,
                networkImage: widget.category?.image,
                height: 200,
                width: 200,
                requiredHeight: ProductInputConfig.categoryImageHeight.toInt(),
                requiredWidth: ProductInputConfig.categoryImageWidth.toInt(),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
                helperText: ProductInputConfig.isCategoryImageRequired
                    ? 'اضغط لاختيار صورة الفئة (مطلوب)'
                    : 'اضغط لاختيار صورة الفئة',
                // ميزات جديدة:
                enableCrop: ProductInputConfig
                    .isCategoryImageRatioEnforced, // تفعيل Crop
                cropAspectRatio:
                    ProductInputConfig.categoryImageWidth /
                    ProductInputConfig.categoryImageHeight,
                maxFileSizeMB: ProductInputConfig.maxCategoryImageSizeMB
                    .toDouble(), // الحد الأقصى
                showFileSize: true, // إظهار حجم الملف
                onImageSelected: (imageModel) {
                  setState(() {
                    _selectedImage = imageModel;
                  });

                  // معلومات للتطوير
                  print('✅ تم اختيار صورة للفئة');
                  print('📸 hasImage: ${imageModel.hasImage}');
                  print('📊 حجم الملف: ${imageModel.readableFileSize}');
                  if (imageModel.fileSizeInKB != null) {
                    print(
                      '📏 بالكيلوبايت: ${imageModel.fileSizeInKB!.toStringAsFixed(2)} KB',
                    );
                  }
                  if (imageModel.fileSizeInMB != null) {
                    print(
                      '📏 بالميجابايت: ${imageModel.fileSizeInMB!.toStringAsFixed(2)} MB',
                    );
                  }
                  if (imageModel.xFile != null) {
                    print('📁 XFile name: ${imageModel.xFile!.name}');
                    print('📁 XFile path: ${imageModel.xFile!.path}');
                  }
                  if (imageModel.bytes != null) {
                    print('💾 Bytes length: ${imageModel.bytes!.length}');
                  }
                  if (imageModel.file != null) {
                    print('📂 File path: ${imageModel.file!.path}');
                  }
                },
              ),
              const SizedBox(height: 24),

              form.buildChildrenWithColumn(
                context: context,
                children: [
                  TextFomrFildValidtion(
                    controller: nameArController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.category,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'اسم الفئة (عربي)',
                    ),
                    labalText: 'اسم الفئة (عربي)',
                    keyData: "nameAr",
                  ),
                  const SizedBox(height: 20),

                  TextFomrFildValidtion(
                    controller: nameEnController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.category,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'اسم الفئة (انجليزية)',
                    ),
                    labalText: 'اسم الفئة (انجليزية)',
                    keyData: "nameEn",
                  ),
                  const SizedBox(height: 20),

                  TextFomrFildValidtion(
                    controller: descriptionController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.description,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'وصف الفئة',
                    ),
                    labalText: 'وصف الفئة',
                    keyData: "description",
                  ),
                  const SizedBox(height: 24),

                  // إعدادات النشر والظهور
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              const Text(
                                "إعدادات النشر والظهور",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "حالة النشاط",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            subtitle: const Text(
                              "تحديد ما إذا كانت الفئة نشطة ومتاحة في التطبيق",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            value: _isActive,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                          ),
                          const Divider(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "نشر للعامة في الكتالوج",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            subtitle: const Text(
                              "تظهر في كتالوج الزوار العام (تتطلب وجود منتج عام نشط واحد على الأقل داخلها)",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            value: _isPublic,
                            activeColor: Colors.green,
                            onChanged: (val) {
                              setState(() {
                                _isPublic = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoad ? null : saveCategory,
                      icon: isLoad
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        widget.category != null
                            ? 'حفظ التعديلات'
                            : 'إضافة الفئة',
                        style: const TextStyle(
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
        );
      },
    );
  }
}
