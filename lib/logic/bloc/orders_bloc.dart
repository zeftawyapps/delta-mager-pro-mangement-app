import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/features/commrec/repo/order_repo.dart';
import 'package:matger_pro_core_logic/features/commrec/data/order_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/order_model.dart';

class OrdersBloc extends Cubit<FeaturDataSourceState<OrderModel>> {
  final OrderRepo repo;

  OrdersBloc({required this.repo})
    : super(FeaturDataSourceState<OrderModel>.defaultState());

  Future<void> loadOrders({
    int page = 1,
    int limit = 10,
    int? currentStepIndex,
    String? workflowSlug,
    String? orderPathId,
  }) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getOrganizationOrders(
      page: page,
      limit: limit,
      currentStepIndex: currentStepIndex,
      workflowSlug: workflowSlug,
      orderPathId: orderPathId,
    );

    if (result.status == StatusModel.success) {
      try {
        final List<OrderModel> orders =
            result.data?.map((e) => OrderModel.fromData(e)).toList() ?? [];
        emit(state.copyWith(listState: DataSourceBaseState.success(orders)));
      } catch (e) {
        emit(
          state.copyWith(
            listState: DataSourceBaseState.failure(
              ErrorStateModel(message: "خطأ في معالجة بيانات الطلبات: $e"),
              () => loadOrders(
                page: page,
                limit: limit,
                currentStepIndex: currentStepIndex,
                workflowSlug: workflowSlug,
                orderPathId: orderPathId,
              ),
            ),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء جلب الطلبات",
            ),
            () => loadOrders(
              page: page,
              limit: limit,
              currentStepIndex: currentStepIndex,
              workflowSlug: workflowSlug,
              orderPathId: orderPathId,
            ),
          ),
        ),
      );
    }
  }

  Future<void> createOrder({
    required String organizationId,
    OrderContactDetails? senderDetails,
    OrderContactDetails? recipientDetails,
    required List<OrderItemData> items,
    required double totalOrderPrice,
    String orderMode = 'C2B',
    String? workflowSlug,
    String? senderOrganizationId,
    int calculationMode = 2,
    Map<String, double>? additionalCalculation,
    Map<String, dynamic>? additionalData,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createOrder(
      organizationId: organizationId,
      senderDetails: senderDetails,
      recipientDetails: recipientDetails,
      items: items,
      totalOrderPrice: totalOrderPrice,
      orderMode: orderMode,
      workflowSlug: workflowSlug,
      senderOrganizationId: senderOrganizationId,
      calculationMode: calculationMode,
      additionalCalculation: additionalCalculation,
      additionalData: additionalData,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderModel.fromData(result.data!),
          ),
        ),
      );
      loadOrders(workflowSlug: workflowSlug);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء إنشاء الطلب",
            ),
            () => createOrder(
              organizationId: organizationId,
              senderDetails: senderDetails,
              recipientDetails: recipientDetails,
              items: items,
              totalOrderPrice: totalOrderPrice,
              orderMode: orderMode,
              workflowSlug: workflowSlug,
              senderOrganizationId: senderOrganizationId,
              calculationMode: calculationMode,
              additionalCalculation: additionalCalculation,
              additionalData: additionalData,
            ),
          ),
        ),
      );
    }
  }

  Future<void> performWorkflowAction(
    String orderId,
    String actionName, {
    int? expectedStepNumber,
    String? targetUserId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.performWorkflowAction(orderId, {
      'actionName': actionName,
      'expectedStepNumber': expectedStepNumber,
      'targetUserId': targetUserId,
    });

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderModel.fromData(result.data!),
          ),
        ),
      );
      // Optionally refresh list if needed
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تنفيذ الإجراء",
            ),
            () => performWorkflowAction(
              orderId,
              actionName,
              expectedStepNumber: expectedStepNumber,
              targetUserId: targetUserId,
            ),
          ),
        ),
      );
    }
  }

  Future<void> claimOrder(String orderId, {int? expectedStepNumber}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.claimOrder(
      orderId,
      expectedStepNumber: expectedStepNumber,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء استلام الطلب",
            ),
            () => claimOrder(orderId, expectedStepNumber: expectedStepNumber),
          ),
        ),
      );
    }
  }

  Future<void> assignOrder(
    String orderId,
    String targetUserId, {
    int? expectedStepNumber,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.assignOrder(
      orderId,
      targetUserId: targetUserId,
      expectedStepNumber: expectedStepNumber,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تعيين الطلب",
            ),
            () => assignOrder(
              orderId,
              targetUserId,
              expectedStepNumber: expectedStepNumber,
            ),
          ),
        ),
      );
    }
  }

  Future<void> updateOrderItems({
    required String orderId,
    required List<OrderItemData> items,
    required double totalOrderPrice,
    int calculationMode = 2,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.updateOrderItems(
      orderId: orderId,
      items: items,
      totalOrderPrice: totalOrderPrice,
      calculationMode: calculationMode,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OrderModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تحديث عناصر الطلب",
            ),
            () => updateOrderItems(
              orderId: orderId,
              items: items,
              totalOrderPrice: totalOrderPrice,
              calculationMode: calculationMode,
            ),
          ),
        ),
      );
    }
  }
}
