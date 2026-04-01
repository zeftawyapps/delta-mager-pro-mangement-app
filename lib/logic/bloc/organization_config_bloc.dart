import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/core/orgnization/repo/organization_repo.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/organization_config_model.dart';

class OrganizationConfigBloc
    extends Cubit<FeaturDataSourceState<OrganizationConfigModel>> {
  final OrganizationRepo repo;

  OrganizationConfigBloc({required this.repo})
    : super(FeaturDataSourceState<OrganizationConfigModel>.defaultState());

  Future<void> loadConfig(String organizationId) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.getOrganizationConfig(organizationId);

    if (result.status == StatusModel.success && result.data != null) {
      final configModel = OrganizationConfigModel.fromData(result.data!);
      emit(state.copyWith(itemState: DataSourceBaseState.success(configModel)));
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تحميل الإعدادات",
            ),
            () => loadConfig(organizationId),
          ),
        ),
      );
    }
  }

  Future<void> getOrganizationConfigByName(String orgName) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.getOrganizationConfigByName(orgName);

    if (result.status == StatusModel.success && result.data != null) {
      final configModel = OrganizationConfigModel.fromData(result.data!);
      emit(state.copyWith(itemState: DataSourceBaseState.success(configModel)));
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تحميل الإعدادات",
            ),
            () => getOrganizationConfigByName(orgName),
          ),
        ),
      );
    }
  }

  Future<void> updateConfigSection({
    required String organizationId,
    required String section,
    required Map<String, dynamic> sectionData,
  }) async {
    final result = await repo.updateOrganizationConfigSection(
      organizationId: organizationId,
      section: section,
      sectionData: sectionData,
    );

    if (result.status == StatusModel.success && result.data != null) {
      final updatedConfigModel = OrganizationConfigModel.fromData(result.data!);
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(updatedConfigModel),
        ),
      );
    } else {
      // Optional: Add failure handling if needed for updates
    }
  }
}
