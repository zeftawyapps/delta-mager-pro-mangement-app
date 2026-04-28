import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:bloc/bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';

class WorkflowManagementBloc
    extends Cubit<FeaturDataSourceState<WorkflowConfigModel>> {
  final WorkflowRepo repo;

  WorkflowManagementBloc({required this.repo})
    : super(FeaturDataSourceState<WorkflowConfigModel>.defaultState());

  Future<void> loadSpecificConfig(
    String organizationId, {
    String entityType = 'orders',
  }) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));

    final result = await repo.getWorkflowConfig(
      orgId: organizationId,
      entityType: entityType,
    );

    if (result.status == StatusModel.success && result.data != null) {
      // Debug prints
      print("DEBUG: Received ${result.data!.length} configs");
      for (var config in result.data!) {
        print("DEBUG: Config for ${config.roleExecutor} has ${config.workflow.steps.length} steps");
        for (var step in config.workflow.steps) {
          print("DEBUG: Step ${step.stepKey} has ${step.actions.length} actions");
        }
      }

      final configs = result.data!
          .map((e) => WorkflowConfigModel.fromData(e))
          .toList();

      emit(
        state.copyWith(
          listState: DataSourceBaseState.success(configs),
        ),
      );
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(
              message:
                  result.message ?? "لم يتم العثور على مسارات عمل لهذا الكيان",
            ),
            () => loadSpecificConfig(organizationId, entityType: entityType),
          ),
        ),
      );
    }
  }

  Future<void> createOrUpdateConfig({
    required String organizationId,
    required WorkflowConfigRequest request,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createConfig(
      orgId: organizationId,
      request: request,
    );

    if (result.status == StatusModel.success) {
      loadSpecificConfig(organizationId, entityType: request.entityType);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء حفظ المسار",
            ),
            () => createOrUpdateConfig(
              organizationId: organizationId,
              request: request,
            ),
          ),
        ),
      );
    }
  }

  Future<void> seedDefault(
    String organizationId, {
    String entityType = 'orders',
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.seedConfig(
      orgId: organizationId,
      request: WorkflowSeedRequest(entityType: entityType),
    );

    if (result.status == StatusModel.success) {
      loadSpecificConfig(organizationId, entityType: entityType);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء إنشاء المسار الافتراضي",
            ),
            () => seedDefault(organizationId, entityType: entityType),
          ),
        ),
      );
    }
  }
}
