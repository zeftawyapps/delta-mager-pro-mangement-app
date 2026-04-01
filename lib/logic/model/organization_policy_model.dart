import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:matger_core_logic/core/orgnization/data/organization_policy.dart';

// Re-exporting core data structures for application-wide use
export 'package:matger_core_logic/core/orgnization/data/organization_policy.dart'
    show OrganizationPolicy, LogisticsPolicy, ShippingPolicy, SalesRulesPolicy, InvoiceSlice;

class OrganizationPolicyModel extends OrganizationPolicy implements BaseViewDataModel {
  OrganizationPolicyModel({
    required super.id,
    super.logistics,
    super.shipping,
    super.salesRules,
  });

  factory OrganizationPolicyModel.fromData(OrganizationPolicy data) {
    return OrganizationPolicyModel(
      id: data.id,
      logistics: data.logistics,
      shipping: data.shipping,
      salesRules: data.salesRules,
    );
  }

  // The superclass OrganizationPolicy already defines a final `id` property, 
  // so we only implement the setter for BaseViewDataModel compatibility.
  @override
  set id(String? value) {
    // id is final in OrganizationPolicy
  }

  @override
  Map<String, dynamic> get map => toJson();

  @override
  set map(Map<String, dynamic>? value) {
    // read-only map based on toJson()
  }
}
