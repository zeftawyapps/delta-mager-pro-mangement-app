import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:JoDija_tamplites/util/validators/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/role_input_form.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/location_models.dart';

class UserInputForm extends StatefulWidget {
  final UserViewProfileModel? user;
  final String? organizationId;
  final bool isCustomer;

  const UserInputForm({
    super.key,
    this.user,
    this.organizationId,
    this.isCustomer = false,
  });

  @override
  State<UserInputForm> createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final ValidationsForm form = ValidationsForm();

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;

  List<String> selectedRoles = [];
  String? _selectedGovernorate;
  String? _selectedCountry;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    emailController = TextEditingController(text: widget.user?.email ?? '');
    passwordController = TextEditingController(text: '');
    phoneController = TextEditingController(text: widget.user?.phone ?? '');
    addressController = TextEditingController(text: widget.user?.address ?? '');
    cityController = TextEditingController(text: widget.user?.cityId ?? '');
    _selectedGovernorate = widget.user?.governorateId;
    _selectedCountry = widget.user?.countryId ?? 'EG';
    selectedRoles = List<String>.from(widget.user?.roles ?? []);
    isActive = widget.user?.isActiveProfile ?? true;

    // Load roles
    context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
    // Load governorates using the default/selected country ID ('EG')
    context.read<LocationsBloc>().loadGovernorates(_selectedCountry);
    // Load cities if a governorate is already selected (editing mode)
    if (_selectedGovernorate != null) {
      context.read<LocationsBloc>().loadCities(_selectedGovernorate!);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void saveUser() {
    if (!form.form.currentState!.validate()) return;

    final usersBloc = context.read<UsersBloc>();
    if (widget.user != null) {
      usersBloc.updateUser(
        userId: widget.user!.userId,
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        isActive: isActive,
        roles: selectedRoles,
        organizationId: widget.organizationId,
        countryId: _selectedCountry,
        governorateId: _selectedGovernorate,
        cityId: cityController.text.trim(),
      );
    } else {
      usersBloc.createUser(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim(),
        roles: selectedRoles,
        address: addressController.text.trim(),
        organizationId: widget.organizationId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsersBloc, FeaturDataSourceState<UserViewProfileModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          orElse: () {},
          success: (data) {
            final isCustomer = widget.isCustomer;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.user != null
                      ? (isCustomer ? 'تم تحديث الزبون بنجاح' : 'تم تحديث المستخدم بنجاح')
                      : (isCustomer ? 'تم إضافة الزبون بنجاح' : 'تم إضافة المستخدم بنجاح'),
                ),
              ),
            );
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
        final isSaving = state.itemState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CloseButton(),
                  Text(
                    widget.user != null 
                        ? (widget.isCustomer ? "تعديل بيانات الزبون" : "تعديل مستخدم")
                        : (widget.isCustomer ? "إضافة زبون" : "إضافة مستخدم جديد"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.isCustomer) _buildUpgradeRequestSection(),
              form.buildChildrenWithColumn(
                context: context,
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
                    baseValidation: [RequiredValidator(), EmailValidator()],
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                    ),
                    labalText: 'البريد الإلكتروني',
                    keyData: "email",
                  ),
                  const SizedBox(height: 16),
                  if (widget.user == null)
                    TextFomrFildValidtion(
                      controller: passwordController,
                      form: form,
                      baseValidation: [RequiredValidator()],
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      labalText: 'كلمة المرور',
                      keyData: "password",
                      isPssword: true,
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
                  const SizedBox(height: 24),
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "اختيار الأدوار",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 🔒 إخفاء زر إنشاء دور جديد للزبائن
                      if (!widget.isCustomer)
                        TextButton.icon(
                          onPressed: _createNewCustomRole,
                          icon: const Icon(Icons.add),
                          label: const Text("دور جديد"),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRolesSelection(),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("نشط"),
                    subtitle: const Text("تفعيل أو تعطيل حساب المستخدم"),
                    value: isActive,
                    onChanged: (val) => setState(() => isActive = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : saveUser,
                        icon: isSaving
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
                          isSaving
                              ? 'جاري الحفظ...'
                              : (widget.user != null ? 'تحديث' : 'حفظ'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
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
        );
      },
    );
  }

  Widget _buildRolesSelection() {
    return BlocBuilder<RolesBloc, FeaturDataSourceState<RoleModel>>(
      builder: (context, state) {
        return state.listState.when(
          init: () => const Text("جاري تحميل الأدوار..."),
          loading: () => const CircularProgressIndicator(),
          success: (roles) {
            if (roles == null || roles.isEmpty) {
              return const Text("لا توجد أدوار متاحة");
            }

            // Filter roles based on whether we are in customer context or staff context
            final isAdminMode = AppShellConfigs.isAdminMode;
            final isTargetCustomer = widget.isCustomer;

            final filteredRoles = roles.where((role) {
              if (isTargetCustomer) {
                // 🛡️ للزبائن: فقط الأدوار التي تم تعليمها كأدوار زبائن
                return role.isCustomerRole == true;
              } else {
                // 🛡️ للموظفين: الأدوار التي ليست للزبائن
                if (!isAdminMode) {
                  final name = role.name.toLowerCase();
                  if (name == 'admin' || name == 'organizationowner') {
                    return false;
                  }
                }
                return role.isCustomerRole == false;
              }
            }).toList();

            if (filteredRoles.isEmpty) {
              return const Text("لا توجد أدوار متاحة للتخصيص");
            }

            return Wrap(
              spacing: 8,
              children: filteredRoles.map((role) {
                final isSelected = selectedRoles.contains(role.name);
                return FilterChip(
                  label: Text(role.displayName ?? role.name),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedRoles.add(role.name);
                      } else {
                        selectedRoles.remove(role.name);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
          failure: (err, reload) =>
              Text("خطأ في تحميل الأدوار: ${err.message}"),
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

        final isLoading = state.governoratesState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        // التأكد من أن القيمة المختارة موجودة في القائمة ومطابقتها بشكل مرن
        String? currentValue;
        try {
          if (_selectedGovernorate != null && governorates.isNotEmpty) {
            currentValue = governorates
                .firstWhere(
                  (g) =>
                      g.id.toString().trim() ==
                      _selectedGovernorate?.toString().trim(),
                )
                .id
                .toString();
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
              cityController.clear(); // مسح المدينة عند تغيير المحافظة
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

        final isLoading = state.citiesState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        // التأكد من أن القيمة المختارة موجودة في القائمة ومطابقتها بشكل مرن
        String? currentValue;
        try {
          if (cityController.text.isNotEmpty && cities.isNotEmpty) {
            currentValue = cities
                .firstWhere(
                  (c) => c.id.toString().trim() == cityController.text.trim(),
                )
                .id
                .toString();
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
          onChanged: _selectedGovernorate == null
              ? null
              : (String? value) {
                  setState(() {
                    cityController.text = value ?? '';
                  });
                },
          validator: (value) =>
              value == null || value.isEmpty ? 'يرجى اختيار المدينة' : null,
          disabledHint: const Text('يرجى اختيار المحافظة أولاً'),
        );
      },
    );
  }

  void _createNewCustomRole() {
    showCustomInputDialog(
      context: context,
      content: RoleInputForm(organizationId: widget.organizationId),
      height: 750,
      width: 650,
      onResult: (result) {
        // Refresh the roles list
        context.read<RolesBloc>().loadRoles(
          organizationId: widget.organizationId,
        );
      },
    );
  }

  Widget _buildUpgradeRequestSection() {
    if (widget.user == null) return const SizedBox.shrink();
    final additionalInfo = widget.user!.additionalInfo ?? {};
    final status = additionalInfo['wholesalerUpgradeStatus']?.toString();
    if (status != 'pending' && status != 'approved_pending_code') {
      return const SizedBox.shrink();
    }

    final shopName = additionalInfo['wholesalerShopName']?.toString() ?? '';
    final taxId = additionalInfo['wholesalerTaxId']?.toString() ?? '';
    final requestedRole = additionalInfo['requestedUpgradeRole']?.toString() ?? 'wholesaler';
    final code = additionalInfo['wholesalerRequestCode']?.toString();

    final isPending = status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPending ? Colors.amber.withOpacity(0.3) : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: isPending ? Colors.amber.withOpacity(0.04) : Colors.green.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storefront_rounded,
                  color: isPending ? Colors.amber : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  isPending ? 'طلب ترقية معلق' : 'طلب مقبول وبانتظار التفعيل',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPending ? Colors.amber.shade900 : Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUpgradeInfoRow("الدور المطلوب:", requestedRole),
            _buildUpgradeInfoRow("اسم المحل/المنشأة:", shopName),
            if (taxId.isNotEmpty) _buildUpgradeInfoRow("السجل التجاري/الرقم الضريبي:", taxId),
            if (code != null) _buildUpgradeInfoRow("رمز التفعيل المولد:", code),
            const SizedBox(height: 16),
            if (isPending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _approveUpgradeRequest,
                  icon: const Icon(Icons.check),
                  label: const Text('قبول الطلب وتوليد كود التفعيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (code != null) {
                          _sendWhatsApp(widget.user!.phone, widget.user!.username ?? 'تاجر', code);
                        }
                      },
                      icon: const Icon(Icons.message, color: Colors.green),
                      label: const Text('إرسال بالواتساب', style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _activateUpgradeRequest,
                      icon: const Icon(Icons.verified_user),
                      label: const Text('تفعيل الترقية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _approveUpgradeRequest() {
    final user = widget.user!;
    final random = Random();
    final generatedCode = (1000 + random.nextInt(9000)).toString();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('قبول الطلب وتوليد كود التفعيل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المستخدم: ${user.username ?? user.email}'),
              const SizedBox(height: 8),
              Text(
                'كود التفعيل المقترح: $generatedCode',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'سيتم تحديث حالة المستخدم إلى "مقبول بانتظار التفعيل" وفتح محادثة الواتساب تلقائياً لإرسال الكود.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);

                context.read<UsersBloc>().updateUser(
                  userId: user.userId,
                  username: user.username,
                  email: user.email,
                  phone: user.phone,
                  address: user.address,
                  isActive: user.isActiveProfile,
                  roles: user.roles,
                  organizationId: user.organizationId,
                  countryId: user.countryId,
                  governorateId: user.governorateId,
                  cityId: user.cityId,
                  additionalFields: {
                    ...user.additionalInfo ?? {},
                    'wholesalerUpgradeStatus': 'approved_pending_code',
                    'wholesalerRequestCode': generatedCode,
                  },
                );

                await _sendWhatsApp(
                  user.phone,
                  user.username ?? 'تاجر',
                  generatedCode,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'تأكيد وإرسال بالواتساب',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _activateUpgradeRequest() {
    final user = widget.user!;
    final additionalInfo = user.additionalInfo ?? {};
    final requestedRole = additionalInfo['requestedUpgradeRole']?.toString() ?? 'wholesaler';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('تفعيل الحساب والترقية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المستخدم: ${user.username ?? user.email}'),
              const SizedBox(height: 8),
              Text(
                'الدور المطلوب الترقية إليه: $requestedRole',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('هل أنت متأكد من تفعيل هذا الحساب وترقيته إلى الدور المطلوب مباشرة؟'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);

                final currentRoles = List<String>.from(user.roles);
                if (!currentRoles.contains(requestedRole)) {
                  currentRoles.add(requestedRole);
                }

                context.read<UsersBloc>().updateUser(
                  userId: user.userId,
                  username: user.username,
                  email: user.email,
                  phone: user.phone,
                  address: user.address,
                  isActive: user.isActiveProfile,
                  roles: currentRoles,
                  organizationId: user.organizationId,
                  countryId: user.countryId,
                  governorateId: user.governorateId,
                  cityId: user.cityId,
                  additionalFields: {
                    ...additionalInfo,
                    'wholesalerUpgradeStatus': 'activated',
                  },
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ تم تفعيل حساب العميل وترقيته لدور ($requestedRole) بنجاح!',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                'تأكيد التفعيل',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendWhatsApp(String phone, String name, String code) async {
    var formattedPhone = phone.trim();
    if (!formattedPhone.startsWith('+') && !formattedPhone.startsWith('00')) {
      if (formattedPhone.startsWith('01')) {
        formattedPhone = '+20$formattedPhone';
      }
    }

    final message =
        'مرحباً $name، تم قبول طلب الترقية لحساب الجملة الخاص بك. رمز التفعيل لتأكيد الحساب هو: $code';
    final url = Uri.parse(
      'https://wa.me/${formattedPhone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح الواتساب للرقم: $formattedPhone. الكود هو: $code',
            ),
          ),
        );
      }
    }
  }
}
