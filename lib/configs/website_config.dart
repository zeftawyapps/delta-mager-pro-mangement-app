import '../logic/services/json_config_service.dart';

class WebsiteConfig {
  static Map<String, dynamic> get _data => JsonConfigService().website;

  // 🔑 Keys for Sections
  static const String keySections = "sections";

  // 🔑 Order Settings Keys
  static const String keyOrderSettings = "orderSettings";
  static const String keyWorkflowSlug = "workflowSlug";
  static const String keyAllowDefaultWorkflow = "allowDefaultWorkflow";
  static const String keyCalculationMode = "calculationMode";
  static const String keyOrderMode = "orderMode";

  // 🔑 Section Types
  static const String typeCategories = "categories";
  static const String typeOffers = "offers";
  static const String typeNewProducts = "new_products";
  static const String typeBestSellerProducts = "best_seller";
  static const String typeBlogPosts = "blog_posts";
  static const String typeCustomBanner = "custom_banner";
  static const String typeIntroSlides = "intro_slides";
  static const String typeMostReadBlogPosts = "most_read_posts";
  static const String typeJockerPost = "jocker_post";
  static const String typeAboutCompany = "about_company";
  static const String typeFaqs = "faqs";
  static const String typeTestimonials = "testimonials";
  static const String typeTrustBadges = "trust_badges";
  static const String typeNewsletterSignup = "newsletter_signup";
  static const String typeFeatures = "features";
  static const String typeTabsShowcase = "tabs_showcase";
  static const String typeShowcase = "showcase";
  static const String typePricing = "pricing";
  static const String typeContactUs = "contact_us";

  // 🔑 Display Modes
  static const String modeHorizontalList = "horizontal_list";
  static const String modeGrid = "grid";
  static const String modeSlider = "slider";

  // 🔑 App Mode Keys
  static const String keyAppMode = "appMode";
  static const String appModeHybrid = "hybrid";
  static const String appModeBlog = "blog";
  static const String appModeStore = "store";

  // 🔑 Logo Style Keys
  static const String keyLogoStyle = "logoStyle";
  static const String logoStyleSolid = "solid";
  static const String logoStyleGradient = "gradient";

  // 🔑 Navbar Layout & Theme Keys
  static const String keyNavbarLayout = "navbarLayout";
  static const String keyNavbarTheme = "navbarTheme";
  // 🔑 Navbar Sticky Behavior
  static const String keyNavbarSticky = "navbarSticky"; // true = ثابت فوق الصفحة | false = يُسحب مع الـ scroll
  // 🔑 Footer Layout & Theme Keys
  static const String keyFooterLayout = "footerLayout";
  static const String keyFooterTheme = "footerTheme";
  // Options list
  static const List<String> navbarLayoutOptions = ["classic", "floating", "boxed"];
  static const List<String> navbarThemeOptions = ["glass", "solid", "gradient", "accent", "custom"];
  static const List<String> footerLayoutOptions = ["classic", "floating", "boxed"];
  static const List<String> footerThemeOptions = ["glass", "solid", "gradient", "accent"];
  // Arabic Labels
  static const Map<String, String> layoutLabels = {
    "classic": "افتراضي كامل العرض (Classic)",
    "floating": "كبسولة عائمة (Floating Capsule)",
    "boxed": "داخل حاوية (Boxed)",
  };
  static const Map<String, String> themeLabels = {
    "glass": "زجاجي ضبابي (Glassmorphic)",
    "solid": "خلفية موحدة (Solid Color)",
    "gradient": "تدرج لوني ناعم (Soft Gradient)",
    "accent": "بلون الهوية الرئيسي (Brand Accent)",
    "custom": "تنسيق ألوان مخصص (Custom Colors)",
  };

  // 🔑 Excess Links Keys
  static const String keyExcessLinksMode = "excessLinksMode";
  static const String excessLinksDropdown = "dropdown";
  static const String excessLinksSidebar = "sidebar";
  static const Map<String, String> excessLinksModeLabels = {
    excessLinksDropdown: "قائمة منسدلة \"المزيد\" (Dropdown)",
    excessLinksSidebar: "القائمة الجانبية فقط (Sidebar Only)",
  };

