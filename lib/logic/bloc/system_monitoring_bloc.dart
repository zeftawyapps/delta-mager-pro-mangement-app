import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';
import 'package:matger_pro_core_logic/features/analytics/data/api_usage_model.dart';
import 'package:matger_pro_core_logic/features/analytics/data/blackbox_log_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';

class SystemMonitoringState {
  final DataSourceBaseState<List<ApiUsage>> apiUsageState;
  final DataSourceBaseState<List<BlackboxLog>> blackboxLogsState;

  SystemMonitoringState({
    required this.apiUsageState,
    required this.blackboxLogsState,
  });

  factory SystemMonitoringState.initial() {
    return SystemMonitoringState(
      apiUsageState: const DataSourceBaseState.init(),
      blackboxLogsState: const DataSourceBaseState.init(),
    );
  }

  SystemMonitoringState copyWith({
    DataSourceBaseState<List<ApiUsage>>? apiUsageState,
    DataSourceBaseState<List<BlackboxLog>>? blackboxLogsState,
  }) {
    return SystemMonitoringState(
      apiUsageState: apiUsageState ?? this.apiUsageState,
      blackboxLogsState: blackboxLogsState ?? this.blackboxLogsState,
    );
  }
}

class SystemMonitoringBloc extends Cubit<SystemMonitoringState> {
  final AnalyticsRepo repo;

  SystemMonitoringBloc({required this.repo}) : super(SystemMonitoringState.initial());

  Future<void> loadApiUsage({
    required String organizationId,
    int limit = 30,
  }) async {
    emit(state.copyWith(apiUsageState: const DataSourceBaseState.loading()));
    final result = await repo.getApiUsageStats(
      organizationId: organizationId,
      limit: limit,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(state.copyWith(apiUsageState: DataSourceBaseState.success(result.data!)));
    } else {
      emit(
        state.copyWith(
          apiUsageState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading API usage statistics"),
            () => loadApiUsage(
              organizationId: organizationId,
              limit: limit,
            ),
          ),
        ),
      );
    }
  }

  Future<void> loadBlackboxLogs({
    String? organizationId,
    int? statusCode,
    int limit = 50,
  }) async {
    emit(state.copyWith(blackboxLogsState: const DataSourceBaseState.loading()));
    final result = await repo.getBlackboxLogs(
      organizationId: organizationId,
      statusCode: statusCode,
      limit: limit,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(state.copyWith(blackboxLogsState: DataSourceBaseState.success(result.data!)));
    } else {
      emit(
        state.copyWith(
          blackboxLogsState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading Blackbox logs"),
            () => loadBlackboxLogs(
              organizationId: organizationId,
              statusCode: statusCode,
              limit: limit,
            ),
          ),
        ),
      );
    }
  }
}
