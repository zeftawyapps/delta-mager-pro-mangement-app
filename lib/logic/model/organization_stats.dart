import 'package:matger_pro_core_logic/core/orgnization/data/organization_stats.dart';

class OrganizationStatsModel extends OrganizationStats {
  OrganizationStatsModel({
    required super.total,
    required super.active,
    required super.inactive,
    required super.templates,
  });

  factory OrganizationStatsModel.fromData(OrganizationStats data) {
    return OrganizationStatsModel(
      total: data.total,
      active: data.active,
      inactive: data.inactive,
      templates: data.templates,
    );
  }
}
