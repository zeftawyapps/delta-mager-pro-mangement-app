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
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';

class UserInputForm extends StatefulWidget {
  final UserViewProfileModel? user;
  final String? organizationId;

  const UserInputForm({super.key, this.user, this.organizationId});

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

  List<String> selectedRoles = [];
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
    selectedRoles = List<String>.from(widget.user?.roles ?? []);
    isActive = widget.user?.isActiveProfile ?? true;

    // Load roles if not loaded
    context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
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
        organizationId: widget.organizationId,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.user != null
                      ? 'تم تحديث المستخدم بنجاح'
                      : 'تم إضافة المستخدم بنجاح',
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
                    widget.user != null ? "تعديل مستخدم" : "إضافة مستخدم جديد",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
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
                  TextFomrFildValidtion(
                    controller: addressController,
                    form: form,
                    baseValidation: const [],
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    labalText: 'العنوان',
                    keyData: "address",
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "اختيار الأدوار",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text("دور مخصص", style: TextStyle(fontSize: 12)),
                        onPressed: _createNewCustomRole,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRolesSelection(),
                  const SizedBox(height: 16),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
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
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
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

            // Filter roles if not in admin mode
            final isAdminMode = AppShellConfigs.isAdminMode;
            final filteredRoles = isAdminMode
                ? roles
                : roles.where((role) {
                    final name = role.name.toLowerCase();
                    return name != 'admin' && name != 'organizationowner';
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

  void _createNewCustomRole() {
    showCustomInputDialog(
      context: context,
      content: RoleInputForm(organizationId: widget.organizationId),
      height: 750,
      width: 650,
      onResult: (result) {
        // Refresh the roles list
        context.read<RolesBloc>().loadRoles(organizationId: widget.organizationId);
      },
    );
  }
}
