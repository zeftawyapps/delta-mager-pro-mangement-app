import '../../configs/product_input_config.dart';
import 'package:matger_pro_core_logic/utls/type_parser.dart';

/// وحدات القياس المتاحة
enum ProductUnit {
  // وحدات السوائل
  ml('مل', 'ml', 'سوائل', false),
  liter('لتر', 'L', 'سوائل', false),

  // وحدات الوزن
  gram('جرام', 'g', 'وزن', false),
  kg('كيلو', 'kg', 'وزن', false),

  // وحدات العد
  piece('قطعة', 'pc', 'عد', true),
  bottle('زجاجة', 'btl', 'عد', false),
  jar('برطمان', 'jar', 'عد', false),
  pack('عبوة', 'pack', 'عد', false),
  box('علبة', 'box', 'عد', false),
  galon('غالون', 'gal', 'سوائل', true),
  sachet('كيس', 'sachet', 'عد', false),
  mm('ملم', 'mm', 'قياس', true);

  final String nameAr;
  final String nameEn;
  final String category;
  final bool _isVisibleStatic;

  const ProductUnit(
    this.nameAr,
    this.nameEn,
    this.category,
    this._isVisibleStatic,
  );

  /// هل الوحدة مرئية؟ (تعتمد على كلاً من allowedUnits في الـ config والقيمة المحددة هنا)
  bool get isVisible {
    // إذا كانت القائمة المسموح بها في الـ config غير فارغة، نعتمد عليها حصرياً
    if (ProductInputConfig.allowedUnits.isNotEmpty) {
      return ProductInputConfig.allowedUnits.contains(name) ||
          ProductInputConfig.allowedUnits.contains(nameEn);
    }

    // إذا كانت القائمة فارغة، نستخدم القيمة الافتراضية المحددة في الـ enum
    return _isVisibleStatic;
  }

  /// الحصول على الوحدة من النص
  static ProductUnit? fromString(String value) {
    try {
      return ProductUnit.values.firstWhere(
        (u) => u.nameAr == value || u.nameEn == value || u.name == value,
      );
    } catch (e) {
      return null;
    }
  }

  /// وحدات السوائل
  static List<ProductUnit> get liquidUnits =>
      values.where((u) => u.category == 'سوائل').toList();

  /// وحدات الوزن
  static List<ProductUnit> get weightUnits =>
      values.where((u) => u.category == 'وزن').toList();

  /// وحدات العد
  static List<ProductUnit> get countUnits =>
      values.where((u) => u.category == 'عد').toList();

  /// قائمة الأحجام السريعة المقترحة لكل وحدة
  List<QuickSize> get quickSizes {
    switch (this) {
      case ProductUnit.gram:
        return const [
          QuickSize('50 جرام', 50),
          QuickSize('100 جرام', 100),
          QuickSize('125 جرام', 125),
          QuickSize('ربع كيلو', 250),
          QuickSize('نص كيلو', 500),
          QuickSize('750 جرام', 750),
          QuickSize('كيلو', 1000),
        ];

      case ProductUnit.kg:
        return const [
          QuickSize('1 كيلو', 1),
          QuickSize('1.5 كيلو', 1.5),
          QuickSize('2 كيلو', 2),
          QuickSize('2.5 كيلو', 2.5),
          QuickSize('3 كيلو', 3),
          QuickSize('4 كيلو', 4),
          QuickSize('5 كيلو', 5),
          QuickSize('10 كيلو', 10),
        ];

      case ProductUnit.ml:
        return const [
          QuickSize('50 مل', 50),
          QuickSize('100 مل', 100),
          QuickSize('150 مل', 150),
          QuickSize('200 مل', 200),
          QuickSize('250 مل', 250),
          QuickSize('350 مل', 350),
          QuickSize('500 مل', 500),
        ];

      case ProductUnit.liter:
        return const [
          QuickSize('1 لتر', 1),
          QuickSize('1.5 لتر', 1.5),
          QuickSize('2 لتر', 2),
          QuickSize('2.5 لتر', 2.5),
          QuickSize('3 لتر', 3),
          QuickSize('4 لتر', 4),
          QuickSize('5 لتر', 5),
          QuickSize('10 لتر', 10),
          QuickSize('18 لتر', 18),
          QuickSize('20 لتر', 20),
          QuickSize('25 لتر', 25),
          QuickSize('50 لتر', 50),
          QuickSize('100 لتر', 100),
        ];

      case ProductUnit.piece:
      case ProductUnit.bottle:
      case ProductUnit.jar:
      case ProductUnit.pack:
      case ProductUnit.box:
      case ProductUnit.sachet:
      case ProductUnit.galon:
      case ProductUnit.mm:
        String unitLabel = nameAr;
        String pluralLabel = nameAr;
        if (this == ProductUnit.piece) pluralLabel = 'قطع';
        if (this == ProductUnit.bottle) pluralLabel = 'زجاجات';
        if (this == ProductUnit.jar) pluralLabel = 'برطمانات';
        if (this == ProductUnit.sachet) pluralLabel = 'أكياس';
        if (this == ProductUnit.box) pluralLabel = 'علب';
        if (this == ProductUnit.pack) pluralLabel = 'عبوات';
        if (this == ProductUnit.galon) pluralLabel = 'غالونات';

        return [
          QuickSize('1 $unitLabel', 1),
          QuickSize('2 $unitLabel', 2),
          QuickSize('3 $pluralLabel', 3),
          QuickSize('4 $pluralLabel', 4),
          QuickSize('5 $pluralLabel', 5),
          QuickSize('6 $pluralLabel', 6),
          QuickSize('10 $pluralLabel', 10),
          QuickSize('12 $unitLabel', 12),
          QuickSize('24 $unitLabel', 24),
          QuickSize('50 $unitLabel', 50),
          QuickSize('100 $unitLabel', 100),
          QuickSize('200 $unitLabel', 200),
          QuickSize('500 $unitLabel', 500),
        ];
    }
  }
}

