import 'dart:typed_data';

import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/features/commrec/repo/product_repo.dart';
import 'package:matger_pro_core_logic/features/commrec/request_body/product_request_bodies.dart';
import 'package:matger_pro_core_logic/features/commrec/data/product_model.dart' show PriceOption;
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

  Future<void> bulkDeleteProducts({
    required List<String> productIds,
    required String organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final request = BulkDeleteProductsRequest(
      organizationId: organizationId,
      productIds: productIds,
    );
    final result = await repo.bulkDeleteProducts(request: request);
    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.success(null)));
      loadProducts();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => bulkDeleteProducts(
              productIds: productIds,
              organizationId: organizationId,
            ),
          ),
        ),
      );
    }
  }

  Future<void> bulkUpdateProducts({
    required List<String> productIds,
    required String organizationId,
    required Map<String, dynamic> updateData,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final request = BulkUpdateProductsRequest(
      organizationId: organizationId,
      productIds: productIds,
      updateData: updateData,
    );
    final result = await repo.bulkUpdateProducts(request: request);
    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      loadProducts();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => bulkUpdateProducts(
              productIds: productIds,
              organizationId: organizationId,
              updateData: updateData,
            ),
          ),
        ),
      );
    }
  }

  Future<void> unifyProductsPrice({
    required List<String> productIds,
    required String organizationId,
    required List<PriceOption> priceOptions,
    double? basePrice,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final request = SharedPricingRequest(
      organizationId: organizationId,
      productIds: productIds,
      priceOptions: priceOptions,
      basePrice: basePrice,
      mode: 'replace',
    );
    final result = await repo.sharedPricingApply(request: request);
    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      loadProducts();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => unifyProductsPrice(
              productIds: productIds,
              organizationId: organizationId,
              priceOptions: priceOptions,
              basePrice: basePrice,
            ),
          ),
        ),
      );
    }
  }

  Future<void> createProductVariants({
    required List<dynamic> variantNames,
    required Map<String, dynamic> template,
    required String organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    // بناء قائمة المنتجات يدوياً لضمان التوافق مع الهيكل المطلوب
    final List<ProductData> products = variantNames.map((nameData) {
      // nameData هو {"ar": "...", "en": "..."}
      final nameMap = nameData as Map<String, String>;
      
      // دمج بيانات القالب مع الاسم المخصص
      final Map<String, dynamic> productJson = {
        ...template,
        'name': nameMap,
        'organizationId': organizationId,
        'id': '', // سيتم توليده في السيرفر
        'images': [],
      };
      
      return ProductData.fromJson(productJson);
    }).toList();

    final request = BulkCreateProductsRequest(
      organizationId: organizationId,
      products: products,
    );
    
    final result = await repo.bulkCreateProducts(request: request);
    
    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      loadProducts();
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => createProductVariants(
              variantNames: variantNames,
              template: template,
              organizationId: organizationId,
            ),
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
