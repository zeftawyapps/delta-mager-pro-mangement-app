import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/order_path/data/order_path_model.dart';

export 'package:matger_pro_core_logic/features/order_path/data/order_path_model.dart';

class OrderPathModel extends OrderPathData implements BaseViewDataModel {
  OrderPathModel({
    required super.id,
    required super.organizationId,
    required super.name,
    super.regions,
    super.workflowSlug,
    super.triggerStepNumber,
    super.autoAssign,
    super.schedule,
    super.isActive,
    super.meta,
  });

  factory OrderPathModel.fromData(OrderPathData data) {
    return OrderPathModel(
      id: data.id,
      organizationId: data.organizationId,
      name: data.name,
      regions: data.regions,
      workflowSlug: data.workflowSlug,
      triggerStepNumber: data.triggerStepNumber,
      autoAssign: data.autoAssign,
      schedule: data.schedule,
      isActive: data.isActive,
      meta: data.meta,
    );
  }

  factory OrderPathModel.fromJson(Map<String, dynamic> json) {
    final data = OrderPathData.fromJson(json);
    return OrderPathModel.fromData(data);
  }

  @override
  set id(String? value) {}

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {}
}
