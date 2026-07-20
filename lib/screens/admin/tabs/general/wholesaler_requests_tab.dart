import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/role_requests_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role_upgrade_request.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/auth_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class WholesalerRequestsTab extends StatefulWidget {
  final bool isDark;
  final String? organizationIdFromRoute;

  const WholesalerRequestsTab({
    super.key,
    required this.isDark,
    this.organizationIdFromRoute,
  });

  @override
  State<WholesalerRequestsTab> createState() => _WholesalerRequestsTabState();
}

class _WholesalerRequestsTabState extends State<WholesalerRequestsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleRequestsBloc>().loadRequests(organizationId: _getOrgId());
    });
  }

  String? _getOrgId() {
    if (widget.organizationIdFromRoute != null &&
        widget.organizationIdFromRoute != "" &&
        widget.organizationIdFromRoute != ":orgName") {
      return widget.organizationIdFromRoute;
    }

    final isAdmin = AppShellConfigs.isAdminMode;
    if (isAdmin) return null;

    final authState = context.read<AuthBloc>().state;
    return authState.itemState.maybeWhen(
      success: (user) => user?.organizationId,
      orElse: () => null,
    );
  }

  void _approveRequest(RoleUpgradeRequest request) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('قبول الطلب وتوليد كود التفعيل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المستخدم: ${request.username ?? request.email ?? request.userId}'),
              const SizedBox(height: 8),
              Text(
                'الدور المطلوب الترقية إليه: ${request.requestedRoleName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'سيتم توليد كود التفعيل وحفظه في النظام، وسنفتح محادثة الواتساب تلقائياً لإرساله للعميل لتأكيد حسابه.',
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

                final result = await context.read<RoleRequestsBloc>().approveRequest(
                  request.id!,
                  organizationId: _getOrgId(),
                );

                if (result.success && result.otpCode != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ تم قبول الطلب وتوليد كود التفعيل بنجاح!')),
                  );
                  // Launch WhatsApp to send OTP
                  await _sendWhatsApp(
                    request.phone ?? '',
                    request.username ?? 'عميل',
                    result.otpCode!,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('❌ فشل قبول الطلب: ${result.message}'),
                    ),
                  );
                }
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

  void _rejectRequest(RoleUpgradeRequest request) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('رفض طلب الترقية'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'سبب الرفض',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى كتابة سبب الرفض أولاً')),
                  );
                  return;
                }
                Navigator.pop(dialogCtx);

                final result = await context.read<RoleRequestsBloc>().rejectRequest(
                  request.id!,
                  reason,
                  organizationId: _getOrgId(),
                );

                if (result.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ تم رفض طلب الترقية بنجاح.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('❌ فشل الرفض: ${result.message}'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'تأكيد الرفض',
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
    if (formattedPhone.isEmpty) return;
    if (!formattedPhone.startsWith('+') && !formattedPhone.startsWith('00')) {
      if (formattedPhone.startsWith('01')) {
        formattedPhone = '+20$formattedPhone';
      }
    }

    final message =
        'مرحباً $name، تم قبول طلب الترقية لحسابك. رمز التفعيل لتأكيد الحساب هو: $code';
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

  @override
  Widget build(BuildContext context) {
    return MasterGrid<RoleUpgradeRequest, RoleRequestsBloc>(
      title: "طلبات ترقية الحسابات",
      viewMode: ViewMode.list,
      childAspectRatio: 5,
      searchHint: "البحث في طلبات الترقية...",
      onAdd: () {},
      canAdd: false,
      onLoad: (bloc) => bloc.loadRequests(organizationId: _getOrgId()),
      onSearch: (bloc, query) => bloc.loadRequests(organizationId: _getOrgId()),
      where: (request) {
        // عرض الطلبات المعلقة (pending) والمقبولة بانتظار التفعيل (approved)
        return request.status == 'pending' || request.status == 'approved';
      },
      itemBuilder: (context, requestItem, isSelected) {
        return WholesalerRequestCard(
          request: requestItem,
          isDark: widget.isDark,
          onApprove: () => _approveRequest(requestItem),
          onReject: () => _rejectRequest(requestItem),
          onResendWhatsApp: () {
            if (requestItem.otpCode != null) {
              _sendWhatsApp(
                requestItem.phone ?? '',
                requestItem.username ?? 'عميل',
                requestItem.otpCode!,
              );
            }
          },
        );
      },
      noDataMessage: "لا توجد طلبات ترقية معلقة حالياً",
    );
  }
}

class WholesalerRequestCard extends StatelessWidget {
  final RoleUpgradeRequest request;
  final bool isDark;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onResendWhatsApp;

  const WholesalerRequestCard({
    super.key,
    required this.request,
    required this.isDark,
    required this.onApprove,
    required this.onReject,
    required this.onResendWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;
    final theme = Theme.of(context);

    final status = request.status;
    final shopName = request.shopName;
    final taxId = request.taxId;
    final code = request.otpCode;

    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? Colors.amber.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(Icons.storefront, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      shopName ?? 'اسم المحل غير محدد',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isPending
                            ? Colors.amber.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPending ? 'قيد الانتظار' : 'بانتظار كود التفعيل',
                        style: TextStyle(
                          color: isPending
                              ? Colors.amber.shade800
                              : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'صاحب الطلب: ${request.username ?? "بدون اسم"} - رقم الهاتف: ${request.phone ?? "غير معروف"}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'الدور المطلوب الترقية إليه: ${request.requestedRoleName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                if (taxId != null && taxId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'السجل التجاري/الرقم الضريبي: $taxId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
                if (!isPending && code != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'الكود المولد: $code',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isPending)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('قبول وتوليد كود'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  label: const Text('رفض الطلب', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: onResendWhatsApp,
                  icon: const Icon(
                    Icons.phone_iphone,
                    size: 18,
                    color: Colors.green,
                  ),
                  label: const Text(
                    'إعادة إرسال بالواتساب',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
