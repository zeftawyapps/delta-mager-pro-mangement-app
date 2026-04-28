import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/test_data.dart';
import 'package:matger_pro_core_logic/core/auth/repos/test_repo.dart';

class TestBloc extends Cubit<FeaturDataSourceState<TestData>> {
  TestRepo testRep;

  TestBloc({required this.testRep})
    : super(FeaturDataSourceState<TestData>.defaultState());

  Future<void> getTestData() async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await testRep.getLandingData();
    if (result.data != null) {
      TestData data = TestData(
        success: true,
        message: result.data?.message ?? "",
        timestamp: result.data?.timestamp ?? "",
        environment: result.data?.environment ?? "",
        version: result.data?.version ?? "",
      );
      emit(state.copyWith(itemState: DataSourceBaseState.success(data)));
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => getTestData(),
          ),
        ),
      );
    }
  }
}
