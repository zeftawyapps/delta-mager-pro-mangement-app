import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/org_lifecycle_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/blog_posts_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/blog_categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/blog_post.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/blog_category.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/blog_post_input_form.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/app_bar_config.dart';

class BlogsScreen extends StatefulWidget with AppShellRouterMixin {
  BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen>
    with SingleTickerProviderStateMixin, SystemManager, OrgLifecycleManager {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // البدء بالاستماع لتغيرات معرّف المنظمة بشكل آمن وإعادة التحميل تلقائياً
    initOrgListener(
      onOrgChanged: (orgId) {
        context.read<BlogPostsBloc>().loadPosts(organizationId: orgId);
        context.read<BlogCategoriesBloc>().loadCategories(
          organizationId: orgId,
        );
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addBlogPost() {
    showCustomInputDialog(
      context: context,
      content: BlogPostInputForm(organizationId: organizationId),
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width * 0.75,
      onResult: (result) {
        context.read<BlogPostsBloc>().loadPosts(organizationId: organizationId);
        context.read<BlogCategoriesBloc>().loadCategories(
          organizationId: organizationId,
        );
      },
    );
  }

  void _editBlogPost(BlogPostModel post) {
    showCustomInputDialog(
      context: context,
      content: BlogPostInputForm(organizationId: organizationId, post: post),
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width * 0.75,
      onResult: (result) {
        context.read<BlogPostsBloc>().loadPosts(organizationId: organizationId);
        context.read<BlogCategoriesBloc>().loadCategories(
          organizationId: organizationId,
        );
      },
    );
  }

  void _deleteBlogPost(BlogPostModel post) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text("هل أنت متأكد من حذف المنشور \"${post.title.ar}\"؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<BlogPostsBloc>().deletePost(
                  post.id,
                  organizationId: organizationId,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("حذف"),
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory() {
    _showCategoryDialog();
  }

  void _editCategory(BlogCategoryModel category) {
    _showCategoryDialog(category: category);
  }

  void _showCategoryDialog({BlogCategoryModel? category}) {
    final isEditing = category != null;
    final nameArController = TextEditingController(
      text: category?.name.ar ?? '',
    );
    final nameEnController = TextEditingController(
      text: category?.name.en ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEditing ? "تعديل تصنيف" : "إضافة تصنيف جديد للمدونة"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameArController,
                  decoration: const InputDecoration(
                    labelText: "الاسم بالعربية",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? "هذا الحقل مطلوب"
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameEnController,
                  decoration: const InputDecoration(
                    labelText: "الاسم بالإنجليزية",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? "هذا الحقل مطلوب"
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context);
                if (isEditing) {
                  context.read<BlogCategoriesBloc>().updateCategory(
                    blogCategoryId: category.id,
                    organizationId: organizationId,
                    data: {
                      'name': {
                        'ar': nameArController.text.trim(),
                        'en': nameEnController.text.trim(),
                      },
                    },
                  );
                } else {
                  context.read<BlogCategoriesBloc>().createCategory(
                    organizationId: organizationId,
                    name: {
                      'ar': nameArController.text.trim(),
                      'en': nameEnController.text.trim(),
                    },
                  );
                }
              },
              child: Text(isEditing ? "حفظ التعديل" : "إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(BlogCategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text("هل أنت متأكد من حذف التصنيف \"${category.name.ar}\"؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<BlogCategoriesBloc>().deleteCategory(
                  category.id,
                  organizationId: organizationId,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("حذف"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.blog,
      mainPath: widget.getMainPath(),
    );

    if (sys.authWidget != null) return sys.authWidget!;

    final canAdd = sys.canAdd;
    final canUpdate = sys.canUpdate;
    final canDelete = sys.canDelete;
    final isDark = sys.isDark;
    final appBarConfig = sys.appBarConfig;
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        appBar: appBarConfig.buildAppBar(
          context: context,
          isAppBar: true,
          currentTilte: "المدونة والصفحات",
          isDesplayTitle: true,
        ),
        body: Column(
          children: [
            Container(
              color: isDark ? DarkColors.background : LightColors.background,
              child: TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.description_outlined),
                    text: "المقالات والصفحات",
                  ),
                  Tab(
                    icon: Icon(Icons.category_outlined),
                    text: "تصنيفات المدونة",
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Posts & Pages
                  MasterGrid<BlogPostModel, BlogPostsBloc>(
                    title: "المقالات والصفحات",
                    searchHint: "ابحث باسم المقال أو الصفحة...",
                    onAdd: _addBlogPost,
                    onLoad: (bloc) => bloc.loadPosts(organizationId: organizationId),
                    onSearch: (bloc, query) => bloc.loadPosts(
                      organizationId: organizationId,
                    ),
                    canAdd: canAdd,
                    canMultiSelect: false,
                    itemBuilder: (context, post, isSelected) => _BlogPostCard(
                      post: post,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      canUpdate: canUpdate,
                      canDelete: canDelete,
                      onEdit: () => _editBlogPost(post),
                      onDelete: () => _deleteBlogPost(post),
                    ),
                    crossAxisCountSmall: 1,
                    crossAxisCountMedium: 2,
                    crossAxisCountLarge: 3,
                    childAspectRatio: 1.35,
                  ),
                  // Tab 2: Categories
                  MasterGrid<BlogCategoryModel, BlogCategoriesBloc>(
                    title: "تصنيفات المدونة",
                    searchHint: "ابحث باسم التصنيف...",
                    onAdd: _addCategory,
                    onLoad: (bloc) =>
                        bloc.loadCategories(organizationId: organizationId),
                    onSearch: (bloc, query) =>
                        bloc.loadCategories(organizationId: organizationId),
                    canAdd: canAdd,
                    canMultiSelect: false,
                    itemBuilder: (context, category, isSelected) => _BlogCategoryCard(
                      category: category,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      canUpdate: canUpdate,
                      canDelete: canDelete,
                      onEdit: () => _editCategory(category),
                      onDelete: () => _deleteCategory(category),
                    ),
                    crossAxisCountSmall: 1,
                    crossAxisCountMedium: 2,
                    crossAxisCountLarge: 4,
                    childAspectRatio: 2.2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlogPostCard extends StatelessWidget {
  final BlogPostModel post;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canUpdate;
  final bool canDelete;

  const _BlogPostCard({
    required this.post,
    required this.isDark,
    required this.primaryColor,
    required this.onEdit,
    required this.onDelete,
    required this.canUpdate,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? DarkColors.surface : Colors.white;
    final textTheme = Theme.of(context).textTheme;

    // Full backend image path mapping
    final displayImageUrl = (post.postType == 'intro' && post.introImageUrl != null && post.introImageUrl!.isNotEmpty)
        ? post.introImageUrl
        : post.imageUrl;

    String? fullImageUrl;
    if (displayImageUrl != null && displayImageUrl.isNotEmpty) {
      if (displayImageUrl.startsWith('http') ||
          displayImageUrl.startsWith('https')) {
        fullImageUrl = displayImageUrl;
      } else {
        final cleanPath = displayImageUrl.startsWith('/')
            ? displayImageUrl.substring(1)
            : displayImageUrl;
        fullImageUrl = '${AppBackendEnv().imageUrl}/$cleanPath';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: post.isJoker
              ? Colors.amber.withOpacity(0.4)
              : (post.isFeatured
                    ? primaryColor.withOpacity(0.3)
                    : Colors.transparent),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header Image & Badges
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (fullImageUrl != null)
                  Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.withOpacity(0.1),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  Container(
                    color: primaryColor.withOpacity(0.05),
                    child: Icon(
                      post.postType == 'page'
                          ? Icons.description_outlined
                          : (post.postType == 'intro'
                              ? Icons.slideshow_outlined
                              : Icons.article_outlined),
                      size: 40,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),

                // Absolute Badges
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: post.postType == 'page'
                          ? Colors.teal
                          : (post.postType == 'intro'
                              ? Colors.purple
                              : Colors.blue),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      post.postType == 'page'
                          ? "صفحة ثابتة"
                          : (post.postType == 'intro'
                              ? "شريحة تعريفية"
                              : "مقال"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                if (post.isJoker)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            "الجوكر",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (post.isFeatured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "مميز",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Post Body Details
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title.ar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "الرابط: /${post.slug}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),

                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Active/Inactive Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: post.isActive
                              ? Colors.green.withOpacity(0.08)
                              : Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: post.isActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          post.isActive ? "نشط" : "مسودة",
                          style: TextStyle(
                            color: post.isActive ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Edit/Delete actions
                      Row(
                        children: [
                          if (canUpdate)
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Colors.blue,
                              ),
                              onPressed: onEdit,
                              tooltip: "تعديل",
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          if (canUpdate && canDelete) const SizedBox(width: 8),
                          if (canDelete)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: onDelete,
                              tooltip: "حذف",
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogCategoryCard extends StatelessWidget {
  final BlogCategoryModel category;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canUpdate;
  final bool canDelete;

  const _BlogCategoryCard({
    required this.category,
    required this.isDark,
    required this.primaryColor,
    required this.onEdit,
    required this.onDelete,
    required this.canUpdate,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? DarkColors.surface : Colors.white;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tag_outlined, size: 16, color: primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name.ar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "EN: ${category.name.en}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Row(
                children: [
                  if (canUpdate)
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.blue,
                      ),
                      onPressed: onEdit,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  if (canUpdate && canDelete) const SizedBox(width: 4),
                  if (canDelete)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
