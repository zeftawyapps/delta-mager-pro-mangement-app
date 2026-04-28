import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/features/commrec/repo/offer_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'dart:typed_data';
import '../model/offer.dart';

class OffersBloc extends Cubit<FeaturDataSourceState<OfferModel>> {
  final OfferRepo repo;

  OffersBloc({required this.repo})
      : super(FeaturDataSourceState<OfferModel>.defaultState());

  Future<void> loadOffers({required String organizationId}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getOffersByOrganization(organizationId);
    if (result.status == StatusModel.success) {
      final offers =
          result.data?.map((e) => OfferModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(offers)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadOffers(organizationId: organizationId),
          ),
        ),
      );
    }
  }

  Future<void> searchOffers({
    required String query,
    required String organizationId,
  }) async {
    if (query.isEmpty) {
      loadOffers(organizationId: organizationId);
      return;
    }

    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getOffersByOrganization(organizationId);

    if (result.status == StatusModel.success) {
      final offers =
          result.data?.map((e) => OfferModel.fromData(e)).toList() ?? [];
      final filtered =
          offers
              .where(
                (o) =>
                    o.name.ar.contains(query) ||
                    (o.description?.ar.contains(query) ?? false),
              )
              .toList();

      emit(state.copyWith(listState: DataSourceBaseState.success(filtered)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => searchOffers(query: query, organizationId: organizationId),
          ),
        ),
      );
    }
  }

  Future<void> createOffer({
    required Map<String, String> name,
    required String organizationId,
    Map<String, String>? description,
    required OfferTargetType targetType,
    required String targetId,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool isActive = true,
    int? sortOrder,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createOffer(
      name: name,
      organizationId: organizationId,
      description: description,
      targetType: targetType.name,
      targetId: targetId,
      discountPercentage: discountPercentage,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      sortOrder: sortOrder,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OfferModel.fromData(result.data!),
          ),
        ),
      );
      loadOffers(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => createOffer(
              name: name,
              organizationId: organizationId,
              description: description,
              targetType: targetType,
              targetId: targetId,
              discountPercentage: discountPercentage,
              startDate: startDate,
              endDate: endDate,
              isActive: isActive,
              sortOrder: sortOrder,
              imageBytes: imageBytes,
              imageName: imageName,
            ),
          ),
        ),
      );
    }
  }

  Future<void> updateOffer({
    required String offerId,
    required String organizationId,
    Map<String, String>? name,
    Map<String, String>? description,
    OfferTargetType? targetType,
    String? targetId,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? sortOrder,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    final result = await repo.updateOffer(
      offerId: offerId,
      name: name,
      description: description,
      targetType: targetType?.name,
      targetId: targetId,
      discountPercentage: discountPercentage,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      sortOrder: sortOrder,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            OfferModel.fromData(result.data!),
          ),
        ),
      );
      loadOffers(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => updateOffer(
              offerId: offerId,
              organizationId: organizationId,
              name: name,
              description: description,
              targetType: targetType,
              targetId: targetId,
              discountPercentage: discountPercentage,
              startDate: startDate,
              endDate: endDate,
              isActive: isActive,
              sortOrder: sortOrder,
              imageBytes: imageBytes,
              imageName: imageName,
            ),
          ),
        ),
      );
    }
  }

  Future<void> deleteOffer(String id, {required String organizationId}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.deleteOffer(id);
    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.success(null)));
      loadOffers(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => deleteOffer(id, organizationId: organizationId),
          ),
        ),
      );
    }
  }
}