  // 🔑 Navbar Categories Toggles
  static const String keyShowStoreCategoriesInNavbar = "showStoreCategoriesInNavbar";
  static const String keyShowBlogCategoriesInNavbar = "showBlogCategoriesInNavbar";

  // 🔑 Footer Categories Toggles
  static const String keyShowStoreCategoriesInFooter = "showStoreCategoriesInFooter";
  static const String keyShowBlogCategoriesInFooter = "showBlogCategoriesInFooter";

  // 🔑 Navbar Order Key
  static const String keyNavbarOrder = "navbarOrder";
  static const List<String> defaultNavbarOrder = [
    "logo",
    "nav",
    "search",
    "tools",
  ];
  static const Map<String, String> navbarOrderLabels = {
    "logo": "الشعار (Logo)",
    "nav": "روابط التنقل (Nav Links)",
    "search": "البحث (Search)",
    "tools": "الأدوات (Cart, User...)",
  };

  // 🔑 Intro Section Sub-config Keys
  static const String keyIntroHybrid = "introHybrid";
  static const String keyIntroBlog = "introBlog";
  static const String keyIntroStore = "introStore";

  // 🔑 Intro Display Styles
  static const String introDisplayAppleFullscreen = "apple_fullscreen";
  static const String introDisplayMinimalGlass = "minimal_glass";
  static const String introDisplayFullSplit = "full_split";
  static const String introDisplayClassicCentered = "classic_centered";
  static const Map<String, String> introDisplayStyleLabels = {
    introDisplayAppleFullscreen: "Apple — ملء الشاشة بالكامل",
    introDisplayMinimalGlass: "Glassmorphism — نص داخل صندوق شفاف",
    introDisplayFullSplit: "Split — صورة ونص جنباً إلى جنب",
    introDisplayClassicCentered: "Classic — بطل افتراضي (Badge + زر + Glow)",
  };

  // 🔑 Background Types
  static const String bgTypeSolid = "solid";
  static const String bgTypeGradient = "gradient";

  // 🔑 Indicator Types
  static const String indicatorPills = "pills";
  static const String indicatorDots = "dots";
  static const String indicatorNone = "none";
  static const String introTextAlignStart = "start";
  static const String introTextAlignCenter = "center";
  static const String introTextAlignEnd = "end";
  static const Map<String, String> introTextAlignLabels = {
    introTextAlignStart: "الطرف (يمين/يسار حسب اللغة)",
    introTextAlignCenter: "المنتصف",
    introTextAlignEnd: "الطرف المعاكس",
  };
  static const String keySlideAnimation = "slideAnimation";
  static const List<String> slideAnimationOptions = ["fade", "slide", "zoom", "flip"];
  static const Map<String, String> slideAnimationLabels = {
    "fade": "تلاشي ناعم (Fade)",
    "slide": "انزلاق أفقي (Slide)",
    "zoom": "تكبير وتلاشي (Zoom)",
    "flip": "التواء كروت (Flip)",
  };
  static const Map<String, String> indicatorTypeLabels = {
    indicatorPills: "أشكال ممدودة (Pills)",
    indicatorDots: "نقاط (Dots)",
    indicatorNone: "بدون مؤشر",
  };

  /// Default styling for one app-mode tab inside intro_slides (hybrid / blog / store).
  static Map<String, dynamic> defaultIntroModeConfig({
    String displayStyle = introDisplayAppleFullscreen,
    String backgroundType = bgTypeSolid,
    String customBg = "",
    String textColor = "",
    bool autoPlay = true,
    int duration = 4000,
    String slideAnimation = "fade",
    String indicatorType = indicatorDots,
    bool showGlow = true,
    bool showBadge = true,
    String badgeText = "",
    bool showButton = true,
    String buttonText = "",
    String buttonLink = "",
    String buttonBg = "",
    String buttonTextColor = "",
    bool useGradientTitle = true,
    bool showHeroImage = true,
    String heroImageUrl = "",
    bool showPrice = false,
    double? price,
    double? originalPrice,
    String discountLabel = "",
    String? textAlign,
  }) {
    final style = normalizeIntroDisplayStyle(displayStyle);
    return {
      "displayStyle": style,
      "backgroundType": backgroundType,
      "customBg": customBg,
      "textColor": textColor,
      "autoPlay": autoPlay,
      "duration": duration,
      "slideAnimation": slideAnimation,
      "indicatorType": indicatorType,
      "textAlign": textAlign ?? normalizeIntroTextAlign(null, displayStyle: style),
      "showGlow": showGlow,
      "showBadge": showBadge,
      "badgeText": badgeText,
      "showButton": showButton,
      "buttonText": buttonText,
      "buttonLink": buttonLink,
      "buttonBg": buttonBg,
      "buttonTextColor": buttonTextColor,
      "useGradientTitle": useGradientTitle,
      "showHeroImage": showHeroImage,
      "heroImageUrl": heroImageUrl,
      "showPrice": showPrice,
      if (price != null) "price": price,
      if (originalPrice != null) "originalPrice": originalPrice,
      "discountLabel": discountLabel,
    };
  }

