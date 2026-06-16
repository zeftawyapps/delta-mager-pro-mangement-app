import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/blog_category.dart';

class BlogCategoriesBloc extends Cubit<FeaturDataSourceState<BlogCategoryModel>> {
  final BlogRepo repo;

  BlogCategoriesBloc({required this.repo})
      : super(FeaturDataSourceState<BlogCategoryModel>.defaultState());

  Future<void> loadCategories({required String organizationId, bool activeOnly = false, String? lang}) async {
    print("[BlogCategoriesBloc] loadCategories called for org: $organizationId, activeOnly: $activeOnly");
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    try {
      final result = await repo.getCategoriesByOrganization(
        organizationId: organizationId,
        activeOnly: activeOnly,
        lang: lang,
      );

      print("[BlogCategoriesBloc] getCategoriesByOrganization result: status=${result.status}, message=${result.message}");

      if (result.status == StatusModel.success) {
        final categories = result.data?.map((e) => BlogCategoryModel.fromData(e)).toList() ?? [];
        print("[BlogCategoriesBloc] Loaded ${categories.length} categories successfully");
        emit(state.copyWith(listState: DataSourceBaseState.success(categories)));
      } else {
        print("[BlogCategoriesBloc] Failed to load categories: ${result.message}");
        emit(
          state.copyWith(
            listState: DataSourceBaseState.failure(
              ErrorStateModel(message: result.message ?? "Error loading categories"),
              () => loadCategories(organizationId: organizationId, activeOnly: activeOnly, lang: lang),
            ),
          ),
        );
      }
    } catch (e, stack) {
      print("[BlogCategoriesBloc] Exception in loadCategories: $e\n$stack");
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: e.toString()),
            () => loadCategories(organizationId: organizationId, activeOnly: activeOnly, lang: lang),
          ),
        ),
      );
    }
  }

  Future<void> createCategory({
    required Map<String, String> name,
    required String organizationId,
    bool isActive = true,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createBlogCategory(
      name: name,
      organizationId: organizationId,
      isActive: isActive,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            BlogCategoryModel.fromData(result.data!),
          ),
        ),
      );
      loadCategories(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error creating category"),
            () {},
          ),
        ),
      );
    }
  }

  Future<void> updateCategory({
    required String blogCategoryId,
    required Map<String, dynamic> data,
    required String organizationId,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.updateBlogCategory(
      blogCategoryId: blogCategoryId,
      data: data,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            BlogCategoryModel.fromData(result.data!),
          ),
        ),
      );
      loadCategories(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error updating category"),
            () => updateCategory(
              blogCategoryId: blogCategoryId,
              data: data,
              organizationId: organizationId,
            ),
          ),
        ),
      );
    }
  }

  Future<void> deleteCategory(String blogCategoryId, {required String organizationId}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.deleteBlogCategory(blogCategoryId);

    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      loadCategories(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error deleting category"),
            () => deleteCategory(blogCategoryId, organizationId: organizationId),
          ),
        ),
      );
    }
  }
}
