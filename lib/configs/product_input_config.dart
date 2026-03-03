class ProductInputConfig {
  static bool get showImages => true;
  static bool get showDescription => true;
  static bool get showDetailedDescription => false;
  static bool get showUsage => false;
  static bool get showBenefits => true;
  static bool get showIngredients => false;
  static bool get showDiscount => true;
  static bool get showIsNew => true;
  static bool get showIsBestSeller => true;
  static bool get showIsOnSale => false;
  static bool get showIsJoker => true;
  static bool get showIsSuperJoker => false;
  static bool get showChangePriceInPopup => true;
  static bool get showDeleteInPopup => true;
  static bool get enableQuickAdd => true;
  static bool get enableRichTextEditor => false;
  static bool get enableMultiSizePricing => true;
  static bool get defaultToSinglePrice => false;
  static List<String> get allowedUnits => [];
  static bool get enableAddProduct => true;
  static bool get showAddProductInGrid => false;
  static bool get enableAddCategory => true;
  static bool get showAddCategoryInGrid => false;
  static bool get enableAddOffer => true;
  static bool get showAddOfferInGrid => false;

  // Product image config
  static bool get isProductImageRequired => false;
  static double get productImageHeight => 200.0;
  static double get productImageWidth => 200.0;
  static bool get isProductImageRatioEnforced => true;
  static int get maxProductImageSizeMB => 5;

  // Category image config
  static bool get isCategoryImageRequired => false;
  static double get categoryImageHeight => 200.0;
  static double get categoryImageWidth => 200.0;
  static bool get isCategoryImageRatioEnforced => true;
  static int get maxCategoryImageSizeMB => 5;
}
