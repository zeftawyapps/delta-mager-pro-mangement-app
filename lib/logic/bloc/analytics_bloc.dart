import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';

class AnalyticsState {
  final DataSourceBaseState<SalesReport> salesReportState;
  final DataSourceBaseState<List<TopSellingProduct>> topSellingProductsState;

  AnalyticsState({
    required this.salesReportState,
    required this.topSellingProductsState,
  });

  factory AnalyticsState.initial() {
    return AnalyticsState(
      salesReportState: const DataSourceBaseState.init(),
      topSellingProductsState: const DataSourceBaseState.init(),
    );
  }

  AnalyticsState copyWith({
    DataSourceBaseState<SalesReport>? salesReportState,
    DataSourceBaseState<List<TopSellingProduct>>? topSellingProductsState,
  }) {
    return AnalyticsState(
      salesReportState: salesReportState ?? this.salesReportState,
      topSellingProductsState: topSellingProductsState ?? this.topSellingProductsState,
    );
  }
}

class AnalyticsBloc extends Cubit<AnalyticsState> {
  final AnalyticsRepo repo;

  AnalyticsBloc({required this.repo}) : super(AnalyticsState.initial());

  Future<void> loadSalesReport({
    required String organizationId,
    String? startDate,
    String? endDate,
    String? lang,
  }) async {
    emit(state.copyWith(salesReportState: const DataSourceBaseState.loading()));
    final result = await repo.getSalesReport(
      organizationId: organizationId,
      startDate: startDate,
      endDate: endDate,
      lang: lang,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(state.copyWith(salesReportState: DataSourceBaseState.success(result.data!)));
    } else {
      emit(
        state.copyWith(
          salesReportState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading sales report"),
            () => loadSalesReport(
              organizationId: organizationId,
              startDate: startDate,
              endDate: endDate,
              lang: lang,
            ),
          ),
        ),
      );
    }
  }

  Future<void> loadTopSellingProducts({
    required String organizationId,
    int limit = 5,
    String? lang,
  }) async {
    emit(state.copyWith(topSellingProductsState: const DataSourceBaseState.loading()));
    final result = await repo.getTopSellingProducts(
      organizationId: organizationId,
      limit: limit,
      lang: lang,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(state.copyWith(topSellingProductsState: DataSourceBaseState.success(result.data!)));
    } else {
      emit(
        state.copyWith(
          topSellingProductsState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading top selling products"),
            () => loadTopSellingProducts(
              organizationId: organizationId,
              limit: limit,
              lang: lang,
            ),
          ),
        ),
      );
    }
  }
}
