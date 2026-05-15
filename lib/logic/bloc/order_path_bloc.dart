import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/features/order_path/repo/order_path_repo.dart';
import 'package:matger_pro_core_logic/features/order_path/data/order_path_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/order_path_model.dart';
import '../model/order_model.dart';

class OrderPathBloc extends Cubit<FeaturDataSourceState<OrderPathModel>> {
  final OrderPathRepo repo;

  /// طلبات خط السير المحمّلة حالياً
  List<OrderModel> _pathOrders = [];
  List<OrderModel> get pathOrders => _pathOrders;

  /// حالة تحميل طلبات خط السير
  bool _isLoadingPathOrders = false;
  bool get isLoadingPathOrders => _isLoadingPathOrders;

  String? _pathOrdersError;
  String? get pathOrdersError => _pathOrdersError;

  OrderPathBloc({required this.repo})
    : super(FeaturDataSourceState<OrderPathModel>.defaultState());

  /// جلب كل خطوط السير الخاصة بمؤسسة
  Future<void> loadOrderPaths(String organizationId) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));

    final result = await repo.getOrganizationOrderPaths(organizationId);

    if (result.status == StatusModel.success) {
      try {
        final List<OrderPathModel> paths =
            result.data?.map((e) => OrderPathModel.fromData(e)).toList() ?? [];
        emit(state.copyWith(listState: DataSourceBaseState.success(paths)));
      } catch (e) {
        emit(
          state.copyWith(
            listState: DataSourceBaseState.failure(
              ErrorStateModel(
                message: "خطأ في معالجة بيانات خطوط السير: $e",
              ),
              () => loadOrderPaths(organizationId),
            ),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء جلب خطوط السير",
            ),
            () => loadOrderPaths(organizationId),
          ),
        ),
      );
    }
  }

  /// إنشاء خط سير جديد
  Future<void> createOrderPath({
    required String organizationId,
    required String name,
    required List<String> regions,
    String? workflowSlug,
    int? triggerStepNumber,
    bool autoAssign = true,
    Map<String, dynamic>? schedule,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    final result = await repo.createOrderPath(
      organizationId: organizationId,
      name: name,
      regions: regions,
      workflowSlug: workflowSlug,
      triggerStepNumber: triggerStepNumber,
      autoAssign: autoAssign,
      schedule: schedule,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderPathModel.fromData(result.data!),
          ),
        ),
      );
      // إعادة تحميل القائمة
      loadOrderPaths(organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء إنشاء خط السير",
            ),
            () => createOrderPath(
              organizationId: organizationId,
              name: name,
              regions: regions,
              workflowSlug: workflowSlug,
              triggerStepNumber: triggerStepNumber,
              autoAssign: autoAssign,
              schedule: schedule,
            ),
          ),
        ),
      );
    }
  }

  /// تعديل خط سير
  Future<void> updateOrderPath({
    required String pathId,
    required String organizationId,
    String? name,
    List<String>? regions,
    String? workflowSlug,
    int? triggerStepNumber,
    bool? autoAssign,
    Map<String, dynamic>? schedule,
    bool? isActive,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    final result = await repo.updateOrderPath(
      pathId: pathId,
      name: name,
      regions: regions,
      workflowSlug: workflowSlug,
      triggerStepNumber: triggerStepNumber,
      autoAssign: autoAssign,
      schedule: schedule,
      isActive: isActive,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderPathModel.fromData(result.data!),
          ),
        ),
      );
      // إعادة تحميل القائمة
      loadOrderPaths(organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تعديل خط السير",
            ),
            () => updateOrderPath(
              pathId: pathId,
              organizationId: organizationId,
              name: name,
              regions: regions,
              workflowSlug: workflowSlug,
              triggerStepNumber: triggerStepNumber,
              autoAssign: autoAssign,
              schedule: schedule,
              isActive: isActive,
            ),
          ),
        ),
      );
    }
  }

  /// حذف خط سير
  Future<void> deleteOrderPath({
    required String pathId,
    required String organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    final result = await repo.deleteOrderPath(pathId);

    if (result.status == StatusModel.success) {
      emit(
        state.copyWith(
          itemState: const DataSourceBaseState.success(null),
        ),
      );
      // إعادة تحميل القائمة
      loadOrderPaths(organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء حذف خط السير",
            ),
            () => deleteOrderPath(
              pathId: pathId,
              organizationId: organizationId,
            ),
          ),
        ),
      );
    }
  }

  /// جلب تفاصيل خط سير محدد
  Future<void> loadOrderPathDetails(String pathId) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    final result = await repo.getOrderPathById(pathId);

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderPathModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء جلب تفاصيل خط السير",
            ),
            () => loadOrderPathDetails(pathId),
          ),
        ),
      );
    }
  }

  /// جلب الطلبات المرتبطة بخط سير معين
  Future<void> loadOrderPathOrders(String pathId) async {
    _isLoadingPathOrders = true;
    _pathOrdersError = null;
    _pathOrders = [];
    // Emit to notify UI of loading state change
    emit(state.copyWith());

    final result = await repo.getOrderPathOrders(pathId);

    if (result.status == StatusModel.success && result.data != null) {
      _pathOrders =
          result.data!.map((e) => OrderModel.fromData(e)).toList();
      _isLoadingPathOrders = false;
      emit(state.copyWith());
    } else {
      _isLoadingPathOrders = false;
      _pathOrdersError =
          result.message ?? "حدث خطأ أثناء جلب طلبات خط السير";
      emit(state.copyWith());
    }
  }

  /// البحث في خطوط السير (محلياً حالياً)
  void searchOrderPaths(String query, {required String organizationId}) {
    if (query.isEmpty) {
      loadOrderPaths(organizationId);
      return;
    }

    state.listState.maybeWhen(
      success: (items) {
        if (items != null) {
          final filtered = items
              .where((p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  (p.workflowSlug?.toLowerCase().contains(query.toLowerCase()) ??
                      false))
              .toList();
          emit(state.copyWith(listState: DataSourceBaseState.success(filtered)));
        }
      },
      orElse: () {
        loadOrderPaths(organizationId);
      },
    );
  }

  /// مسح طلبات خط السير (عند الخروج من الشاشة مثلاً)
  void clearPathOrders() {
    _pathOrders = [];
    _isLoadingPathOrders = false;
    _pathOrdersError = null;
  }
}

