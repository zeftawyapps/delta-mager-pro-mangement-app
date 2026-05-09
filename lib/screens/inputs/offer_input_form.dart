import 'package:JoDija_tamplites/util/widgits/input_text/refrance_input_text_field.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/images_widgets/image_picker_widget.dart';
import '../../logic/model/offer.dart';
import '../../logic/bloc/offers_bloc.dart';
import '../../logic/bloc/categories_bloc.dart';
import '../../logic/bloc/products_bloc.dart';
import '../../logic/model/category.dart';
import '../../logic/model/product_model.dart';
import 'package:flutter/material.dart';
import '../../consts/constants/views/assets.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/validators/numper_validator.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/drobdaown_validation.dart';

class OfferInputForm extends StatefulWidget {
  final OfferModel? offer;
  const OfferInputForm({super.key, this.offer});

  @override
  State<OfferInputForm> createState() => _OfferInputFormState();
}

class _OfferInputFormState extends State<OfferInputForm> {
  late TextEditingController nameArController;
  late TextEditingController nameEnController;
  late TextEditingController descriptionArController;
  late TextEditingController descriptionEnController;
  late TextEditingController discountController;
  late TextEditingController sortOrderController;
  late TextEditingController productNameController;

  OfferTargetType selectedTargetType = OfferTargetType.product;
  String? selectedTargetId;
  DateTime? startDate;
  DateTime? endDate;
  bool isActive = true;
  ImageFileModel? selectedImage;

  ValidationsForm form = ValidationsForm();
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    nameArController = TextEditingController(text: widget.offer?.name.ar ?? '');
    nameEnController = TextEditingController(text: widget.offer?.name.en ?? '');
    descriptionArController = TextEditingController(
      text: widget.offer?.description.ar ?? '',
    );
    descriptionEnController = TextEditingController(
      text: widget.offer?.description.en ?? '',
    );
    discountController = TextEditingController(
      text: widget.offer?.discountPercentage.toString() ?? '0',
    );
    sortOrderController = TextEditingController(
      text: widget.offer?.sortOrder.toString() ?? '0',
    );
    productNameController = TextEditingController();

    if (widget.offer != null) {
      selectedTargetType = widget.offer!.targetType;
      selectedTargetId = widget.offer!.targetId;
      startDate = widget.offer!.startDate;
      endDate = widget.offer!.endDate;
      isActive = widget.offer!.isActive;
    }

