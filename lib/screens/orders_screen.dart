import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_shell_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/order_path_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/orders_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_config_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/org_lifecycle_manager.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/helpers/order_role_config_helper.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/assign_staff_sheet.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_filter_toolbar.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_list_container.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_management_sheet.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_path_filter_bar.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/order_step_tab_bar.dart';
import 'package:delta_mager_pro_mangement_app/screens/orders/widgets/workflow_selector.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';

class OrdersScreen extends StatefulWidget with AppShellRouterMixin {
  final bool canAdd;
  OrdersScreen({super.key, this.canAdd = true});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin, SystemManager, OrgLifecycleManager {
  TabController? _stepTabController;
  int _selectedWorkflowIndex = 0;
  int _selectedStepIndex = 0;
  late AppChangesValues appChangesValues;
  String? _selectedFilterPathId;
  bool _sortByDistance = false;
  int _selectedDateFilter = 0; // 0 for Today, 1 for Tomorrow

  @override
  void initState() {
    super.initState();
    appChangesValues = context.read<AppChangesValues>();
    initOrgListener(
      onOrgChanged: (orgId) {
        _loadWorkflows(orgId);
        context.read<OrderPathBloc>().loadOrderPaths(orgId);
        setState(() {});
      },
    );

    final bloc = context.read<WorkflowManagementBloc>();
    bloc.state.listState.maybeWhen(
      success: (configs) {
        if (configs != null && configs.isNotEmpty) {
          final visibleConfigs = OrderRoleConfigHelper.getVisibleConfigs(
            originalConfigs: configs,
            orgConfig: _getOrgConfig(),
            userRoles: _getCurrentRoles(),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _initializeTabController(visibleConfigs);
              if (OrderRoleConfigHelper.canSortByDistance(
                orgConfig: _getOrgConfig(),
                userRoles: _getCurrentRoles(),
              )) {
                setState(() {
                  _sortByDistance = true;
                });
              }
            }
          });
        }
      },
      orElse: () {},
    );
  }

  void _loadWorkflows([String? orgId]) {
    context.read<WorkflowManagementBloc>().loadSpecificConfig(
      orgId ?? organizationId,
      entityType: 'orders',
    );
  }

  List<String> _getCurrentRoles() {
    final user = appChangesValues.user;
    final profile = appChangesValues.userProfile;
    return [...?user?.roles, ...?profile?.roles];
  }

  dynamic _getOrgConfig() {
    return context.read<OrganizationConfigBloc>().state.itemState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );
  }

  WorkflowConfigModel? _getActiveConfig() {
    final wfState = context.read<WorkflowManagementBloc>().state;
    return wfState.listState.maybeWhen(
      success: (configs) {
        if (configs != null && configs.isNotEmpty) {
          final visibleConfigs = OrderRoleConfigHelper.getVisibleConfigs(
            originalConfigs: configs,
            orgConfig: _getOrgConfig(),
            userRoles: _getCurrentRoles(),
          );
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
    final visibleSteps = OrderRoleConfigHelper.getVisibleSteps(
      originalSteps: activeConfig.workflow.steps,
      orgConfig: _getOrgConfig(),
      userRoles: _getCurrentRoles(),
    );
    if (visibleSteps.isEmpty) return 0;

    final currentIndex = _selectedStepIndex < visibleSteps.length
        ? _selectedStepIndex
        : 0;
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

  String _getActiveWorkflowSlug() {
    final activeConfig = _getActiveConfig();
    final slug = activeConfig?.workflowSlug;
    return (slug == null || slug.isEmpty) ? 'default' : slug;
  }

  @override
  void dispose() {
    _stepTabController?.dispose();
    super.dispose();
  }

  void _initializeTabController(
    List<WorkflowConfigModel> configs, {
    int? forcedIndex,
  }) {
    _selectedFilterPathId = null;
    if (configs.isEmpty) return;
    final currentConfig = configs[_selectedWorkflowIndex];
    final originalSteps = currentConfig.workflow.steps;
    final visibleSteps = OrderRoleConfigHelper.getVisibleSteps(
      originalSteps: originalSteps,
      orgConfig: _getOrgConfig(),
      userRoles: _getCurrentRoles(),
    );

    if (visibleSteps.isEmpty) {
      _stepTabController?.dispose();
      _stepTabController = null;
      _selectedStepIndex = 0;
      setState(() {});
      return;
    }

    int targetIndex = forcedIndex ?? _selectedStepIndex;
    if (targetIndex >= visibleSteps.length) {
      targetIndex = 0;
    }
    _selectedStepIndex = targetIndex;

    if (_stepTabController == null ||
        _stepTabController!.length != visibleSteps.length) {
      _stepTabController?.dispose();
      _stepTabController = TabController(
        length: visibleSteps.length,
        vsync: this,
        initialIndex: _selectedStepIndex,
      );

      _stepTabController!.addListener(() {
        if (!_stepTabController!.indexIsChanging) {
          setState(() {
            _selectedStepIndex = _stepTabController!.index;
            _selectedFilterPathId = null;
          });
          _loadOrders(_getActiveWorkflowSlug(), _getActiveAbsoluteStepIndex());
        }
      });
    } else {
      if (forcedIndex != null) {
        _stepTabController!.index = targetIndex;
      }
    }

    if (visibleSteps.isNotEmpty) {
      final selectedVisibleStep = visibleSteps[_selectedStepIndex];
      final absoluteIndex = originalSteps.indexOf(selectedVisibleStep);
      _loadOrders(
        currentConfig.workflowSlug,
        absoluteIndex != -1 ? absoluteIndex : 0,
      );
    }

    setState(() {});
  }

  Future<void> _loadOrders(String slug, int currentStepIndex) async {
    final finalSlug = slug.isEmpty ? 'default' : slug;
    double? latitude;
    double? longitude;
    bool? sortByDistanceParam;

    final roles = _getCurrentRoles();
    final orgConfig = _getOrgConfig();

    final allPaths = context.read<OrderPathBloc>().state.listState.maybeWhen(
      success: (list) => list ?? [],
      orElse: () => <OrderPathModel>[],
    );

    final String? effectiveOrderPathId =
        _selectedFilterPathId ??
        OrderRoleConfigHelper.getEffectivePathId(
          orgConfig: orgConfig,
          userRoles: roles,
          allPaths: allPaths,
          selectedDateFilter: _selectedDateFilter,
          selectedFilterPathId: _selectedFilterPathId,
          enableLog: true,
        );

    final bool shouldSortByDistance = OrderRoleConfigHelper.canSortByDistance(
      orgConfig: orgConfig,
      userRoles: roles,
    );

    if (shouldSortByDistance &&
        _sortByDistance &&
        effectiveOrderPathId != null) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 5),
            );
            latitude = position.latitude;
            longitude = position.longitude;
            sortByDistanceParam = true;
          }
        }
      } catch (e) {
        debugPrint("Error fetching location for closest sorting: $e");
      }
    }

    if (!mounted) return;

    context.read<OrdersBloc>().loadOrders(
      workflowSlug: finalSlug,
      currentStepIndex: currentStepIndex,
      orderPathId: effectiveOrderPathId,
      sortByDistance: sortByDistanceParam,
      latitude: latitude,
      longitude: longitude,
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

  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.order,
      mainPath: widget.getMainPath(),
      widgetCanAdd: widget.canAdd,
    );

    if (sys.authWidget != null) return sys.authWidget!;

    final appBarConfig = sys.appBarConfig;
    final orgConfig = _getOrgConfig();
    final userRoles = _getCurrentRoles();

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
                    final visibleConfigs =
                        OrderRoleConfigHelper.getVisibleConfigs(
                          originalConfigs: configs,
                          orgConfig: orgConfig,
                          userRoles: userRoles,
                        );
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

                  final visibleConfigs =
                      OrderRoleConfigHelper.getVisibleConfigs(
                        originalConfigs: configs,
                        orgConfig: orgConfig,
                        userRoles: userRoles,
                      );
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
                  final visibleSteps = OrderRoleConfigHelper.getVisibleSteps(
                    originalSteps: originalSteps,
                    orgConfig: orgConfig,
                    userRoles: userRoles,
                  );

                  final pathState = context.watch<OrderPathBloc>().state;
                  final allPaths = pathState.listState.maybeWhen(
                    success: (list) => list ?? [],
                    orElse: () => <OrderPathModel>[],
                  );

                  final activeStepIndex = _getActiveAbsoluteStepIndex();
                  final currentStepNumber = _getActiveStepNumber(
                    activeStepIndex,
                  );

                  final displayPaths = OrderRoleConfigHelper.getDisplayPaths(
                    currentConfig: currentConfig,
                    orgConfig: orgConfig,
                    userRoles: userRoles,
                    allPaths: allPaths,
                    currentStepNumber: currentStepNumber,
                  );

                  final showDateFilter =
                      OrderRoleConfigHelper.isSpecificPathRole(
                        orgConfig: orgConfig,
                        userRoles: userRoles,
                      );

                  final showDistanceSort =
                      OrderRoleConfigHelper.canSortByDistance(
                        orgConfig: orgConfig,
                        userRoles: userRoles,
                      );

                  final currentStepKey =
                      visibleSteps.isNotEmpty &&
                          _stepTabController != null &&
                          _stepTabController!.index < visibleSteps.length
                      ? visibleSteps[_stepTabController!.index].stepKey
                      : null;

                  final currentStepName =
                      visibleSteps.isNotEmpty &&
                          _stepTabController != null &&
                          _stepTabController!.index < visibleSteps.length
                      ? visibleSteps[_stepTabController!.index].stepName.ar
                      : '';

                  final showAggregation =
                      OrderRoleConfigHelper.canAggregateOrders(
                        orgConfig: orgConfig,
                        userRoles: userRoles,
                        currentStepKey: currentStepKey,
                      );

                  final ordersBlocState = context.watch<OrdersBloc>().state;
                  final ordersList = ordersBlocState.listState.maybeWhen(
                    success: (list) => list ?? [],
                    orElse: () => <OrderModel>[],
                  );

                  final currentStep =
                      visibleSteps.isNotEmpty &&
                          _stepTabController != null &&
                          _stepTabController!.index < visibleSteps.length
                      ? visibleSteps[_stepTabController!.index]
                      : null;

                  return Column(
                    children: <Widget>[
                      if (visibleConfigs.length > 1)
                        WorkflowSelector(
                          configs: visibleConfigs,
                          selectedWorkflowIndex: _selectedWorkflowIndex,
                          onSelected: (index) {
                            setState(() {
                              _selectedWorkflowIndex = index;
                              _selectedFilterPathId = null;
                              _sortByDistance = false;
                              _initializeTabController(
                                visibleConfigs,
                                forcedIndex: 0,
                              );
                            });
                          },
                        ),
                      const Divider(height: 1),
                      if (_stepTabController != null)
                        OrderStepTabBar(
                          visibleSteps: visibleSteps,
                          selectedIndex: _selectedStepIndex,
                          onStepSelected: (index) {
                            setState(() {
                              _stepTabController?.animateTo(index);
                            });
                          },
                        ),
                      OrderPathFilterBar(
                        displayPaths: displayPaths,
                        selectedPathId: _selectedFilterPathId,
                        onPathSelected: (pathId) {
                          setState(() {
                            _selectedFilterPathId = pathId;
                            _sortByDistance = false;
                            _loadOrders(
                              currentConfig.workflowSlug,
                              _getActiveAbsoluteStepIndex(),
                            );
                          });
                        },
                      ),
                      OrderFilterToolbar(
                        showDateFilter: showDateFilter,
                        showDistanceSort: showDistanceSort,
                        showAggregation: showAggregation,
                        selectedDateFilter: _selectedDateFilter,
                        sortByDistance: _sortByDistance,
                        filteredOrders: ordersList,
                        currentStepName: currentStepName,
                        selectedFilterPathId: _selectedFilterPathId,
                        orgConfig: orgConfig,
                        organizationId: organizationId,
                        onDateFilterChanged: (newFilter) {
                          setState(() {
                            _selectedDateFilter = newFilter;
                            _selectedFilterPathId = null;
                          });
                          _loadOrders(
                            currentConfig.workflowSlug,
                            _getActiveAbsoluteStepIndex(),
                          );
                        },
                        onSortByDistanceChanged: (val) {
                          setState(() {
                            _sortByDistance = val;
                          });
                          _loadOrders(
                            currentConfig.workflowSlug,
                            _getActiveAbsoluteStepIndex(),
                          );
                        },
                      ),
                      Expanded(
                        child: OrderListContainer(
                          currentStep: currentStep,
                          orgConfig: orgConfig,
                          userRoles: userRoles,
                          onManageOrder: (order) =>
                              _showOrderManagementSheet(order, sys),
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
}
