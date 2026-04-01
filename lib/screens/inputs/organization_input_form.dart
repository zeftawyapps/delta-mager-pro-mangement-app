import 'package:delta_mager_pro_mangement_app/logic/bloc/organizations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import '../../logic/model/organization_model.dart';

// Subclass to override toJson to inject 'orgName' for the backend payload
class OrganizationDataWithOrgName extends OrganizationData {
  final String orgName;

  OrganizationDataWithOrgName({
    required this.orgName,
    required super.name,
    required super.ownerId,
    required super.address,
    required super.phone,
    required super.email,
    super.location,
    super.organizationId = '',
    super.isActive = true,
    super.isDataComplete = false,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['orgName'] = orgName;
    return map;
  }
}

class OrganizationInputForm extends StatefulWidget {
  const OrganizationInputForm({super.key});

  @override
  State<OrganizationInputForm> createState() => _OrganizationInputFormState();
}

class _OrganizationInputFormState extends State<OrganizationInputForm> {
  final ValidationsForm form = ValidationsForm();

  // Organization Controllers
  late TextEditingController orgNameController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  // Owner Controllers
  late TextEditingController ownerUsernameController;
  late TextEditingController ownerEmailController;
  late TextEditingController ownerPasswordController;
  late TextEditingController ownerPhoneController;
  late TextEditingController ownerNameController;
  late TextEditingController ownerAddressController;

  @override
  void initState() {
    super.initState();
    orgNameController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    ownerUsernameController = TextEditingController();
    ownerEmailController = TextEditingController();
    ownerPasswordController = TextEditingController();
    ownerPhoneController = TextEditingController();
    ownerNameController = TextEditingController();
    ownerAddressController = TextEditingController();
  }

  @override
  void dispose() {
    orgNameController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();

    ownerUsernameController.dispose();
    ownerEmailController.dispose();
    ownerPasswordController.dispose();
    ownerPhoneController.dispose();
    ownerNameController.dispose();
    ownerAddressController.dispose();
    super.dispose();
  }

  void saveOrganization() {
    if (!form.form.currentState!.validate()) return;

    final userData = {
      "username": ownerUsernameController.text.trim(),
      "email": ownerEmailController.text.trim(),
      "password": ownerPasswordController.text.trim(),
      "phone": ownerPhoneController.text.trim(),
      "name": ownerNameController.text.trim(),
      "address": ownerAddressController.text.trim(),
    };

    final orgData = OrganizationDataWithOrgName(
      orgName: orgNameController.text.trim(),
      name: nameController.text.trim(),
      ownerId: '', // Owner will be created backend
      address: addressController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      location: LocationData(latitude: 30.0444, longitude: 31.2357),
    );

    context.read<OrganizationsBloc>().createOrganizationWithOwner(
      userData: userData,
      organizationData: orgData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizationsBloc, FeaturDataSourceState<OrganizationModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          orElse: () {},
          success: (data) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم إنشاء المنظمة بنجاح')));
            if (Navigator.canPop(context)) {
              Navigator.of(context).maybePop(data);
            }
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: const Text('❌ خطأ في الإدخال راجع الدعم الفني'),
              ),
            );
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
                  const Text(
                    "بيانات إنشاء منظمة جديدة",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
              const SizedBox(height: 24),

              form.buildChildrenWithColumn(
                context: context,
                children: [
                  // --- بيانات المنظمة ---
                  _buildSectionTitle(context, "إعدادات المنظمة (Company)"),
                  const SizedBox(height: 12),
                  TextFomrFildValidtion(
                    controller: orgNameController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.label, color: Theme.of(context).primaryColor),
                      labelText: 'الاسم التعريفي (Slug / orgName)',
                      hintText: 'مثال: deltaDomansy',
                    ),
                    labalText: 'الاسم التعريفي',
                    keyData: "orgName",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: nameController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.business, color: Theme.of(context).primaryColor),
                      labelText: 'اسم المنظمة (العرض)',
                    ),
                    labalText: 'اسم المنظمة',
                    keyData: "name",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: emailController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                      labelText: 'البريد الإلكتروني للشركة',
                    ),
                    labalText: 'البريد الإلكتروني للشركة',
                    keyData: "email",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: phoneController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                      labelText: 'رقم الهاتف',
                    ),
                    labalText: 'رقم الهاتف',
                    keyData: "phone",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: addressController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                      labelText: 'عنوان الشركة',
                    ),
                    labalText: 'عنوان الشركة',
                    keyData: "address",
                  ),
                  const SizedBox(height: 24),

                  // --- بيانات المالك ---
                  _buildSectionTitle(context, "بيانات المالك (Owner)"),
                  const SizedBox(height: 12),
                  TextFomrFildValidtion(
                    controller: ownerUsernameController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_circle, color: Theme.of(context).primaryColor),
                      labelText: 'اسم مستخدم المالك (Username)',
                    ),
                    labalText: 'اسم مستخدم المالك',
                    keyData: "username",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: ownerNameController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                      labelText: 'اسم المالك بالكامل',
                    ),
                    labalText: 'اسم المالك',
                    keyData: "ownerName",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: ownerEmailController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline, color: Theme.of(context).primaryColor),
                      labelText: 'البريد الإلكتروني للمالك',
                    ),
                    labalText: 'البريد الإلكتروني للمالك',
                    keyData: "ownerEmail",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: ownerPasswordController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                      labelText: 'كلمة مرور المالك',
                    ),
                    labalText: 'كلمة المرور',
                    keyData: "ownerPassword",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: ownerPhoneController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone_android, color: Theme.of(context).primaryColor),
                      labelText: 'رقم هاتف المالك',
                    ),
                    labalText: 'رقم الهاتف للمالك',
                    keyData: "ownerPhone",
                  ),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: ownerAddressController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
                      labelText: 'عنوان المالك',
                    ),
                    labalText: 'عنوان المالك',
                    keyData: "ownerAddress",
                  ),
                  const SizedBox(height: 32),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoad ? null : saveOrganization,
                      icon: isLoad
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add_business),
                      label: Text(
                        isLoad ? 'جاري الإنشاء...' : 'إنشاء المنظمة والمالك',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
