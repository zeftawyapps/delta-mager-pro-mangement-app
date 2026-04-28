import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/location_models.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/drobdaown_validation.dart';
import '../../logic/model/organization_model.dart';

class OrganizationInputForm extends StatefulWidget {
  final OrganizationModel? organization;
  const OrganizationInputForm({super.key, this.organization});

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

  // Location Selections
  String? selectedCountryId;
  String? selectedGovernorateId;
  String? selectedCityId;

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
    orgNameController = TextEditingController(text: widget.organization?.orgName ?? '');
    nameController = TextEditingController(text: widget.organization?.name ?? '');
    emailController = TextEditingController(text: widget.organization?.email ?? '');
    phoneController = TextEditingController(text: widget.organization?.phone ?? '');
    addressController = TextEditingController(text: widget.organization?.address ?? '');

    selectedCountryId = widget.organization?.countryId;
    selectedGovernorateId = widget.organization?.governorateId;
    selectedCityId = widget.organization?.cityId;

    ownerUsernameController = TextEditingController();
    ownerEmailController = TextEditingController();
    ownerPasswordController = TextEditingController();
    ownerPhoneController = TextEditingController();
    ownerNameController = TextEditingController();
    ownerAddressController = TextEditingController();

    // Load countries on init
    context.read<LocationsBloc>().loadCountries();
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

    final orgData = OrganizationModel(
      id: '',
      orgName: orgNameController.text.trim(),
      name: nameController.text.trim(),
      ownerId: '', // Owner will be created backend
      address: addressController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      countryId: selectedCountryId,
      governorateId: selectedGovernorateId,
      cityId: selectedCityId,
      location: LocationData(latitude: 30.0444, longitude: 31.2357),
    );

    context.read<OrganizationsBloc>().createOrganizationWithOwner(
      userData: userData,
      organizationData: orgData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      OrganizationsBloc,
      FeaturDataSourceState<OrganizationModel>
    >(
      listener: (context, state) {
        state.itemState.maybeWhen(
          orElse: () {},
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إنشاء المنظمة بنجاح')),
            );
            if (Navigator.canPop(context)) {
              Navigator.of(context).maybePop(data);
            }
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  '❌ ${error.message ?? 'خطأ في الإدخال راجع الدعم الفني'}',
                ),
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
                  Text(
                    widget.organization != null ? "تعديل بيانات المنظمة" : "بيانات إنشاء منظمة جديدة",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      prefixIcon: Icon(
                        Icons.label,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.business,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'اسم المنظمة (العرض)',
                    ),
                    labalText: 'اسم المنظمة',
                    keyData: "name",
                  ),
                  const SizedBox(height: 16),

                  // --- الموقع الجغرافي (هرمي) ---
                  // 1. الدولة
                  BlocBuilder<LocationsBloc, LocationsState>(
                    buildWhen: (p, c) => p.countriesState != c.countriesState,
                    builder: (context, locState) {
                      final countries = locState.countriesState.maybeWhen(
                        success: (data) => data ?? [],
                        orElse: () => <CountryModel>[],
                      );

                      return DropdownButtonFormField<String>(
                        value: selectedCountryId,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.public,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: 'الدولة',
                          border: const OutlineInputBorder(),
                        ),
                        items: countries
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.nameAr),
                              ),
                            )
                            .toList(),
                        validator: (value) =>
                            value == null ? 'يرجى اختيار الدولة' : null,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedCountryId = val;
                              selectedGovernorateId = null;
                              selectedCityId = null;
                              context.read<LocationsBloc>().loadGovernorates(
                                val,
                              );
                            });
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. المحافظة
                  BlocBuilder<LocationsBloc, LocationsState>(
                    builder: (context, locState) {
                      final govs = locState.governoratesState.maybeWhen(
                        success: (data) => data ?? [],
                        orElse: () => <GovernorateModel>[],
                      );
                      final isGovLoading = locState.governoratesState.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey('gov_field_$selectedCountryId'),
                            value: selectedGovernorateId,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.map,
                                color: selectedCountryId == null
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                              ),
                              labelText: isGovLoading
                                  ? 'جاري التحميل...'
                                  : 'المحافظة',
                              border: const OutlineInputBorder(),
                            ),
                            items: govs
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g.id,
                                    child: Text(g.nameAr),
                                  ),
                                )
                                .toList(),
                            validator: (value) =>
                                value == null ? 'يرجى اختيار المحافظة' : null,
                            onChanged: selectedCountryId == null || isGovLoading
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setState(() {
                                        selectedGovernorateId = val;
                                        selectedCityId = null;
                                      });
                                      context.read<LocationsBloc>().loadCities(
                                        val,
                                      );
                                    }
                                  },
                          ),
                          if (isGovLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 8, right: 8),
                              child: LinearProgressIndicator(minHeight: 2),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. المدينة
                  BlocBuilder<LocationsBloc, LocationsState>(
                    builder: (context, locState) {
                      final cities = locState.citiesState.maybeWhen(
                        success: (data) => data ?? [],
                        orElse: () => <CityModel>[],
                      );
                      final isCityLoading = locState.citiesState.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey('city_field_$selectedGovernorateId'),
                            value: selectedCityId,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: selectedGovernorateId == null
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                              ),
                              labelText: isCityLoading
                                  ? 'جاري التحميل...'
                                  : 'المدينة',
                              border: const OutlineInputBorder(),
                            ),
                            items: cities
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.nameAr),
                                  ),
                                )
                                .toList(),
                            validator: (value) =>
                                value == null ? 'يرجى اختيار المدينة' : null,
                            onChanged:
                                selectedGovernorateId == null || isCityLoading
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setState(() => selectedCityId = val);
                                    }
                                  },
                          ),
                          if (isCityLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 8, right: 8),
                              child: LinearProgressIndicator(minHeight: 2),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  TextFomrFildValidtion(
                    controller: emailController,
                    form: form,
                    baseValidation: [RequiredValidator()],
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: Theme.of(context).primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.home,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'عنوان المالك',
                    ),
                    labalText: 'عنوان المالك',
                    keyData: "ownerAddress",
                  ),
                  const SizedBox(height: 32),
                  // أزرار الحفظ والإلغاء
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
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
                                : Icon(
                                  widget.organization != null
                                      ? Icons.edit
                                      : Icons.add_business,
                                ),
                            label: Text(
                              isLoad
                                  ? 'جاري الحفظ...'
                                  : (widget.organization != null
                                      ? 'تحديث البيانات'
                                      : 'إنشاء المنظمة والمالك'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: const Text(
                              "إلغاء",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
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
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
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