  /// Full intro_slides section config (three app-mode variants).
  static Map<String, dynamic> get defaultIntroSlidesConfig => {
        keyIntroHybrid: defaultIntroModeConfig(
          displayStyle: introDisplayAppleFullscreen,
          backgroundType: bgTypeGradient,
          customBg: "linear-gradient(135deg, #100C1C, #1A2332)",
          textColor: "#FFFFFF",
        ),
        keyIntroBlog: defaultIntroModeConfig(
          displayStyle: introDisplayMinimalGlass,
          backgroundType: bgTypeSolid,
          customBg: "#0F172A",
          textColor: "#F8FAFC",
          autoPlay: false,
          indicatorType: indicatorPills,
        ),
        keyIntroStore: defaultIntroModeConfig(
          displayStyle: introDisplayFullSplit,
          backgroundType: bgTypeGradient,
          customBg: "linear-gradient(135deg, #1A2332, #0D47A1)",
          textColor: "#FFFFFF",
          duration: 3000,
          indicatorType: indicatorNone,
          showPrice: true,
          price: 199.99,
          originalPrice: 249,
          discountLabel: "20% OFF",
          buttonText: "اشتري الآن",
          buttonLink: "/store/101",
        ),
      };

  // 🟠 Default Structure
  static const Map<String, dynamic> defaultValues = {
    keySections: [
      {
        "id": "web_intro",
        "type": typeIntroSlides,
        "displayMode": modeSlider,
        "title": "الشرائح التعريفية",
        "description": "سلايدر الهيرو في أعلى الصفحة",
        "isActive": true,
        "config": {
          "introHybrid": {
            "displayStyle": "apple_fullscreen",
            "backgroundType": "gradient",
            "customBg": "linear-gradient(135deg, #100C1C, #1A2332)",
            "textColor": "#FFFFFF",
            "autoPlay": true,
            "duration": 4000,
            "indicatorType": "dots",
          },
          "introBlog": {
            "displayStyle": "minimal_glass",
            "backgroundType": "solid",
            "customBg": "#0F172A",
            "textColor": "#F8FAFC",
            "autoPlay": false,
            "duration": 4000,
            "indicatorType": "pills",
          },
          "introStore": {
            "displayStyle": "full_split",
            "backgroundType": "gradient",
            "customBg": "linear-gradient(135deg, #1A2332, #0D47A1)",
            "textColor": "#FFFFFF",
            "autoPlay": true,
            "duration": 3000,
            "indicatorType": "none",
          },
        },
      },
      {
        "id": "web_offers",
        "type": typeOffers,
        "displayMode": modeSlider,
        "title": "أحدث العروض والخصومات",
        "isActive": true,
        "config": {"autoPlay": true, "variant": "default"}
      },
      {
        "id": "web_categories",
        "type": typeCategories,
        "displayMode": modeHorizontalList,
        "title": "تسوق حسب التصنيف",
        "isActive": true,
        "config": {"variant": "round"}
      },
      {
        "id": "web_new_products",
        "type": typeNewProducts,
        "displayMode": modeGrid,
        "title": "وصل حديثاً",
        "isActive": true,
        "config": {"crossAxisCount": 4}
      },
      {
        "id": "web_best_sellers",
        "type": typeBestSellerProducts,
        "displayMode": modeGrid,
        "title": "الأكثر مبيعاً",
        "isActive": true,
        "config": {"crossAxisCount": 4}
      },
      {
        "id": "web_blog_posts",
        "type": typeBlogPosts,
        "displayMode": modeGrid,
        "title": "أحدث المقالات في المدونة",
        "isActive": true,
        "config": {"limit": 3}
      },
      {
        "id": "web_jocker_post",
        "type": typeJockerPost,
        "displayMode": modeGrid,
        "title": "Jocker Post",
        "isActive": true,
        "config": {
          "imageCount": 1,
          "fullScreen": false,
          "margin": 16
        }
      },
      {
        "id": "web_features",
        "type": typeFeatures,
        "displayMode": modeGrid,
        "title": "المميزات والركائز الأساسية",
        "description": "كل ما تحتاجه لإدارة تجارتك بكفاءة",
        "isActive": false,
        "config": {
          "items": [
            {
              "icon": "📦",
              "title": "إدارة الطلبات",
              "description": "تتبع ومعالجة الطلبات من لحظة الإنشاء حتى التسليم"
            },
            {
              "icon": "📊",
              "title": "تقارير وتحليلات",
              "description": "لوحة تحكم شاملة لمتابعة أداء متجرك ومبيعاتك"
            },
            {
              "icon": "🛒",
              "title": "متجر إلكتروني",
              "description": "واجهة متجر احترافية قابلة للتخصيص بالكامل"
            }
          ]
        }
      },
      {
        "id": "web_tabs_showcase",
        "type": typeTabsShowcase,
        "displayMode": modeGrid,
        "title": "بنية النظام",
        "description": "طبقات متكاملة لإدارة تجارتك",
        "isActive": false,
        "config": {
          "tabs": [
            {
              "label": "طبقة العميل",
              "content": "واجهة متجر إلكتروني حديثة للعملاء",
              "items": [
                {"icon": "🛍️", "title": "تصفح المنتجات", "description": "تجربة تسوق سلسة ومتجاوبة"},
                {"icon": "🛒", "title": "سلة المشتريات", "description": "إدارة سهلة للطلبات والدفع"}
              ]
            },
            {
              "label": "طبقة التشغيل",
              "content": "أدوات إدارة شاملة للتجار",
              "items": [
                {"icon": "📋", "title": "إدارة الطلبات", "description": "متابعة ومعالجة الطلبات بكفاءة"},
                {"icon": "📦", "title": "إدارة المخزون", "description": "تحكم كامل في المنتجات والكميات"}
              ]
            }
          ]
        }
      },
      {
        "id": "web_showcase",
        "type": typeShowcase,
        "displayMode": modeSlider,
        "title": "معرض شاشات النظام",
        "description": "استكشف واجهات النظام المختلفة",
        "isActive": false,
        "config": {
          "tabs": [
            {"label": "لوحة التحكم", "imageUrl": ""},
            {"label": "المتجر الإلكتروني", "imageUrl": ""}
          ]
        }
      },
      {
        "id": "web_pricing",
        "type": typePricing,
        "displayMode": modeGrid,
        "title": "الباقات والأسعار",
        "description": "اختر الباقة المناسبة لاحتياجاتك",
        "isActive": false,
        "config": {
          "plans": [
            {
              "name": "أساسي",
              "price": "99",
              "period": "شهرياً",
              "features": ["متجر إلكتروني", "إدارة الطلبات", "تقارير أساسية"],
              "isPopular": false,
              "buttonText": "ابدأ الآن",
              "buttonLink": "/contact"
            },
            {
              "name": "احترافي",
              "price": "199",
              "period": "شهرياً",
              "features": ["كل مميزات الأساسي", "تخصيص كامل", "دعم أولوية"],
              "isPopular": true,
              "buttonText": "اشترك الآن",
              "buttonLink": "/contact"
            }
          ]
        }
      },
      {
        "id": "web_contact_us",
        "type": typeContactUs,
        "displayMode": modeGrid,
        "title": "تواصل معنا",
        "description": "نحن هنا لمساعدتك",
        "isActive": false,
        "config": {
          "phone": "",
          "email": "",
          "address": "",
          "mapUrl": "",
          "showForm": true
        }
      },
    ],
    keyOrderSettings: {
      keyWorkflowSlug: null,
      keyAllowDefaultWorkflow: true,
      keyCalculationMode: 2,
      keyOrderMode: "C2B",
    }
  };

