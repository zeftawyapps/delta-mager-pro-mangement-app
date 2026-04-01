import 'dart:typed_data';

import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/features/commrec/repo/product_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/product_model.dart';


class ProductsBloc extends Cubit<FeaturDataSourceState<ProductModel>> {
  final ProductRepo repo;

  ProductsBloc({required this.repo})
    : super(FeaturDataSourceState<ProductModel>.defaultState());

  Future<void> loadProducts({int page = 1, int limit = 100}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getProducts(page: page, limit: limit);
    if (result.status == StatusModel.success) {
      final products =
          result.data?.map((e) => ProductModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(products)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadProducts(page: page, limit: limit),
          ),
        ),
      );
    }
  }

  Future<void> createProduct({
    required dynamic name,
    required String categoryId,
    required String organizationId,
    required double price,
    Uint8List? imageBytes,
    String? imageName,
    Map<String, dynamic>? additionalData,
    bool isNew = false,
    bool isBestSeller = false,
    bool isOnSale = false,
    bool isJoker = false,
    bool isSuperJoker = false,
    bool isAvailable = true,
    double? oldPrice,
    double? discount,
    List<PriceOption>? priceOptions,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createProduct(
      name: name,
      categoryId: categoryId,
      organizationId: organizationId,
      price: price,
      imageBytes: imageBytes,
      imageName: imageName,
      additionalData: additionalData,
      isNew: isNew,
      isBestSeller: isBestSeller,
      isOnSale: isOnSale,
      isJoker: isJoker,
      isSuperJoker: isSuperJoker,
      isAvailable: isAvailable,
      oldPrice: oldPrice,
      discount: discount,
      priceOptions: priceOptions,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            ProductModel.fromData(result.data!),
          ),
        ),
      );
      // Refresh the list after creation
      loadProducts();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => createProduct(
              name: name,
              categoryId: categoryId,
              organizationId: organizationId,
              price: price,
              imageBytes: imageBytes,
              imageName: imageName,
              additionalData: additionalData,
              isNew: isNew,
              isBestSeller: isBestSeller,
              isOnSale: isOnSale,
              isJoker: isJoker,
              isSuperJoker: isSuperJoker,
              isAvailable: isAvailable,
              oldPrice: oldPrice,
              discount: discount,
              priceOptions: priceOptions,
            ),
          ),
        ),
      );
    }
  }

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    final result = await repo.updateProduct(
      productId: productId,
      data: data,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            ProductModel.fromData(result.data!),
          ),
        ),
      );
      loadProducts();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => updateProduct(
              productId: productId,
              data: data,
              imageBytes: imageBytes,
              imageName: imageName,
            ),
          ),
        ),
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.deleteProduct(id);
    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.success(null)));
      loadProducts();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => deleteProduct(id),
          ),
        ),
      );
    }
  }

  Future<void> searchProducts({
    required String query,
    required String organizationId,
  }) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.searchProducts(
      name: query,
      organizationId: organizationId,
    );
    if (result.status == StatusModel.success) {
      final products =
          result.data?.map((e) => ProductModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(products)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => searchProducts(query: query, organizationId: organizationId),
          ),
        ),
      );
    }
  }
}
