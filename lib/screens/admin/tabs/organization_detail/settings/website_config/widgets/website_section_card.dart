import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/widgits/images_widgets/image_picker_widget.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/configs/website_config.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/views/assets.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';
import 'intro_color_picker_widgets.dart';

class WebsiteSectionCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> section;
  final bool isEditing;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onRemove;
  final void Function(Map<String, dynamic>) onSectionChanged;
  final Map<int, ImageFileModel?>? pendingShowcaseImages;
  final void Function(int tabIndex, ImageFileModel? image)? onShowcaseImageChanged;
  final String appMode;
  final OrganizationConfig? organizationConfig;

  const WebsiteSectionCard({
    super.key,
    required this.index,
    required this.section,
    required this.isEditing,
    required this.isDark,
    required this.primaryColor,
    required this.onRemove,
    required this.onSectionChanged,
    this.pendingShowcaseImages,
    this.onShowcaseImageChanged,
    this.appMode = WebsiteConfig.appModeHybrid,
    this.organizationConfig,
  });

  @override
  State<WebsiteSectionCard> createState() => _WebsiteSectionCardState();
}

class _WebsiteSectionCardState extends State<WebsiteSectionCard> {
  final Map<String, String> _typeOptions = {
    WebsiteConfig.typeCategories: "الأصناف",
    WebsiteConfig.typeOffers: "العروض",
    WebsiteConfig.typeNewProducts: "المنتجات الجديدة",
    WebsiteConfig.typeBestSellerProducts: "الأكثر مبيعاً",
    WebsiteConfig.typeBlogPosts: "أحدث المقالات",
    WebsiteConfig.typeCustomBanner: "بانر إعلاني مخصص",
    WebsiteConfig.typeIntroSlides: "الشرائح التعريفية (Intro Slides)",
    WebsiteConfig.typeMostReadBlogPosts: "المقالات الأكثر قراءة/رواجاً",
    WebsiteConfig.typeJockerPost: "Jocker Post",
    WebsiteConfig.typeAboutCompany: "تعريف بالشركة (مقال كامل)",
    WebsiteConfig.typeFaqs: "الأسئلة الشائعة (FAQ)",
    WebsiteConfig.typeTestimonials: "آراء وتقييمات العملاء",
    WebsiteConfig.typeTrustBadges: "ثقة وضمان الشحن والدفع",
    WebsiteConfig.typeNewsletterSignup: "الاشتراك بالنشرة البريدية",
    WebsiteConfig.typeFeatures: "المميزات والركائز الأساسية",
    WebsiteConfig.typeTabsShowcase: "بنية النظام (تبويبات تفاعلية)",
    WebsiteConfig.typeShowcase: "معرض شاشات النظام",
    WebsiteConfig.typePricing: "الباقات والأسعار",
    WebsiteConfig.typeContactUs: "تواصل معنا",
  };

  Map<String, String> get _filteredTypeOptions {
    if (widget.appMode == WebsiteConfig.appModeBlog) {
      final map = Map<String, String>.from(_typeOptions);
      map.remove(WebsiteConfig.typeOffers);
      map.remove(WebsiteConfig.typeNewProducts);
      map.remove(WebsiteConfig.typeBestSellerProducts);
      return map;
    }
    return _typeOptions;
  }

  final Map<String, String> _modeOptions = {
    WebsiteConfig.modeHorizontalList: "قائمة عرضية (Scroll)",
    WebsiteConfig.modeGrid: "شبكة (Grid)",
  };

  IconData _getIconForType(String type) {
    switch (type) {
      case WebsiteConfig.typeCategories:
        return Icons.category;
      case WebsiteConfig.typeOffers:
        return Icons.local_offer;
      case WebsiteConfig.typeNewProducts:
        return Icons.new_releases;
      case WebsiteConfig.typeBestSellerProducts:
        return Icons.star;
      case WebsiteConfig.typeBlogPosts:
        return Icons.article;
      case WebsiteConfig.typeCustomBanner:
        return Icons.image;
      case WebsiteConfig.typeIntroSlides:
        return Icons.slideshow;
      case WebsiteConfig.typeMostReadBlogPosts:
        return Icons.trending_up;
      case WebsiteConfig.typeJockerPost:
        return Icons.image;
      case WebsiteConfig.typeAboutCompany:
        return Icons.business;
      case WebsiteConfig.typeFaqs:
        return Icons.quiz;
      case WebsiteConfig.typeTestimonials:
        return Icons.rate_review;
      case WebsiteConfig.typeTrustBadges:
        return Icons.verified_user;
      case WebsiteConfig.typeNewsletterSignup:
        return Icons.mark_email_read;
      case WebsiteConfig.typeFeatures:
        return Icons.auto_awesome;
      case WebsiteConfig.typeTabsShowcase:
        return Icons.tab;
      case WebsiteConfig.typeShowcase:
        return Icons.photo_library;
      case WebsiteConfig.typePricing:
        return Icons.payments;
      case WebsiteConfig.typeContactUs:
        return Icons.contact_mail;
      default:
        return Icons.grid_view;
    }
  }

  String _getLabelForType(String type) => _typeOptions[type] ?? type;
  String _getLabelForMode(String mode) => _modeOptions[mode] ?? mode;

  String? _resolveShowcaseNetworkUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) return null;
    final url = AppBackendEnv.resolveImageUrl(imageUrl);
    return url.isEmpty ? null : url;
  }

  Widget _buildShowcaseImagePicker(int tabIndex, Map<String, dynamic> tab) {
    final pendingImage = widget.pendingShowcaseImages?[tabIndex];
    final hasPendingImage = pendingImage?.hasImage == true;
    final networkUrl = hasPendingImage
        ? null
        : _resolveShowcaseNetworkUrl(tab['imageUrl']?.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          "أو ارفع صورة من الجهاز",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Center(
          child: IgnorePointer(
            ignoring: !widget.isEditing,
            child: SizedBox(
              width: 280,
              child: ImagePecker(
                key: ValueKey('showcase_${widget.section['id']}_$tabIndex'),
                placeholderAsset: AppAsset.imgplaceholder,
                networkImage: networkUrl,
                height: 160,
                width: 280,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
                helperText: widget.isEditing
                    ? 'اضغط لاختيار صورة الموك أب'
                    : 'صورة التبويب الحالية',
                onImageSelected: (imageModel) {
                  widget.onShowcaseImageChanged?.call(tabIndex, imageModel);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String? value,
    ValueChanged<String> onChanged, {
    Key? key,
  }) {
    return TextFormField(
      key: key,
      initialValue: value,
      enabled: widget.isEditing,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: widget.isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isEditing
                ? AppColors.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: options.containsKey(value) ? value : options.keys.first,
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: widget.isEditing ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: widget.isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isEditing
                ? AppColors.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildColumnCountSelector(Map<String, dynamic> section) {
    final options = [2, 3, 4];
    if (section['config'] == null) section['config'] = {};
    final currentCount = section['config']['crossAxisCount'] ?? 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "عدد الأعمدة (Grid Columns)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: options
              .map(
                (count) => ButtonSegment(
                  value: count,
                  label: Text("$count أعمدة"),
                ),
              )
              .toList(),
          selected: {currentCount},
          onSelectionChanged: widget.isEditing
              ? (newSelection) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config']['crossAxisCount'] = newSelection.first;
                  widget.onSectionChanged(newSection);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildBlogLimitSelector(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final currentLimit = section['config']['limit'] ?? 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "عدد المقالات المعروضة (Limit)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 3, label: Text("3 مقالات")),
            ButtonSegment(value: 6, label: Text("6 مقالات")),
            ButtonSegment(value: 9, label: Text("9 مقالات")),
          ],
          selected: {currentLimit},
          onSelectionChanged: widget.isEditing
              ? (newSelection) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config']['limit'] = newSelection.first;
                  widget.onSectionChanged(newSection);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildAutoPlayToggle(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final autoPlay = section['config']['autoPlay'] ?? true;

    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text("تدوير تلقائي (Auto Play)", style: TextStyle(fontSize: 13)),
      value: autoPlay,
      onChanged: widget.isEditing
          ? (val) {
              final newSection = Map<String, dynamic>.from(widget.section);
              if (newSection['config'] == null) newSection['config'] = {};
              newSection['config']['autoPlay'] = val;
              widget.onSectionChanged(newSection);
            }
          : null,
    );
  }

  Widget _buildCustomBannerConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final currentVariant = section['config']['variant'] ?? 'promo_card';
    
    final variantOptions = {
      'promo_card': 'كرت ترويجي مستطيل زجاجي (Promo Card)',
      'offers_box': 'صندوق ترويجي مربع (Offers Box)',
    };

    return Column(
      children: [
        _buildDropdown(
          "شكل البانر الترويجي (Variant)",
          currentVariant,
          variantOptions,
          (val) {
            if (val == null) return;
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['variant'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          "رابط الصورة (Image URL)",
          section['config']['imageUrl'],
          (val) {
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['imageUrl'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          "نص الزر (Button Text)",
          section['config']['buttonText'],
          (val) {
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['buttonText'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          "رابط التوجيه (Button Link)",
          section['config']['buttonLink'] ?? section['config']['linkUrl'],
          (val) {
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['buttonLink'] = val;
            // Mirror to linkUrl for backward compatibility
            newSection['config']['linkUrl'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
      ],
    );
  }

  Widget _buildOffersConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final currentVariant = section['config']['variant'] ?? 'default';

    final variantOptions = {
      'default': 'سلايدر العروض التفاعلي الافتراضي (Default Slider)',
      'hero_slide': 'سلايدر عريض كامل الشاشة (Hero Slide)',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          "شكل عرض السلايدر (Variant)",
          currentVariant,
          variantOptions,
          (val) {
            if (val == null) return;
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['variant'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
        const SizedBox(height: 12),
        _buildAutoPlayToggle(section),
      ],
    );
  }

  Widget _buildCategoriesConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final currentVariant = section['config']['variant'] ?? 'round';

    final variantOptions = {
      'round': 'أيقونات دائرية مميزة (Round Icons)',
      'glass_card': 'كروت مستطيلة زجاجية (Glass Cards)',
      'pills': 'كبسولات نصية خفيفة (Pills)',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          "شكل عرض الأقسام (Variant)",
          currentVariant,
          variantOptions,
          (val) {
            if (val == null) return;
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['variant'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
      ],
    );
  }

  Widget _buildAboutCompanyConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final currentPos = section['config']['imagePosition'] ?? 'left';

    final options = {
      'top': 'أعلى النص (Top)',
      'bottom': 'أسفل النص (Bottom)',
      'right': 'يمين النص (Right)',
      'left': 'يسار النص (Left)',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          "الرابط الفرعي للمقال التعريفي (Post Slug)",
          section['config']['postSlug'],
          (val) {
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['postSlug'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          "موضع الصورة بالنسبة للنص",
          currentPos,
          options,
          (val) {
            if (val == null) return;
            final newSection = Map<String, dynamic>.from(widget.section);
            if (newSection['config'] == null) newSection['config'] = {};
            newSection['config']['imagePosition'] = val;
            widget.onSectionChanged(newSection);
          },
        ),
      ],
    );
  }

  Widget _buildJockerPostConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final imageCount = section['config']['imageCount'] ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اختيار صورة واحدة أو صورتين
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "عدد الصور",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text("صورة واحدة")),
                ButtonSegment(value: 2, label: Text("صورتين")),
              ],
              selected: {imageCount},
              onSelectionChanged: widget.isEditing
                  ? (newSelection) {
                      final newSection = Map<String, dynamic>.from(widget.section);
                      if (newSection['config'] == null) newSection['config'] = {};
                      newSection['config']['imageCount'] = newSelection.first;
                      widget.onSectionChanged(newSection);
                    }
                  : null,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Full Screen toggle
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "عرض كامل (Full Screen)",
            style: TextStyle(fontSize: 13),
          ),
          subtitle: const Text(
            "عند التفعيل، الصورة تأخذ كامل عرض الشاشة بدون هوامش",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          value: section['config']['fullScreen'] ?? false,
          onChanged: widget.isEditing
              ? (val) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config']['fullScreen'] = val;
                  if (val) {
                    newSection['config']['margin'] = 0;
                  }
                  widget.onSectionChanged(newSection);
                }
              : null,
        ),

        // Margin reduction (فقط لو fullScreen = false)
        if (!(section['config']['fullScreen'] ?? false)) ...[
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "تقليل المسافة (Margin Reduction)",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text("0")),
                  ButtonSegment(value: 8, label: Text("8")),
                  ButtonSegment(value: 16, label: Text("16")),
                  ButtonSegment(value: 24, label: Text("24")),
                  ButtonSegment(value: 32, label: Text("32")),
                ],
                selected: {section['config']['margin'] ?? 16},
                onSelectionChanged: widget.isEditing
                    ? (newSelection) {
                        final newSection = Map<String, dynamic>.from(widget.section);
                        if (newSection['config'] == null) newSection['config'] = {};
                        newSection['config']['margin'] = newSelection.first;
                        widget.onSectionChanged(newSection);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFaqsConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    if (section['config']['items'] == null) {
      section['config']['items'] = [];
    }

    final List items = List.from(section['config']['items']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "إدارة الأسئلة والأجوبة",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(items.length, (index) {
          final item = Map<String, dynamic>.from(items[index] ?? {});
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: widget.isEditing
                        ? () {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newItems = List.from(newSection['config']['items'] ?? []);
                            newItems.removeAt(index);
                            newSection['config']['items'] = newItems;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                  ),
                  _buildTextField(
                    "السؤال",
                    item['question'] ?? '',
                    (val) {
                      final newSection = Map<String, dynamic>.from(widget.section);
                      if (newSection['config'] == null) newSection['config'] = {};
                      newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                      final List newItems = List.from(newSection['config']['items'] ?? []);
                      final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                      updatedItem['question'] = val;
                      newItems[index] = updatedItem;
                      newSection['config']['items'] = newItems;
                      widget.onSectionChanged(newSection);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    "الإجابة",
                    item['answer'] ?? '',
                    (val) {
                      final newSection = Map<String, dynamic>.from(widget.section);
                      if (newSection['config'] == null) newSection['config'] = {};
                      newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                      final List newItems = List.from(newSection['config']['items'] ?? []);
                      final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                      updatedItem['answer'] = val;
                      newItems[index] = updatedItem;
                      newSection['config']['items'] = newItems;
                      widget.onSectionChanged(newSection);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: widget.isEditing
              ? () {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final List newItems = List.from(newSection['config']['items'] ?? []);
                  newItems.add({'question': '', 'answer': ''});
                  newSection['config']['items'] = newItems;
                  widget.onSectionChanged(newSection);
                }
              : null,
          icon: const Icon(Icons.add),
          label: const Text("إضافة سؤال وجواب جديد"),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor.withOpacity(0.1),
            foregroundColor: widget.primaryColor,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadgesConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    if (section['config']['items'] == null) {
      section['config']['items'] = [];
    }

    final List items = List.from(section['config']['items']);

    final commerceEmojis = [
      '🚚', '🛡️', '🎧', '⭐', '💰', '🎁', '🏷️', '💳', 
      '📦', '🤝', '🔥', '⚡', '💎', '🌍', '🛒', '🛍️', 
      '💼', '💯', '⏰', '✨'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "إدارة بطاقات الثقة والضمان",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(items.length, (index) {
          final item = Map<String, dynamic>.from(items[index] ?? {});

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: widget.isEditing
                        ? () {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newItems = List.from(newSection['config']['items'] ?? []);
                            newItems.removeAt(index);
                            newSection['config']['items'] = newItems;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                  ),
                  _buildTextField(
                    "الأيقونة (إيموجي - Emoji)",
                    item['icon'] ?? '🚚',
                    (val) {
                      final newSection = Map<String, dynamic>.from(widget.section);
                      if (newSection['config'] == null) newSection['config'] = {};
                      newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                      final List newItems = List.from(newSection['config']['items'] ?? []);
                      final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                      updatedItem['icon'] = val;
                      newItems[index] = updatedItem;
                      newSection['config']['items'] = newItems;
                      widget.onSectionChanged(newSection);
                    },
                    key: ValueKey(item['icon'] ?? '🚚'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.start,
                      children: commerceEmojis.map((emoji) {
                        final isSelected = item['icon'] == emoji;
                        return InkWell(
                          onTap: widget.isEditing
                              ? () {
                                  final newSection = Map<String, dynamic>.from(widget.section);
                                  if (newSection['config'] == null) newSection['config'] = {};
                                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                                  final List newItems = List.from(newSection['config']['items'] ?? []);
                                  final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                                  updatedItem['icon'] = emoji;
                                  newItems[index] = updatedItem;
                                  newSection['config']['items'] = newItems;
                                  widget.onSectionChanged(newSection);
                                }
                              : null,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.primaryColor.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? widget.primaryColor
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "العنوان",
                    item['title'] ?? '',
                    (val) {
                      final newSection = Map<String, dynamic>.from(widget.section);
                      if (newSection['config'] == null) newSection['config'] = {};
                      newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                      final List newItems = List.from(newSection['config']['items'] ?? []);
                      final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                      updatedItem['title'] = val;
                      newItems[index] = updatedItem;
                      newSection['config']['items'] = newItems;
                      widget.onSectionChanged(newSection);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    "الوصف/التفاصيل",
                    item['description'] ?? '',
                    (val) {
                      final newSection = Map<String, dynamic>.from(widget.section);
                      if (newSection['config'] == null) newSection['config'] = {};
                      newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                      final List newItems = List.from(newSection['config']['items'] ?? []);
                      final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                      updatedItem['description'] = val;
                      newItems[index] = updatedItem;
                      newSection['config']['items'] = newItems;
                      widget.onSectionChanged(newSection);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: widget.isEditing
              ? () {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final List newItems = List.from(newSection['config']['items'] ?? []);
                  newItems.add({'title': '', 'description': '', 'icon': '🚚'});
                  newSection['config']['items'] = newItems;
                  widget.onSectionChanged(newSection);
                }
              : null,
          icon: const Icon(Icons.add),
          label: const Text("إضافة بطاقة ثقة جديدة"),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor.withOpacity(0.1),
            foregroundColor: widget.primaryColor,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  void _updateConfigField(
    Map<String, dynamic> section,
    String field,
    dynamic value,
    void Function(Map<String, dynamic>) onChanged,
  ) {
    final newSection = Map<String, dynamic>.from(section);
    if (newSection['config'] == null) newSection['config'] = {};
    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
    newSection['config'][field] = value;
    onChanged(newSection);
  }

  Widget _buildFeaturesConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    if (section['config']['items'] == null) section['config']['items'] = [];
    final List items = List.from(section['config']['items']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("إدارة المميزات", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(items.length, (index) {
          final item = Map<String, dynamic>.from(items[index] ?? {});
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: widget.isEditing
                        ? () {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newItems = List.from(newSection['config']['items'] ?? []);
                            newItems.removeAt(index);
                            newSection['config']['items'] = newItems;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                  ),
                  _buildTextField("الأيقونة (إيموجي)", item['icon'] ?? '✨', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newItems = List.from(newSection['config']['items'] ?? []);
                    final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                    updatedItem['icon'] = val;
                    newItems[index] = updatedItem;
                    newSection['config']['items'] = newItems;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 8),
                  _buildTextField("العنوان", item['title'] ?? '', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newItems = List.from(newSection['config']['items'] ?? []);
                    final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                    updatedItem['title'] = val;
                    newItems[index] = updatedItem;
                    newSection['config']['items'] = newItems;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 8),
                  _buildTextField("التفاصيل", item['description'] ?? '', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newItems = List.from(newSection['config']['items'] ?? []);
                    final updatedItem = Map<String, dynamic>.from(newItems[index] ?? {});
                    updatedItem['description'] = val;
                    newItems[index] = updatedItem;
                    newSection['config']['items'] = newItems;
                    widget.onSectionChanged(newSection);
                  }),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: widget.isEditing
              ? () {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final List newItems = List.from(newSection['config']['items'] ?? []);
                  newItems.add({'icon': '✨', 'title': '', 'description': ''});
                  newSection['config']['items'] = newItems;
                  widget.onSectionChanged(newSection);
                }
              : null,
          icon: const Icon(Icons.add),
          label: const Text("إضافة ميزة جديدة"),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor.withOpacity(0.1),
            foregroundColor: widget.primaryColor,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildTabsShowcaseConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    if (section['config']['tabs'] == null) section['config']['tabs'] = [];
    final List tabs = List.from(section['config']['tabs']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("إدارة التبويبات التفاعلية", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(tabs.length, (tabIndex) {
          final tab = Map<String, dynamic>.from(tabs[tabIndex] ?? {});
          final List tabItems = List.from(tab['items'] ?? []);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: widget.primaryColor.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: widget.isEditing
                        ? () {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                            newTabs.removeAt(tabIndex);
                            newSection['config']['tabs'] = newTabs;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                  ),
                  _buildTextField("اسم التبويب", tab['label'] ?? '', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                    final updatedTab = Map<String, dynamic>.from(newTabs[tabIndex] ?? {});
                    updatedTab['label'] = val;
                    newTabs[tabIndex] = updatedTab;
                    newSection['config']['tabs'] = newTabs;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 8),
                  _buildTextField("المحتوى النصي", tab['content'] ?? '', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                    final updatedTab = Map<String, dynamic>.from(newTabs[tabIndex] ?? {});
                    updatedTab['content'] = val;
                    newTabs[tabIndex] = updatedTab;
                    newSection['config']['tabs'] = newTabs;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 12),
                  const Text("عناصر التبويب", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ...List.generate(tabItems.length, (itemIndex) {
                    final item = Map<String, dynamic>.from(tabItems[itemIndex] ?? {});
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.orange, size: 18),
                            onPressed: widget.isEditing
                                ? () {
                                    final newSection = Map<String, dynamic>.from(widget.section);
                                    if (newSection['config'] == null) newSection['config'] = {};
                                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                                    final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                                    final updatedTab = Map<String, dynamic>.from(newTabs[tabIndex] ?? {});
                                    final List newItems = List.from(updatedTab['items'] ?? []);
                                    newItems.removeAt(itemIndex);
                                    updatedTab['items'] = newItems;
                                    newTabs[tabIndex] = updatedTab;
                                    newSection['config']['tabs'] = newTabs;
                                    widget.onSectionChanged(newSection);
                                  }
                                : null,
                          ),
                          _buildTextField("أيقونة", item['icon'] ?? '⚡', (val) {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                            final updatedTab = Map<String, dynamic>.from(newTabs[tabIndex] ?? {});
                            final List newItems = List.from(updatedTab['items'] ?? []);
                            final updatedItem = Map<String, dynamic>.from(newItems[itemIndex] ?? {});
                            updatedItem['icon'] = val;
                            newItems[itemIndex] = updatedItem;
                            updatedTab['items'] = newItems;
                            newTabs[tabIndex] = updatedTab;
                            newSection['config']['tabs'] = newTabs;
                            widget.onSectionChanged(newSection);
                          }),
                          const SizedBox(height: 6),
                          _buildTextField("عنوان العنصر", item['title'] ?? '', (val) {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                            final updatedTab = Map<String, dynamic>.from(newTabs[tabIndex] ?? {});
                            final List newItems = List.from(updatedTab['items'] ?? []);
                            final updatedItem = Map<String, dynamic>.from(newItems[itemIndex] ?? {});
                            updatedItem['title'] = val;
                            newItems[itemIndex] = updatedItem;
                            updatedTab['items'] = newItems;
                            newTabs[tabIndex] = updatedTab;
                            newSection['config']['tabs'] = newTabs;
                            widget.onSectionChanged(newSection);
                          }),
                          const SizedBox(height: 6),
                          _buildTextField("وصف العنصر", item['description'] ?? '', (val) {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                            final updatedTab = Map<String, dynamic>.from(newTabs[tabIndex] ?? {});
                            final List newItems = List.from(updatedTab['items'] ?? []);
                            final updatedItem = Map<String, dynamic>.from(newItems[itemIndex] ?? {});
                            updatedItem['description'] = val;
                            newItems[itemIndex] = updatedItem;
                            updatedTab['items'] = newItems;
                            newTabs[tabIndex] = updatedTab;
                            newSection['config']['tabs'] = newTabs;
                            widget.onSectionChanged(newSection);
                          }),
                          const Divider(),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: widget.isEditing
                        ? () {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                            final updatedTab = Map<String, dynamic>.from(newTabs[tabIndex] ?? {});
                            final List newItems = List.from(updatedTab['items'] ?? []);
                            newItems.add({'icon': '⚡', 'title': '', 'description': ''});
                            updatedTab['items'] = newItems;
                            newTabs[tabIndex] = updatedTab;
                            newSection['config']['tabs'] = newTabs;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("إضافة عنصر للتبويب"),
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: widget.isEditing
              ? () {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                  newTabs.add({'label': '', 'content': '', 'items': []});
                  newSection['config']['tabs'] = newTabs;
                  widget.onSectionChanged(newSection);
                }
              : null,
          icon: const Icon(Icons.add),
          label: const Text("إضافة تبويب جديد"),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor.withOpacity(0.1),
            foregroundColor: widget.primaryColor,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildShowcaseConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    if (section['config']['tabs'] == null) section['config']['tabs'] = [];
    final List tabs = List.from(section['config']['tabs']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("إدارة معرض الصور", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(tabs.length, (index) {
          final tab = Map<String, dynamic>.from(tabs[index] ?? {});
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: widget.isEditing
                        ? () {
                            widget.onShowcaseImageChanged?.call(index, null);
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                            newTabs.removeAt(index);
                            newSection['config']['tabs'] = newTabs;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                  ),
                  _buildTextField("اسم التبويب", tab['label'] ?? '', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                    final updatedTab = Map<String, dynamic>.from(newTabs[index] ?? {});
                    updatedTab['label'] = val;
                    newTabs[index] = updatedTab;
                    newSection['config']['tabs'] = newTabs;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 8),
                  _buildTextField("رابط صورة الموك أب (Image URL)", tab['imageUrl'] ?? '', (val) {
                    widget.onShowcaseImageChanged?.call(index, null);
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                    final updatedTab = Map<String, dynamic>.from(newTabs[index] ?? {});
                    updatedTab['imageUrl'] = val;
                    newTabs[index] = updatedTab;
                    newSection['config']['tabs'] = newTabs;
                    widget.onSectionChanged(newSection);
                  }),
                  if (widget.onShowcaseImageChanged != null)
                    _buildShowcaseImagePicker(index, tab),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: widget.isEditing
              ? () {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final List newTabs = List.from(newSection['config']['tabs'] ?? []);
                  newTabs.add({'label': '', 'imageUrl': ''});
                  newSection['config']['tabs'] = newTabs;
                  widget.onSectionChanged(newSection);
                }
              : null,
          icon: const Icon(Icons.add),
          label: const Text("إضافة تبويب صورة"),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor.withOpacity(0.1),
            foregroundColor: widget.primaryColor,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    if (section['config']['plans'] == null) section['config']['plans'] = [];
    final List plans = List.from(section['config']['plans']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("إدارة الباقات والأسعار", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(plans.length, (planIndex) {
          final plan = Map<String, dynamic>.from(plans[planIndex] ?? {});
          final List features = List.from(plan['features'] ?? []);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: widget.primaryColor.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: widget.isEditing
                        ? () {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newPlans = List.from(newSection['config']['plans'] ?? []);
                            newPlans.removeAt(planIndex);
                            newSection['config']['plans'] = newPlans;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                  ),
                  _buildTextField("اسم الباقة", plan['name'] ?? '', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newPlans = List.from(newSection['config']['plans'] ?? []);
                    final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                    updatedPlan['name'] = val;
                    newPlans[planIndex] = updatedPlan;
                    newSection['config']['plans'] = newPlans;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField("السعر", plan['price'] ?? '', (val) {
                          final newSection = Map<String, dynamic>.from(widget.section);
                          if (newSection['config'] == null) newSection['config'] = {};
                          newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                          final List newPlans = List.from(newSection['config']['plans'] ?? []);
                          final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                          updatedPlan['price'] = val;
                          newPlans[planIndex] = updatedPlan;
                          newSection['config']['plans'] = newPlans;
                          widget.onSectionChanged(newSection);
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField("الفترة", plan['period'] ?? 'شهرياً', (val) {
                          final newSection = Map<String, dynamic>.from(widget.section);
                          if (newSection['config'] == null) newSection['config'] = {};
                          newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                          final List newPlans = List.from(newSection['config']['plans'] ?? []);
                          final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                          updatedPlan['period'] = val;
                          newPlans[planIndex] = updatedPlan;
                          newSection['config']['plans'] = newPlans;
                          widget.onSectionChanged(newSection);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text("الأكثر شعبية", style: TextStyle(fontSize: 13)),
                    value: plan['isPopular'] ?? false,
                    onChanged: widget.isEditing
                        ? (val) {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newPlans = List.from(newSection['config']['plans'] ?? []);
                            final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                            updatedPlan['isPopular'] = val;
                            newPlans[planIndex] = updatedPlan;
                            newSection['config']['plans'] = newPlans;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField("نص الزر", plan['buttonText'] ?? 'اشترك الآن', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newPlans = List.from(newSection['config']['plans'] ?? []);
                    final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                    updatedPlan['buttonText'] = val;
                    newPlans[planIndex] = updatedPlan;
                    newSection['config']['plans'] = newPlans;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 8),
                  _buildTextField("رابط الزر", plan['buttonLink'] ?? '/contact', (val) {
                    final newSection = Map<String, dynamic>.from(widget.section);
                    if (newSection['config'] == null) newSection['config'] = {};
                    newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                    final List newPlans = List.from(newSection['config']['plans'] ?? []);
                    final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                    updatedPlan['buttonLink'] = val;
                    newPlans[planIndex] = updatedPlan;
                    newSection['config']['plans'] = newPlans;
                    widget.onSectionChanged(newSection);
                  }),
                  const SizedBox(height: 12),
                  const Text("مميزات الباقة", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ...List.generate(features.length, (featIndex) {
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.orange, size: 18),
                          onPressed: widget.isEditing
                              ? () {
                                  final newSection = Map<String, dynamic>.from(widget.section);
                                  if (newSection['config'] == null) newSection['config'] = {};
                                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                                  final List newPlans = List.from(newSection['config']['plans'] ?? []);
                                  final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                                  final List newFeatures = List.from(updatedPlan['features'] ?? []);
                                  newFeatures.removeAt(featIndex);
                                  updatedPlan['features'] = newFeatures;
                                  newPlans[planIndex] = updatedPlan;
                                  newSection['config']['plans'] = newPlans;
                                  widget.onSectionChanged(newSection);
                                }
                              : null,
                        ),
                        Expanded(
                          child: _buildTextField("ميزة", features[featIndex]?.toString() ?? '', (val) {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newPlans = List.from(newSection['config']['plans'] ?? []);
                            final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                            final List newFeatures = List.from(updatedPlan['features'] ?? []);
                            newFeatures[featIndex] = val;
                            updatedPlan['features'] = newFeatures;
                            newPlans[planIndex] = updatedPlan;
                            newSection['config']['plans'] = newPlans;
                            widget.onSectionChanged(newSection);
                          }),
                        ),
                      ],
                    );
                  }),
                  TextButton.icon(
                    onPressed: widget.isEditing
                        ? () {
                            final newSection = Map<String, dynamic>.from(widget.section);
                            if (newSection['config'] == null) newSection['config'] = {};
                            newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                            final List newPlans = List.from(newSection['config']['plans'] ?? []);
                            final updatedPlan = Map<String, dynamic>.from(newPlans[planIndex] ?? {});
                            final List newFeatures = List.from(updatedPlan['features'] ?? []);
                            newFeatures.add('');
                            updatedPlan['features'] = newFeatures;
                            newPlans[planIndex] = updatedPlan;
                            newSection['config']['plans'] = newPlans;
                            widget.onSectionChanged(newSection);
                          }
                        : null,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("إضافة ميزة"),
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: widget.isEditing
              ? () {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final List newPlans = List.from(newSection['config']['plans'] ?? []);
                  newPlans.add({
                    'name': '',
                    'price': '',
                    'period': 'شهرياً',
                    'features': <String>[],
                    'isPopular': false,
                    'buttonText': 'اشترك الآن',
                    'buttonLink': '/contact',
                  });
                  newSection['config']['plans'] = newPlans;
                  widget.onSectionChanged(newSection);
                }
              : null,
          icon: const Icon(Icons.add),
          label: const Text("إضافة باقة جديدة"),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor.withOpacity(0.1),
            foregroundColor: widget.primaryColor,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildContactUsConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};
    final config = section['config'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("بيانات التواصل", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildTextField("رقم الهاتف", config['phone'] ?? '', (val) {
          _updateConfigField(section, 'phone', val, widget.onSectionChanged);
        }),
        const SizedBox(height: 8),
        _buildTextField("البريد الإلكتروني", config['email'] ?? '', (val) {
          _updateConfigField(section, 'email', val, widget.onSectionChanged);
        }),
        const SizedBox(height: 8),
        _buildTextField("العنوان", config['address'] ?? '', (val) {
          _updateConfigField(section, 'address', val, widget.onSectionChanged);
        }),
        const SizedBox(height: 8),
        _buildTextField("رابط خريطة Google (Map URL)", config['mapUrl'] ?? '', (val) {
          _updateConfigField(section, 'mapUrl', val, widget.onSectionChanged);
        }),
        const SizedBox(height: 8),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text("عرض نموذج الاتصال", style: TextStyle(fontSize: 13)),
          value: config['showForm'] ?? true,
          onChanged: widget.isEditing
              ? (val) => _updateConfigField(section, 'showForm', val, widget.onSectionChanged)
              : null,
        ),
      ],
    );
  }

  Widget _buildIntroDisplayModeSelector(Map<String, dynamic> section) {
    final selectedMode = WebsiteConfig.normalizeDisplayMode(
      section['displayMode'],
      WebsiteConfig.typeIntroSlides,
    );
    final introModeOptions = {
      WebsiteConfig.modeSlider: "سلايدر (شريحة واحدة)",
      WebsiteConfig.modeGrid: "شبكة (كل الشرائح)",
    };

    return _buildDropdown(
      "طريقة عرض الشرائح",
      selectedMode,
      introModeOptions,
      (val) {
        if (val == null) return;
        final newSection = Map<String, dynamic>.from(widget.section);
        newSection['displayMode'] = WebsiteConfig.normalizeDisplayMode(
          val,
          WebsiteConfig.typeIntroSlides,
        );
        widget.onSectionChanged(newSection);
      },
    );
  }

  Widget _buildIntroClassicHeroFields({
    required Map<String, dynamic> subConfig,
    required String introKey,
    required IntroThemePalette palette,
    required void Function(String field, dynamic val) updateSub,
  }) {
    final isStore = introKey == WebsiteConfig.keyIntroStore;
    final showBadge = subConfig['showBadge'] ?? true;
    final showButton = subConfig['showButton'] ?? true;
    final showPrice = subConfig['showPrice'] ?? false;
    final showHeroImage = subConfig['showHeroImage'] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.25)),
          ),
          child: const Text(
            "إعدادات عناصر التفاعل (CTA Button، Badge، Glow). المحتوى (العنوان/الوصف) يدار من مقالات intro.",
            style: TextStyle(fontSize: 11, height: 1.4),
          ),
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text("توهج الخلفية (Glow)", style: TextStyle(fontSize: 13)),
          value: subConfig['showGlow'] ?? true,
          onChanged: widget.isEditing ? (v) => updateSub('showGlow', v) : null,
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text("إظهار الشارة (Badge)", style: TextStyle(fontSize: 13)),
          value: showBadge,
          onChanged: widget.isEditing ? (v) => updateSub('showBadge', v) : null,
        ),
        if (showBadge)
          _buildTextField(
            "نص الشارة (فارغ = افتراضي حسب وضع الموقع)",
            subConfig['badgeText']?.toString() ?? '',
            (val) => updateSub('badgeText', val),
          ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text("عنوان Gradient", style: TextStyle(fontSize: 13)),
          value: subConfig['useGradientTitle'] ?? true,
          onChanged: widget.isEditing ? (v) => updateSub('useGradientTitle', v) : null,
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text("إظهار زر التفاعل CTA (مثل ابدأ القراءة / اشتري الآن)", style: TextStyle(fontSize: 13)),
          value: showButton,
          onChanged: widget.isEditing ? (v) => updateSub('showButton', v) : null,
        ),
        if (showButton) ...[
          _buildTextField(
            "نص الزر (فارغ = افتراضي)",
            subConfig['buttonText']?.toString() ?? '',
            (val) => updateSub('buttonText', val),
          ),
          _buildTextField(
            "رابط الزر (href / URL)",
            subConfig['buttonLink']?.toString() ?? '',
            (val) => updateSub('buttonLink', val),
          ),
          const SizedBox(height: 8),
          const Text("خلفية الزر (Button Background)", style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          IntroBackgroundColorPicker(
            backgroundType: 'solid',
            customBg: subConfig['buttonBg']?.toString() ?? '',
            isEditing: widget.isEditing,
            palette: palette,
            onChanged: (v) => updateSub('buttonBg', v),
          ),
          const SizedBox(height: 8),
          const Text("لون نص الزر (Button Text Color)", style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          IntroTextColorPicker(
            textColor: subConfig['buttonTextColor']?.toString() ?? '',
            isEditing: widget.isEditing,
            palette: palette,
            onChanged: (v) => updateSub('buttonTextColor', v),
          ),
          const SizedBox(height: 12),
        ],
        if (isStore) ...[
          const SizedBox(height: 8),
          const Text(
            "خيارات المتجر (Store Hero)",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text("صورة جانبية", style: TextStyle(fontSize: 13)),
            value: showHeroImage,
            onChanged: widget.isEditing ? (v) => updateSub('showHeroImage', v) : null,
          ),
          if (showHeroImage)
            _buildTextField(
              "رابط الصورة (فارغ = صورة intro أو افتراضي)",
              subConfig['heroImageUrl']?.toString() ?? '',
              (val) => updateSub('heroImageUrl', val),
            ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text("عرض السعر", style: TextStyle(fontSize: 13)),
            value: showPrice,
            onChanged: widget.isEditing ? (v) => updateSub('showPrice', v) : null,
          ),
          if (showPrice) ...[
            _buildTextField(
              "السعر",
              subConfig['price']?.toString() ?? '',
              (val) => updateSub('price', double.tryParse(val) ?? val),
            ),
            _buildTextField(
              "السعر قبل الخصم",
              subConfig['originalPrice']?.toString() ?? '',
              (val) => updateSub('originalPrice', double.tryParse(val) ?? val),
            ),
            _buildTextField(
              "نص الخصم (مثال: 20% OFF)",
              subConfig['discountLabel']?.toString() ?? '',
              (val) => updateSub('discountLabel', val),
            ),
          ],
        ],
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildIntroSlidesConfig(Map<String, dynamic> section) {
    if (section['config'] == null) section['config'] = {};

    const tabs = [
      {'key': WebsiteConfig.keyIntroBlog,   'label': '🗞️ مدونة',   'icon': Icons.article_outlined},
      {'key': WebsiteConfig.keyIntroStore,  'label': '🛍️ متجر',   'icon': Icons.storefront_outlined},
      {'key': WebsiteConfig.keyIntroHybrid, 'label': '🔀 الهجين', 'icon': Icons.join_full},
    ];

    final activeIntroKey = switch (widget.appMode) {
      WebsiteConfig.appModeBlog => WebsiteConfig.keyIntroBlog,
      WebsiteConfig.appModeStore => WebsiteConfig.keyIntroStore,
      _ => WebsiteConfig.keyIntroBlog,
    };
    final activeTabIndex = tabs.indexWhere((t) => t['key'] == activeIntroKey);
    final activeTab = tabs[activeTabIndex < 0 ? 0 : activeTabIndex];
    final activeStyle = WebsiteConfig.normalizeIntroDisplayStyle(
      (section['config']?[activeIntroKey] as Map?)?['displayStyle'],
    );
    final activeStyleLabel =
        WebsiteConfig.introDisplayStyleLabels[activeStyle] ?? activeStyle;
    final appModeLabel = switch (widget.appMode) {
      WebsiteConfig.appModeBlog => 'مدونة',
      WebsiteConfig.appModeStore => 'متجر',
      _ => 'هجين',
    };

    return DefaultTabController(
      key: ValueKey('intro_tabs_${section['id']}_$activeTabIndex'),
      length: 3,
      initialIndex: activeTabIndex < 0 ? 0 : activeTabIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.primaryColor.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "محتوى الشرائح (نص + صورة)",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "يُدار من المدونة: أنشئ مقالات بنوع «Intro Slide» (postType: intro) "
                  "مع introTitle و introDescription و introImage.",
                  style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 4),
                const Text(
                  "الإعدادات أدناه تتحكم في الشكل فقط حسب وضع الموقع (هجين / مدونة / متجر).",
                  style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withOpacity(0.35)),
                  ),
                  child: Text(
                    "وضع الموقع الحالي: $appModeLabel — التبويب النشط على الويب: "
                    "${activeTab['label']} ($activeStyleLabel)",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildIntroDisplayModeSelector(section),
          const SizedBox(height: 12),
          const Text(
            "اعدادات السلايدر لكل وضع",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TabBar(
            isScrollable: true,
            labelColor: widget.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: widget.primaryColor,
            tabs: tabs.map((t) => Tab(
              icon: Icon(t['icon'] as IconData, size: 16),
              text: t['label'] as String,
            )).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 720,
            child: TabBarView(
              children: tabs.map((t) {
                final key = t['key'] as String;
                final subConfig = Map<String, dynamic>.from(
                  section['config'][key] ?? {},
                );

                void updateSub(String field, dynamic val) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final sub = Map<String, dynamic>.from(newSection['config'][key] ?? {});
                  if (field == 'displayStyle') {
                    sub[field] = WebsiteConfig.normalizeIntroDisplayStyle(val);
                  } else {
                    sub[field] = val;
                  }
                  newSection['config'][key] = sub;
                  widget.onSectionChanged(newSection);
                }

                void updateSubFields(Map<String, dynamic> fields) {
                  final newSection = Map<String, dynamic>.from(widget.section);
                  if (newSection['config'] == null) newSection['config'] = {};
                  newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                  final sub = Map<String, dynamic>.from(newSection['config'][key] ?? {});
                  fields.forEach((field, val) {
                    if (field == 'displayStyle') {
                      sub[field] = WebsiteConfig.normalizeIntroDisplayStyle(val);
                    } else {
                      sub[field] = val;
                    }
                  });
                  newSection['config'][key] = sub;
                  widget.onSectionChanged(newSection);
                }

                final currentStyle = WebsiteConfig.normalizeIntroDisplayStyle(
                  subConfig['displayStyle'],
                );
                final bgType = subConfig['backgroundType'] ?? WebsiteConfig.bgTypeSolid;
                final autoPlay = subConfig['autoPlay'] ?? true;
                final duration = ((subConfig['duration'] ?? 4000) as num).toDouble();
                final indicator = subConfig['indicatorType'] ?? WebsiteConfig.indicatorDots;
                final themePalette = IntroThemePalette.fromOrganizationConfig(
                  widget.organizationConfig,
                );

                void onBackgroundTypeChanged(String type) {
                  final currentBg = subConfig['customBg']?.toString() ?? '';
                  if (type == WebsiteConfig.bgTypeGradient) {
                    if (!IntroColorUtils.isGradient(currentBg)) {
                      final start = currentBg.isEmpty
                          ? (themePalette.colors['primary'] ?? '#100C1C')
                          : IntroColorUtils.normalizeToWebsiteHex(currentBg);
                      final end = themePalette.colors['secondary'] ??
                          themePalette.colors['accent'] ??
                          '#1A2332';
                      updateSubFields({
                        'backgroundType': type,
                        'customBg': IntroColorUtils.buildGradient(start, end),
                      });
                      return;
                    }
                  } else if (IntroColorUtils.isGradient(currentBg)) {
                    updateSubFields({
                      'backgroundType': type,
                      'customBg': IntroColorUtils.parseGradientColors(currentBg).start,
                    });
                    return;
                  }
                  updateSub('backgroundType', type);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // displayStyle
                      DropdownButtonFormField<String>(
                        value: currentStyle,
                        items: WebsiteConfig.introDisplayStyleLabels.entries.map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13))),
                        ).toList(),
                        onChanged: widget.isEditing ? (v) => updateSub('displayStyle', v) : null,
                        decoration: const InputDecoration(
                          labelText: "شكل العرض (Display Style)",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: WebsiteConfig.normalizeIntroTextAlign(
                          subConfig['textAlign'],
                          displayStyle: currentStyle,
                        ),
                        items: WebsiteConfig.introTextAlignLabels.entries.map((e) =>
                          DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value, style: const TextStyle(fontSize: 13)),
                          ),
                        ).toList(),
                        onChanged: widget.isEditing ? (v) => updateSub('textAlign', v) : null,
                        decoration: const InputDecoration(
                          labelText: "محاذاة النص (Text Align)",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildIntroClassicHeroFields(
                        subConfig: subConfig,
                        introKey: key,
                        palette: themePalette,
                        updateSub: updateSub,
                      ),

                      // backgroundType
                      const Text("نوع الخلفية", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: WebsiteConfig.bgTypeSolid, label: Text("لون صريح")),
                          ButtonSegment(value: WebsiteConfig.bgTypeGradient, label: Text("تدرج")),
                        ],
                        selected: {bgType},
                        onSelectionChanged: widget.isEditing
                            ? (v) => onBackgroundTypeChanged(v.first)
                            : null,
                      ),
                      const SizedBox(height: 12),

                      IntroBackgroundColorPicker(
                        backgroundType: bgType,
                        customBg: subConfig['customBg']?.toString() ?? '',
                        isEditing: widget.isEditing,
                        palette: themePalette,
                        onChanged: (v) => updateSub('customBg', v),
                      ),
                      const SizedBox(height: 12),

                      IntroTextColorPicker(
                        textColor: subConfig['textColor']?.toString() ?? '',
                        isEditing: widget.isEditing,
                        palette: themePalette,
                        onChanged: (v) => updateSub('textColor', v),
                      ),
                      const SizedBox(height: 12),

                      // autoPlay
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("تدوير تلقائي (Auto Play)", style: TextStyle(fontSize: 13)),
                        value: autoPlay,
                        onChanged: widget.isEditing ? (v) => updateSub('autoPlay', v) : null,
                      ),

                      // duration slider
                      if (autoPlay) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("مدة كل شريحة (ms)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("${duration.round()} ms", style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        Slider(
                          value: duration,
                          min: 2000,
                          max: 8000,
                          divisions: 12,
                          activeColor: widget.primaryColor,
                          onChanged: widget.isEditing ? (v) => updateSub('duration', v.round()) : null,
                        ),
                      ],

                      // slideAnimation
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: subConfig['slideAnimation'] ?? 'fade',
                        items: WebsiteConfig.slideAnimationLabels.entries.map((e) =>
                          DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value, style: const TextStyle(fontSize: 13)),
                          ),
                        ).toList(),
                        onChanged: widget.isEditing ? (v) => updateSub('slideAnimation', v) : null,
                        decoration: const InputDecoration(
                          labelText: "تأثير أنيميشن الانتقال بين الشرائح (Slide Animation)",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // indicatorType
                      const Text("مؤشر الشرائح (Indicator)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      SegmentedButton<String>(
                        segments: WebsiteConfig.indicatorTypeLabels.entries.map((e) =>
                          ButtonSegment(value: e.key, label: Text(e.value, style: const TextStyle(fontSize: 11))),
                        ).toList(),
                        selected: {indicator},
                        onSelectionChanged: widget.isEditing
                            ? (v) => updateSub('indicatorType', v.first)
                            : null,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;

    return Card(
      key: ValueKey(section['id']),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        leading: Icon(_getIconForType(section['type']), color: widget.primaryColor),
        title: Text(
          section['title'] ?? 'بدون عنوان',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${_getLabelForType(section['type'])} - ${_getLabelForMode(section['displayMode'])}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: widget.isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: section['isActive'] ?? true,
                    onChanged: (val) {
                      final newSection = Map<String, dynamic>.from(section);
                      newSection['isActive'] = val;
                      widget.onSectionChanged(newSection);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
                  const Icon(Icons.drag_handle),
                ],
              )
            : Icon(
                Icons.circle,
                size: 12,
                color: (section['isActive'] ?? true)
                    ? Colors.green
                    : Colors.grey,
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  "العنوان",
                  section['title'],
                  (val) {
                    final newSection = Map<String, dynamic>.from(section);
                    newSection['title'] = val;
                    widget.onSectionChanged(newSection);
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  "وصف القسم (Sub-title / Description)",
                  section['description'],
                  (val) {
                    final newSection = Map<String, dynamic>.from(section);
                    newSection['description'] = val;
                    widget.onSectionChanged(newSection);
                  },
                ),
                const SizedBox(height: 12),

                // ── تصميم الحاوية ─────────────────────────────────────
                const Text(
                  "تنسيق هيكل القسم (Container Style)",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("تنسيق صندوقي (Boxed)", style: TextStyle(fontSize: 12)),
                        value: section['config']?['boxedLayout'] ?? false,
                        onChanged: widget.isEditing
                            ? (val) {
                                final newSection = Map<String, dynamic>.from(section);
                                if (newSection['config'] == null) newSection['config'] = {};
                                newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                                newSection['config']['boxedLayout'] = val;
                                if (!val) {
                                  newSection['config']['hasShadow'] = false;
                                }
                                widget.onSectionChanged(newSection);
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("تأثير الظل (Shadow)", style: TextStyle(fontSize: 12)),
                        value: section['config']?['hasShadow'] ?? false,
                        onChanged: widget.isEditing && (section['config']?['boxedLayout'] ?? false)
                            ? (val) {
                                final newSection = Map<String, dynamic>.from(section);
                                if (newSection['config'] == null) newSection['config'] = {};
                                newSection['config'] = Map<String, dynamic>.from(newSection['config']);
                                newSection['config']['hasShadow'] = val;
                                widget.onSectionChanged(newSection);
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildDropdown(
                  "نوع المحتوى",
                  section['type'],
                  _filteredTypeOptions,
                  (val) {
                    if (val == null) return;
                    widget.onSectionChanged(
                      WebsiteConfig.resetSectionForType(section, val),
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (section['type'] == WebsiteConfig.typeNewProducts ||
                    section['type'] == WebsiteConfig.typeBestSellerProducts) ...[
                  _buildColumnCountSelector(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeBlogPosts ||
                    section['type'] == WebsiteConfig.typeMostReadBlogPosts) ...[
                  _buildBlogLimitSelector(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeCategories) ...[
                  _buildCategoriesConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeOffers) ...[
                  _buildOffersConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeIntroSlides) ...[
                  _buildIntroSlidesConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeCustomBanner) ...[
                  _buildCustomBannerConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeJockerPost) ...[
                  _buildJockerPostConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeAboutCompany) ...[
                  _buildAboutCompanyConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeFaqs) ...[
                  _buildFaqsConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeTrustBadges) ...[
                  _buildTrustBadgesConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeFeatures) ...[
                  _buildFeaturesConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeTabsShowcase) ...[
                  _buildTabsShowcaseConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeShowcase) ...[
                  _buildShowcaseConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typePricing) ...[
                  _buildPricingConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] == WebsiteConfig.typeContactUs) ...[
                  _buildContactUsConfig(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] != WebsiteConfig.typeOffers &&
                    section['type'] != WebsiteConfig.typeIntroSlides &&
                    section['displayMode'] == WebsiteConfig.modeSlider) ...[
                  _buildAutoPlayToggle(section),
                  const SizedBox(height: 12),
                ],
                if (section['type'] != WebsiteConfig.typeJockerPost &&
                    section['type'] != WebsiteConfig.typeAboutCompany &&
                    section['type'] != WebsiteConfig.typeFaqs &&
                    section['type'] != WebsiteConfig.typeTestimonials &&
                    section['type'] != WebsiteConfig.typeTrustBadges &&
                    section['type'] != WebsiteConfig.typeCategories &&
                    section['type'] != WebsiteConfig.typeOffers &&
                    section['type'] != WebsiteConfig.typeIntroSlides &&
                    section['type'] != WebsiteConfig.typeNewsletterSignup &&
                    section['type'] != WebsiteConfig.typeFeatures &&
                    section['type'] != WebsiteConfig.typeTabsShowcase &&
                    section['type'] != WebsiteConfig.typeShowcase &&
                    section['type'] != WebsiteConfig.typePricing &&
                    section['type'] != WebsiteConfig.typeContactUs) ...[
                  _buildDropdown(
                    "طريقة العرض",
                    section['displayMode'],
                    _modeOptions,
                    (val) {
                      if (val == null) return;
                      final newSection = Map<String, dynamic>.from(section);
                      newSection['displayMode'] = val;
                      widget.onSectionChanged(newSection);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
