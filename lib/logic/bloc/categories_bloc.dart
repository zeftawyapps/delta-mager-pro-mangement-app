import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/features/commrec/repo/category_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/category.dart';
import 'dart:typed_data';

class CategoriesBloc extends Cubit<FeaturDataSourceState<CategoryModel>> {
  final CategoryRepo repo;

  CategoriesBloc({required this.repo})
    : super(FeaturDataSourceState<CategoryModel>.defaultState());

  Future<void> loadCategories({required String shopId}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getCategoriesByOrganization(shopId);
    if (result.status == StatusModel.success) {
      // success
      final categories =
          result.data?.map((e) => CategoryModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(categories)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => loadCategories(shopId: shopId),
          ),
        ),
      );
    }
  }

  Future<void> deleteCategory(String id, {required String shopId}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.deleteCategory(id);
    if (result.status == StatusModel.success) {
      emit(
        state.copyWith(itemState: const DataSourceBaseState.init()),
      ); // Reset itemState
      loadCategories(shopId: shopId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => deleteCategory(id, shopId: shopId),
          ),
        ),
      );
    }
  }

  Future<void> createCategory({
    required String name,
    required String shopId,
    String? description,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createCategory(
      name: name,
      shopId: shopId,
      description: description,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            CategoryModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => createCategory(
              name: name,
              shopId: shopId,
              description: description,
              imageBytes: imageBytes,
              imageName: imageName,
            ),
          ),
        ),
      );
    }
  }

  Future<void> updateCategory({
    required String categoryId,
    String? name,
    bool? isActive,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.updateCategory(
      categoryId: categoryId,
      name: name,
      isActive: isActive,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            CategoryModel.fromData(result.data!),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error"),
            () => updateCategory(
              categoryId: categoryId,
              name: name,
              isActive: isActive,
              imageBytes: imageBytes,
              imageName: imageName,
            ),
          ),
        ),
      );
    }
  }
}
