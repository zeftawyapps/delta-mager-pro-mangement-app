import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_core_logic/config/paoject_config.dart';
import 'package:matger_core_logic/core/auth/repos/auth_repo.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';

class AuthBloc extends Cubit<FeaturDataSourceState<Users>> {
  final AuthRepo authRepo;
  final AppChangesValues? appChangesValues;

  AuthBloc({required this.authRepo, this.appChangesValues})
    : super(FeaturDataSourceState<Users>.defaultState());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await authRepo.login(username: email, password: password);

    if (result.status == StatusModel.success && result.data != null) {
      try {
        final user = Users.fromUserModel(result.data!);
        appChangesValues?.setUser(user);
        ProjectAPIHeader.setHeader(user.token!);
        emit(state.copyWith(itemState: DataSourceBaseState.success(user)));
      } catch (e) {
        emit(
          state.copyWith(
            itemState: DataSourceBaseState.failure(
              ErrorStateModel(message: "خطأ في معالجة بيانات المستخدم: $e"),
              () => login(email: email, password: password),
            ),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "فشل تسجيل الدخول"),
            () => login(email: email, password: password),
          ),
        ),
      );
    }
  }

  // للتوافق مع شاشة تسجيل الدخول الحالية
  Future<void> signeIn({required Map<String, dynamic> map}) async {
    final email = map['email']?.toString() ?? '';
    final password = map['pass']?.toString() ?? '';
    return login(email: email, password: password);
  }

  // حالياً مجرد placeholder كما هو متبع في شاشة تسجيل الدخول
  void checkSavedUser({
    required Function(Users) onUserFound,
    required VoidCallback onUserNotFound,
  }) {
    // يمكن إضافة منطق التحقق من التوكن المحفوظ لاحقاً
    onUserNotFound();
  }

  // إضافة signOut
  void signOut() {
    emit(FeaturDataSourceState<Users>.defaultState());
  }
}
