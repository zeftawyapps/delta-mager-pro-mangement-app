import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:matger_pro_core_logic/features/workflow/workflow_constants.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class OrderManagementSheet extends StatelessWidget {
  final OrderModel order;
  final SystemConfig sys;
  final AppChangesValues appChangesValues;
  final VoidCallback onActionCompleted;
  final VoidCallback onAssignClicked;

  const OrderManagementSheet({
    super.key,
    required this.order,
    required this.sys,
    required this.appChangesValues,
    required this.onActionCompleted,
    required this.onAssignClicked,
  });

  @override
  Widget build(BuildContext context) {
    final canPerformAction = sys.checkPermission(SystemJobs.workflowAction);
    final canAssign =
        sys.checkPermission(SystemJobs.workflowAssigner) ||
        sys.checkPermission(SystemJobs.admin);
    final currentUser = appChangesValues.user;

    debugPrint('🔍 Workflow Permissions for ${currentUser?.username}:');
    debugPrint(' - canPerformAction: $canPerformAction');
    debugPrint(' - canAssign: $canAssign');
    debugPrint(' - User Permissions: ${currentUser?.permissions}');

    final stepInfo = order.workFlow?.stepInfo;
    final currentStepIndex = order.workFlow?.currentStepIndex ?? 0;

    final assignedUserId = stepInfo?.assignedUserId;

    final isUnclaimed = assignedUserId == null;
    final isAssignedToMe =
        assignedUserId != null &&
        (assignedUserId == currentUser?.id ||
            assignedUserId == currentUser?.username);

    final orderActions = stepInfo?.actions ?? [];
    final selectionMode = stepInfo?.selectionMode ?? '';
    final canBeClaimed =
        selectionMode == WorkflowSelectionMode.claim ||
        selectionMode == WorkflowSelectionMode.market;
    final stepName = stepInfo?.stepName?.ar ?? 'غير محدد';
    final stepKey = stepInfo?.stepKey ?? '';

    final bool showActions =
        (selectionMode == WorkflowSelectionMode.broadcast ||
            selectionMode == WorkflowSelectionMode.consensus ||
            selectionMode == WorkflowSelectionMode.direct) ||
        ((selectionMode == WorkflowSelectionMode.claim ||
                selectionMode == WorkflowSelectionMode.market ||
                selectionMode == WorkflowSelectionMode.assign) &&
            isAssignedToMe);

    Color sheetColor = Colors.blue;
    if (stepInfo != null && stepInfo.stepColor != null && stepInfo.stepColor!.isNotEmpty) {
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

    return BlocConsumer<
      WorkflowManagementBloc,
      FeaturDataSourceState<WorkflowConfigModel>
    >(
      listener: (ctx, wfState) {
        wfState.itemState.maybeWhen(
          success: (_) {
            Navigator.pop(context);
            onActionCompleted();
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(height: 24),

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

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (!isLoading) ...[
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

                if (canAssign && selectionMode == WorkflowSelectionMode.assign)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onAssignClicked,
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
  }
}
