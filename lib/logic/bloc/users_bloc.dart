import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/features/users/repo/user_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/user_profile.dart';

class UsersBloc extends Cubit<FeaturDataSourceState<UserViewProfileModel>> {
  final UserRepo repo;

  UsersBloc({required this.repo})
    : super(FeaturDataSourceState<UserViewProfileModel>.defaultState());

  Future<void> loadUsers({String? organizationId}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = organizationId != null
        ? await repo.searchProfilesInOrg(organizationId: organizationId)
        : await repo.getActiveProfiles();
        
    if (result.status == StatusModel.success) {
      final users =
          result.data?.map((e) => UserViewProfileModel.fromData(e)).toList() ??
          [];
      emit(state.copyWith(listState: DataSourceBaseState.success(users)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading users"),
            () => loadUsers(organizationId: organizationId),
          ),
        ),
      );
    }
  }

  Future<void> createUser({
    required String username,
    required String email,
    required String password,
    required String phone,
    List<String> roles = const [],
    String? address,
    String? organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createNewUser(
      username: username,
      email: email,
      password: password,
      phone: phone,
      roles: roles,
      address: address,
      organizationId: organizationId,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            UserViewProfileModel.fromData(result.data!),
          ),
        ),
      );
      loadUsers(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error creating user"),
            () => createUser(
              username: username,
              email: email,
              password: password,
              phone: phone,
              roles: roles,
              address: address,
              organizationId: organizationId,
            ),
          ),
        ),
      );
    }
  }

  Future<void> updateUser({
    required String userId,
    String? username,
    String? email,
    String? phone,
    String? address,
    bool? isActive,
    String? organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.updateProfile(
      userId: userId,
      username: username,
      email: email,
      phone: phone,
      address: address,
      isActive: isActive,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            UserViewProfileModel.fromData(result.data!),
          ),
        ),
      );
      loadUsers(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error updating user"),
            () => updateUser(
              userId: userId,
              username: username,
              email: email,
              phone: phone,
              address: address,
              isActive: isActive,
            ),
          ),
        ),
      );
    }
  }

  Future<void> activateUser(String userId, {String? organizationId}) async {
    final result = await repo.activateUser(userId);
    if (result.status == StatusModel.success) {
      loadUsers(organizationId: organizationId);
    }
  }

  Future<void> deactivateUser(String userId, {String? organizationId}) async {
    final result = await repo.deactivateUser(userId);
    if (result.status == StatusModel.success) {
      loadUsers(organizationId: organizationId);
    }
  }

  Future<void> addRoleToUser(String userId, String roleName, {String? organizationId}) async {
    final result = await repo.addRoleToUser(userId: userId, roleName: roleName);
    if (result.status == StatusModel.success) {
      loadUsers(organizationId: organizationId);
    }
  }

  Future<void> removeRoleFromUser(String userId, String roleName, {String? organizationId}) async {
    final result = await repo.removeRoleFromUser(
      userId: userId,
      roleName: roleName,
    );
    if (result.status == StatusModel.success) {
      loadUsers(organizationId: organizationId);
    }
  }

  Future<void> searchUsers(String? term, {String? organizationId}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));

    final result = organizationId != null
        ? await repo.searchProfilesInOrg(
            organizationId: organizationId,
            term: term,
          )
        : await repo.searchProfiles(term: term);

    if (result.status == StatusModel.success) {
      final users =
          result.data?.map((e) => UserViewProfileModel.fromData(e)).toList() ??
          [];
      emit(state.copyWith(listState: DataSourceBaseState.success(users)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error searching users"),
            () => searchUsers(term, organizationId: organizationId),
          ),
        ),
      );
    }
  }
}
