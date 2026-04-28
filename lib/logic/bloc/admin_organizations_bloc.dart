import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/core/orgnization/repo/organization_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_requests.dart';
import '../model/organization_model.dart';
import '../model/organization_stats.dart';

class AdminOrganizationsBloc
    extends Cubit<FeaturDataSourceState<OrganizationModel>> {
  final OrganizationRepo repo;

  AdminOrganizationsBloc({required this.repo})
    : super(FeaturDataSourceState<OrganizationModel>.defaultState());

  /// Loads all organizations that are marked as active.
  /// Updates [state.listState].
  Future<void> loadActiveOrganizations() async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getActiveOrganizations();
    if (result.status == StatusModel.success) {
      final organizations =
          result.data?.map((e) => OrganizationModel.fromData(e)).toList() ?? [];
      emit(
        state.copyWith(listState: DataSourceBaseState.success(organizations)),
      );
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "Error loading organizations",
            ),
            () => loadActiveOrganizations(),
          ),
        ),
      );
    }
  }

  /// Creates a new organization and a new owner user at the same time.
  /// If [templateOrgId] is provided, it clones settings from that template.
  /// Updates [state.itemState].
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

  /// Creates a new organization for an existing user.
  /// Updates [state.itemState].
  Future<void> createOrganizationForExistingUser({
    required String userId,
    required Map<String, dynamic> organizationData,
    String? templateOrgId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createOrganizationForExistingUser(
      userId: userId,
      organizationData: organizationData,
      templateOrgId: templateOrgId,
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
            () => createOrganizationForExistingUser(
              userId: userId,
              organizationData: organizationData,
              templateOrgId: templateOrgId,
            ),
          ),
        ),
      );
    }
  }

  /// Loads organizations that have completed their data profile.
  /// Updates [state.listState].
  Future<void> loadCompleteOrganizations() async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getCompleteOrganizations();
    if (result.status == StatusModel.success) {
      final organizations =
          result.data?.map((e) => OrganizationModel.fromData(e)).toList() ?? [];
      emit(
        state.copyWith(listState: DataSourceBaseState.success(organizations)),
      );
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadCompleteOrganizations(),
          ),
        ),
      );
    }
  }

  /// Loads organizations that are missing data.
  /// Updates [state.listState].
  Future<void> loadIncompleteOrganizations() async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getIncompleteOrganizations();
    if (result.status == StatusModel.success) {
      final organizations =
          result.data?.map((e) => OrganizationModel.fromData(e)).toList() ?? [];
      emit(
        state.copyWith(listState: DataSourceBaseState.success(organizations)),
      );
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadIncompleteOrganizations(),
          ),
        ),
      );
    }
  }

  /// Searches for organizations within a [radius] (in km) of [lat] and [lng].
  /// Updates [state.listState].
  Future<void> searchByLocation(double lat, double lng, double radius) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.searchByLocation(
      OrganizationLocationSearchRequest(lat: lat, lng: lng, radius: radius),
    );
    if (result.status == StatusModel.success) {
      final organizations =
          result.data?.map((e) => OrganizationModel.fromData(e)).toList() ?? [];
      emit(
        state.copyWith(listState: DataSourceBaseState.success(organizations)),
      );
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => searchByLocation(lat, lng, radius),
          ),
        ),
      );
    }
  }

  /// Clones settings and configurations from a template organization to a target organization.
  /// Resets [state.itemState] on success.
  Future<void> cloneOrganization({
    required String templateOrgId,
    required String targetOrgId,
    bool? overwrite,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.cloneOrganization(
      templateOrgId: templateOrgId,
      targetOrgId: targetOrgId,
      overwrite: overwrite,
    );

    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.success()));
      loadActiveOrganizations();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => cloneOrganization(
              templateOrgId: templateOrgId,
              targetOrgId: targetOrgId,
              overwrite: overwrite,
            ),
          ),
        ),
      );
    }
  }

  /// Deletes an organization permanently.
  /// Calls [loadActiveOrganizations] on success to refresh the list.
  Future<void> deleteOrganization(String id) async {
    final result = await repo.deleteOrganization(id);
    if (result.status == StatusModel.success) {
      loadActiveOrganizations();
    }
  }

  /// Sets whether an organization is treated as a template for cloning.
  Future<void> setTemplateStatus({
    required String id,
    required bool isTemplate,
  }) async {
    final result = await repo.setTemplateStatus(id: id, isTemplate: isTemplate);
    if (result.status == StatusModel.success) {
      loadActiveOrganizations();
    }
  }

  /// Activates an organization to allow its operation.
  Future<void> activateOrganization(String id) async {
    final result = await repo.activateOrganization(id);
    if (result.status == StatusModel.success) {
      loadActiveOrganizations();
    }
  }

  /// Deactivates an organization (Disable operations).
  Future<void> deactivateOrganization(String id) async {
    final result = await repo.deactivateOrganization(id);
    if (result.status == StatusModel.success) {
      loadActiveOrganizations();
    }
  }

  /// Fetches global statistics for organizations and updates [state.feadState].
  Future<void> loadOrganizationStats() async {
    emit(state.copyWith(feadState: const DataSourceBaseState.loading()));
    final result = await repo.getOrganizationStats();
    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          feadState: DataSourceBaseState.success(
            OrganizationStatsModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          feadState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadOrganizationStats(),
          ),
        ),
      );
    }
  }
}
