class AppRoutes {
  static String activeOrgName = 'deltaeNewOrg1';

  static const String splash = '/splash';
  static String loginWithOrgName(String orgName) {
    return '/$orgName/login';
  }

  static String logIn = '/:orgName/login';
  static const String welcome = '/welcom';
  static const String loginAdmin = '/delta/matgerpro/loginAdmin';
  static const String adminOperations = '/delta/matgerpro/adminOperations';
  static const String customAnalyses = '/analyses/custem/:id/new';
  static const String customAnalyses2 = '/analyses/custem2/:id/new';
  static const String analyses = '/analyses';
  static const String settings = '/settings';
  static const String systemSettings = '/system-settings';
  static const String systemManagment = '/system-managment';
  static const String cpCategory = '/category';
  static const String products = '/products';
  static const String offers = '/offers';
  static const String cpOrders = '/orders';
  static const String aboutUsPrivacy = '/about-us-privacy';
  static const String cpBlogs = '/blogs';
  static const String cpUsers = '/users';
  static const String standalone = '/standalone';
  static const String testMasterGrid = '/test-master-grid';
}
