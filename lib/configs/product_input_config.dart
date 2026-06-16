import '../logic/services/json_config_service.dart';

class ProductInputConfig {
  static Map<String, dynamic> get _data => JsonConfigService().productInput;

  // 🔑 Keys
  static const String keyShowImages = "showImages";
  static const String keyShowDescription = "showDescription";
  static const String keyShowDetailedDescription = "showDetailedDescription";
  static const String keyShowUsage = "showUsage";
  static const String keyShowBenefits = "showBenefits";
  static const String keyShowIngredients = "showIngredients";
  static const String keyShowIsNew = "showIsNew";
  static const String keyShowIsBestSeller = "showIsBestSeller";
  static const String keyShowIsOnSale = "showIsOnSale";
  static const String keyShowIsJoker = "showIsJoker";
  static const String keyShowIsSuperJoker = "showIsSuperJoker";
  static const String keyShowIsInsideOffer = "showIsInsideOffer";
  static const String keyShowDiscount = "showDiscount";
  static const String keyShowDiscountPercentage = "showDiscountPercentage";
  static const String keyEnableMultiSizePricing = "enableMultiSizePricing";
  static const String keyDefaultToSinglePrice = "defaultToSinglePrice";
  static const String keyAllowedUnits = "allowedUnits";
  static const String keyEnableAddProduct = "enableAddProduct";
  static const String keyShowAddProductInGrid = "showAddProductInGrid";
  static const String keyEnableAddCategory = "enableAddCategory";
  static const String keyShowAddCategoryInGrid = "showAddCategoryInGrid";
  static const String keyEnableAddOffer = "enableAddOffer";
  static const String keyShowAddOfferInGrid = "showAddOfferInGrid";
  static const String keyEnableQuickAdd = "enableQuickAdd";
  static const String keyShowChangePriceInPopup = "showChangePriceInPopup";
  static const String keyShowDeleteInPopup = "showDeleteInPopup";
  static const String keyEnableRichTextEditor = "enableRichTextEditor";
  static const String keyShowVariants = "showVariants";
  static const String keyShowAddons = "showAddons";
  static const String keyShowOptions = "showOptions";

  // Image Config Keys (Flat Structure as used in UI)
  static const String keyProductImageIsRequired = "productImage_isRequired";
  static const String keyProductImageEnforceRatio = "productImage_enforceRatio";
  static const String keyProductImageHeight = "productImage_height";
  static const String keyProductImageWidth = "productImage_width";
  static const String keyProductImageMaxSizeMB = "productImage_maxSizeMB";

  static const String keyCategoryImageIsRequired = "categoryImage_isRequired";
  static const String keyCategoryImageEnforceRatio =
      "categoryImage_enforceRatio";
  static const String keyCategoryImageHeight = "categoryImage_height";
  static const String keyCategoryImageWidth = "categoryImage_width";
  static const String keyCategoryImageMaxSizeMB = "categoryImage_maxSizeMB";

  static const String keyMaxProductImages = "maxProductImages";
  static const String keyPriceTiers = "priceTiers";

  // 🟠 القيم الافتراضية الموحدة للمشروع
  static const Map<String, dynamic> defaultValues = {
    keyShowImages: true,
    keyShowDescription: true,
    keyShowDetailedDescription: false,
    keyShowUsage: false,
    keyShowBenefits: true,
    keyShowIngredients: false,
    keyShowIsNew: true,
    keyShowIsBestSeller: true,
    keyShowIsOnSale: false,
    keyShowIsJoker: true,
    keyShowIsSuperJoker: false,
    keyShowIsInsideOffer: false,
    keyShowDiscount: true,
    keyShowDiscountPercentage: true,
    keyEnableMultiSizePricing: true,
    keyDefaultToSinglePrice: false,
    keyAllowedUnits: ["piece", "box", "kg", "gram", "liter", "ml", "pack"],
    keyEnableAddProduct: true,
    keyShowAddProductInGrid: false,
    keyEnableAddCategory: true,
    keyShowAddCategoryInGrid: false,
    keyEnableAddOffer: true,
    keyShowAddOfferInGrid: false,
    keyEnableQuickAdd: true,
    keyShowChangePriceInPopup: true,
    keyShowDeleteInPopup: true,
    keyEnableRichTextEditor: false,
    keyShowVariants: false,
    keyShowAddons: false,
    keyShowOptions: false,
    keyProductImageIsRequired: false,
    keyProductImageEnforceRatio: true,
    keyProductImageHeight: 300,
    keyProductImageWidth: 300,
    keyProductImageMaxSizeMB: 5,
    keyCategoryImageIsRequired: false,
    keyCategoryImageEnforceRatio: true,
    keyCategoryImageHeight: 200,
    keyCategoryImageWidth: 200,
    keyCategoryImageMaxSizeMB: 2,
    keyMaxProductImages: 5,
    keyPriceTiers: [
      {
        "code": "wholesale",
        "name": {"ar": "جملة", "en": "Wholesale"}
      },
      {
        "code": "distributor",
        "name": {"ar": "موزع / وكيل", "en": "Distributor"}
      }
    ],
  };

