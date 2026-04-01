import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/grid_view_model.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import '../../../inputs/organization_input_form.dart';
import '../../organization_detail_screen.dart';

class OrganizationsTab extends StatelessWidget {
  final bool isDark;

  const OrganizationsTab({super.key, required this.isDark});

  void _addOrganization(BuildContext context) {
    showCustomInputDialog(
      context: context,
      content: const OrganizationInputForm(),
      height: 600,
      width: 500,
      onResult: (result) {
        context.read<AdminOrganizationsBloc>().loadActiveOrganizations();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOrganizationsBloc, FeaturDataSourceState<OrganizationModel>>(
      builder: (context, state) {
        return state.listState.when(
          init: () => const Center(child: CircularProgressIndicator()),
          loading: () {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: isDark ? DarkColors.primary : LightColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "جاري تحميل المنظمات الفعالة...",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
          success: (organizations) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final layoutWidth = constraints.maxWidth;
                final crossAxisCount = layoutWidth < 650 ? 2 : layoutWidth < 900 ? 3 : 4;

                return GridViewModel<OrganizationModel>(
                  data: organizations ?? [],
                  canAdd: true,
                  onAdd: () => _addOrganization(context),
                  listItem: (index, organization) {
                    return OrganizationCardItem(organization: organization, isDark: isDark);
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                );
              },
            );
          },
          failure: (error, callback) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                  const SizedBox(height: 16),
                  Text(error.message ?? 'حدث خطأ غير معروف', style: const TextStyle(color: Colors.orange)),
                  TextButton(
                    onPressed: () => context.read<AdminOrganizationsBloc>().loadActiveOrganizations(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class OrganizationCardItem extends StatefulWidget {
  final OrganizationModel organization;
  final bool isDark;

  const OrganizationCardItem({
    super.key,
    required this.organization,
    required this.isDark,
  });

  @override
  State<OrganizationCardItem> createState() => _OrganizationCardItemState();
}

class _OrganizationCardItemState extends State<OrganizationCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrganizationDetailScreen(organization: widget.organization),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isDark ? DarkColors.surface : LightColors.surface,
              border: Border.all(
                color: _isHovered
                    ? primaryColor.withOpacity(0.6)
                    : (widget.isDark ? DarkColors.divider.withOpacity(0.2) : LightColors.divider.withOpacity(0.2)),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? primaryColor.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isHovered ? 85 : 80,
                    height: _isHovered ? 85 : 80,
                    decoration: BoxDecoration(
                      color: (_isHovered ? primaryColor : (widget.isDark ? DarkColors.primary : LightColors.primary)).withOpacity(_isHovered ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(_isHovered ? 0.3 : 0.2),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.store,
                        size: 32,
                        color: _isHovered ? primaryColor : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.organization.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.organization.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.organization.phone,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
