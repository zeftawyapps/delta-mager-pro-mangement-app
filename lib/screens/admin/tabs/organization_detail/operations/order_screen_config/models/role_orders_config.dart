class RoleOrdersConfig {
  final bool showSenderInfo;
  final bool showRecipientInfo;
  final bool showItems;
  final bool showPrice;
  final bool canEditOrder;
  final bool canCancelOrder;
  final bool canAssignOrder;
  final List<String> allowedSteps;
  final String? selectedWorkflowId;
  final bool filterByPath;
  final List<String> allowedPaths;
  final bool showPathFilterBar;
  final bool filterBySpecificPath;
  final String? specificPathId;
  final bool filterByAssignedUser;
  final bool sortByClosestLocation;
  final bool allowOrderAggregation;
  final List<String> aggregationSteps;

  const RoleOrdersConfig({
    this.showSenderInfo = true,
    this.showRecipientInfo = true,
    this.showItems = true,
    this.showPrice = true,
    this.canEditOrder = false,
    this.canCancelOrder = false,
    this.canAssignOrder = false,
    this.allowedSteps = const [],
    this.selectedWorkflowId,
    this.filterByPath = false,
    this.allowedPaths = const [],
    this.showPathFilterBar = false,
    this.filterBySpecificPath = false,
    this.specificPathId,
    this.filterByAssignedUser = false,
    this.sortByClosestLocation = false,
    this.allowOrderAggregation = false,
    this.aggregationSteps = const [],
  });

  factory RoleOrdersConfig.defaultConfig() => const RoleOrdersConfig();

  factory RoleOrdersConfig.fromMap(Map<String, dynamic> map) {
    bool _parseBool(dynamic val, bool defaultValue) {
      if (val == null) return defaultValue;
      if (val is bool) return val;
      if (val is String) {
        return val.toLowerCase() == 'true';
      }
      return defaultValue;
    }

    return RoleOrdersConfig(
      showSenderInfo: _parseBool(map['showSenderInfo'], true),
      showRecipientInfo: _parseBool(map['showRecipientInfo'], true),
      showItems: _parseBool(map['showItems'], true),
      showPrice: _parseBool(map['showPrice'], true),
      canEditOrder: _parseBool(map['canEditOrder'], false),
      canCancelOrder: _parseBool(map['canCancelOrder'], false),
      canAssignOrder: _parseBool(map['canAssignOrder'], false),
      allowedSteps: map['allowedSteps'] != null
          ? List<String>.from(map['allowedSteps'])
          : [],
      selectedWorkflowId: map['selectedWorkflowId']?.toString(),
      filterByPath: _parseBool(map['filterByPath'], false),
      allowedPaths: map['allowedPaths'] != null
          ? List<String>.from(map['allowedPaths'])
          : [],
      showPathFilterBar: _parseBool(map['showPathFilterBar'], false),
      filterBySpecificPath: _parseBool(map['filterBySpecificPath'], false),
      specificPathId: map['specificPathId']?.toString(),
      filterByAssignedUser: _parseBool(map['filterByAssignedUser'], false),
      sortByClosestLocation: _parseBool(map['sortByClosestLocation'], false),
      allowOrderAggregation: _parseBool(map['allowOrderAggregation'], false),
      aggregationSteps: map['aggregationSteps'] != null
          ? List<String>.from(map['aggregationSteps'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showSenderInfo': showSenderInfo,
      'showRecipientInfo': showRecipientInfo,
      'showItems': showItems,
      'showPrice': showPrice,
      'canEditOrder': canEditOrder,
      'canCancelOrder': canCancelOrder,
      'canAssignOrder': canAssignOrder,
      'allowedSteps': allowedSteps,
      'selectedWorkflowId': selectedWorkflowId,
      'filterByPath': filterByPath,
      'allowedPaths': allowedPaths,
      'showPathFilterBar': showPathFilterBar,
      'filterBySpecificPath': filterBySpecificPath,
      'specificPathId': specificPathId,
      'filterByAssignedUser': filterByAssignedUser,
      'sortByClosestLocation': sortByClosestLocation,
      'allowOrderAggregation': allowOrderAggregation,
      'aggregationSteps': aggregationSteps,
    };
  }

  RoleOrdersConfig copyWith({
    bool? showSenderInfo,
    bool? showRecipientInfo,
    bool? showItems,
    bool? showPrice,
    bool? canEditOrder,
    bool? canCancelOrder,
    bool? canAssignOrder,
    List<String>? allowedSteps,
    String? selectedWorkflowId,
    bool? filterByPath,
    List<String>? allowedPaths,
    bool? showPathFilterBar,
    bool? filterBySpecificPath,
    String? specificPathId,
    bool? filterByAssignedUser,
    bool? sortByClosestLocation,
    bool? allowOrderAggregation,
    List<String>? aggregationSteps,
  }) {
    return RoleOrdersConfig(
      showSenderInfo: showSenderInfo ?? this.showSenderInfo,
      showRecipientInfo: showRecipientInfo ?? this.showRecipientInfo,
      showItems: showItems ?? this.showItems,
      showPrice: showPrice ?? this.showPrice,
      canEditOrder: canEditOrder ?? this.canEditOrder,
      canCancelOrder: canCancelOrder ?? this.canCancelOrder,
      canAssignOrder: canAssignOrder ?? this.canAssignOrder,
      allowedSteps: allowedSteps ?? this.allowedSteps,
      selectedWorkflowId: selectedWorkflowId ?? this.selectedWorkflowId,
      filterByPath: filterByPath ?? this.filterByPath,
      allowedPaths: allowedPaths ?? this.allowedPaths,
      showPathFilterBar: showPathFilterBar ?? this.showPathFilterBar,
      filterBySpecificPath: filterBySpecificPath ?? this.filterBySpecificPath,
      specificPathId: specificPathId ?? this.specificPathId,
      filterByAssignedUser: filterByAssignedUser ?? this.filterByAssignedUser,
      sortByClosestLocation: sortByClosestLocation ?? this.sortByClosestLocation,
      allowOrderAggregation: allowOrderAggregation ?? this.allowOrderAggregation,
      aggregationSteps: aggregationSteps ?? this.aggregationSteps,
    );
  }
}
