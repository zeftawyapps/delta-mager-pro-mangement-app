import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/offer.dart';

class AppChangesValues extends ChangeNotifier {
  String? laseRoute;

  Users? user;
  void setUser(Users? newUser) {
    if (user != newUser) {
      user = newUser;
      notifyListeners();
    }
  }

  static String? getLastRoute(BuildContext context) {
    var changvalue = context.read<AppChangesValues>();
    return changvalue.laseRoute;
  }

  static Widget? checkAuth(BuildContext context, AppShellRouterMixin router) {
    var changvalue = context.read<AppChangesValues>();
    var user = changvalue.user;

    if (user == null) {
      Future.delayed(Duration.zero, () {
        router.goRoute(context, AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return null;
  }

  String? selectedCategoryId;
  void setSelectedCategoryId(String? id) {
    if (selectedCategoryId != id) {
      selectedCategoryId = id;
      notifyListeners();
    }
  }

  String? selectedOrderId;
  void setSelectedOrderId(String? id) {
    if (selectedOrderId != id) {
      selectedOrderId = id;
      notifyListeners();
    }
  }

  void clearLastRoute() {
    laseRoute = null;
    notifyListeners();
  }

  void setLastRoute(String route) {
    if (laseRoute != route) {
      laseRoute = route;
      notifyListeners();
    }
  }

  void setSelectedOfferTargetType(OfferTargetType type, {String? targetId}) {
    if (type == OfferTargetType.category) {
      selectedCategoryId = targetId;
    }
    notifyListeners();
  }

  double? offerDiscount;
  void setOfferDiscount(double? discount) {
    if (offerDiscount != discount) {
      offerDiscount = discount;
      notifyListeners();
    }
  }
}
