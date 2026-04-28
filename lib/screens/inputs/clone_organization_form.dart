import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class CloneOrganizationForm extends StatefulWidget {
  final OrganizationModel targetOrganization;
  final bool isDark;

  const CloneOrganizationForm({
    super.key,
    required this.targetOrganization,
    required this.isDark,
  });

  @override
  State<CloneOrganizationForm> createState() => _CloneOrganizationFormState();
}

class _CloneOrganizationFormState extends State<CloneOrganizationForm> {
  String? _selectedTemplateId;
  bool _overwrite = true;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;
    final surfaceColor = widget.isDark
        ? DarkColors.surface
        : LightColors.surface;
    final secondaryTextColor = widget.isDark
        ? DarkColors.textSecondary
        : LightColors.textSecondary;

    return BlocListener<
      AdminOrganizationsBloc,
      FeaturDataSourceState<OrganizationModel>
    >(
      listenWhen: (previous, current) =>
          previous.itemState != current.itemState,
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم الاستنساخ بنجاح')));
            Navigator.of(context).pop();
          },
          failure: (error, _) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('خطأ: ${error.message}')));
          },
          orElse: () {},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.copy_all_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'استنساخ الإعدادات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                      Text(
                        'إلى: ${widget.targetOrganization.name}',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'اختر المنظمة المصدر (القالب):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            BlocBuilder<
              AdminOrganizationsBloc,
              FeaturDataSourceState<OrganizationModel>
            >(
              builder: (context, state) {
                return state.listState.maybeWhen(
                  success: (organizations) {
                    final templateOrganizations =
                        organizations
                            ?.where(
                              (org) =>
                                  org.isTemplate &&
                                  org.id != widget.targetOrganization.id,
                            )
                            .toList() ??
                        [];

                    if (templateOrganizations.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'لا توجد قوالب (Templates) متاحة للنسخ منها حالياً',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.amber, fontSize: 13),
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedTemplateId,
                      dropdownColor: surfaceColor,
                      hint: const Text('اختر القالب المصدر'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.auto_awesome_motion_rounded,
                        ),
                        filled: true,
                        fillColor: primaryColor.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: templateOrganizations.map((org) {
                        return DropdownMenuItem<String>(
                          value: org.id,
                          child: Text(org.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTemplateId = value;
                        });
                      },
                    );
                  },
                  orElse: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'وضع الإحلال (Overwrite)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _overwrite
                          ? 'سيتم حذف الإعدادات القديمة واستبدالها بالكامل'
                          : 'سيتم دمج الإعدادات الجديدة مع الإبقاء على القديمة',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                    value: _overwrite,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _overwrite = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<
              AdminOrganizationsBloc,
              FeaturDataSourceState<OrganizationModel>
            >(
              builder: (context, state) {
                final isLoading = state.itemState.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );

                return ElevatedButton(
                  onPressed: (_selectedTemplateId == null || isLoading)
                      ? null
                      : () {
                          context
                              .read<AdminOrganizationsBloc>()
                              .cloneOrganization(
                                templateOrgId: _selectedTemplateId!,
                                targetOrgId: widget.targetOrganization.id,
                                overwrite: _overwrite,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline_rounded),
                      const SizedBox(width: 8),
                      Text(
                        isLoading ? 'جاري الاستنساخ...' : 'بدء عملية الاستنساخ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: widget.isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
