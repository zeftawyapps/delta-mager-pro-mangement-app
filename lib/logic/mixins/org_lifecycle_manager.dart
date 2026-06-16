import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';

mixin OrgLifecycleManager<T extends StatefulWidget> on State<T> {
  AppChangesValues? _lifecycleAppChangesValues;
  StreamSubscription? _lifecycleConfigSubscription;
  VoidCallback? _lifecycleListener;
  String? _lifecycleLastOrgId;

  /// Call this in `initState` to start listening to organization changes.
  /// It automatically triggers `onOrgChanged` when the database organization ID resolves
  /// or changes (e.g. when loaded asynchronously from the local cache on page refresh).
  void initOrgListener({
    required void Function(String orgId) onOrgChanged,
    bool fireImmediately = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AppChangesValues>().user;
      if (user == null) return; // لا تقم بتهيئة المستمع إذا لم يكن هناك مستخدم مسجل دخول

      _lifecycleAppChangesValues = context.read<AppChangesValues>();
      final configBloc = context.read<OrganizationConfigBloc>();

      _lifecycleLastOrgId = organizationId;

      if (fireImmediately) {
        onOrgChanged(_lifecycleLastOrgId!);
      }

      _lifecycleListener = () {
        _checkAndTrigger(onOrgChanged);
      };
      _lifecycleAppChangesValues?.addListener(_lifecycleListener!);

      _lifecycleConfigSubscription = configBloc.stream.listen((_) {
        _checkAndTrigger(onOrgChanged);
      });
    });
  }

  void _checkAndTrigger(void Function(String orgId) onOrgChanged) {
    if (!mounted) return;

    final user = context.read<AppChangesValues>().user;
    if (user == null) return; // تجنب استدعاء تحديثات البيانات إذا تم تسجيل الخروج

    final currentOrgId = organizationId;
    if (_lifecycleLastOrgId != currentOrgId) {
      _lifecycleLastOrgId = currentOrgId;
      onOrgChanged(currentOrgId);
    }
  }

  /// Automatically resolves the database organization ID from the loaded configuration
  /// or falls back to the user's organizationId or default 'shop1'.
  String get organizationId {
    final orgConfig = context.read<OrganizationConfigBloc>().organizationConfig;
    if (orgConfig != null && orgConfig.id.isNotEmpty) {
      return orgConfig.id;
    }

    final routeOrgId = _routeOrganizationId;
    if (routeOrgId != null) return routeOrgId;

    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  String? get _routeOrganizationId {
    try {
      final params = (widget as dynamic).getPrams();
      final orgName = params?['orgName'];
      if (orgName is String && orgName.isNotEmpty && orgName != ':orgName') {
        AppRoutes.activeOrgName = orgName;
        return orgName;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  void dispose() {
    if (_lifecycleListener != null) {
      _lifecycleAppChangesValues?.removeListener(_lifecycleListener!);
    }
    _lifecycleConfigSubscription?.cancel();
    super.dispose();
  }
}
