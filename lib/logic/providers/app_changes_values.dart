import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/offer.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:matger_pro_core_logic/core/auth/data/user_model.dart';

class AppChangesValues extends ChangeNotifier {
  String? laseRoute;

  Users? user;
  UserViewProfileModel? userProfile;
  
  /// حفظ بيانات المستخدم في الكاش المحلي
  Future<void> _saveUserToCache(Users? newUser) async {
    final prefs = await SharedPreferences.getInstance();
    if (newUser != null) {
      final userJson = jsonEncode(newUser.toJson());
      await prefs.setString('cached_user_data', userJson);
    } else {
      await prefs.remove('cached_user_data');
    }
  }

  /// تحميل بيانات المستخدم من الكاش المحلي عند بدء التطبيق
  Future<void> loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user_data');
      if (userJson != null) {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        user = Users.fromUserModel(UserModel.fromJson(userData));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from cache: $e');
    }
  }

  void setUser(Users? newUser) {
    if (user != newUser) {
      user = newUser;
      _saveUserToCache(newUser); // حفظ في الكاش
      notifyListeners();
    }
  }

  void setUserProfile(UserViewProfileModel? profile) {
    if (userProfile != profile) {
      userProfile = profile;
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
        final targetRoute = AppShellConfigs.isAdminMode 
            ? AppRoutes.loginAdmin 
            : AppRoutes.loginWithOrgName(AppRoutes.activeOrgName);
            
        router.goRoute(
          context,
          targetRoute,
          replace: true,
        );
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
