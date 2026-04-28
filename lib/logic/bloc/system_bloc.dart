import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/system_models.dart';
import 'package:matger_pro_core_logic/core/system/repo/system_repo.dart';
import 'package:matger_pro_core_logic/core/system/data/system_models.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';

class SystemBloc extends Cubit<FeaturDataSourceState<SystemInfoModel>> {
  final SystemRepo repo;
  SystemInfoModel? systemInfo;

  SystemBloc({required this.repo})
    : super(FeaturDataSourceState<SystemInfoModel>.defaultState());

  // 1. جلب معلومات النظام (System Info)
  Future<void> loadSystemInfo() async {
    // التحقق من الحالة الحالية لمنع الطلبات المتكررة أثناء التحميل
    bool alreadyLoading = false;
    state.itemState.maybeWhen(
      loading: () => alreadyLoading = true,
      orElse: () {},
    );
    if (alreadyLoading) return;

    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.getSystemInfo();

    if (result.status == StatusModel.success && result.data != null) {
      final model = SystemInfoModel.fromData(result.data!);
      systemInfo = model;
      emit(state.copyWith(itemState: DataSourceBaseState.success(model)));
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "فشل تحميل بيانات النظام",
            ),
            () => loadSystemInfo(),
          ),
        ),
      );
    }
  }

  // 2. تهيئة النظام (Bootstrap)
  Future<void> bootstrapSystem(
    BootstrapRequest request,
    String systemKey,
  ) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.bootstrapSystem(request, systemKey);

    if (result.status == StatusModel.success) {
      // بعد النجاح، نعيد تحميل بيانات النظام للتأكد من تحديث حالة isBootstrapped
      await loadSystemInfo();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "فشل تهيئة النظام"),
            () => bootstrapSystem(request, systemKey),
          ),
        ),
      );
    }
  }
}
