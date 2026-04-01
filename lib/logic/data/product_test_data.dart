import '../model/product_model.dart';

class ProductTestData {
  static final sampleProduct = ProductModel(
    productId: 'prod_12345',
    name: LocalizedString({
      'ar': 'علبة عسل سدر فاخر',
      'en': 'Premium Sidr Honey Jar',
    }),
    categoryId: 'honey_category',
    organizationId: 'org_delta',
    price: 450.0,
    oldPrice: 600.0,
    cost: 300.0,
    images: [
      'https://picsum.photos/id/237/600/400',
      'https://picsum.photos/id/238/600/400',
      'https://picsum.photos/id/239/600/400',
    ],
    isActive: true,
    stockQuantity: 150,
    isNew: true,
    isBestSeller: true,
    isAvailable: true,
    discount: 25.0,
    rating: 4.8,
    isJoker: false,
    isSuperJoker: true,
    isOnSale: true,
    additionalData: {
      'description':
          'عسل سدر أصلي مستخلص من أجود أنواع أشجار السدر، يتميز بجودته العالية وطعمه الفريد وفوائده الصحية المتعددة.',
    },
    priceOptions: [
      PriceOption(
        quantity: 500,
        unit: 'جم',
        price: 250.0,
        isDefault: false,
        sizeDisplay: LocalizedString({'ar': 'نصف كيلو', 'en': '500g'}),
      ),
      PriceOption(
        quantity: 1,
        unit: 'كجم',
        price: 450.0,
        isDefault: true,
        sizeDisplay: LocalizedString({'ar': 'عبوة 1 كيلو', 'en': '1 Kg Pack'}),
      ),
      PriceOption(
        quantity: 2,
        unit: 'كجم',
        price: 850.0,
        oldPrice: 900.0,
        isDefault: false,
        sizeDisplay: LocalizedString({
          'ar': 'عبوة توفير 2 كيلو',
          'en': 'Value 2kg Pack',
        }),
      ),
    ],
    createdAt: DateTime.now(),
  );
}
