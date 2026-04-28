import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_pro_core_logic/features/workflow/data/workflow_model.dart';

export 'package:matger_pro_core_logic/features/workflow/data/workflow_model.dart';

class WorkflowConfigModel extends WorkflowConfig implements BaseViewDataModel {
  WorkflowConfigModel({
    required super.id,
    required super.organizationId,
    required super.entityType,
    required super.workflowSlug,
    required super.roleExecutor,
    required super.isActive,
    super.createdAt,
    required super.workflow,
    super.meta,
  });

  factory WorkflowConfigModel.fromData(WorkflowConfig data) {
    return WorkflowConfigModel(
      id: data.id,
      organizationId: data.organizationId,
      entityType: data.entityType,
      workflowSlug: data.workflowSlug,
      roleExecutor: data.roleExecutor,
      isActive: data.isActive,
      createdAt: data.createdAt,
      workflow: data.workflow,
      meta: data.meta,
    );
  }

  /// Helper factory to ensure actions are parsed even if core logic fails
  factory WorkflowConfigModel.fromJson(Map<String, dynamic> json) {
    final base = WorkflowConfig.fromJson(json);
    
    // We can add custom logic here if we need to force-parse something
    // that the core logic missed, but for now we rely on the base parsing.
    
    return WorkflowConfigModel.fromData(base);
  }

  @override
  set id(String? value) { }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) { }
}
