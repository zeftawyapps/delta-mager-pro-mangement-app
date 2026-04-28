import 'package:matger_pro_core_logic/models/localized_string.dart';
import '../model/category.dart';

class ControlPanelDataProvider {
  static List<CategoryModel> categories = [
    CategoryModel(
      id: '1',
      name: LocalizedString.fromJson('إلكترونيات'),
      organizationId: 'shop1',
      imageUrl: 'https://via.placeholder.com/150',
      description: LocalizedString.fromJson('كل ما يتعلق بالإلكترونيات والتقنية'),
    ),
    CategoryModel(
      id: '2',
      name: LocalizedString.fromJson('ملابس'),
      organizationId: 'shop1',
      imageUrl: 'https://via.placeholder.com/150',
      description: LocalizedString.fromJson('أزياء للرجال والنساء والأطفال'),
    ),
    CategoryModel(
      id: '3',
      name: LocalizedString.fromJson('أدوات منزلية'),
      organizationId: 'shop1',
      imageUrl: 'https://via.placeholder.com/150',
      description: LocalizedString.fromJson('مستلزمات المنزل والمطبخ'),
    ),
  ];

  static int getProductCountInCategory(String categoryId) {
    // This should ideally fetch from a products repository
    // For now returning a dummy value or matching with some logic
    return 0;
  }
}
