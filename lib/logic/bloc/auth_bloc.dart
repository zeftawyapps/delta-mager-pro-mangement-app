import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:bloc/bloc.dart';
import 'package:matger_pro_core_logic/config/paoject_config.dart';
import 'package:matger_pro_core_logic/core/auth/repos/auth_repo.dart';
import 'package:matger_pro_core_logic/core/auth/data/user_model.dart';
import 'package:JoDija_reposatory/utilis/models/remote_base_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:JoDija_tamplites/util/shardeprefrance/shard_check.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'dart:convert';

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
        ProjectAPIHeader.setToken(user.token!);

        // Log user permissions for debugging as requested by user
        debugPrint('👤 User: ${user.name} (${user.username})');
        debugPrint(
          '🔐 Permissions: ${user.permissions?.join(', ') ?? 'No explicit permissions'}',
        );

        // 💾 حفظ لبيانات تسجيل الدخول
        SharedPrefranceChecking().setDataInShardRefrace(
          email: email,
          pass: base64Encode(utf8.encode(password)), // Hashed (Encoded)
          token: user.token!,
        );

        emit(state.copyWith(itemState: DataSourceBaseState.success(user)));
      } catch (e) {
        emit(
          state.copyWith(
            itemState: DataSourceBaseState.failure(
              ErrorStateModel(message: result.message),
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

  Future<RemoteBaseModel<UserModel>> loginOrg({
    required String orgName,
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await authRepo.loginOrg(
      orgName: orgName,
      username: username,
      password: password,
    );

    if (result.status == StatusModel.success && result.data != null) {
      try {
        final user = Users.fromUserModel(result.data!);
        appChangesValues?.setUser(user);
        ProjectAPIHeader.setToken(user.token!);

        // Log user permissions for debugging as requested by user
        debugPrint('👤 User: ${user.name} (${user.username})');
        debugPrint(
          '🔐 Permissions: ${user.permissions?.join(', ') ?? 'No explicit permissions'}',
        );

        // 💾 حفظ لبيانات تسجيل الدخول
        SharedPrefranceChecking().setDataInShardRefrace(
          email: username,
          pass: base64Encode(utf8.encode(password)), // Hashed (Encoded)
          token: user.token!,
        );

        emit(state.copyWith(itemState: DataSourceBaseState.success(user)));
      } catch (e) {
        emit(
          state.copyWith(
            itemState: DataSourceBaseState.failure(
              ErrorStateModel(message: "خطأ في معالجة بيانات المستخدم: $e"),
              () => loginOrg(
                orgName: orgName,
                username: username,
                password: password,
              ),
            ),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "فشل تسجيل الدخول"),
            () => loginOrg(
              orgName: orgName,
              username: username,
              password: password,
            ),
          ),
        ),
      );
    }
    return result;
  }

  // للتوافق مع شاشة تسجيل الدخول الحالية
  Future<RemoteBaseModel<UserModel>> signeIn({
    required Map<String, dynamic> map,
  }) async {
    final email = map['email']?.toString() ?? '';
    final password = map['pass']?.toString() ?? '';

    // If it's an admin login (based on flag or route), use global login
    if (AppShellConfigs.isAdminMode) {
      final res = await authRepo.login(username: email, password: password);
      if (res.status == StatusModel.success && res.data != null) {
        final user = Users.fromUserModel(res.data!);
        appChangesValues?.setUser(user);
        ProjectAPIHeader.setToken(user.token!);

        // 💾 حفظ لبيانات تسجيل الدخول للادمن
        SharedPrefranceChecking().setDataInShardRefrace(
          email: email,
          pass: base64Encode(utf8.encode(password)), // Hashed (Encoded)
          token: user.token!,
        );

        emit(state.copyWith(itemState: DataSourceBaseState.success(user)));
      }
      return res;
    }

    final orgName = map['orgName']?.toString() ?? AppRoutes.activeOrgName;
    return loginOrg(orgName: orgName, username: email, password: password);
  }

  // حالياً مجرد placeholder كما هو متبع في شاشة تسجيل الدخول
  void checkSavedUser({
    required Function(Users user) onUserFound,
    required Function() onUserNotFound,
  }) {
    SharedPrefranceChecking sharedPrefranceChecking = SharedPrefranceChecking();

    sharedPrefranceChecking.IsUserRejised(
      isRegistAction: (shardUserModel) async {
        // المستخدم مسجل - قم بتسجيل الدخول تلقائياً
        if (shardUserModel.email != null && shardUserModel.pass != null) {
          AppRoutes.defaultOrgName = AppRoutes.activeOrgName;

          final result = await signeIn(
            map: {
              "orgName": AppRoutes.activeOrgName,
              "email": shardUserModel.email!,
              "pass": utf8.decode(base64Decode(shardUserModel.pass!)), // Decode
            },
          );

          if (result.status == StatusModel.success && result.data != null) {
            final user = Users.fromUserModel(result.data!);
            onUserFound(user);
          } else {
            onUserNotFound();
          }
        } else {
          onUserNotFound();
        }
      },
      NotRegistAction: () {
        onUserNotFound();
      },
    );
  }

  // إضافة signOut مع مسح البيانات المخزنة وتصفير التوكن
  void signOut() {
    SharedPrefranceChecking().clearDataInShardRefrace();
    ProjectAPIHeader.setToken(''); // تصفير التوكن في الهيدر
    appChangesValues?.setUser(null); // تصفير بيانات المستخدم المشتركة
    emit(FeaturDataSourceState<Users>.defaultState());
  }

  // دالة تغيير كلمة المرور
  Future<void> changePassword({
    required String identifier,
    required String newPassword,
  }) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));

    final result = await authRepo.changePassword(
      identifier: identifier,
      newPassword: newPassword,
    );

    if (result.status == StatusModel.success) {
      emit(state.copyWith(itemState: const DataSourceBaseState.success(null)));
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "فشل تغيير كلمة المرور"),
            () => changePassword(
              identifier: identifier,
              newPassword: newPassword,
            ),
          ),
        ),
      );
    }
  }
}
