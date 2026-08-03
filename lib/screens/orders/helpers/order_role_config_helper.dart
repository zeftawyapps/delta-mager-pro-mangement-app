import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';

/// Helper class for managing and parsing order roles, workflow steps, path filtering,
/// and permission rules configured inside organization settings.
class OrderRoleConfigHelper {
  /// Returns the workflow steps visible to the user based on their active roles.
  static List<WorkflowStep> getVisibleSteps({
    required List<WorkflowStep> originalSteps,
    required dynamic orgConfig,
    required List<String> userRoles,
  }) {
    if (orgConfig == null) return originalSteps;
    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) return originalSteps;
    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) return originalSteps;

    final List<String> allowedSteps = [];
    bool hasRoleConfig = false;

    for (final role in userRoles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map) {
          final steps = rConfig['allowedSteps'];
          if (steps is List) {
            allowedSteps.addAll(steps.map((e) => e.toString()));
            hasRoleConfig = true;
          }
        }
      }
    }

    if (!hasRoleConfig) return originalSteps;

    final filtered = originalSteps
        .where((step) => allowedSteps.contains(step.stepKey))
        .toList();

    return filtered.isEmpty ? originalSteps : filtered;
  }

  /// Returns the workflow configs visible to the user based on their active roles.
  static List<WorkflowConfigModel> getVisibleConfigs({
    required List<WorkflowConfigModel> originalConfigs,
    required dynamic orgConfig,
    required List<String> userRoles,
  }) {
    if (orgConfig == null) return originalConfigs;
    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) return originalConfigs;
    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) return originalConfigs;

    String? selectedWorkflowId;
    for (final role in userRoles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map) {
          final wId = rConfig['selectedWorkflowId'];
          if (wId != null && wId.toString().isNotEmpty) {
            selectedWorkflowId = wId.toString();
            break;
          }
        }
      }
    }

    if (selectedWorkflowId == null) return originalConfigs;

    final filtered = originalConfigs
        .where((config) => config.id == selectedWorkflowId)
        .toList();
    return filtered.isEmpty ? originalConfigs : filtered;
  }

  /// Resolves the effective order path ID for filtering orders based on user role settings
  /// and target day schedule (Today or Tomorrow).
  static String? getEffectivePathId({
    required dynamic orgConfig,
    required List<String> userRoles,
    required List<OrderPathModel> allPaths,
    required int selectedDateFilter, // 0 for Today, 1 for Tomorrow
    String? selectedFilterPathId,
    bool enableLog = false,
  }) {
    if (selectedFilterPathId != null) return selectedFilterPathId;
    if (orgConfig == null) return null;

    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) return null;

    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) return null;

    final targetDate = selectedDateFilter == 0
        ? DateTime.now()
        : DateTime.now().add(const Duration(days: 1));
    final targetWeekday = targetDate.weekday; // 1 = Monday, 2 = Tuesday ... 7 = Sunday

    if (enableLog) {
      debugPrint("========== [ORDER_PATH_DAY_FILTER_LOG] ==========");
      debugPrint(
        "📅 Mode: ${selectedDateFilter == 0 ? 'Today (اليوم)' : 'Tomorrow (الغد)'}",
      );
      debugPrint(
        "📅 Target Date: $targetDate | Weekday Number: $targetWeekday (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)",
      );
      debugPrint("📦 Total Paths in Memory: ${allPaths.length}");
    }

    for (final role in userRoles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map) {
          if (rConfig['filterBySpecificPath'] == true ||
              rConfig['filterBySpecificPath'] == 'true') {
            final allowed = rConfig['allowedPaths'];
            if (allowed is List && allowed.isNotEmpty) {
              if (enableLog) debugPrint("🔍 Role '$role' allowedPaths: $allowed");
              if (allPaths.isEmpty) {
                if (enableLog) {
                  debugPrint(
                    "   ⏳ Order paths still loading into memory, returning null temporarily.",
                  );
                }
                return null;
              }
              for (final allowedId in allowed) {
                final pathObj = allPaths.where((p) => p.id == allowedId).firstOrNull;
                if (pathObj != null) {
                  final schedule = pathObj.schedule;
                  if (schedule == null ||
                      schedule.type == 'always' ||
                      schedule.type == 'daily') {
                    if (enableLog) {
                      debugPrint("   ✅ MATCH (Always/Daily)! Path: '${pathObj.name}'");
                    }
                    return pathObj.id;
                  }
                  final days = schedule.values;
                  if (enableLog) {
                    debugPrint(
                      "   Checking Path '${pathObj.name}' ($allowedId) - Work Days: $days against Target Weekday: $targetWeekday",
                    );
                  }
                  if (days.contains(targetWeekday) ||
                      (targetWeekday == 7 && days.contains(0))) {
                    if (enableLog) {
                      debugPrint(
                        "   ✅ MATCH FOUND! Selected Path: '${pathObj.name}' ($allowedId)",
                      );
                      debugPrint("=================================================");
                    }
                    return pathObj.id;
                  }
                } else {
                  if (enableLog) {
                    debugPrint(
                      "   ⚠️ Path ID '$allowedId' is not yet present in loaded allPaths in memory.",
                    );
                  }
                }
              }
              if (enableLog) {
                debugPrint(
                  "   ⚠️ No day match found for weekday $targetWeekday in allowedPaths. Returning 'none' to yield 0 orders.",
                );
                debugPrint("=================================================");
              }
              // Role is restricted to specific path, but NO path matches today's/tomorrow's schedule.
              // Return 'none' so backend queries orderPathId='none' and returns [] (0 orders).
              return 'none';
            }
            final sId = rConfig['specificPathId']?.toString();
            if (sId != null && sId.isNotEmpty) {
              if (enableLog) {
                debugPrint("   ℹ️ Returning specificPathId: $sId");
                debugPrint("=================================================");
              }
              return sId;
            }
            return 'none';
          }
        }
      }
    }
    if (enableLog) {
      debugPrint("=================================================");
    }
    return null;
  }

  /// Checks if the user role requires filtering by a specific path date range.
  static bool isSpecificPathRole({
    required dynamic orgConfig,
    required List<String> userRoles,
  }) {
    if (orgConfig == null) return false;
    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) return false;
    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) return false;

    for (final role in userRoles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map) {
          if (rConfig['filterBySpecificPath'] == true ||
              rConfig['filterBySpecificPath'] == 'true') {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Checks whether nearest location distance sorting is enabled for the user's role.
  static bool canSortByDistance({
    required dynamic orgConfig,
    required List<String> userRoles,
  }) {
    if (orgConfig == null) return false;
    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) return false;
    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) return false;

    for (final role in userRoles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map &&
            (rConfig['sortByClosestLocation'] == true ||
                rConfig['sortByClosestLocation'] == 'true')) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks whether warehouse order aggregation is enabled for the current step and user role.
  static bool canAggregateOrders({
    required dynamic orgConfig,
    required List<String> userRoles,
    required String? currentStepKey,
  }) {
    if (orgConfig == null || currentStepKey == null) return false;
    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) return false;
    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) return false;

    for (final role in userRoles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map) {
          final isAllowed =
              rConfig['allowOrderAggregation'] == true ||
              rConfig['allowOrderAggregation'] == 'true';
          if (isAllowed) {
            final aggSteps = rConfig['aggregationSteps'];
            if (aggSteps is List && aggSteps.isNotEmpty) {
              if (aggSteps.contains(currentStepKey)) {
                return true;
              }
            } else {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  /// Filters order paths to display in the horizontal path bar based on role settings and current step.
  static List<OrderPathModel> getDisplayPaths({
    required WorkflowConfigModel? currentConfig,
    required dynamic orgConfig,
    required List<String> userRoles,
    required List<OrderPathModel> allPaths,
    required int currentStepNumber,
  }) {
    if (currentConfig == null || orgConfig == null) return [];

    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) return [];

    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) return [];

    bool showPathFilterBar = false;
    final List<String> allowedPaths = [];

    for (final role in userRoles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map) {
          if (rConfig['showPathFilterBar'] == true ||
              rConfig['showPathFilterBar'] == 'true') {
            showPathFilterBar = true;
          }
          final paths = rConfig['allowedPaths'];
          if (paths is List) {
            allowedPaths.addAll(paths.map((e) => e.toString()));
          }
        }
      }
    }

    if (!showPathFilterBar) return [];

    final currentWorkflowSlug = currentConfig.workflowSlug;
    final workflowPaths = allPaths
        .where((p) => p.workflowSlug == currentWorkflowSlug)
        .toList();

    return (allowedPaths.isEmpty
            ? workflowPaths
            : workflowPaths.where((p) => allowedPaths.contains(p.id)).toList())
        .where((p) => p.triggerStepNumber == currentStepNumber)
        .toList();
  }

  /// Returns sender and recipient information visibility based on role configuration.
  static ({bool showSender, bool showRecipient}) getSenderRecipientVisibility({
    required dynamic orgConfig,
    required List<String> userRoles,
  }) {
    bool showSender = true;
    bool showRecipient = true;

    if (orgConfig == null) {
      return (showSender: showSender, showRecipient: showRecipient);
    }

    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig != null && ordersConfig is Map) {
      final rolesConfig = ordersConfig['rolesConfig'];
      if (rolesConfig != null && rolesConfig is Map) {
        for (final role in userRoles) {
          if (rolesConfig.containsKey(role)) {
            final rConfig = rolesConfig[role];
            if (rConfig is Map) {
              if (rConfig.containsKey('showSenderInfo')) {
                showSender = rConfig['showSenderInfo'] == true;
              }
              if (rConfig.containsKey('showRecipientInfo')) {
                showRecipient = rConfig['showRecipientInfo'] == true;
              }
            }
          }
        }
      }
    }
    return (showSender: showSender, showRecipient: showRecipient);
  }

  /// Resolves the step color from hex string or fallback palette.
  static Color getStepColor(WorkflowStep step) {
    if (step.stepColor != null &&
        step.stepColor!.isNotEmpty &&
        step.stepColor != '#000000' &&
        step.stepColor != '0x000000') {
      try {
        String hex = step.stepColor!.replaceAll('#', '').replaceAll('0x', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      } catch (_) {}
    }

    final key = step.stepKey.toLowerCase();
    if (key.contains('start') || key.contains('new')) return Colors.blue;
    if (key.contains('processing') || key.contains('prepare')) {
      return Colors.orange;
    }
    if (key.contains('ship') || key.contains('delivery')) {
      return Colors.deepPurple;
    }
    if (key.contains('complete') ||
        key.contains('success') ||
        key.contains('done')) {
      return Colors.green;
    }
    if (key.contains('cancel') || key.contains('reject')) return Colors.red;
    if (key.contains('claim') || key.contains('accept')) return Colors.teal;

    final List<Color> palette = [
      Colors.blue,
      Colors.orange,
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return palette[(step.stepNumber - 1) % palette.length];
  }
}