  // 🔵 Getters
  static bool _getBool(String key) {
    final defaultValue = defaultValues[key] as bool? ?? false;
    final val = _data[key];
    if (val == null) return defaultValue;
    if (val is bool) return val;
    if (val is String) {
      return val.toLowerCase() == 'true';
    }
    return defaultValue;
  }

  static double _getDouble(String key) {
    final defaultValue = (defaultValues[key] as num? ?? 0.0).toDouble();
    final val = _data[key];
    if (val == null) return defaultValue;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? defaultValue;
    }
    return defaultValue;
  }

  static int _getInt(String key) {
    final defaultValue = (defaultValues[key] as num? ?? 0).toInt();
    final val = _data[key];
    if (val == null) return defaultValue;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? defaultValue;
    }
    return defaultValue;
  }

  static bool get showImages => _getBool(keyShowImages);
  static bool get showDescription => _getBool(keyShowDescription);
  static bool get showDetailedDescription => _getBool(keyShowDetailedDescription);
  static bool get showUsage => _getBool(keyShowUsage);
  static bool get showBenefits => _getBool(keyShowBenefits);
  static bool get showIngredients => _getBool(keyShowIngredients);
  static bool get showIsInsideOffer => _getBool(keyShowIsInsideOffer);
  static bool get showDiscount => _getBool(keyShowDiscount);
  static bool get showDiscountPercentage => _getBool(keyShowDiscountPercentage);
  static bool get showIsNew => _getBool(keyShowIsNew);
  static bool get showIsBestSeller => _getBool(keyShowIsBestSeller);
  static bool get showIsOnSale => _getBool(keyShowIsOnSale);
  static bool get showIsJoker => _getBool(keyShowIsJoker);
  static bool get showIsSuperJoker => _getBool(keyShowIsSuperJoker);
  static bool get showChangePriceInPopup => _getBool(keyShowChangePriceInPopup);
  static bool get showDeleteInPopup => _getBool(keyShowDeleteInPopup);
  static bool get enableQuickAdd => _getBool(keyEnableQuickAdd);
  static bool get enableRichTextEditor => _getBool(keyEnableRichTextEditor);
  static bool get showVariants => _getBool(keyShowVariants);
  static bool get showAddons => _getBool(keyShowAddons);
  static bool get showOptions => _getBool(keyShowOptions);
  static bool get enableMultiSizePricing => _getBool(keyEnableMultiSizePricing);
  static bool get defaultToSinglePrice => _getBool(keyDefaultToSinglePrice);
  static List<String> get allowedUnits {
    final val = _data[keyAllowedUnits];
    if (val == null) return List<String>.from(defaultValues[keyAllowedUnits]);
    if (val is List) return List<String>.from(val);
    return List<String>.from(defaultValues[keyAllowedUnits]);
  }
  static bool get enableAddProduct => _getBool(keyEnableAddProduct);
  static bool get showAddProductInGrid => _getBool(keyShowAddProductInGrid);
  static bool get enableAddCategory => _getBool(keyEnableAddCategory);
  static bool get showAddCategoryInGrid => _getBool(keyShowAddCategoryInGrid);
  static bool get enableAddOffer => _getBool(keyEnableAddOffer);
  static bool get showAddOfferInGrid => _getBool(keyShowAddOfferInGrid);

  static bool get isProductImageRequired => _getBool(keyProductImageIsRequired);
  static double get productImageHeight => _getDouble(keyProductImageHeight);
  static double get productImageWidth => _getDouble(keyProductImageWidth);
  static bool get isProductImageRatioEnforced => _getBool(keyProductImageEnforceRatio);
  static int get maxProductImageSizeMB => _getInt(keyProductImageMaxSizeMB);

  static bool get isCategoryImageRequired => _getBool(keyCategoryImageIsRequired);
  static double get categoryImageHeight => _getDouble(keyCategoryImageHeight);
  static double get categoryImageWidth => _getDouble(keyCategoryImageWidth);
  static bool get isCategoryImageRatioEnforced => _getBool(keyCategoryImageEnforceRatio);
  static int get maxCategoryImageSizeMB => _getInt(keyCategoryImageMaxSizeMB);

  static int get maxProductImages => _getInt(keyMaxProductImages);
  static List<Map<String, dynamic>> get priceTiers {
    final val = _data[keyPriceTiers];
    if (val == null) {
      return List<Map<String, dynamic>>.from(
        (defaultValues[keyPriceTiers] as List).map((e) => Map<String, dynamic>.from(e))
      );
    }
    if (val is List) {
      return List<Map<String, dynamic>>.from(
        val.map((e) => Map<String, dynamic>.from(e as Map))
      );
    }
    return List<Map<String, dynamic>>.from(
      (defaultValues[keyPriceTiers] as List).map((e) => Map<String, dynamic>.from(e))
    );
  }
}
