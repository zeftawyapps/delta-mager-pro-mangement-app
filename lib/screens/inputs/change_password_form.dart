import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/form_validations.dart';
import 'package:JoDija_tamplites/util/widgits/input_form_validation/widgets/text_form_vlidation.dart';
import 'package:JoDija_tamplites/util/validators/required_validator.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final ValidationsForm form = ValidationsForm();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, FeaturDataSourceState>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تغيير كلمة المرور بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          },
          failure: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message ?? 'فشل تغيير كلمة المرور'),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_reset, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                const Text(
                  "تغيير كلمة المرور",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            form.buildChildrenWithColumn(
              context: context,
              children: [
                TextFomrFildValidtion(
                  controller: newPasswordController,
                  form: form,
                  baseValidation: [RequiredValidator()],
                  isPssword: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: Icon(Icons.lock_open),
                  ),
                  labalText: 'كلمة المرور الجديدة',
                  keyData: 'new_password',
                ),
                const SizedBox(height: 16),
                TextFomrFildValidtion(
                  controller: confirmPasswordController,
                  form: form,
                  baseValidation: [
                    RequiredValidator(),
                    _MatchValidator(newPasswordController),
                  ],
                  isPssword: true,
                  decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور الجديدة',
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                  labalText: 'تأكيد كلمة المرور الجديدة',
                  keyData: 'confirm_password',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("إلغاء"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BlocBuilder<AuthBloc, FeaturDataSourceState>(
                    builder: (context, state) {
                      final isLoading = state.itemState.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      );

                      return ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Text("تحديث كلمة المرور"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (form.form.currentState!.validate()) {
      // جلب بيانات المستخدم الحالي من الـ AppChangesValues
      final user = context.read<AppChangesValues>().user;
      final identifier = user?.email ?? user?.username ?? "";

      context.read<AuthBloc>().changePassword(
        identifier: identifier,
        newPassword: newPasswordController.text,
      );
    }
  }
}

class _MatchValidator extends RequiredValidator {
  final TextEditingController otherController;

  _MatchValidator(this.otherController);

  @override
  bool validate(String? value) {
    // إذا كانت القيمة فارغة، نترك التحقق للـ RequiredValidator الأساسي الموجود في القائمة
    if (value == null || value.isEmpty) {
      return true;
    }

    return value == otherController.text;
  }
}
