import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/features/users/repo/user_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/role_upgrade_request.dart';

class RoleRequestsBloc extends Cubit<FeaturDataSourceState<RoleUpgradeRequest>> {
  final UserRepo repo;

  RoleRequestsBloc({required this.repo})
      : super(FeaturDataSourceState<RoleUpgradeRequest>.defaultState());

  Future<void> loadRequests({String? organizationId}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.loadRoleRequests();

    if (result.status == StatusModel.success) {
      final rawList = result.data ?? [];
      final List<RoleUpgradeRequest> requests = rawList
          .map((item) => RoleUpgradeRequest.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      emit(state.copyWith(listState: DataSourceBaseState.success(requests)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadRequests(organizationId: organizationId),
          ),
        ),
      );
    }
  }

  Future<({bool success, String message, String? otpCode})> approveRequest(
      String requestId, {String? organizationId}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.approveRoleRequest(requestId);

    if (result.status == StatusModel.success && result.data != null) {
      final data = result.data;
      final otp = data?['otpCode']?.toString();
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      // Reload list to update status
      loadRequests(organizationId: organizationId);
      return (success: true, message: result.message ?? 'Approved', otpCode: otp);
    } else {
      final msg = result.message ?? 'Failed to approve';
      emit(state.copyWith(itemState: DataSourceBaseState.failure(
        ErrorStateModel(message: msg),
        () {},
      )));
      return (success: false, message: msg, otpCode: null);
    }
  }

  Future<({bool success, String message})> rejectRequest(
      String requestId, String reason, {String? organizationId}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.rejectRoleRequest(requestId, reason);

    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      // Reload list to update status
      loadRequests(organizationId: organizationId);
      return (success: true, message: result.message ?? 'Rejected');
    } else {
      final msg = result.message ?? 'Failed to reject';
      emit(state.copyWith(itemState: DataSourceBaseState.failure(
        ErrorStateModel(message: msg),
        () {},
      )));
      return (success: false, message: msg);
    }
  }
}