  // 🔵 Getters
  static List<Map<String, dynamic>> get sections {
    final list = _data[keySections] as List?;
    if (list == null) return List<Map<String, dynamic>>.from(defaultValues[keySections]);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Map<String, dynamic> get orderSettings {
    final settings = _data[keyOrderSettings];
    if (settings == null || settings is! Map) {
      return Map<String, dynamic>.from(defaultValues[keyOrderSettings]);
    }
    return Map<String, dynamic>.from(settings);
  }

  static String? get defaultWorkflowSlug {
    final val = orderSettings[keyWorkflowSlug];
    return val?.toString();
  }

  static bool get defaultAllowDefaultWorkflow {
    final settings = orderSettings;
    final val = settings[keyAllowDefaultWorkflow];
    if (val == null) return true;
    if (val is bool) return val;
    if (val is String) {
      return val.toLowerCase() == 'true';
    }
    return true;
  }

  static int get defaultCalculationMode {
    final settings = orderSettings;
    final val = settings[keyCalculationMode];
    if (val == null) return 2;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? 2;
    }
    return 2;
  }

  static String get defaultOrderMode {
    final settings = orderSettings;
    final val = settings[keyOrderMode];
    return val?.toString() ?? 'C2B';
  }

  static const Set<String> _allDisplayModes = {
    modeHorizontalList,
    modeGrid,
    modeSlider,
  };

