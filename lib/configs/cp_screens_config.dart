import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';

class CPScreensConfig {
  static List<RouteItem> getAvailableRoutes(
    Users user, {
    List<RouteItem> routes = const [],
  }) {
    if (AppShellConfigs.isClientAppMode) {
      for (var route in routes) {
        route.isVisableInSideBar = true;
      }
      return routes;
    }

    for (var route in routes) {
      // ✅ التركيبة الديناميكية: screen.sidebarId:view
      final String permissionKey = "screen.${route.id}:view";

      // ✅ فحص الصلاحية: هل يملك المستخدم هذه الصلاحية المحددة أو هو Super Admin (*:*)
      final bool hasAccess =
          (user.permissions?.contains(permissionKey) ?? false) ||
          (user.permissions?.contains('*:*') ?? false);

      // ✅ تعديل الظهور في القائمة الجانبية
      route.isVisableInSideBar = hasAccess;

      // ✅ تأكيد أن الشاشات غير المفاعلة لا يمكن الوصول لمسارها (اختياري للأمان الإضافي)
      if (!hasAccess && route.isSideBarRouted != false) {
        route.isVisableInSideBar = false;
      }
    }

    return routes;
  }
}
