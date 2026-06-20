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
