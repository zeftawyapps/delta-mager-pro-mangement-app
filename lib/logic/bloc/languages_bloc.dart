import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/language_model.dart';
import 'package:matger_pro_core_logic/core/system/repo/system_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';

class LanguagesBloc extends Cubit<FeaturDataSourceState<LanguageModel>> {
  final SystemRepo repo;

  LanguagesBloc({required this.repo})
      : super(FeaturDataSourceState<LanguageModel>.defaultState());

  // جلب اللغات
  Future<void> loadLanguages() async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getLanguages();

    if (result.status == StatusModel.success) {
      final models = result.data?.map((e) => LanguageModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(models)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "فشل تحميل اللغات"),
            () => loadLanguages(),
          ),
        ),
      );
    }
  }

  // تهيئة اللغات
  Future<void> seedLanguages() async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.seedLanguages();

    if (result.status == StatusModel.success) {
      await loadLanguages();
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "فشل تهيئة اللغات"),
            () => seedLanguages(),
          ),
        ),
      );
    }
  }
}