/// غلاف بسيط للأحجام السريعة
class QuickSize {
  final String label;
  final double quantity;
  const QuickSize(this.label, this.quantity);
}

/// نموذج السعر حسب الحجم والوحدة
class PriceOption {
  final double quantity; // الكمية (100, 250, 500, 1000)
  final ProductUnit unit; // الوحدة
  final double price; // السعر
  final double? oldPrice; // السعر القديم (للخصم)
  final bool isDefault; // هل هذا الحجم الافتراضي؟

  PriceOption({
    required this.quantity,
    required this.unit,
    required this.price,
    this.oldPrice,
    this.isDefault = false,
  });

  /// اسم الحجم للعرض (مثل: 100 جرام، ربع كيلو)
  String get sizeDisplay {
    // تحويل الأحجام الشائعة لأسماء عربية
    if (unit == ProductUnit.gram || unit == ProductUnit.kg) {
      if (quantity == 250) return 'ربع كيلو';
      if (quantity == 500) return 'نص كيلو';
      if (quantity == 750) return 'ثلاثة أرباع كيلو';
      if (quantity == 1000 || (unit == ProductUnit.kg && quantity == 1))
        return 'كيلو';
    }
    if (unit == ProductUnit.ml || unit == ProductUnit.liter) {
      if (quantity == 1000 || (unit == ProductUnit.liter && quantity == 1))
        return 'لتر';
    }
    return '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} ${unit.nameAr}';
  }

  /// حساب السعر النهائي بعد الخصم
  double get finalPrice =>
      oldPrice != null && oldPrice! > price ? price : price;

  /// حساب نسبة الخصم (نقوم بتصفيره لأنه مأخوذ من المنتج ككل الآن)
  int? get discountPercentage => null;

  /// هل يوجد خصم؟
  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  /// حساب سعر الوحدة (للمقارنة)
  double get pricePerUnit => price / quantity;

  /// نص السعر للعرض
  String get priceDisplay => '${price.toStringAsFixed(0)} ج.م';

  /// نص كامل للعرض
  String get fullDisplay => '$sizeDisplay - $priceDisplay';

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'unit': unit.name,
      'price': price,
      'oldPrice': oldPrice,
      'isDefault': isDefault,
    };
  }

  factory PriceOption.fromJson(Map<String, dynamic> json) {
    return PriceOption(
      quantity: TypeParser.parseDouble(json['quantity']),
      unit: ProductUnit.fromString(json['unit'] ?? 'gram') ?? ProductUnit.gram,
      price: TypeParser.parseDouble(json['price']),
      oldPrice:
          json['oldPrice'] != null ? TypeParser.parseDouble(json['oldPrice']) : null,
      isDefault: TypeParser.parseBool(json['isDefault']),
    );
  }

  PriceOption copyWith({
    double? quantity,
    ProductUnit? unit,
    double? price,
    double? oldPrice,
    bool? isDefault,
  }) {
    return PriceOption(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() => fullDisplay;
}
