import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/core/orgnization/repo/organization_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/organization_model.dart';

class AdminOrganizationsBloc extends Cubit<FeaturDataSourceState<OrganizationModel>> {
  final OrganizationRepo repo;

  AdminOrganizationsBloc({required this.repo})
    : super(FeaturDataSourceState<OrganizationModel>.defaultState());

  Future<void> loadActiveOrganizations() async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getActiveOrganizations();
    if (result.status == StatusModel.success) {
      final organizations =
          result.data?.map((e) => OrganizationModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(organizations)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading organizations"),
            () => loadActiveOrganizations(),
          ),
        ),
      );
    }
  }

  Future<void> createOrganizationWithOwner({
    required Map<String, dynamic> userData,
    required OrganizationData organizationData,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createOrganizationWithOwner(
      userData: userData,
      organizationData: organizationData,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrganizationModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => createOrganizationWithOwner(
              userData: userData,
              organizationData: organizationData,
            ),
          ),
        ),
      );
    }
  }
}
