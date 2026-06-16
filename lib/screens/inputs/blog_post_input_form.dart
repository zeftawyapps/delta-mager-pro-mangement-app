import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:JoDija_tamplites/util/widgits/images_widgets/image_picker_widget.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/blog_posts_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/blog_categories_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/blog_post.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/blog_category.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';

class BlogPostInputForm extends StatefulWidget {
  final String organizationId;
  final BlogPostModel? post;

  const BlogPostInputForm({super.key, required this.organizationId, this.post});

  @override
  State<BlogPostInputForm> createState() => _BlogPostInputFormState();
}

class _BlogPostInputFormState extends State<BlogPostInputForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TabController _editorTabController;

  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;
  late TextEditingController _slugController;
  late TextEditingController _coreKeyController;

  late QuillController _quillControllerAr;
  late QuillController _quillControllerEn;

  // Intro Controllers
  late TextEditingController _introTitleArController;
  late TextEditingController _introTitleEnController;
  late TextEditingController _introDescriptionArController;
  late TextEditingController _introDescriptionEnController;

  // SEO Controllers
  late TextEditingController _seoTitleArController;
  late TextEditingController _seoTitleEnController;
  late TextEditingController _seoDescriptionArController;
  late TextEditingController _seoDescriptionEnController;
  late TextEditingController _seoKeywordsController;

  String _postType = 'post';
  String? _blogCategoryId;
  bool _isActive = true;
  bool _isJoker = false;
  bool _isFeatured = false;
  bool _isMost = false;
  bool _showInFooter = false;
  bool _showInNavigation = false;

  ImageFileModel? _selectedImage;
  ImageFileModel? _selectedIntroImage;
  bool _showSeoPanel = false;
  bool _showIntroPanel = false;

  @override
  void initState() {
    super.initState();
    _editorTabController = TabController(length: 2, vsync: this);

    final p = widget.post;
    _titleArController = TextEditingController(text: p?.title.ar ?? '');
    _titleEnController = TextEditingController(text: p?.title.en ?? '');
    _slugController = TextEditingController(text: p?.slug ?? '');
    _coreKeyController = TextEditingController(text: p?.coreKey ?? '');

    _introTitleArController = TextEditingController(text: p?.introTitleAr ?? '');
    _introTitleEnController = TextEditingController(text: p?.introTitleEn ?? '');
    _introDescriptionArController = TextEditingController(text: p?.introDescriptionAr ?? '');
    _introDescriptionEnController = TextEditingController(text: p?.introDescriptionEn ?? '');

    _seoTitleArController = TextEditingController(text: p?.seoTitleAr ?? '');
    _seoTitleEnController = TextEditingController(text: p?.seoTitleEn ?? '');
    _seoDescriptionArController = TextEditingController(
      text: p?.seoDescriptionAr ?? '',
    );
    _seoDescriptionEnController = TextEditingController(
      text: p?.seoDescriptionEn ?? '',
    );
    _seoKeywordsController = TextEditingController(
      text: p?.seoKeywords.join(', ') ?? '',
    );

    _postType = p?.postType ?? 'post';
    _blogCategoryId = p?.blogCategoryId;
    _isActive = p?.isActive ?? true;
    _isJoker = p?.isJoker ?? false;
    _isFeatured = p?.isFeatured ?? false;
    _isMost = p?.isMost ?? false;
    _showInFooter = p?.showInFooter ?? false;
    _showInNavigation = p?.showInNavigation ?? false;

    // Load rich text html editors safely
    _quillControllerAr = _initQuillController(p?.content.ar ?? '');
    _quillControllerEn = _initQuillController(p?.content.en ?? '');

    // Load categories for selector
    context.read<BlogCategoriesBloc>().loadCategories(
      organizationId: widget.organizationId,
    );
  }

  QuillController _initQuillController(String htmlContent) {
    Delta delta;
    try {
      if (htmlContent.isNotEmpty) {
        delta = HtmlToDelta().convert(htmlContent);
        // Quill requires the delta to have at least one op (the trailing newline).
        // HtmlToDelta can return an empty delta for whitespace-only / bad HTML.
        if (delta.isEmpty) {
          delta = Delta()..insert('\n');
        }
      } else {
        delta = Delta()..insert('\n');
      }
    } catch (_) {
      delta = Delta()..insert('\n');
    }
    return QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  String _quillToHtml(QuillController controller) {
    try {
      final deltaJson = controller.document.toDelta().toJson();
      final converter = QuillDeltaToHtmlConverter(
        List<Map<String, dynamic>>.from(deltaJson),
      );
      return converter.convert();
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _editorTabController.dispose();
    _titleArController.dispose();
    _titleEnController.dispose();
    _slugController.dispose();
    _coreKeyController.dispose();
    _quillControllerAr.dispose();
    _quillControllerEn.dispose();
    _introTitleArController.dispose();
    _introTitleEnController.dispose();
    _introDescriptionArController.dispose();
    _introDescriptionEnController.dispose();
    _seoTitleArController.dispose();
    _seoTitleEnController.dispose();
    _seoDescriptionArController.dispose();
    _seoDescriptionEnController.dispose();
    _seoKeywordsController.dispose();
    super.dispose();
  }

  void _savePost() {
    if (!_formKey.currentState!.validate()) return;

    final title = {
      'ar': _titleArController.text.trim(),
      'en': _titleEnController.text.trim(),
    };
    final content = {
      'ar': _quillToHtml(_quillControllerAr),
      'en': _quillToHtml(_quillControllerEn),
    };

    // Intro fields
    Map<String, String>? introTitle;
    if (_introTitleArController.text.isNotEmpty ||
        _introTitleEnController.text.isNotEmpty) {
      introTitle = {
        'ar': _introTitleArController.text.trim(),
        'en': _introTitleEnController.text.trim(),
      };
    }

    Map<String, String>? introDescription;
    if (_introDescriptionArController.text.isNotEmpty ||
        _introDescriptionEnController.text.isNotEmpty) {
      introDescription = {
        'ar': _introDescriptionArController.text.trim(),
        'en': _introDescriptionEnController.text.trim(),
      };
    }

    // SEO fields
    Map<String, String>? seoTitle;
    if (_seoTitleArController.text.isNotEmpty ||
        _seoTitleEnController.text.isNotEmpty) {
      seoTitle = {
        'ar': _seoTitleArController.text.trim(),
        'en': _seoTitleEnController.text.trim(),
      };
    }

    Map<String, String>? seoDescription;
    if (_seoDescriptionArController.text.isNotEmpty ||
        _seoDescriptionEnController.text.isNotEmpty) {
      seoDescription = {
        'ar': _seoDescriptionArController.text.trim(),
        'en': _seoDescriptionEnController.text.trim(),
      };
    }

    List<String> seoKeywords = [];
    if (_seoKeywordsController.text.isNotEmpty) {
      seoKeywords = _seoKeywordsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final isEditing = widget.post != null;

    // Sanitize footer and navigation properties for non-page types
    final showInFooter = _postType == 'page' ? _showInFooter : false;
    final showInNavigation = _postType == 'page' ? _showInNavigation : false;

    if (isEditing) {
      final Map<String, dynamic> updateData = {
        'title': title,
        'slug': _slugController.text.trim(),
        'content': content,
        'postType': _postType,
        'blogCategoryId': (_postType == 'page' || _postType == 'intro') ? null : _blogCategoryId,
        'isActive': _isActive,
        'isJoker': _isJoker,
        'isFeatured': _isFeatured,
        'isMost': _isMost,
        'showInFooter': showInFooter,
        'showInNavigation': showInNavigation,
        'seoTitle': seoTitle,
        'seoDescription': seoDescription,
        'seoKeywords': seoKeywords,
        if (_postType == 'page') 'coreKey': _coreKeyController.text.trim(),
        if (_postType == 'intro') ...{
          'introTitle': introTitle,
          'introDescription': introDescription,
        },
      };

      context.read<BlogPostsBloc>().updatePost(
        blogPostId: widget.post!.id,
        data: updateData,
        organizationId: widget.organizationId,
        imageBytes: _selectedImage?.bytes,
        imageName: _selectedImage?.file?.path.split('/').last,
        introImageBytes: _selectedIntroImage?.bytes,
        introImageName: _selectedIntroImage?.file?.path.split('/').last,
      );
    } else {
      context.read<BlogPostsBloc>().createPost(
        title: title,
        slug: _slugController.text.trim(),
        content: content,
        postType: _postType,
        blogCategoryId: (_postType == 'page' || _postType == 'intro') ? null : _blogCategoryId,
        organizationId: widget.organizationId,
        imageBytes: _selectedImage?.bytes,
        imageName: _selectedImage?.file?.path.split('/').last,
        isActive: _isActive,
        isJoker: _isJoker,
        isFeatured: _isFeatured,
        isMost: _isMost,
        showInFooter: showInFooter,
        showInNavigation: showInNavigation,
        seoTitle: seoTitle,
        seoDescription: seoDescription,
        seoKeywords: seoKeywords,
        coreKey: _postType == 'page' ? _coreKeyController.text.trim() : null,
        introTitle: _postType == 'intro' ? introTitle : null,
        introDescription: _postType == 'intro' ? introDescription : null,
        introImageBytes: _postType == 'intro' ? _selectedIntroImage?.bytes : null,
        introImageName: _postType == 'intro' ? _selectedIntroImage?.file?.path.split('/').last : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;
    final isEditing = widget.post != null;

    return BlocListener<BlogPostsBloc, FeaturDataSourceState<BlogPostModel>>(
      listener: (context, state) {
        state.itemState.maybeWhen(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing
                      ? 'تم تعديل المنشور بنجاح'
                      : 'تم إضافة المنشور بنجاح',
                ),
              ),
            );
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop(data);
            }
          },
          failure: (error, reload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('❌ ${error.message ?? 'حدث خطأ ما'}'),
              ),
            );
          },
          orElse: () {},
        );
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? DarkColors.surface : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'تعديل المنشور' : 'إضافة منشور جديد',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if (Navigator.of(context, rootNavigator: true).canPop()) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Form Contents
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: Main details (Left/Center area - 65% width)
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Arabic & English Title Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _titleArController,
                                    decoration: const InputDecoration(
                                      labelText: "عنوان المقال (بالعربية)",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.title),
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                        ? "العنوان بالعربية مطلوب"
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _titleEnController,
                                    decoration: const InputDecoration(
                                      labelText: "عنوان المقال (بالإنجليزية)",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.title),
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                        ? "العنوان بالإنجليزية مطلوب"
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Post content editor tabs
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  TabBar(
                                    controller: _editorTabController,
                                    labelColor: primaryColor,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: primaryColor,
                                    tabs: const [
                                      Tab(text: "المحتوى بالعربية (HTML)"),
                                      Tab(text: "المحتوى بالإنجليزية (HTML)"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 350,
                                    child: TabBarView(
                                      controller: _editorTabController,
                                      children: [
                                        _buildRichEditor(
                                          _quillControllerAr,
                                          isDark,
                                        ),
                                        _buildRichEditor(
                                          _quillControllerEn,
                                          isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Intro Slide Panel (Only shown if type is intro)
                            if (_postType == 'intro') ...[
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: primaryColor.withOpacity(0.15),
                                  ),
                                ),
                                color: primaryColor.withOpacity(0.02),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.slideshow, color: primaryColor),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "إعدادات الشريحة التعريفية (Intro Slide)",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _introTitleArController,
                                              decoration: const InputDecoration(
                                                labelText: "عنوان الشريحة بالعربية",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _introTitleEnController,
                                              decoration: const InputDecoration(
                                                labelText: "عنوان الشريحة بالإنجليزية",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _introDescriptionArController,
                                              maxLines: 2,
                                              decoration: const InputDecoration(
                                                labelText: "وصف الشريحة بالعربية",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _introDescriptionEnController,
                                              maxLines: 2,
                                              decoration: const InputDecoration(
                                                labelText: "وصف الشريحة بالإنجليزية",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "صورة الشريحة التعريفية:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 180,
                                        width: 320,
                                        child: ImagePecker(
                                          networkImage: _getCleanImageUrl(widget.post?.introImageUrl),
                                          onImageSelected: (imageModel) {
                                            setState(() {
                                              _selectedIntroImage = imageModel;
                                            });
                                          },
                                          placeholderAsset: AppAsset.imgplaceholder,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // SEO & Metadata Panel (Premium collapsible Card)
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: primaryColor.withOpacity(0.15),
                                ),
                              ),
                              color: primaryColor.withOpacity(0.02),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Icon(Icons.search, color: primaryColor),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "إعدادات أرشفة محركات البحث والـ SEO (اختياري)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      _showSeoPanel
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: primaryColor,
                                    ),
                                    onTap: () => setState(
                                      () => _showSeoPanel = !_showSeoPanel,
                                    ),
                                  ),
                                  if (_showSeoPanel)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _seoTitleArController,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            "عنوان SEO بالعربية",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _seoTitleEnController,
                                                  decoration: const InputDecoration(
                                                    labelText:
                                                        "عنوان SEO بالإنجليزية",
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _seoDescriptionArController,
                                                  maxLines: 2,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            "وصف SEO بالعربية",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _seoDescriptionEnController,
                                                  maxLines: 2,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            "وصف SEO بالإنجليزية",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _seoKeywordsController,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  "الكلمات الدلالية للـ SEO (افصل بينها بفاصلة ,)",
                                              hintText:
                                                  "مثال: تسوق, متجر, ملابس, موضة",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Column 2: Configurations & Image (Right area - 35% width)
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Post image cover
                            const Text(
                              "الصورة البصرية للمنشور:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ImagePecker(
                              networkImage: _getCleanImageUrl(widget.post?.imageUrl),
                              onImageSelected: (imageModel) {
                                setState(() {
                                  _selectedImage = imageModel;
                                });
                              },
                              placeholderAsset: AppAsset.imgplaceholder,
                            ),
                            const SizedBox(height: 24),

                            // 2. Publication Settings
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DarkColors.surfaceVariant
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Post type Dropdown
                                  DropdownButtonFormField<String>(
                                    value: _postType,
                                    decoration: const InputDecoration(
                                      labelText: "نوع المنشور",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'post',
                                        child: Text("مقال أو خبر (Post)"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'page',
                                        child: Text("صفحة ثابتة (Page)"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'intro',
                                        child: Text("شريحة تعريفية (Intro Slide)"),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _postType = val);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // CoreKey field (only shown if type is page)
                                  if (_postType == 'page') ...[
                                    TextFormField(
                                      controller: _coreKeyController,
                                      decoration: const InputDecoration(
                                        labelText: "مفتاح الصفحة (Core Key)",
                                        hintText: "مثال: privacy-policy",
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (val) =>
                                          _postType == 'page' &&
                                              (val == null ||
                                                  val.trim().isEmpty)
                                          ? "مفتاح الصفحة مطلوب للصفحات التعريفية"
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Category Dropdown (only shown if type is post)
                                  if (_postType == 'post') ...[
                                    BlocBuilder<
                                      BlogCategoriesBloc,
                                      FeaturDataSourceState<BlogCategoryModel>
                                    >(
                                      builder: (context, state) {
                                        final categories = state.listState
                                            .maybeWhen(
                                              success: (items) => items,
                                              orElse: () =>
                                                  <BlogCategoryModel>[],
                                            );
                                        final isLoading = state.listState
                                            .maybeWhen(
                                              loading: () => true,
                                              orElse: () => false,
                                            );
                                        final isFailure = state.listState
                                            .maybeWhen(
                                              failure: (err, retry) => true,
                                              orElse: () => false,
                                            );
                                        final errorMsg = state.listState
                                            .maybeWhen(
                                              failure: (err, retry) =>
                                                  err.message,
                                              orElse: () => null,
                                            );

                                        print(
                                          "[BlogPostInputForm] BlocBuilder state: ${state.listState}, categories count: ${categories!.length}, error: $errorMsg",
                                        );

                                        // Safeguard: Ensure the selected value exists in the loaded items
                                        final selectedValue =
                                            categories.any(
                                              (cat) =>
                                                  cat.id == _blogCategoryId,
                                            )
                                            ? _blogCategoryId
                                            : null;

                                        if (isFailure) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "⚠️ فشل تحميل التصنيفات: ${errorMsg ?? ''}",
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              TextButton.icon(
                                                onPressed: () {
                                                  context
                                                      .read<
                                                        BlogCategoriesBloc
                                                      >()
                                                      .loadCategories(
                                                        organizationId: widget
                                                            .organizationId,
                                                      );
                                                },
                                                icon: const Icon(
                                                  Icons.refresh,
                                                  size: 16,
                                                ),
                                                label: const Text(
                                                  "إعادة المحاولة",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        if (categories.isEmpty && !isLoading) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "⚠️ لا توجد تصنيفات مدونة حالياً. يرجى إضافة تصنيف أولاً من علامة تبويب التصنيفات.",
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              DropdownButtonFormField<String>(
                                                value: null,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText:
                                                          "تصنيف المقال (فارغ)",
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                items: const [],
                                                onChanged: null,
                                              ),
                                            ],
                                          );
                                        }

                                        return DropdownButtonFormField<String>(
                                          value: selectedValue,
                                          decoration: InputDecoration(
                                            labelText: "تصنيف المقال",
                                            border: const OutlineInputBorder(),
                                            suffixIcon: isLoading
                                                ? const Padding(
                                                    padding: EdgeInsets.all(
                                                      12.0,
                                                    ),
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          items: categories.map((cat) {
                                            return DropdownMenuItem<String>(
                                              value: cat.id,
                                              child: Text(cat.name.ar),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              _blogCategoryId = val;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Friendly Slug
                                  TextFormField(
                                    controller: _slugController,
                                    decoration: const InputDecoration(
                                      labelText: "الرابط الفريد (Slug)",
                                      hintText: "مثال: how-to-shop",
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                        ? "الرابط الفرعي مطلوب"
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  const Divider(),

                                  // Switches for Joker, Featured, Active
                                  SwitchListTile(
                                    title: const Text(
                                      "نشر فوري (نشط)",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: _isActive,
                                    onChanged: (val) =>
                                        setState(() => _isActive = val),
                                    activeColor: primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                  ),

                                  SwitchListTile(
                                    title: const Text(
                                      "تثبيت كالجوكر الرئيسي",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    subtitle: const Text(
                                      "مقال رئيسي كبير أعلى الصفحة الهبوط",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    value: _isJoker,
                                    onChanged: (val) =>
                                        setState(() => _isJoker = val),
                                    activeColor: Colors.amber,
                                    contentPadding: EdgeInsets.zero,
                                  ),

                                  SwitchListTile(
                                    title: const Text(
                                      "تثبيت كمقال مميز",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    subtitle: const Text(
                                      "يعرض في قسم المميز بالصفحة الهبوط",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    value: _isFeatured,
                                    onChanged: (val) =>
                                        setState(() => _isFeatured = val),
                                    activeColor: primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                  ),

                                  if (_postType == 'post') ...[
                                    SwitchListTile(
                                      title: const Text(
                                        "تثبيت كالأكثر رواجاً/قراءة (isMost)",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      subtitle: const Text(
                                        "يعرض في قسم المقالات الأكثر رواجاً بالصفحة الهبوط",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      value: _isMost,
                                      onChanged: (val) =>
                                          setState(() => _isMost = val),
                                      activeColor: primaryColor,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ],

                                  if (_postType == 'page') ...[
                                    SwitchListTile(
                                      title: const Text(
                                        "إظهار في التذييل (Footer)",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      value: _showInFooter,
                                      onChanged: (val) =>
                                          setState(() => _showInFooter = val),
                                      activeColor: primaryColor,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    SwitchListTile(
                                      title: const Text(
                                        "إظهار في القائمة العلوية (Navigation)",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      value: _showInNavigation,
                                      onChanged: (val) =>
                                          setState(() => _showInNavigation = val),
                                      activeColor: primaryColor,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions (Save / Cancel)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? DarkColors.surface : Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _savePost,
                          icon: const Icon(Icons.save),
                          label: Text(
                            isEditing ? 'حفظ التعديلات' : 'نشر المنشور',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "إلغاء",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichEditor(QuillController controller, bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showInlineCode: false,
              showSubscript: false,
              showSuperscript: false,
              showSearchButton: false,
              showListCheck: false,
              showIndent: false,
              multiRowsDisplay: false,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(
                placeholder: "ابدأ بالكتابة وتنسيق المقال هنا...",
                expands: true,
                scrollable: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _getCleanImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    final cleanPath = rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl;
    return '${AppBackendEnv().imageUrl}/$cleanPath';
  }
}
