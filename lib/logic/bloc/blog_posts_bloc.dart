import 'dart:typed_data';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/blog_post.dart';

class BlogPostsBloc extends Cubit<FeaturDataSourceState<BlogPostModel>> {
  final BlogRepo repo;

  BlogPostsBloc({required this.repo})
      : super(FeaturDataSourceState<BlogPostModel>.defaultState());

  Future<void> loadPosts({required String organizationId, String? lang}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getPostsByOrganization(
      organizationId: organizationId,
      lang: lang,
    );

    if (result.status == StatusModel.success) {
      final posts = result.data?.map((e) => BlogPostModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(posts)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading posts"),
            () => loadPosts(organizationId: organizationId, lang: lang),
          ),
        ),
      );
    }
  }

  Future<void> loadPostsByType({required String postType, required String organizationId, String? lang}) async {
    emit(state.copyWith(listState: const DataSourceBaseState.loading()));
    final result = await repo.getPostsByType(
      postType: postType,
      organizationId: organizationId,
      lang: lang,
    );

    if (result.status == StatusModel.success) {
      final posts = result.data?.map((e) => BlogPostModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(listState: DataSourceBaseState.success(posts)));
    } else {
      emit(
        state.copyWith(
          listState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading posts by type"),
            () => loadPostsByType(postType: postType, organizationId: organizationId, lang: lang),
          ),
        ),
      );
    }
  }

  Future<void> createPost({
    required Map<String, String> title,
    required String slug,
    required Map<String, String> content,
    required String postType,
    String? blogCategoryId,
    required String organizationId,
    List<String> relatedProducts = const [],
    Uint8List? imageBytes,
    String? imageName,
    bool isActive = true,
    String? coreKey,
    Map<String, String>? seoTitle,
    Map<String, String>? seoDescription,
    List<String> seoKeywords = const [],
    bool isJoker = false,
    bool isFeatured = false,
    bool isMost = false,
    bool showInFooter = false,
    bool showInNavigation = false,
    Map<String, String>? introTitle,
    Map<String, String>? introDescription,
    Uint8List? introImageBytes,
    String? introImageName,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.createBlogPost(
      title: title,
      slug: slug,
      content: content,
      postType: postType,
      blogCategoryId: blogCategoryId,
      organizationId: organizationId,
      relatedProducts: relatedProducts,
      imageBytes: imageBytes,
      imageName: imageName,
      isActive: isActive,
      coreKey: coreKey,
      seoTitle: seoTitle,
      seoDescription: seoDescription,
      seoKeywords: seoKeywords,
      isJoker: isJoker,
      isFeatured: isFeatured,
      isMost: isMost,
      showInFooter: showInFooter,
      showInNavigation: showInNavigation,
      introTitle: introTitle,
      introDescription: introDescription,
      introImageBytes: introImageBytes,
      introImageName: introImageName,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            BlogPostModel.fromData(result.data!),
          ),
        ),
      );
      loadPosts(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error creating post"),
            () {},
          ),
        ),
      );
    }
  }

  Future<void> updatePost({
    required String blogPostId,
    required Map<String, dynamic> data,
    required String organizationId,
    Uint8List? imageBytes,
    String? imageName,
    Uint8List? introImageBytes,
    String? introImageName,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.updateBlogPost(
      blogPostId: blogPostId,
      data: data,
      imageBytes: imageBytes,
      imageName: imageName,
      introImageBytes: introImageBytes,
      introImageName: introImageName,
    );

    if (result.status == StatusModel.success && result.data != null) {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(
            BlogPostModel.fromData(result.data!),
          ),
        ),
      );
      loadPosts(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error updating post"),
            () => updatePost(
              blogPostId: blogPostId,
              data: data,
              organizationId: organizationId,
              imageBytes: imageBytes,
              imageName: imageName,
            ),
          ),
        ),
      );
    }
  }

  Future<void> deletePost(String blogPostId, {required String organizationId}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.deleteBlogPost(blogPostId);

    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      loadPosts(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error deleting post"),
            () => deletePost(blogPostId, organizationId: organizationId),
          ),
        ),
      );
    }
  }

  Future<void> seedLegalPages({required String organizationId}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.seedDefaultLegalPages(organizationId: organizationId);

    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.init()));
      loadPosts(organizationId: organizationId);
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error seeding legal pages"),
            () => seedLegalPages(organizationId: organizationId),
          ),
        ),
      );
    }
  }
}
