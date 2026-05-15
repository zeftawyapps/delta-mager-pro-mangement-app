import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/location_models.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class ProfileInputForm extends StatefulWidget {
  final UserViewProfileModel user;
  final String? organizationId;

  const ProfileInputForm({super.key, required this.user, this.organizationId});

  @override
  State<ProfileInputForm> createState() => _ProfileInputFormState();
}

class _ProfileInputFormState extends State<ProfileInputForm> {
  final ValidationsForm form = ValidationsForm();
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  String? _selectedGovernorate;
  String? _selectedCity;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    addressController = TextEditingController(text: widget.user.address ?? '');
    _selectedGovernorate = widget.user.governorateId;
    _selectedCity = widget.user.cityId;
    _selectedCountry = widget.user.countryId ?? 'EG';

    // Load governorates for the country
    context.read<LocationsBloc>().loadGovernorates(_selectedCountry);

    // Load cities if governorate is already selected
    if (_selectedGovernorate != null) {
      context.read<LocationsBloc>().loadCities(_selectedGovernorate!);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void saveProfile() {
    if (!form.form.currentState!.validate()) return;

    context.read<UsersBloc>().updateMyProfile(
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      organizationId: widget.organizationId,
      countryId: _selectedCountry,
      governorateId: _selectedGovernorate,
      cityId: _selectedCity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsersBloc, FeaturDataSourceState<UserViewProfileModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
            );
            if (data != null) {
              context.read<AppChangesValues>().setUserProfile(data);
            }
            Navigator.of(context).maybePop(data);
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('❌ خطأ: ${error.message}'),
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isSaving = state.itemState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: form.form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFomrFildValidtion(
                  controller: usernameController,
                  form: form,
                  baseValidation: [RequiredValidator()],
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    prefixIcon: Icon(Icons.person),
                  ),
                  labalText: 'اسم المستخدم',
                  keyData: "username",
                ),
                const SizedBox(height: 16),
                TextFomrFildValidtion(
                  controller: emailController,
                  form: form,
                  baseValidation: [RequiredValidator()],
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email),
                  ),
                  labalText: 'البريد الإلكتروني',
                  keyData: "email",
                ),
                const SizedBox(height: 16),
                TextFomrFildValidtion(
                  controller: phoneController,
                  form: form,
                  baseValidation: [RequiredValidator()],
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  labalText: 'رقم الهاتف',
                  keyData: "phone",
                ),
                const SizedBox(height: 16),
                _buildGovernorateDropdown(),
                const SizedBox(height: 16),
                _buildCityDropdown(),
                const SizedBox(height: 16),
                TextFomrFildValidtion(
                  controller: addressController,
                  form: form,
                  baseValidation: [RequiredValidator()],
                  decoration: const InputDecoration(
                    labelText: 'العنوان بالتفصيل',
                    prefixIcon: Icon(Icons.home),
                  ),
                  labalText: 'العنوان بالتفصيل',
                  keyData: "address",
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isSaving ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'حفظ التغييرات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGovernorateDropdown() {
    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, state) {
        final governorates = state.governoratesState.maybeWhen(
          success: (data) => data ?? [],
          orElse: () => <GovernorateModel>[],
        );

        final isLoading = state.governoratesState.maybeWhen(loading: () => true, orElse: () => false);

        // التأكد من أن القيمة المختارة موجودة في القائمة ومطابقتها بشكل مرن
        String? currentValue;
        try {
          if (_selectedGovernorate != null && governorates.isNotEmpty) {
            currentValue = governorates.firstWhere(
              (g) => g.id.toString().trim() == _selectedGovernorate?.toString().trim()
            ).id.toString();
          }
        } catch (_) {}

        return DropdownButtonFormField<String>(
          value: currentValue,
          hint: isLoading ? const Text('جاري تحميل المحافظات...') : null,
          decoration: const InputDecoration(
            labelText: 'المحافظة',
            prefixIcon: Icon(Icons.map),
          ),
          items: governorates.map((gov) {
            return DropdownMenuItem<String>(
              value: gov.id.toString(),
              child: Text(gov.nameAr),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedGovernorate = value;
              _selectedCity = null; // Reset city when governorate changes
            });
            if (value != null) {
              context.read<LocationsBloc>().loadCities(value);
            }
          },
          validator: (value) => value == null ? 'يرجى اختيار المحافظة' : null,
        );
      },
    );
  }

  Widget _buildCityDropdown() {
    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, state) {
        final cities = state.citiesState.maybeWhen(
          success: (data) => data ?? [],
          orElse: () => <CityModel>[],
        );

        final isLoading = state.citiesState.maybeWhen(loading: () => true, orElse: () => false);

        // التأكد من أن القيمة المختارة موجودة في القائمة
        String? currentValue;
        try {
          if (_selectedCity != null && cities.isNotEmpty) {
             currentValue = cities.firstWhere(
              (c) => c.id.toString().trim() == _selectedCity?.toString().trim()
            ).id.toString();
          }
        } catch (_) {}

        return DropdownButtonFormField<String>(
          value: currentValue,
          hint: isLoading ? const Text('جاري تحميل المدن...') : null,
          decoration: const InputDecoration(
            labelText: 'المدينة',
            prefixIcon: Icon(Icons.location_city),
          ),
          items: cities.map((city) {
            return DropdownMenuItem<String>(
              value: city.id.toString(),
              child: Text(city.nameAr),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedCity = value;
            });
          },
          validator: (value) => value == null ? 'يرجى اختيار المدينة' : null,
        );
      },
    );
  }
}
