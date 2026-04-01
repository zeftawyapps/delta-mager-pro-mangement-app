import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/features/roles/repo/role_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/role.dart';

class RolesBloc extends Cubit<FeaturDataSourceState<RoleModel>> {
  final RoleRepo repo;

  RolesBloc({required this.repo})
    : super(FeaturDataSourceState<RoleModel>.defaultState());

  Future<void> loadRoles({String? organizationId}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getRoles(organizationId: organizationId);
    if (result.status == StatusModel.success) {
      final roles =
          result.data?.map((e) => RoleModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(roles)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadRoles(organizationId: organizationId),
          ),
        ),
      );
    }
  }

  Future<void> createRole({
    required String name,
    String? displayName,
    String? description,
    required List<String> permissions,
    String? organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createRole(
      name: name,
      displayName: displayName,
      description: description,
      permissions: permissions,
      organizationId: organizationId,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            RoleModel.fromData(result.data!),
          ),
        ),
      );
      loadRoles(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => createRole(
              name: name,
              displayName: displayName,
              description: description,
              permissions: permissions,
              organizationId: organizationId,
            ),
          ),
        ),
      );
    }
  }

  Future<void> updateRole({
    required String roleId,
    String? name,
    String? displayName,
    String? description,
    List<String>? permissions,
    bool? isActive,
    String? organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.updateRole(
      roleId: roleId,
      name: name,
      displayName: displayName,
      description: description,
      permissions: permissions,
      isActive: isActive,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            RoleModel.fromData(result.data!),
          ),
        ),
      );
      loadRoles(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => updateRole(
              roleId: roleId,
              name: name,
              displayName: displayName,
              description: description,
              permissions: permissions,
              organizationId: organizationId,
            ),
          ),
        ),
      );
    }
  }

  Future<void> deleteRole(String id, {String? organizationId}) async {
    final result = await repo.deleteRole(id);
    if (result.status == StatusModel.success) {
      loadRoles(organizationId: organizationId);
    }
  }
}
