import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/core/orgnization/repo/organization_repo.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/organization_policy_model.dart';

class OrganizationPolicyBloc extends Cubit<FeaturDataSourceState<OrganizationPolicyModel>> {
  final OrganizationRepo repo;

  OrganizationPolicyBloc({required this.repo})
    : super(FeaturDataSourceState<OrganizationPolicyModel>.defaultState());

  Future<void> loadPolicy(String organizationId) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.getOrganizationPolicy(organizationId);
    
    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrganizationPolicyModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "حدث خطأ أثناء تحميل السياسات"),
            () => loadPolicy(organizationId),
          ),
        ),
      );
    }
  }
}
