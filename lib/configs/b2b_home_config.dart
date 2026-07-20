import '../logic/services/json_config_service.dart';

class B2bHomeConfig {
  static Map<String, dynamic> get _data => JsonConfigService().b2bHomeLayout;

  // 🔑 Keys for Sections
  static const String keySections = "sections";

  // 🔑 Section Types
  static const String typeCategories = "categories";
  static const String typeOffers = "offers";
  static const String typeNewProducts = "new_products";
  static const String typeBestSellerProducts = "best_seller";
  static const String typeJokerProducts = "joker_products";
  static const String typeSuperJokerProducts = "super_joker_products";
  static const String typeOnSaleProducts = "on_sale_products";
  static const String typeCustomBanner = "custom_banner";

  // 🔑 Display Modes
  static const String modeHorizontalList = "horizontal_list";
  static const String modeGrid = "grid";
  static const String modeSlider = "slider";

  // 🔑 Order Settings Keys
  static const String keyOrderSettings = "orderSettings";
  static const String keyWorkflowSlug = "workflowSlug";
  static const String keyWholesaleWorkflowSlug = "wholesaleWorkflowSlug";
  static const String keyAllowDefaultWorkflow = "allowDefaultWorkflow";
  static const String keyCalculationMode = "calculationMode";
  static const String keyOrderMode = "orderMode";

  // 🔑 Role Upgrade Keys
  /// هل ميزة طلب ترقية الدور مفعلة أصلاً؟
  static const String keyAllowRoleUpgrade = "allowRoleUpgrade";

  /// قائمة الأدوار (role names) التي يُسمح للعميل بطلب الترقية إليها.
  /// إذا كانت فارغة أو null → تُعرض جميع أدوار العملاء (isCustomerRole == true).
  static const String keyAllowedUpgradeRoles = "allowedUpgradeRoles";

  // 🔑 Price Selector Keys
  /// هل ميزة اختيار فئة السعر مقيدة بأدوار معينة؟
  static const String keyRestrictPriceSelector = "restrictPriceSelector";

  /// قائمة الأدوار المسموح لها باختيار فئة السعر.
  static const String keyAllowedPriceSelectorRoles = "allowedPriceSelectorRoles";

  // 🟠 Default Structure
  static const Map<String, dynamic> defaultValues = {
    keySections: [
      {
        "id": "sec_categories",
        "type": typeCategories,
        "displayMode": modeHorizontalList,
        "title": "التصنيفات",
        "isActive": true,
        "config": {"height": 120.0}
      },
      {
        "id": "sec_offers",
        "type": typeOffers,
        "displayMode": modeSlider,
        "title": "أقوى العروض",
        "isActive": true,
        "config": {"aspectRatio": 16 / 9, "autoPlay": true}
      },
      {
        "id": "sec_new",
        "type": typeNewProducts,
        "displayMode": modeGrid,
        "title": "وصل حديثاً",
        "isActive": true,
        "config": {"crossAxisCount": 4}
      },
    ],
    keyOrderSettings: {
      keyWorkflowSlug: null,
      keyWholesaleWorkflowSlug: null,
      keyAllowDefaultWorkflow: true,
      keyCalculationMode: 2,
      keyOrderMode: "B2B",
      keyAllowRoleUpgrade: false,
      keyAllowedUpgradeRoles: <String>[],
      keyRestrictPriceSelector: false,
      keyAllowedPriceSelectorRoles: <String>[],
    }
  };

  // 🔵 Getters — Order Settings
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

  static String? get wholesaleWorkflowSlug {
    final val = orderSettings[keyWholesaleWorkflowSlug];
    return val?.toString();
  }

  static bool get defaultAllowDefaultWorkflow {
    final settings = orderSettings;
    final val = settings[keyAllowDefaultWorkflow];
    if (val == null) return true;
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return true;
  }

  static int get defaultCalculationMode {
    final settings = orderSettings;
    final val = settings[keyCalculationMode];
    if (val == null) return 2;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 2;
    return 2;
  }

  static String get defaultOrderMode {
    final settings = orderSettings;
    final val = settings[keyOrderMode];
    return val?.toString() ?? 'B2B';
  }

  // 🔵 Getters — Role Upgrade
  /// هل ميزة طلب الترقية مفعلة؟ (افتراضي: false — لازم الأدمن يفعّلها بنفسه)
  static bool get allowRoleUpgrade {
    final val = orderSettings[keyAllowRoleUpgrade];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return false;
  }

  /// الأدوار المسموح بطلب الترقية إليها.
  /// إذا كانت القائمة فارغة → لا فلتر، كل الأدوار ذات isCustomerRole==true مسموحة.
  static List<String> get allowedUpgradeRoles {
    final raw = orderSettings[keyAllowedUpgradeRoles];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  // 🔵 Getters — Price Selector Restrict
  /// هل يتم تقييد زر فئة السعر بأدوار محددة؟
  static bool get restrictPriceSelector {
    final val = orderSettings[keyRestrictPriceSelector];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return false;
  }

  /// الأدوار المسموح لها بتبديل فئات الأسعار.
  static List<String> get allowedPriceSelectorRoles {
    final raw = orderSettings[keyAllowedPriceSelectorRoles];
    if (raw is List) {
      return raw.map((e) => e is Map ? (e['key']?.toString() ?? '') : e.toString()).toList();
    }
    return [];
  }

  // 🔵 Sections
  static List<Map<String, dynamic>> get sections {
    final list = _data[keySections] as List?;
    if (list == null) {
      return List<Map<String, dynamic>>.from(defaultValues[keySections]);
    }
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

