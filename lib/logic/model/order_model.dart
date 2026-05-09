import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/commrec/data/order_model.dart';

export 'package:matger_pro_core_logic/features/commrec/data/order_model.dart';

class OrderModel extends OrderData implements BaseViewDataModel {
  OrderModel({
    required super.id,
    required super.organizationId,
    super.senderDetails,
    super.recipientDetails,
    super.items,
    required super.totalOrderPrice,
    super.orderMode,
    super.status,
    super.workFlow,
    super.meta,
    super.workflowSlug,
    super.handlerUserId,
    super.handlerOrgId,
    super.additionalCalculation,
    super.additionalData,
  });

  factory OrderModel.fromData(OrderData data) {
    return OrderModel(
      id: data.id,
      organizationId: data.organizationId,
      senderDetails: data.senderDetails,
      recipientDetails: data.recipientDetails,
      items: data.items,
      totalOrderPrice: data.totalOrderPrice,
      orderMode: data.orderMode,
      status: data.status,
      workFlow: data.workFlow,
      meta: data.meta,
      workflowSlug: data.workflowSlug,
      handlerUserId: data.handlerUserId,
      handlerOrgId: data.handlerOrgId,
      additionalCalculation: data.additionalCalculation,
      additionalData: data.additionalData,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final data = OrderData.fromJson(json);
    return OrderModel.fromData(data);
  }

  @override
  set id(String? value) {}

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {}
}
