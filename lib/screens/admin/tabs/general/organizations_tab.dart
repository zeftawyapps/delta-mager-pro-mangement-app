import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/grid_view_model.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import '../../../inputs/organization_input_form.dart';
import '../../../inputs/clone_organization_form.dart';
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
    return BlocBuilder<
      AdminOrganizationsBloc,
      FeaturDataSourceState<OrganizationModel>
    >(
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
                final crossAxisCount = layoutWidth < 650
                    ? 2
                    : layoutWidth < 900
                    ? 3
                    : 4;

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GridViewModel<OrganizationModel>(
                    data: organizations ?? [],
                    canAdd: true,
                    onAdd: () => _addOrganization(context),
                    listItem: (index, organization) {
                      return OrganizationCardItem(
                        organization: organization,
                        isDark: isDark,
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
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
                  const Icon(
                    Icons.error_outline,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.message ?? 'حدث خطأ غير معروف',
                    style: const TextStyle(color: Colors.orange),
                  ),
                  TextButton(
                    onPressed: () => context
                        .read<AdminOrganizationsBloc>()
                        .loadActiveOrganizations(),
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
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrganizationDetailScreen(organization: widget.organization),
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
                    : (widget.isDark
                          ? DarkColors.divider.withOpacity(0.2)
                          : LightColors.divider.withOpacity(0.2)),
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
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: widget.organization.isTemplate
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'قالب',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: widget.isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'clone') {
                        _showCloneDialog(context);
                      } else if (value == 'delete') {
                        _showDeleteConfirm(context);
                      } else if (value == 'template') {
                        context
                            .read<AdminOrganizationsBloc>()
                            .setTemplateStatus(
                              id: widget.organization.id,
                              isTemplate: !widget.organization.isTemplate,
                            );
                      } else if (value == 'toggle_active') {
                        if (widget.organization.isActive) {
                          context
                              .read<AdminOrganizationsBloc>()
                              .deactivateOrganization(widget.organization.id);
                        } else {
                          context
                              .read<AdminOrganizationsBloc>()
                              .activateOrganization(widget.organization.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'clone',
                        child: Row(
                          children: [
                            const Icon(Icons.copy_all_rounded, size: 18),
                            const SizedBox(width: 8),
                            const Text('نسخ من (Clone)'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'template',
                        child: Row(
                          children: [
                            Icon(
                              widget.organization.isTemplate
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.organization.isTemplate
                                  ? 'إزالة كقالب'
                                  : 'تعيين كقالب',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle_active',
                        child: Row(
                          children: [
                            Icon(
                              widget.organization.isActive
                                  ? Icons.block_flipped
                                  : Icons.check_circle_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.organization.isActive
                                  ? 'تعطيل المنظمة'
                                  : 'تفعيل المنظمة',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'حذف',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isHovered ? 85 : 80,
                        height: _isHovered ? 85 : 80,
                        decoration: BoxDecoration(
                          color:
                              (_isHovered
                                      ? primaryColor
                                      : (widget.isDark
                                            ? DarkColors.primary
                                            : LightColors.primary))
                                  .withOpacity(_isHovered ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(
                              _isHovered ? 0.3 : 0.2,
                            ),
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
                          color: widget.isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.organization.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.organization.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '${widget.organization.orgName}/login',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final link =
                                    '${widget.organization.orgName}/login';
                                Clipboard.setData(ClipboardData(text: link));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ الرابط المختصر'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCloneDialog(BuildContext context) {
    showCustomInputDialog(
      context: context,
      content: CloneOrganizationForm(
        targetOrganization: widget.organization,
        isDark: widget.isDark,
      ),
      height: 550,
      width: 450,
      onResult: (result) {
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('جاري بدء عملية الاستنساخ...')),
          );
        }
      },
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنظمة'),
        content: Text(
          'هل أنت متأكد من حذف ${widget.organization.name}؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminOrganizationsBloc>().deleteOrganization(
                widget.organization.id,
              );
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