  /// Maps legacy/alternate values (e.g. website "slide") to admin schema values.
  static String normalizeDisplayMode(dynamic mode, String type) {
    final raw = mode?.toString() ?? '';
    if (raw == 'slide') return modeSlider;

    if (type == typeIntroSlides) {
      return raw == modeGrid ? modeGrid : modeSlider;
    }

    if (_allDisplayModes.contains(raw)) return raw;
    return defaultDisplayModeForType(type);
  }

  /// Maps legacy short style names to intro displayStyle enum values.
  static String normalizeIntroDisplayStyle(dynamic value) {
    final raw = value?.toString() ?? '';
    if (introDisplayStyleLabels.containsKey(raw)) return raw;

    const legacy = {
      'classic': introDisplayClassicCentered,
      'glass': introDisplayMinimalGlass,
      'split': introDisplayFullSplit,
      'apple': introDisplayAppleFullscreen,
    };
    return legacy[raw] ?? introDisplayAppleFullscreen;
  }

  /// start = side by language; classic defaults to center when unset.
  static String normalizeIntroTextAlign(
    dynamic value, {
    String? displayStyle,
  }) {
    final raw = value?.toString() ?? '';
    if (raw == introTextAlignStart ||
        raw == introTextAlignCenter ||
        raw == introTextAlignEnd) {
      return raw;
    }
    final style = normalizeIntroDisplayStyle(displayStyle);
    if (style == introDisplayClassicCentered) return introTextAlignCenter;
    return introTextAlignStart;
  }

