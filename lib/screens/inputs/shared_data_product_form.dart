import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/products_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/category.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class SharedDataProductForm extends StatefulWidget {
  final String organizationId;
  const SharedDataProductForm({super.key, required this.organizationId});

  @override
  State<SharedDataProductForm> createState() => _SharedDataProductFormState();
}

class _SharedDataProductFormState extends State<SharedDataProductForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategoryId;
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController(text: "100");
  bool _isActive = true;

  final List<Map<String, TextEditingController>> _variantControllers = [
    {'ar': TextEditingController(), 'en': TextEditingController()},
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    for (var controllers in _variantControllers) {
      controllers['ar']?.dispose();
      controllers['en']?.dispose();
    }
    super.dispose();
  }

  void _addVariant() {
    setState(() {
      _variantControllers.add({
        'ar': TextEditingController(),
        'en': TextEditingController(),
      });
    });
  }

  void _removeVariant(int index) {
    if (_variantControllers.length > 1) {
      setState(() {
        _variantControllers[index]['ar']?.dispose();
        _variantControllers[index]['en']?.dispose();
        _variantControllers.removeAt(index);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final List<Map<String, String>> variantNames = _variantControllers.map((
        c,
      ) {
        return {'ar': c['ar']!.text, 'en': c['en']!.text};
      }).toList();

      final template = {
        'categoryId': _selectedCategoryId,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
        'isActive': _isActive,
        'stockQuantity': int.tryParse(_stockController.text) ?? 0,
      };

      context.read<ProductsBloc>().createProductVariants(
        variantNames: variantNames,
        template: template,
        organizationId: widget.organizationId,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "إضافة منتجات ببيانات مشتركة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? DarkColors.primary : LightColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // القسم الأول: البيانات المشتركة
                  _buildSectionTitle("البيانات المشتركة", isDark),
                  const SizedBox(height: 10),
                  BlocBuilder<
                    CategoriesBloc,
                    FeaturDataSourceState<CategoryModel>
                  >(
                    builder: (context, state) {
                      final categories = state.listState.maybeWhen(
                        success: (data) => data ?? <CategoryModel>[],
                        orElse: () => <CategoryModel>[],
                      );
                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: "القسم",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((c) {
                          return DropdownMenuItem(
                            value: c.categoryId,
                            child: Text(c.name.ar),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategoryId = val),
                        validator: (val) => val == null ? "مطلوب" : null,
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "السعر",
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val!.isEmpty ? "مطلوب" : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "الكمية",
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val!.isEmpty ? "مطلوب" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "الوصف المشترك",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    title: const Text("نشط"),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                  const Divider(height: 40),

                  // القسم الثاني: قائمة المنتجات (الأسماء)
                  _buildSectionTitle("قائمة المنتجات", isDark),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  ...List.generate(_variantControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Card(
                        elevation: 0,
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: isDark
                                        ? DarkColors.primary
                                        : LightColors.primary,
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_variantControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _removeVariant(index),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _variantControllers[index]['ar'],
                                decoration: const InputDecoration(
                                  labelText: "الاسم بالعربي",
                                  isDense: true,
                                ),
                                validator: (val) =>
                                    val!.isEmpty ? "مطلوب" : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _variantControllers[index]['en'],
                                decoration: const InputDecoration(
                                  labelText: "الاسم بالإنجليزي",
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _addVariant,
                    icon: const Icon(Icons.add),
                    label: const Text("إضافة منتج "),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark
                            ? DarkColors.primary
                            : LightColors.primary,
                      ),
                      foregroundColor: isDark
                          ? DarkColors.primary
                          : LightColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? DarkColors.primary
                    : LightColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "إنشاء المنتجات الآن",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }
}
