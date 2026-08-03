import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/list_view_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/orders_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/helpers/order_role_config_helper.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_item_card.dart';

class OrderListContainer extends StatelessWidget {
  final WorkflowStep? currentStep;
  final dynamic orgConfig;
  final List<String> userRoles;
  final void Function(OrderModel order) onManageOrder;

  const OrderListContainer({
    super.key,
    required this.currentStep,
    required this.orgConfig,
    required this.userRoles,
    required this.onManageOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, FeaturDataSourceState<OrderModel>>(
      builder: (context, orderState) {
        return orderState.listState.maybeWhen(
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (orders) {
            final ordersList = orders ?? [];

            if (ordersList.isEmpty) {
              final stepName = currentStep?.stepName.ar ?? '';
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
                      "لا توجد طلبات في مرحلة $stepName",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final visibility = OrderRoleConfigHelper.getSenderRecipientVisibility(
              orgConfig: orgConfig,
              userRoles: userRoles,
            );

            final stepColor = currentStep != null
                ? OrderRoleConfigHelper.getStepColor(currentStep!)
                : Theme.of(context).primaryColor;

            return ListViewModel<OrderModel>(
              data: ordersList,
              listItem: (index, order) {
                return OrderItemCard(
                  order: order,
                  stepColor: stepColor,
                  showSenderInfo: visibility.showSender,
                  showRecipientInfo: visibility.showRecipient,
                  onManageOrder: () => onManageOrder(order),
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: reload,
                  child: const Text("إعادة المحاولة"),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