  static Map<String, dynamic> _deepCloneMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key, _deepCloneMap(Map<String, dynamic>.from(value)));
      }
      if (value is List) {
        return MapEntry(
          key,
          value.map((item) {
            if (item is Map) {
              return _deepCloneMap(Map<String, dynamic>.from(item));
            }
            return item;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  static Map<String, dynamic> deepCloneSection(Map<String, dynamic> section) {
    return _deepCloneMap(section);
  }

  static Map<String, dynamic>? _defaultSectionTemplateForType(String type) {
    final defaults = defaultValues[keySections] as List;
    for (final entry in defaults) {
      if (entry is Map && entry['type'] == type) {
        return Map<String, dynamic>.from(entry);
      }
    }
    return null;
  }

  static String defaultDisplayModeForType(String type) {
    final template = _defaultSectionTemplateForType(type);
    return template?['displayMode']?.toString() ?? modeGrid;
  }

  static Map<String, dynamic> defaultConfigForType(String type) {
    if (type == typeIntroSlides) {
      return _deepCloneMap(defaultIntroSlidesConfig);
    }

    final template = _defaultSectionTemplateForType(type);
    final config = template?['config'];
    if (config is Map) {
      return _deepCloneMap(Map<String, dynamic>.from(config));
    }
    return {};
  }

  /// Clears stale config when the section type changes, then applies fresh defaults.
  static Map<String, dynamic> resetSectionForType(
    Map<String, dynamic> section,
    String newType,
  ) {
    return {
      'id': section['id'] ?? 'web_sec_${DateTime.now().millisecondsSinceEpoch}',
      'type': newType,
      'displayMode': defaultDisplayModeForType(newType),
      'title': section['title'] ?? 'قسم جديد على الويب',
      if (section['description'] != null) 'description': section['description'],
      'isActive': section['isActive'] ?? true,
      'config': defaultConfigForType(newType),
    };
  }

  static Map<String, dynamic> _sanitizeIntroModeConfig(Map<String, dynamic> sub) {
    final displayStyle = normalizeIntroDisplayStyle(sub['displayStyle']);
    final bgType = sub['backgroundType'] ?? bgTypeSolid;
    var customBg = sub['customBg']?.toString() ?? '';

    // Clean gradient string when backgroundType is solid
    if (bgType == bgTypeSolid && customBg.contains('linear-gradient')) {
      final matches = RegExp(r'#[0-9A-Fa-f]{6}').allMatches(customBg).map((m) => m.group(0)!).toList();
      if (matches.isNotEmpty) {
        customBg = matches.first;
      } else {
        customBg = '';
      }
    }

    return {
      'displayStyle': displayStyle,
      'backgroundType': bgType,
      'customBg': customBg,
      'textColor': sub['textColor'] ?? '',
      'autoPlay': sub['autoPlay'] ?? true,
      'duration': ((sub['duration'] ?? 4000) as num).toInt(),
      'slideAnimation': sub['slideAnimation'] ?? 'fade',
      'indicatorType': sub['indicatorType'] ?? indicatorDots,
      'textAlign': normalizeIntroTextAlign(
        sub['textAlign'],
        displayStyle: displayStyle,
      ),
      'showGlow': sub['showGlow'] ?? true,
      'showBadge': sub['showBadge'] ?? true,
      'badgeText': sub['badgeText'] ?? '',
      'showButton': sub['showButton'] ?? true,
      'buttonText': sub['buttonText'] ?? '',
      'buttonLink': sub['buttonLink'] ?? '',
      'buttonBg': sub['buttonBg'] ?? '',
      'buttonTextColor': sub['buttonTextColor'] ?? '',
      'useGradientTitle': sub['useGradientTitle'] ?? true,
      'showHeroImage': sub['showHeroImage'] ?? true,
      'heroImageUrl': sub['heroImageUrl'] ?? '',
      'showPrice': sub['showPrice'] ?? false,
      if (sub['price'] != null) 'price': (sub['price'] as num).toDouble(),
      if (sub['originalPrice'] != null)
        'originalPrice': (sub['originalPrice'] as num).toDouble(),
      'discountLabel': sub['discountLabel'] ?? '',
    };
  }

  static List<dynamic> _deepCloneList(List? list) {
    return (list ?? []).map((item) {
      if (item is Map) {
        return _deepCloneMap(Map<String, dynamic>.from(item));
      }
      return item;
    }).toList();
  }

  static Map<String, dynamic> _sanitizeIntroSlidesConfig(
    Map<String, dynamic> config,
  ) {
    final sanitized = _deepCloneMap(defaultIntroSlidesConfig);

    for (final key in [keyIntroHybrid, keyIntroBlog, keyIntroStore]) {
      final sub = config[key];
      if (sub is Map) {
        sanitized[key] = _sanitizeIntroModeConfig(
          Map<String, dynamic>.from({
            ...(sanitized[key] as Map<String, dynamic>),
            ...sub,
          }),
        );
      }
    }

    if (config.containsKey('boxedLayout')) {
      sanitized['boxedLayout'] = config['boxedLayout'] ?? false;
    }
    if (config.containsKey('hasShadow')) {
      sanitized['hasShadow'] = config['hasShadow'] ?? false;
    }

    return sanitized;
  }

  static Map<String, dynamic> sanitizeConfigForType(
    Map<String, dynamic> config,
    String type,
  ) {
    switch (type) {
      case typeIntroSlides:
        return _sanitizeIntroSlidesConfig(config);
      case typeNewProducts:
      case typeBestSellerProducts:
        return {
          'crossAxisCount': (config['crossAxisCount'] as num?)?.toInt() ?? 4,
        };
      case typeBlogPosts:
      case typeMostReadBlogPosts:
        return {'limit': (config['limit'] as num?)?.toInt() ?? 3};
      case typeCategories:
        return {'variant': config['variant'] ?? 'round'};
      case typeOffers:
        return {
          'autoPlay': config['autoPlay'] ?? true,
          'variant': config['variant'] ?? 'default',
        };
      case typeCustomBanner:
        return {
          if (config['imageUrl'] != null) 'imageUrl': config['imageUrl'],
          if (config['buttonText'] != null) 'buttonText': config['buttonText'],
          if (config['buttonLink'] != null)
            'buttonLink': config['buttonLink']
          else if (config['linkUrl'] != null)
            'buttonLink': config['linkUrl'],
          if (config['variant'] != null) 'variant': config['variant'],
        };
      case typeJockerPost:
        return {
          'imageCount': (config['imageCount'] as num?)?.toInt() ?? 1,
          'fullScreen': config['fullScreen'] ?? false,
          'margin': (config['margin'] as num?)?.toInt() ?? 16,
        };
      case typeAboutCompany:
        return {
          'imagePosition': config['imagePosition'] ?? 'left',
          if (config['postSlug'] != null) 'postSlug': config['postSlug'],
          if (config['imageUrl'] != null) 'imageUrl': config['imageUrl'],
        };
      case typeFaqs:
      case typeTestimonials:
      case typeTrustBadges:
      case typeFeatures:
        return {'items': _deepCloneList(config['items'] as List?)};
      case typeTabsShowcase:
      case typeShowcase:
        return {'tabs': _deepCloneList(config['tabs'] as List?)};
      case typePricing:
        return {'plans': _deepCloneList(config['plans'] as List?)};
      case typeContactUs:
        return {
          'phone': config['phone'] ?? '',
          'email': config['email'] ?? '',
          'address': config['address'] ?? '',
          'mapUrl': config['mapUrl'] ?? '',
          'showForm': config['showForm'] ?? true,
        };
      default:
        return {};
    }
  }

  /// Normalizes a section loaded from API (legacy values, nested refs).
  static Map<String, dynamic> normalizeSectionFromApi(
    Map<String, dynamic> section,
  ) {
    final cloned = deepCloneSection(section);
    final type = cloned['type']?.toString() ?? '';
    cloned['displayMode'] = normalizeDisplayMode(cloned['displayMode'], type);

    final config = Map<String, dynamic>.from(cloned['config'] ?? {});
    if (type == typeIntroSlides) {
      for (final key in [keyIntroHybrid, keyIntroBlog, keyIntroStore]) {
        final sub = config[key];
        if (sub is Map) {
          final normalizedSub = Map<String, dynamic>.from(sub);
          normalizedSub['displayStyle'] = normalizeIntroDisplayStyle(
            normalizedSub['displayStyle'],
          );
          config[key] = normalizedSub;
        }
      }
    }
    cloned['config'] = config;
    return cloned;
  }

  /// Builds a clean section payload for save (replaces config, no stale keys).
  static Map<String, dynamic> sanitizeSectionForSave(
    Map<String, dynamic> section,
  ) {
    final type = section['type']?.toString() ?? '';
    final sanitized = <String, dynamic>{
      'id': section['id'],
      'type': type,
      'displayMode': normalizeDisplayMode(section['displayMode'], type),
      'title': section['title'] ?? '',
      'isActive': section['isActive'] ?? true,
      'config': sanitizeConfigForType(
        Map<String, dynamic>.from(section['config'] ?? {}),
        type,
      ),
    };

    final description = section['description'];
    if (description != null && description.toString().isNotEmpty) {
      sanitized['description'] = description;
    }

    return sanitized;
  }
}
