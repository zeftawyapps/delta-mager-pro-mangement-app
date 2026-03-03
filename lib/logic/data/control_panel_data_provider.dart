import '../model/category.dart';

class ControlPanelDataProvider {
  static List<CategoryModel> categories = [
    CategoryModel(
      categoryId: '1',
      name: 'إلكترونيات',
      organizationId: 'shop1',
      imageUrl: 'https://via.placeholder.com/150',
      description: 'كل ما يتعلق بالإلكترونيات والتقنية',
    ),
    CategoryModel(
      categoryId: '2',
      name: 'ملابس',
      organizationId: 'shop1',
      imageUrl: 'https://via.placeholder.com/150',
      description: 'أزياء للرجال والنساء والأطفال',
    ),
    CategoryModel(
      categoryId: '3',
      name: 'أدوات منزلية',
      organizationId: 'shop1',
      imageUrl: 'https://via.placeholder.com/150',
      description: 'مستلزمات المنزل والمطبخ',
    ),
  ];

  static int getProductCountInCategory(String categoryId) {
    // This should ideally fetch from a products repository
    // For now returning a dummy value or matching with some logic
    return 0;
  }
}
