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
  static const String keyShowDiscount = "showDiscount";
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
    keyShowDiscount: true,
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
  };

  // 🔵 Getters
  static bool get showImages =>
      _data[keyShowImages] ?? defaultValues[keyShowImages];
  static bool get showDescription =>
      _data[keyShowDescription] ?? defaultValues[keyShowDescription];
  static bool get showDetailedDescription =>
      _data[keyShowDetailedDescription] ??
      defaultValues[keyShowDetailedDescription];
  static bool get showUsage =>
      _data[keyShowUsage] ?? defaultValues[keyShowUsage];
  static bool get showBenefits =>
      _data[keyShowBenefits] ?? defaultValues[keyShowBenefits];
  static bool get showIngredients =>
      _data[keyShowIngredients] ?? defaultValues[keyShowIngredients];
  static bool get showDiscount =>
      _data[keyShowDiscount] ?? defaultValues[keyShowDiscount];
  static bool get showIsNew => _data[keyShowIsNew] ?? defaultValues[keyShowIsNew];
  static bool get showIsBestSeller =>
      _data[keyShowIsBestSeller] ?? defaultValues[keyShowIsBestSeller];
  static bool get showIsOnSale =>
      _data[keyShowIsOnSale] ?? defaultValues[keyShowIsOnSale];
  static bool get showIsJoker =>
      _data[keyShowIsJoker] ?? defaultValues[keyShowIsJoker];
  static bool get showIsSuperJoker =>
      _data[keyShowIsSuperJoker] ?? defaultValues[keyShowIsSuperJoker];
  static bool get showChangePriceInPopup =>
      _data[keyShowChangePriceInPopup] ?? defaultValues[keyShowChangePriceInPopup];
  static bool get showDeleteInPopup =>
      _data[keyShowDeleteInPopup] ?? defaultValues[keyShowDeleteInPopup];
  static bool get enableQuickAdd =>
      _data[keyEnableQuickAdd] ?? defaultValues[keyEnableQuickAdd];
  static bool get enableRichTextEditor =>
      _data[keyEnableRichTextEditor] ?? defaultValues[keyEnableRichTextEditor];
  static bool get enableMultiSizePricing =>
      _data[keyEnableMultiSizePricing] ?? defaultValues[keyEnableMultiSizePricing];
  static bool get defaultToSinglePrice =>
      _data[keyDefaultToSinglePrice] ?? defaultValues[keyDefaultToSinglePrice];
  static List<String> get allowedUnits =>
      List<String>.from(_data[keyAllowedUnits] ?? defaultValues[keyAllowedUnits]);
  static bool get enableAddProduct =>
      _data[keyEnableAddProduct] ?? defaultValues[keyEnableAddProduct];
  static bool get showAddProductInGrid =>
      _data[keyShowAddProductInGrid] ?? defaultValues[keyShowAddProductInGrid];
  static bool get enableAddCategory =>
      _data[keyEnableAddCategory] ?? defaultValues[keyEnableAddCategory];
  static bool get showAddCategoryInGrid =>
      _data[keyShowAddCategoryInGrid] ?? defaultValues[keyShowAddCategoryInGrid];
  static bool get enableAddOffer =>
      _data[keyEnableAddOffer] ?? defaultValues[keyEnableAddOffer];
  static bool get showAddOfferInGrid =>
      _data[keyShowAddOfferInGrid] ?? defaultValues[keyShowAddOfferInGrid];

  static bool get isProductImageRequired =>
      _data[keyProductImageIsRequired] ?? defaultValues[keyProductImageIsRequired];
  static double get productImageHeight =>
      (_data[keyProductImageHeight] ?? defaultValues[keyProductImageHeight])
          .toDouble();
  static double get productImageWidth =>
      (_data[keyProductImageWidth] ?? defaultValues[keyProductImageWidth])
          .toDouble();
  static bool get isProductImageRatioEnforced =>
      _data[keyProductImageEnforceRatio] ??
      defaultValues[keyProductImageEnforceRatio];
  static int get maxProductImageSizeMB =>
      (_data[keyProductImageMaxSizeMB] ?? defaultValues[keyProductImageMaxSizeMB])
          .toInt();

  static bool get isCategoryImageRequired =>
      _data[keyCategoryImageIsRequired] ??
      defaultValues[keyCategoryImageIsRequired];
  static double get categoryImageHeight =>
      (_data[keyCategoryImageHeight] ?? defaultValues[keyCategoryImageHeight])
          .toDouble();
  static double get categoryImageWidth =>
      (_data[keyCategoryImageWidth] ?? defaultValues[keyCategoryImageWidth])
          .toDouble();
  static bool get isCategoryImageRatioEnforced =>
      _data[keyCategoryImageEnforceRatio] ??
      defaultValues[keyCategoryImageEnforceRatio];
  static int get maxCategoryImageSizeMB =>
      (_data[keyCategoryImageMaxSizeMB] ??
              defaultValues[keyCategoryImageMaxSizeMB])
          .toInt();
}