    // تحميل المنتجات المخفضة عند البدء إذا كان نوع الهدف هو منتج
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedTargetType == OfferTargetType.product) {
        context.read<ProductsBloc>().loadDiscountedProducts();
      }
    });
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    descriptionArController.dispose();
    descriptionEnController.dispose();
    discountController.dispose();
    sortOrderController.dispose();
    productNameController.dispose();
    super.dispose();
  }

  void _saveOffer() {
    if (!form.form.currentState!.validate()) return;
    if (selectedTargetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الهدف (منتج أو قسم)')),
      );
      return;
    }

    final organizationId =
        context.read<AppChangesValues>().user?.organizationId ?? '';
    final bloc = context.read<OffersBloc>();

    final name = {
      'ar': nameArController.text.trim(),
      'en': nameEnController.text.trim(),
    };
    final description = {
      'ar': descriptionArController.text.trim(),
      'en': descriptionEnController.text.trim(),
    };

    if (widget.offer != null) {
      bloc.updateOffer(
        offerId: widget.offer!.id,
        organizationId: organizationId,
        name: name,
        description: description,
        targetType: selectedTargetType,
        targetId: selectedTargetId,
        discountPercentage: double.tryParse(discountController.text),
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
        sortOrder: int.tryParse(sortOrderController.text),
        imageBytes: selectedImage?.bytes,
        imageName: selectedImage?.file?.path.split('/').last,
      );
    } else {
      bloc.createOffer(
        name: name,
        organizationId: organizationId,
        description: description,
        targetType: selectedTargetType,
        targetId: selectedTargetId!,
        discountPercentage: double.tryParse(discountController.text),
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
        sortOrder: int.tryParse(sortOrderController.text),
        imageBytes: selectedImage?.bytes,
        imageName: selectedImage?.file?.path.split('/').last,
      );
    }
  }

  void _showProductSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 600,
            height: 500,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'البحث عن منتج',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: MasterGrid<ProductModel, ProductsBloc>(
                    title: 'المنتجات',
                    canAdd: false,
                    onAdd: () {},
                    searchHint: 'ابحث باسم المنتج...',
                    onLoad: (bloc) => bloc.loadDiscountedProducts(),
                    onSearch: (bloc, query) => bloc.loadDiscountedProducts(),
                    itemBuilder: (context, product, isSelected) {
                      return ListTile(
                        leading: product.images.isNotEmpty
                            ? Image.network(product.images.first, width: 40, height: 40, fit: BoxFit.cover)
                            : const Icon(Icons.image),
                        title: Text(product.nameAr),
                        subtitle: Text('${product.price} ر.س'),
                        trailing: product.discount != null 
                            ? Text('%${product.discount} خصم', style: const TextStyle(color: Colors.green))
                            : null,
                      );
                    },
                    onItemTap: (product) {
                      setState(() {
                        selectedTargetId = product.id;
                        productNameController.text = product.nameAr;
                        
                        // تحديث الخصم تلقائياً
                        double? discountVal = product.discount;
                        if (discountVal == null || discountVal == 0) {
                          final additionalDiscount = product.additionalData['discount'];
                          if (additionalDiscount != null) {
                            discountVal = double.tryParse(additionalDiscount.toString());
                          }
                        }
                        discountController.text = (discountVal ?? 0).toString();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OffersBloc, FeaturDataSourceState<OfferModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (data) => Navigator.of(context).maybePop(data),
          failure: (error, _) {
            if (_isDialogShowing) return;
            _isDialogShowing = true;

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('خطأ'),
                content: Text(error.message ?? 'حدث خطأ ما'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('حسناً'),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CloseButton(),
                  Text(
                    widget.offer != null ? "تعديل العرض" : "إضافة عرض جديد",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),

              ImagePecker(
                placeholderAsset: AppAsset.imgplaceholder,
                networkImage: widget.offer?.imageUrl,
                height: 150,
                width: 150,
                onImageSelected: (imageModel) =>
                    setState(() => selectedImage = imageModel),
              ),
              const SizedBox(height: 24),

              form.buildChildrenWithColumn(
                context: context,
                children: [
                  TextFomrFildValidtion(
                    controller: nameArController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    labalText: 'اسم العرض (عربي)',
                    keyData: "nameAr",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: nameEnController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    labalText: 'اسم العرض (إنجليزي)',
                    keyData: "nameEn",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: descriptionArController,
                    form: form,
                    baseValidation: const [],
                    labalText: 'الوصف (عربي)',
                    keyData: "descAr",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: descriptionEnController,
                    form: form,
                    baseValidation: const [],
                    labalText: 'الوصف (إنجليزي)',
                    keyData: "descEn",
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFomrFildValidtion(
                          controller: discountController,
                          form: form,
                          textInputType: TextInputType.number,
                          baseValidation: [
                            RequiredValidator(),
                            NumperValidator(),
                          ],
                          labalText: 'نسبة الخصم (%)',
                          keyData: "discount",
                          isReadOnly:
                              true, // الحقل مغلق لأنه يتم جلبه من المنتج المختار
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFomrFildValidtion(
                          controller: sortOrderController,
                          form: form,
                          textInputType: TextInputType.number,
                          baseValidation: const [],
                          labalText: 'الترتيب',
                          keyData: "sort",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  RefranceFormField(
                    controller: productNameController,
                    decoration: const InputDecoration(
                      labelText: 'المنتج المستهدف',
                      hintText: 'اضغط للبحث عن منتج...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    textStyle: const TextStyle(),
                    hintText: 'اضغط للبحث عن منتج...',
                    onSave: (val) {},
                    onvlaidate: (val) => val == null || val.isEmpty ? 'يرجى اختيار منتج' : null,
                    onTap: _showProductSearchDialog,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setState(() => startDate = date);
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            startDate == null
                                ? 'تاريخ البدء'
                                : startDate!.toString().split(' ').first,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  endDate ??
                                  DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setState(() => endDate = date);
                          },
                          icon: const Icon(Icons.event),
                          label: Text(
                            endDate == null
                                ? 'تاريخ الانتهاء'
                                : endDate!.toString().split(' ').first,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SwitchListTile(
                    title: const Text('نشط'),
                    value: isActive,
                    onChanged: (val) => setState(() => isActive = val),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoad ? null : _saveOffer,
                      icon: isLoad
                          ? const RotatingProgressIndicator()
                          : const Icon(Icons.save),
                      label: Text(
                        widget.offer != null ? 'حفظ التعديلات' : 'إضافة العرض',
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

class RotatingProgressIndicator extends StatelessWidget {
  const RotatingProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
