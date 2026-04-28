import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';

class AppRoutes {
  static String? _internalOrgName;

  // 🌍 بيانات عالمية محفوظة طوال فترة تشغيل التطبيق

  /// 🚀 استخراج اسم المنظمة الفعال مع التعامل مع القيم الافتراضية
  static String get activeOrgName {
    if (_internalOrgName != null &&
        _internalOrgName != "" &&
        _internalOrgName != ":sorgName" &&
        _internalOrgName != ":orgName") {
      return _internalOrgName!;
    }
    return AppShellConfigs.defaultOrgName;
  }

  static set defaultOrgName(String value) {
    AppShellConfigs.defaultOrgName = value;
  }

  static set activeOrgName(String value) {
    _internalOrgName = value;
  }

  static const String splash = '/splash';
  static String loginWithOrgName(String orgName) {
    return '/$orgName/login';
  }

  static String welcomWithOrgName(String orgName) {
    return '/$orgName/welcom';
  }

  static String catigoryWithOrgName(String orgName) {
    return '/$orgName/category';
  }

  static String productsWithOrgName(String orgName) {
    return '/$orgName/products';
  }

  static String offersWithOrgName(String orgName) {
    return '/$orgName/offers';
  }

  static String ordersWithOrgName(String orgName) {
    return '/$orgName/orders';
  }

  static String aboutUsPrivacyWithOrgName(String orgName) {
    return '/$orgName/about-us-privacy';
  }

  static String blogsWithOrgName(String orgName) {
    return '/$orgName/blogs';
  }

  static String usersWithOrgName(String orgName) {
    return '/$orgName/users';
  }

  static String standaloneWithOrgName(String orgName) {
    return '/$orgName/standalone';
  }

  static String testMasterGridWithOrgName(String orgName) {
    return '/$orgName/test-master-grid';
  }

  static String policiesWithOrgName(String orgName) {
    return '/$orgName/policies';
  }

  static String get logIn => "/:orgName/login";
  static String get welcome => "/:orgName/welcom";
  static const String loginAdmin = '/delta/matgerpro/loginAdmin';
  static const String adminOperations = '/delta/matgerpro/adminOperations';
  static const String customAnalyses = '/analyses/custem/:org/new';
  static const String customAnalyses2 = '/analyses/custem2/:id/new';
  static String get analyses => "/:orgName/analyses";
  static String get settings => "/:orgName/settings";
  static String get systemSettings => "/:orgName/system-settings";
  static String get systemManagment => "/:orgName/system-managment";
  static String get cpCategory => "/:orgName/category";
  static String get products => "/:orgName/products";
  static String get offers => "/:orgName/offers";
  static String get cpOrders => "/:orgName/orders";
  static String get aboutUsPrivacy => "/:orgName/about-us-privacy";
  static String get cpBlogs => "/:orgName/blogs";
  static String get cpUsers => "/:orgName/users";
  static String get standalone => "/:orgName/standalone";
  static String get testMasterGrid => "/:orgName/test-master-grid";
  static String get policies => "/:orgName/policies";
}
