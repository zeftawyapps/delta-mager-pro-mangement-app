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
  final bool filterByAssignedUser;

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
    this.filterByAssignedUser = false,
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
      filterByAssignedUser: _parseBool(map['filterByAssignedUser'], false),
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
      'filterByAssignedUser': filterByAssignedUser,
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
    bool? filterByAssignedUser,
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
      filterByAssignedUser: filterByAssignedUser ?? this.filterByAssignedUser,
    );
  }
}
