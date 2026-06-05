import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/orders_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/routes.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/list_view_model.dart';

// Extracted Widgets
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/workflow_selector.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_item_card.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_management_sheet.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/assign_staff_sheet.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/order_path_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';

class OrdersScreen extends StatefulWidget with AppShellRouterMixin {
  final bool canAdd;
  OrdersScreen({super.key, this.canAdd = true});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin, SystemManager {
  TabController? _stepTabController;
  int _selectedWorkflowIndex = 0;
  late AppChangesValues appChangesValues;

  String get organizationId {
    final params = widget.getPrams();
    final orgName = params?['orgName'];
    if (orgName != null && orgName != "" && orgName != ":orgName") {
      AppRoutes.activeOrgName = orgName;
      return orgName;
    }
    final user = appChangesValues.user;
    return user?.organizationId ?? 'shop1';
  }

  @override
  void initState() {
    super.initState();
    appChangesValues = context.read<AppChangesValues>();
    _loadWorkflows();
    context.read<OrderPathBloc>().loadOrderPaths(organizationId);
  }

  void _loadWorkflows() {
    context.read<WorkflowManagementBloc>().loadSpecificConfig(
      organizationId,
      entityType: 'orders',
    );
  }

  List<WorkflowStep> _getVisibleSteps(List<WorkflowStep> originalSteps, String workflowSlug) {
    final user = appChangesValues.user;
    final roles = user?.roles ?? [];

    final isExempt = AppShellConfigs.isAdminMode ||
        roles.contains('admin') ||
        roles.contains('organizationOwner') ||
        roles.contains('owner') ||
        roles.contains('super_admin');

    if (isExempt) {
      return originalSteps;
    }

    final orgConfig = context.read<OrganizationConfigBloc>().state.itemState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );

    if (orgConfig == null) {
      return originalSteps;
    }

    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) {
      return originalSteps;
    }

    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) {
      return originalSteps;
    }

    List<String> allowedSteps = [];
    bool hasRoleConfig = false;

    for (final role in roles) {
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

    if (!hasRoleConfig) {
      return originalSteps;
    }

    final filtered = originalSteps.where((step) => allowedSteps.contains(step.stepKey)).toList();
    
    if (filtered.isEmpty) {
      return originalSteps;
    }

    return filtered;
  }

  List<WorkflowConfigModel> _getVisibleConfigs(List<WorkflowConfigModel> originalConfigs) {
    final user = appChangesValues.user;
    final roles = user?.roles ?? [];

    final isExempt = AppShellConfigs.isAdminMode ||
        roles.contains('admin') ||
        roles.contains('organizationOwner') ||
        roles.contains('owner') ||
        roles.contains('super_admin');

    if (isExempt) {
      return originalConfigs;
    }

    final orgConfig = context.read<OrganizationConfigBloc>().state.itemState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );

    if (orgConfig == null) {
      return originalConfigs;
    }

    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) {
      return originalConfigs;
    }

    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) {
      return originalConfigs;
    }

    String? selectedWorkflowId;
    for (final role in roles) {
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

    if (selectedWorkflowId == null) {
      return originalConfigs;
    }

    final filtered = originalConfigs.where((config) => config.id == selectedWorkflowId).toList();
    if (filtered.isEmpty) {
      return originalConfigs;
    }

    return filtered;
  }

  WorkflowConfigModel? _getActiveConfig() {
    final wfState = context.read<WorkflowManagementBloc>().state;
    return wfState.listState.maybeWhen(
      success: (configs) {
        if (configs != null && configs.isNotEmpty) {
          final visibleConfigs = _getVisibleConfigs(configs);
          if (_selectedWorkflowIndex < visibleConfigs.length) {
            return visibleConfigs[_selectedWorkflowIndex];
          }
        }
        return null;
      },
      orElse: () => null,
    );
  }

  int _getActiveAbsoluteStepIndex() {
    final activeConfig = _getActiveConfig();
    if (activeConfig == null) return 0;
    final visibleSteps = _getVisibleSteps(activeConfig.workflow.steps, activeConfig.workflowSlug);
    if (_stepTabController == null || visibleSteps.isEmpty) return 0;
    
    final currentIndex = _stepTabController!.index;
    if (currentIndex >= visibleSteps.length) return 0;
    
    final selectedVisibleStep = visibleSteps[currentIndex];
    final originalSteps = activeConfig.workflow.steps;
    final absoluteIndex = originalSteps.indexOf(selectedVisibleStep);
    return absoluteIndex != -1 ? absoluteIndex : 0;
  }

  int _getActiveStepNumber(int absoluteStepIndex) {
    final activeConfig = _getActiveConfig();
    if (activeConfig == null) return absoluteStepIndex + 1;
    final steps = activeConfig.workflow.steps;
    if (absoluteStepIndex < steps.length) {
      return steps[absoluteStepIndex].stepNumber;
    }
    return absoluteStepIndex + 1;
  }

  List<OrderModel> _filterOrdersByPath(List<OrderModel> originalOrders, int absoluteStepIndex) {
    final user = appChangesValues.user;
    final roles = user?.roles ?? [];

    final isExempt = AppShellConfigs.isAdminMode ||
        roles.contains('admin') ||
        roles.contains('organizationOwner') ||
        roles.contains('owner') ||
        roles.contains('super_admin');

    if (isExempt) {
      return originalOrders;
    }

    final orgConfig = context.read<OrganizationConfigBloc>().state.itemState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );

    if (orgConfig == null) {
      return originalOrders;
    }

    final ordersConfig = orgConfig.ordersConfig;
    if (ordersConfig == null || ordersConfig is! Map) {
      return originalOrders;
    }

    final rolesConfig = ordersConfig['rolesConfig'];
    if (rolesConfig == null || rolesConfig is! Map) {
      return originalOrders;
    }

    bool filterByPath = false;
    List<String> allowedPaths = [];

    for (final role in roles) {
      if (rolesConfig.containsKey(role)) {
        final rConfig = rolesConfig[role];
        if (rConfig is Map) {
          final isFilterEnabled = rConfig['filterByPath'] == true || rConfig['filterByPath'] == 'true';
          if (isFilterEnabled) {
            filterByPath = true;
            final paths = rConfig['allowedPaths'];
            if (paths is List) {
              allowedPaths.addAll(paths.map((e) => e.toString()));
            }
          }
        }
      }
    }

    if (!filterByPath) {
      return originalOrders;
    }

    final pathState = context.read<OrderPathBloc>().state;
    final allPaths = pathState.listState.maybeWhen(
      success: (list) => list ?? [],
      orElse: () => <OrderPathModel>[],
    );

    return originalOrders.where((order) {
      final orderPathId = order.externalReferences['orderPathId']?.toString();
      if (orderPathId == null || orderPathId.isEmpty) {
        return true;
      }

      final pathObj = allPaths.where((p) => p.id == orderPathId).firstOrNull;
      if (pathObj == null) {
        return true;
      }

      final currentStepNumber = _getActiveStepNumber(absoluteStepIndex);
      if (pathObj.triggerStepNumber == currentStepNumber) {
        return allowedPaths.contains(orderPathId);
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _stepTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.order,
      mainPath: widget.getMainPath(),
      widgetCanAdd: widget.canAdd,
    );

    if (sys.authWidget != null) return sys.authWidget!;

    // ignore: unused_local_variable
    final canAdd = sys.canAdd;
    // ignore: unused_local_variable
    final canUpdate = sys.canUpdate;
    // ignore: unused_local_variable
    final canDelete = sys.canDelete;
    // ignore: unused_local_variable
    final featureConfig = sys.featureConfig;
    final isDark = sys.isDark;
    final appBarConfig = sys.appBarConfig;

    return Scaffold(
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: 'إدارة الطلبات',
        isDesplayTitle: true,
      ),
      body:
          BlocConsumer<
            WorkflowManagementBloc,
            FeaturDataSourceState<WorkflowConfigModel>
          >(
            listener: (context, state) {
              state.listState.maybeWhen(
                success: (configs) {
                  if (configs != null && configs.isNotEmpty) {
                    final visibleConfigs = _getVisibleConfigs(configs);
                    _initializeTabController(visibleConfigs);
                  }
                },
                orElse: () {},
              );

              state.itemState.maybeWhen(
                failure: (error, _) {
                  _showErrorDialog(context, error.message ?? 'حدث خطأ');
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.listState.when(
                init: () => const SizedBox(),
                loading: () => const Center(child: CircularProgressIndicator()),
                success: (configs) {
                  if (configs == null || configs.isEmpty) {
                    return const Center(
                      child: Text("لا توجد مسارات عمل معرفة لهذه المنظمة"),
                    );
                  }

                  final visibleConfigs = _getVisibleConfigs(configs);
                  if (visibleConfigs.isEmpty) {
                    return const Center(
                      child: Text("لا توجد مسارات عمل متاحة لهذا المستخدم"),
                    );
                  }

                  if (_selectedWorkflowIndex >= visibleConfigs.length) {
                    _selectedWorkflowIndex = 0;
                  }

                  final currentConfig = visibleConfigs[_selectedWorkflowIndex];
                  final originalSteps = currentConfig.workflow.steps;
                  final visibleSteps = _getVisibleSteps(originalSteps, currentConfig.workflowSlug);

                  return Column(
                    children: <Widget>[
                      if (visibleConfigs.length > 1)
                        WorkflowSelector(
                          configs: visibleConfigs,
                          selectedWorkflowIndex: _selectedWorkflowIndex,
                          onSelected: (index) {
                            setState(() {
                              _selectedWorkflowIndex = index;
                              _initializeTabController(visibleConfigs, forcedIndex: 0);
                            });
                          },
                        ),

                      const Divider(height: 1),

                      if (_stepTabController != null)
                        Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: visibleSteps.length,
                            itemBuilder: (context, index) {
                              final s = visibleSteps[index];
                              final isSelected =
                                  _stepTabController?.index == index;
                              final stepColor = _getStepColor(s);

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                margin: const EdgeInsets.only(
                                  left: 10,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _stepTabController?.animateTo(index);
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: isSelected
                                          ? stepColor
                                          : stepColor.withOpacity(0.08),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : stepColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: stepColor.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        if (isSelected)
                                          const SizedBox(width: 8),
                                        Text(
                                          s.stepName.ar,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : stepColor,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      Expanded(
                        child:
                            BlocBuilder<
                              OrdersBloc,
                              FeaturDataSourceState<OrderModel>
                            >(
                              builder: (context, orderState) {
                                return orderState.listState.maybeWhen(
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  success: (orders) {
                                    final currentAbsoluteStepIndex = _getActiveAbsoluteStepIndex();
                                    final filteredOrders = _filterOrdersByPath(orders ?? [], currentAbsoluteStepIndex);

                                    if (filteredOrders.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            const Icon(
                                              Icons.shopping_basket_outlined,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "لا توجد طلبات في مرحلة ${visibleSteps[_stepTabController?.index ?? 0].stepName.ar}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return ListViewModel<OrderModel>(
                                      data: filteredOrders,
                                      listItem: (index, order) {
                                        final stepColor = _getStepColor(
                                          visibleSteps[_stepTabController?.index ?? 0],
                                        );

                                        return OrderItemCard(
                                          order: order,
                                          stepColor: stepColor,
                                          onManageOrder: () =>
                                              _showOrderManagementSheet(
                                                order,
                                                sys,
                                              ),
                                        );
                                      },
                                    );
                                  },
                                  failure: (error, reload) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          error.message ??
                                              "حدث خطأ أثناء جلب الطلبات",
                                        ),
                                        TextButton(
                                          onPressed: reload,
                                          child: const Text("إعادة المحاولة"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  orElse: () => const SizedBox(),
                                );
                              },
                            ),
                      ),
                    ],
                  );
                },
                failure: (error, reload) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        error.message ??
                            "حدث خطأ أثناء تحميل إعدادات سير العمل",
                      ),
                      ElevatedButton(
                        onPressed: reload,
                        child: const Text("إعادة المحاولة"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showOrderManagementSheet(OrderModel order, SystemConfig sys) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return OrderManagementSheet(
          order: order,
          sys: sys,
          appChangesValues: appChangesValues,
          onActionCompleted: () {
            _loadOrders(
              _getActiveWorkflowSlug(),
              _getActiveAbsoluteStepIndex(),
            );
          },
          onAssignClicked: () {
            Navigator.pop(sheetContext);
            final currentStepIndex = order.workFlow?.currentStepIndex ?? 0;
            _showAssignSheet(order, currentStepIndex);
          },
        );
      },
    );
  }

  void _showAssignSheet(OrderModel order, int currentStepIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return AssignStaffSheet(
          order: order,
          currentStepIndex: currentStepIndex,
          organizationId: organizationId,
          onAssigned: () {
            _loadOrders(
              _getActiveWorkflowSlug(),
              _getActiveAbsoluteStepIndex(),
            );
          },
        );
      },
    );
  }

  String _getActiveWorkflowSlug() {
    final activeConfig = _getActiveConfig();
    return activeConfig?.workflowSlug ?? '';
  }

  void _initializeTabController(
    List<WorkflowConfigModel> configs, {
    int? forcedIndex,
  }) {
    if (configs.isEmpty) return;
    final currentConfig = configs[_selectedWorkflowIndex];
    final originalSteps = currentConfig.workflow.steps;
    final visibleSteps = _getVisibleSteps(originalSteps, currentConfig.workflowSlug);

    int targetIndex = forcedIndex ?? (_stepTabController?.index ?? 0);

    if (targetIndex >= visibleSteps.length) {
      targetIndex = 0;
    }

    if (_stepTabController == null ||
        _stepTabController!.length != visibleSteps.length) {
      _stepTabController?.dispose();
      _stepTabController = TabController(
        length: visibleSteps.length,
        vsync: this,
        initialIndex: targetIndex,
      );

      _stepTabController!.addListener(() {
        if (!_stepTabController!.indexIsChanging) {
          final selectedVisibleStep = visibleSteps[_stepTabController!.index];
          final absoluteIndex = originalSteps.indexOf(selectedVisibleStep);
          _loadOrders(
            currentConfig.workflowSlug,
            absoluteIndex != -1 ? absoluteIndex : 0,
          );
        }
      });
    } else {
      if (forcedIndex != null) {
        _stepTabController!.index = targetIndex;
      }
    }

    if (visibleSteps.isNotEmpty) {
      final selectedVisibleStep = visibleSteps[_stepTabController!.index];
      final absoluteIndex = originalSteps.indexOf(selectedVisibleStep);
      _loadOrders(
        currentConfig.workflowSlug,
        absoluteIndex != -1 ? absoluteIndex : 0,
      );
    }

    setState(() {});
  }

  void _loadOrders(String slug, int currentStepIndex) {
    context.read<OrdersBloc>().loadOrders(
      workflowSlug: slug,
      currentStepIndex: currentStepIndex,
    );
  }

  Color _getStepColor(WorkflowStep step) {
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
    if (key.contains('processing') || key.contains('prepare'))
      return Colors.orange;
    if (key.contains('ship') || key.contains('delivery'))
      return Colors.deepPurple;
    if (key.contains('complete') ||
        key.contains('success') ||
        key.contains('done'))
      return Colors.green;
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تنبيه! خطأ في التنفيذ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'فهمت',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
