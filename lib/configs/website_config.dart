import '../logic/services/json_config_service.dart';

class WebsiteConfig {
  static Map<String, dynamic> get _data => JsonConfigService().website;

  // 🔑 Keys for Sections
  static const String keySections = "sections";

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
    introDisplayClassicCentered: "Classic — نص في المنتصف",
  };

  // 🔑 Background Types
  static const String bgTypeSolid = "solid";
  static const String bgTypeGradient = "gradient";

  // 🔑 Indicator Types
  static const String indicatorPills = "pills";
  static const String indicatorDots = "dots";
  static const String indicatorNone = "none";
  static const Map<String, String> indicatorTypeLabels = {
    indicatorPills: "أشكال ممدودة (Pills)",
    indicatorDots: "نقاط (Dots)",
    indicatorNone: "بدون مؤشر",
  };

  // 🟠 Default Structure
  static const Map<String, dynamic> defaultValues = {
    keySections: [
      {
        "id": "web_offers",
        "type": typeOffers,
        "displayMode": modeSlider,
        "title": "أحدث العروض والخصومات",
        "isActive": true,
        "config": {"autoPlay": true}
      },
      {
        "id": "web_categories",
        "type": typeCategories,
        "displayMode": modeHorizontalList,
        "title": "تسوق حسب التصنيف",
        "isActive": true,
        "config": {}
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
    ]
  };

  // 🔵 Getters
  static List<Map<String, dynamic>> get sections {
    final list = _data[keySections] as List?;
    if (list == null) return List<Map<String, dynamic>>.from(defaultValues[keySections]);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
