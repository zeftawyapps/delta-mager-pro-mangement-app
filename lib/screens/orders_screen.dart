import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/orders_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/list_view_model.dart';
import 'package:matger_pro_core_logic/features/workflow/workflow_constants.dart';

class OrdersScreen extends StatefulWidget with AppShellRouterMixin {
  final bool canAdd;
  OrdersScreen({super.key, this.canAdd = true});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin, SystemManager {
  TabController? _stepTabController;
  int _selectedWorkflowIndex = 0;

  String get organizationId {
    final params = widget.getPrams();
    final orgName = params?['orgName'];
    if (orgName != null && orgName != "" && orgName != ":orgName") {
      AppRoutes.activeOrgName = orgName;
      return orgName;
    }
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  @override
  void initState() {
    super.initState();
    _loadWorkflows();
  }

  void _loadWorkflows() {
    context.read<WorkflowManagementBloc>().loadSpecificConfig(
      organizationId,
      entityType: 'orders',
    );
  }

  @override
  void dispose() {
    _stepTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.order,
      mainPath: widget.getMainPath(),
      widgetCanAdd: widget.canAdd,
    );

    if (sys.authWidget != null) return sys.authWidget!;

    // ignore: unused_local_variable
    final canAdd = sys.canAdd;
    // ignore: unused_local_variable
    final canUpdate = sys.canUpdate;
    // ignore: unused_local_variable
    final canDelete = sys.canDelete;
    // ignore: unused_local_variable
    final featureConfig = sys.featureConfig;
    final isDark = sys.isDark;
    final appBarConfig = sys.appBarConfig;

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: 'إدارة الطلبات',
        isDesplayTitle: true,
      ),
      body: BlocConsumer<WorkflowManagementBloc, FeaturDataSourceState<WorkflowConfigModel>>(
        listener: (context, state) {
          // استخدام maybeWhen كما في شاشة المنتجات
          state.listState.maybeWhen(
            success: (configs) {
              if (configs != null && configs.isNotEmpty) {
                _initializeTabController(configs);
              }
            },
            orElse: () {},
          );

          // معالجة أخطاء تنفيذ الخطوات (itemState)
          state.itemState.maybeWhen(
            failure: (error, _) {
              _showErrorDialog(context, error.message ?? 'حدث خطأ');
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.listState.when(
            init: () => const SizedBox(),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (configs) {
              if (configs == null || configs.isEmpty) {
                return const Center(
                  child: Text("لا توجد مسارات عمل معرفة لهذه المنظمة"),
                );
              }

              final currentConfig = configs[_selectedWorkflowIndex];
              final steps = currentConfig.workflow.steps;

              return Column(
                children: <Widget>[
                  // 1. اختيار نوع سير العمل (مثلاً: جملة، وكيل، إلخ)
                  if (configs.length > 1) _buildWorkflowSelector(configs),

                  const Divider(height: 1),

                  // 2. خطوات مسار العمل بشكل Chips ملونة
                  if (_stepTabController != null)
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          final s = steps[index];
                          final isSelected = _stepTabController?.index == index;
                          final stepColor = _getStepColor(s);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            margin: const EdgeInsets.only(
                              left: 10,
                              top: 4,
                              bottom: 4,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _stepTabController?.animateTo(index);
                                });
                              },
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: isSelected
                                      ? stepColor
                                      : stepColor.withOpacity(0.08),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : stepColor.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: stepColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    if (isSelected) const SizedBox(width: 8),
                                    Text(
                                      s.stepName.ar,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : stepColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // 3. عرض الطلبات بناءً على سير العمل والخطوة
                  Expanded(
                    child: BlocBuilder<OrdersBloc, FeaturDataSourceState<OrderModel>>(
                      builder: (context, orderState) {
                        return orderState.listState.maybeWhen(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          success: (orders) {
                            if (orders == null || orders.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.shopping_basket_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "لا توجد طلبات في مرحلة ${steps[_stepTabController?.index ?? 0].stepName.ar}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListViewModel<OrderModel>(
                              data: orders,

                              listItem: (index, order) {
                                final sender = order.senderDetails;
                                final items = order.items;
                                final stepColor = _getStepColor(
                                  steps[_stepTabController?.index ?? 0],
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ExpansionTile(
                                    shape: const RoundedRectangleBorder(
                                      side: BorderSide.none,
                                    ),
                                    collapsedShape:
                                        const RoundedRectangleBorder(
                                          side: BorderSide.none,
                                        ),
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: stepColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                        color: stepColor,
                                      ),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "طلب #${order.id.substring(order.id.length - 5).toUpperCase()}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "${order.totalOrderPrice} ج.م",
                                          style: TextStyle(
                                            color: stepColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person_outline,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              sender?.name ?? "عميل غير معروف",
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone_outlined,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              sender?.phone ?? "بدون هاتف",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    children: [
                                      const Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "المنتجات المطلوبية:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ...items
                                                .map(
                                                  (item) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 8.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey[100],
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: const Icon(
                                                            Icons
                                                                .inventory_2_outlined,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                item.name ??
                                                                    "منتج",
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Text(
                                                                "${item.quantity} × ${item.unitPrice} ج.م",
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          "${item.totalPrice} ج.م",
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            const SizedBox(height: 16),
                                            // --- زر إدارة الطلب → يفتح Bottom Sheet ---
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _showOrderManagementSheet(
                                                      order,
                                                      sys,
                                                    ),
                                                icon: const Icon(
                                                  Icons
                                                      .settings_suggest_outlined,
                                                  size: 20,
                                                ),
                                                label: const Text(
                                                  "إدارة الطلب",
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: stepColor,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 16),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    "إجمالي الطلب النهائي",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${order.totalOrderPrice} ج.م",
                                                    style: TextStyle(
                                                      color: stepColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
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
                                );
                              },
                            );
                          },
                          failure: (error, reload) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  error.message ?? "حدث خطأ أثناء جلب الطلبات",
                                ),
                                TextButton(
                                  onPressed: reload,
                                  child: const Text("إعادة المحاولة"),
                                ),
                              ],
                            ),
                          ),
                          orElse: () => const SizedBox(),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            failure: (error, reload) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    error.message ?? "حدث خطأ أثناء تحميل إعدادات سير العمل",
                  ),
                  ElevatedButton(
                    onPressed: reload,
                    child: const Text("إعادة المحاولة"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Bottom Sheet لإدارة الطلب — تقرأ حالة الطلب نفسه (stepInfo) وليس القالب العام
  void _showOrderManagementSheet(OrderModel order, SystemConfig sys) {
    final canPerformAction = sys.checkPermission(SystemJobs.workflowAction);
    final canAssign =
        sys.checkPermission(SystemJobs.workflowAssigner) ||
        sys.checkPermission(SystemJobs.admin);
    final currentUser = context.read<AppChangesValues>().user;

    // Log permissions for debugging
    debugPrint('🔍 Workflow Permissions for ${currentUser?.username}:');
    debugPrint(' - canPerformAction: $canPerformAction');
    debugPrint(' - canAssign: $canAssign');
    debugPrint(' - User Permissions: ${currentUser?.permissions}');

    // بيانات من الطلب نفسه
    final stepInfo = order.workFlow?.stepInfo;
    final currentStepIndex = order.workFlow?.currentStepIndex ?? 0;

    // المتغير assignedUserId هو صاحب الخطوة الحقيقي
    final assignedUserId = stepInfo?.assignedUserId;

    final isUnclaimed = assignedUserId == null;
    final isAssignedToMe =
        assignedUserId != null &&
        (assignedUserId == currentUser?.id ||
            assignedUserId == currentUser?.username);

    // الأكشنز المتاحة من الطلب نفسه
    final orderActions = stepInfo?.actions ?? [];
    final selectionMode = stepInfo?.selectionMode ?? '';
    final canBeClaimed =
        selectionMode == WorkflowSelectionMode.claim ||
        selectionMode == WorkflowSelectionMode.market;
    final stepName = stepInfo?.stepName?.ar ?? 'غير محدد';
    final stepKey = stepInfo?.stepKey ?? '';

    // تحديد ما إذا كان يجب عرض الأزرار التنفيذية
    final bool showActions =
        (selectionMode == WorkflowSelectionMode.broadcast ||
            selectionMode == WorkflowSelectionMode.consensus ||
            selectionMode == WorkflowSelectionMode.direct) ||
        ((selectionMode == WorkflowSelectionMode.claim ||
                selectionMode == WorkflowSelectionMode.market ||
                selectionMode == WorkflowSelectionMode.assign) &&
            isAssignedToMe);

    // لون الخطوة
    Color sheetColor = Colors.blue;
    if (stepInfo?.stepColor != null && stepInfo!.stepColor!.isNotEmpty) {
      try {
        String hex = stepInfo.stepColor!
            .replaceAll('#', '')
            .replaceAll('0x', '');
        if (hex.length == 6) hex = 'FF$hex';
        sheetColor = Color(int.parse(hex, radix: 16));
      } catch (_) {}
    } else {
      final key = stepKey.toLowerCase();
      if (key.contains('start') || key.contains('new'))
        sheetColor = Colors.blue;
      else if (key.contains('processing') || key.contains('prepare'))
        sheetColor = Colors.orange;
      else if (key.contains('ship') || key.contains('delivery'))
        sheetColor = Colors.deepPurple;
      else if (key.contains('complete') || key.contains('done'))
        sheetColor = Colors.green;
      else if (key.contains('cancel') || key.contains('reject'))
        sheetColor = Colors.red;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocConsumer<
          WorkflowManagementBloc,
          FeaturDataSourceState<WorkflowConfigModel>
        >(
          listener: (ctx, wfState) {
            wfState.itemState.maybeWhen(
              success: (_) {
                Navigator.pop(sheetContext);
                // إعادة تحميل الطلبات بعد نجاح العملية
                _loadOrders(
                  _getActiveWorkflowSlug(),
                  _stepTabController?.index ?? 0,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم تنفيذ الإجراء بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              orElse: () {},
            );
          },
          builder: (ctx, wfState) {
            final isLoading = wfState.itemState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: sheetColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.settings_suggest,
                              color: sheetColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "إدارة الطلب #${order.id.substring(order.id.length - 5).toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: sheetColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'الخطوة: $stepName',
                                  style: TextStyle(
                                    color: sheetColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // --- حالة الملكية ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnclaimed
                          ? Colors.orange.withOpacity(0.08)
                          : (isAssignedToMe
                                ? Colors.green.withOpacity(0.08)
                                : Colors.grey.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isUnclaimed
                            ? Colors.orange.withOpacity(0.3)
                            : (isAssignedToMe
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isUnclaimed
                              ? Icons.hourglass_empty
                              : (isAssignedToMe
                                    ? Icons.check_circle
                                    : Icons.person),
                          color: isUnclaimed
                              ? Colors.orange
                              : (isAssignedToMe ? Colors.green : Colors.grey),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUnclaimed
                              ? '⏳ لم يتم استلام الطلب بعد'
                              : (isAssignedToMe
                                    ? '✅ أنت المسؤول عن هذا الطلب'
                                    : '👤 مستلم من قبل موظف آخر'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isUnclaimed
                                ? Colors.orange[800]
                                : (isAssignedToMe
                                      ? Colors.green[800]
                                      : Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Loading indicator ---
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // --- الإجراءات ---
                  if (!isLoading) ...[
                    // 1. زر استلام الطلب (Claim)
                    // يظهر إذا كان النمط 'claim' أو 'market' والطلب غير مستلم
                    if (canBeClaimed && isUnclaimed && canPerformAction)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<WorkflowManagementBloc>().claimTask(
                                entityType: 'orders',
                                entryId: order.id,
                                expectedStepNumber: currentStepIndex + 1,
                              );
                            },
                            icon: const Icon(Icons.pan_tool_outlined, size: 20),
                            label: const Text(
                              'استلام الطلب',
                              style: TextStyle(fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 2. أكشنز الطلب (من stepInfo.actions)
                    // تظهر إذا:
                    // - النمط 'broadcast' أو 'consensus' (متاحة للجميع)
                    // - أو النمط يحتاج ملكية وأنا المسؤول عن الطلب
                    if (canPerformAction &&
                        showActions &&
                        orderActions.isNotEmpty) ...[
                      const Text(
                        'الإجراءات المتاحة:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...orderActions.map((action) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context
                                    .read<WorkflowManagementBloc>()
                                    .performAction(
                                      entityType: 'orders',
                                      entryId: order.id,
                                      actionName: action.actionName,
                                      expectedStepNumber: currentStepIndex + 1,
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sheetColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                action.displayName.ar.isNotEmpty
                                    ? action.displayName.ar
                                    : action.actionName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],

                    // 3. رسالة تنبيه إذا كان الطلب مستلم من شخص آخر في الأنماط التي تتطلب ملكية
                    if (!isUnclaimed &&
                        !isAssignedToMe &&
                        (selectionMode == WorkflowSelectionMode.claim ||
                            selectionMode == WorkflowSelectionMode.market ||
                            selectionMode == WorkflowSelectionMode.assign))
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'هذا الطلب مستلم من قبل موظف آخر، لا يمكنك تنفيذ إجراءات عليه.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // 4. زر التعيين (Assign) — فقط لمن لديه صلاحية workflowAssigner
                    if (canAssign)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _showAssignSheet(order, currentStepIndex);
                            },
                            icon: const Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 20,
                            ),
                            label: const Text(
                              'تعيين لموظف',
                              style: TextStyle(fontSize: 15),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Bottom Sheet لتعيين الطلب لموظف
  void _showAssignSheet(OrderModel order, int currentStepIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تعيين الطلب لموظف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              const Text('اختر الموظف المناسب:'),
              const SizedBox(height: 12),
              Expanded(
                child:
                    BlocBuilder<
                      UsersBloc,
                      FeaturDataSourceState<UserViewProfileModel>
                    >(
                      builder: (context, state) {
                        return state.listState.when(
                          init: () {
                            context.read<UsersBloc>().loadUsers(
                              organizationId: organizationId,
                            );
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          success: (users) {
                            if (users == null || users.isEmpty) {
                              return const Center(
                                child: Text('لا يوجد موظفين متاحين'),
                              );
                            }
                            return ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(user.username ?? ''),
                                  subtitle: Text(user.email ?? ''),
                                  trailing: const Icon(Icons.chevron_left),
                                  onTap: () {
                                    context
                                        .read<WorkflowManagementBloc>()
                                        .assignTask(
                                          entityType: 'orders',
                                          entryId: order.id,
                                          targetUserId: user.userId,
                                          expectedStepNumber: currentStepIndex,
                                        );
                                    Navigator.pop(sheetContext);
                                    // إعادة تحميل القائمة
                                    _loadOrders(
                                      _getActiveWorkflowSlug(),
                                      _stepTabController?.index ?? 0,
                                    );
                                  },
                                );
                              },
                            );
                          },
                          failure: (error, reload) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(error.message ?? 'Error'),
                                TextButton(
                                  onPressed: reload,
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper: الحصول على الـ workflowSlug النشط حالياً
  String _getActiveWorkflowSlug() {
    final wfState = context.read<WorkflowManagementBloc>().state;
    return wfState.listState.maybeWhen(
      success: (configs) {
        if (configs != null && configs.isNotEmpty) {
          return configs[_selectedWorkflowIndex].workflowSlug;
        }
        return '';
      },
      orElse: () => '',
    );
  }

  Widget _buildWorkflowSelector(List<WorkflowConfigModel> configs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDark ? DarkColors.background : Colors.grey[50],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: configs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedWorkflowIndex == index;
          final primaryColor = isDark
              ? DarkColors.primary
              : LightColors.primary;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(configs[index].roleExecutor),
              selected: isSelected,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              selectedColor: primaryColor,
              backgroundColor: isDark ? DarkColors.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedWorkflowIndex = index;
                    _initializeTabController(configs, forcedIndex: 0);
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _initializeTabController(List<WorkflowConfigModel> configs,
      {int? forcedIndex}) {
    if (configs.isEmpty) return;
    final steps = configs[_selectedWorkflowIndex].workflow.steps;

    // الاحتفاظ بالخطوة الحالية إذا لم يتم تمرير forcedIndex
    int targetIndex = forcedIndex ?? (_stepTabController?.index ?? 0);

    // التأكد من أن الـ index ضمن الحدود المتاحة
    if (targetIndex >= steps.length) {
      targetIndex = 0;
    }

    // إعادة إنشاء الـ Controller فقط إذا لم يكن موجوداً أو تغير عدد الخطوات
    if (_stepTabController == null ||
        _stepTabController!.length != steps.length) {
      _stepTabController?.dispose();
      _stepTabController = TabController(
        length: steps.length,
        vsync: this,
        initialIndex: targetIndex,
      );

      _stepTabController!.addListener(() {
        if (!_stepTabController!.indexIsChanging) {
          _loadOrders(
            configs[_selectedWorkflowIndex].workflowSlug,
            _stepTabController!.index,
          );
        }
      });
    } else {
      // إذا كان موجوداً، نغير الـ index فقط إذا كان forcedIndex مطلوباً
      if (forcedIndex != null) {
        _stepTabController!.index = targetIndex;
      }
    }

    // تحميل الطلبات للخطوة المختارة (الحالية أو المحددة)
    _loadOrders(
      configs[_selectedWorkflowIndex].workflowSlug,
      _stepTabController!.index,
    );

    setState(() {}); // لتحديث الواجهة
  }

  void _loadOrders(String slug, int currentStepIndex) {
    context.read<OrdersBloc>().loadOrders(
      workflowSlug: slug,
      currentStepIndex: currentStepIndex,
    );
  }

  Color _getStepColor(WorkflowStep step) {
    // 1. استخدام اللون من الـ API إذا كان موجوداً وغير أسود افتراضي
    if (step.stepColor != null &&
        step.stepColor!.isNotEmpty &&
        step.stepColor != '#000000' &&
        step.stepColor != '0x000000') {
      try {
        String hex = step.stepColor!.replaceAll('#', '').replaceAll('0x', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      } catch (_) {}
    }

    // 2. ألوان افتراضية ذكية بناءً على مفتاح الخطوة
    final key = step.stepKey.toLowerCase();
    if (key.contains('start') || key.contains('new')) return Colors.blue;
    if (key.contains('processing') || key.contains('prepare'))
      return Colors.orange;
    if (key.contains('ship') || key.contains('delivery'))
      return Colors.deepPurple;
    if (key.contains('complete') ||
        key.contains('success') ||
        key.contains('done'))
      return Colors.green;
    if (key.contains('cancel') || key.contains('reject')) return Colors.red;
    if (key.contains('claim') || key.contains('accept')) return Colors.teal;

    // 3. لوحة ألوان احتياطية في حال لم يتوفر ما سبق
    final List<Color> palette = [
      Colors.blue,
      Colors.orange,
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return palette[(step.stepNumber - 1) % palette.length];
  }

  /// عرض تنبيه خطأ بتصميم متميز
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تنبيه! خطأ في التنفيذ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'فهمت',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
