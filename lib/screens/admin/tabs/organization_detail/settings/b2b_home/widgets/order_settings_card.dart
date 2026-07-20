import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/configs/b2b_home_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/roles_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/role.dart';

class OrderSettingsCard extends StatefulWidget {
  final Map<String, dynamic> orderSettings;
  final bool isEditing;
  final bool isDark;
  final Color primaryColor;
  final String organizationId;
  final void Function(Map<String, dynamic>) onSettingsChanged;

  const OrderSettingsCard({
    super.key,
    required this.orderSettings,
    required this.isEditing,
    required this.isDark,
    required this.primaryColor,
    required this.organizationId,
    required this.onSettingsChanged,
  });

  @override
  State<OrderSettingsCard> createState() => _OrderSettingsCardState();
}

class _OrderSettingsCardState extends State<OrderSettingsCard> {
  // ────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // تحميل الأدوار لعرضها في قائمة اختيار الأدوار المسموح بالترقية إليها
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolesBloc>().loadRoles(
        organizationId: widget.organizationId,
      );
    });
  }

  // ────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────

  Widget _buildDropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: options.containsKey(value) ? value : options.keys.first,
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: widget.isEditing ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: widget.isEditing ? AppColors.primary : Colors.grey,
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isEditing
                ? AppColors.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        isDense: true,
      ),
    );
  }

  // ────────────────────────────────────────────
  // Build: Allowed Upgrade Roles section
  // يجلب الأدوار من RolesBloc ويعرض فقط isCustomerRole == true
  // ────────────────────────────────────────────
  Widget _buildAllowedUpgradeRoles() {
    return BlocBuilder<RolesBloc, FeaturDataSourceState<RoleModel>>(
      builder: (context, state) {
        // الأدوار المحفوظة الآن List<Map> تحتوي key + displayName + description
        // للتوافق مع الإصدارات القديمة (كانت List<String>) نتعامل مع الحالتين
        final rawList = widget.orderSettings['allowedUpgradeRoles'];
        final Set<String> selectedKeys = rawList is List
            ? Set<String>.from(
                rawList.map((e) => e is Map ? e['key']?.toString() : e.toString()),
              )
            : <String>{};

        final isLoading = state.listState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final customerRoles = state.listState.maybeWhen(
          success: (roles) => (roles ?? [])
              .where((r) => r.isCustomerRole == true && r.name != null)
              .toList(),
          orElse: () => <RoleModel>[],
        );

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (customerRoles.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'لا توجد أدوار زبائن (isCustomerRole) مُفعَّلة. فعِّل الخيار من صفحة الصلاحيات لتظهر هنا.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          );
        }

        /// يحفظ الأدوار المختارة كـ List<Map> بحيث يحتوي كل عنصر على:
        /// { "key": role.name, "displayName": ..., "description": ... }
        void toggle(RoleModel role) {
          final key = role.name!;
          final newKeys = Set<String>.from(selectedKeys);

          if (newKeys.contains(key)) {
            newKeys.remove(key);
          } else {
            newKeys.add(key);
          }

          // نبني قائمة الأدوار المختارة كاملة من الـ customerRoles الحالية
          final selectedRolesMaps = customerRoles
              .where((r) => newKeys.contains(r.name))
              .map((r) => {
                    'key': r.name!,
                    'displayName': r.displayName?.isNotEmpty == true
                        ? r.displayName!
                        : r.name!,
                    'description': r.description ?? '',
                  })
              .toList();

          final newSettings = Map<String, dynamic>.from(widget.orderSettings);
          newSettings['allowedUpgradeRoles'] = selectedRolesMaps;
          widget.onSettingsChanged(newSettings);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: customerRoles.map((role) {
            final roleName = role.name!;
            final displayName = (role.displayName?.isNotEmpty == true)
                ? role.displayName!
                : roleName;
            final description = role.description;
            final isChecked = selectedKeys.contains(roleName);

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: widget.isEditing ? () => toggle(role) : null,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isChecked
                        ? widget.primaryColor.withOpacity(0.08)
                        : (widget.isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.withOpacity(0.04)),
                    border: Border.all(
                      color: isChecked
                          ? widget.primaryColor.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.2),
                      width: isChecked ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: widget.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onChanged:
                            widget.isEditing ? (_) => toggle(role) : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // الاسم + الـ key badge
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isChecked
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isChecked
                                          ? widget.primaryColor
                                          : (widget.isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? widget.primaryColor.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isChecked
                                          ? widget.primaryColor.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    roleName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isChecked
                                          ? widget.primaryColor
                                          : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // الوصف
                            if (description != null && description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isChecked)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.check_circle_rounded,
                              color: widget.primaryColor, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAllowedPriceSelectorRoles() {
    return BlocBuilder<RolesBloc, FeaturDataSourceState<RoleModel>>(
      builder: (context, state) {
        final rawList = widget.orderSettings['allowedPriceSelectorRoles'];
        final Set<String> selectedKeys = rawList is List
            ? Set<String>.from(
                rawList.map((e) => e is Map ? e['key']?.toString() : e.toString()),
              )
            : <String>{};

        final isLoading = state.listState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final customerRoles = state.listState.maybeWhen(
          success: (roles) => (roles ?? [])
              .where((r) => r.isCustomerRole == true && r.name != null)
              .toList(),
          orElse: () => <RoleModel>[],
        );

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (customerRoles.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'لا توجد أدوار زبائن (isCustomerRole) مُفعَّلة. فعِّل الخيار من صفحة الصلاحيات لتظهر هنا.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          );
        }

        void toggle(RoleModel role) {
          final key = role.name!;
          final newKeys = Set<String>.from(selectedKeys);

          if (newKeys.contains(key)) {
            newKeys.remove(key);
          } else {
            newKeys.add(key);
          }

          final selectedRolesMaps = customerRoles
              .where((r) => newKeys.contains(r.name))
              .map((r) => {
                    'key': r.name!,
                    'displayName': r.displayName?.isNotEmpty == true
                        ? r.displayName!
                        : r.name!,
                    'description': r.description ?? '',
                  })
              .toList();

          final newSettings = Map<String, dynamic>.from(widget.orderSettings);
          newSettings['allowedPriceSelectorRoles'] = selectedRolesMaps;
          widget.onSettingsChanged(newSettings);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: customerRoles.map((role) {
            final roleName = role.name!;
            final displayName = (role.displayName?.isNotEmpty == true)
                ? role.displayName!
                : roleName;
            final description = role.description;
            final isChecked = selectedKeys.contains(roleName);

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: widget.isEditing ? () => toggle(role) : null,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isChecked
                        ? widget.primaryColor.withOpacity(0.08)
                        : (widget.isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.withOpacity(0.04)),
                    border: Border.all(
                      color: isChecked
                          ? widget.primaryColor.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.2),
                      width: isChecked ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: widget.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onChanged:
                            widget.isEditing ? (_) => toggle(role) : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isChecked
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isChecked
                                          ? widget.primaryColor
                                          : (widget.isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? widget.primaryColor.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isChecked
                                          ? widget.primaryColor.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    roleName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isChecked
                                          ? widget.primaryColor
                                          : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (description != null && description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isChecked)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.check_circle_rounded,
                              color: widget.primaryColor, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final allowRoleUpgrade = widget.orderSettings['allowRoleUpgrade'] != false;
    final restrictPriceSelector = widget.orderSettings['restrictPriceSelector'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.primaryColor.withOpacity(0.2), width: 1),
      ),
      elevation: 0,
      color: widget.primaryColor.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_applications,
                      color: widget.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "إعدادات الطلبات الافتراضية",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (widget.isEditing)
                  const Chip(
                    label: Text(
                      "وضع التعديل",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Order Mode dropdown ──────────────────
            _buildDropdown(
              "نمط الطلب (Order Mode)",
              widget.orderSettings[B2bHomeConfig.keyOrderMode] ?? "B2B",
              {
                "B2B": "B2B (Business to Business)",
                "C2B": "C2B (Customer to Business)",
              },
              (val) {
                final newSettings = Map<String, dynamic>.from(
                  widget.orderSettings,
                );
                newSettings[B2bHomeConfig.keyOrderMode] = val;
                widget.onSettingsChanged(newSettings);
              },
            ),
            const SizedBox(height: 16),

            // ── Workflow dropdown ────────────────────
            BlocBuilder<
              WorkflowManagementBloc,
              FeaturDataSourceState<WorkflowConfigModel>
            >(
              buildWhen: (prev, next) => prev.listState != next.listState,
              builder: (context, state) {
                final workflows = state.listState.maybeWhen(
                  success: (data) => data ?? [],
                  orElse: () => [],
                );

                final Map<String, String> workflowOptions = {
                  "": "بدون سير عمل (Default)",
                };
                for (var wf in workflows) {
                  workflowOptions[wf.workflowSlug] = wf.workflowSlug;
                }

                return _buildDropdown(
                  "سير العمل (Workflow)",
                  widget.orderSettings[B2bHomeConfig.keyWorkflowSlug] ?? "",
                  workflowOptions,
                  (val) {
                    final newSettings = Map<String, dynamic>.from(
                      widget.orderSettings,
                    );
                    newSettings[B2bHomeConfig.keyWorkflowSlug] = val;
                    widget.onSettingsChanged(newSettings);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // ── Calculation Mode dropdown ────────────
            _buildDropdown(
              "طريقة حساب السعر (Calculation Mode)",
              (widget.orderSettings[B2bHomeConfig.keyCalculationMode] ?? 2)
                  .toString(),
              {
                "0": "يدوي (Manual) - قبول السعر كما هو",
                "1": "تصحيح (Auto-correction) - تعديل آلي في حال الخطأ",
                "2": "تحقق صارم (Strict Validation) - رفض في حال الخطأ",
              },
              (val) {
                final newSettings = Map<String, dynamic>.from(
                  widget.orderSettings,
                );
                newSettings[B2bHomeConfig.keyCalculationMode] =
                    int.tryParse(val!) ?? 2;
                widget.onSettingsChanged(newSettings);
              },
            ),
            const SizedBox(height: 16),

            // ── Allow Default Workflow switch ────────
            SwitchListTile(
              title: const Text(
                "السماح بسير العمل الافتراضي (Allow Default Workflow)",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                "تفعيل هذا الخيار يسمح للنظام باستخدام سير العمل التلقائي في حال عدم توفر المخصص",
                style: TextStyle(fontSize: 12),
              ),
              value:
                  widget.orderSettings[B2bHomeConfig.keyAllowDefaultWorkflow] ??
                  true,
              onChanged: widget.isEditing
                  ? (val) {
                      final newSettings = Map<String, dynamic>.from(
                        widget.orderSettings,
                      );
                      newSettings[B2bHomeConfig.keyAllowDefaultWorkflow] = val;
                      widget.onSettingsChanged(newSettings);
                    }
                  : null,
              activeColor: widget.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // ── Allow Role Upgrade switch ────────────
            SwitchListTile(
              title: const Text(
                "تمكين طلب ترقية حسابات الزبائن (Enable Customer Role Upgrade)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "يسمح لزبائن التجزئة بتقديم طلب ترقية الحساب للأدوار المتاحة من ملفهم الشخصي",
                style: TextStyle(fontSize: 12),
              ),
              value: widget.orderSettings['allowRoleUpgrade'] ?? false,
              onChanged: widget.isEditing
                  ? (val) {
                      final newSettings = Map<String, dynamic>.from(
                        widget.orderSettings,
                      );
                      newSettings['allowRoleUpgrade'] = val;
                      // إذا أُغلقت الميزة امسح الأدوار المختارة أيضاً
                      if (!val) {
                        newSettings['allowedUpgradeRoles'] = [];
                      }
                      widget.onSettingsChanged(newSettings);
                    }
                  : null,
              activeColor: widget.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),

            // ── Allowed Upgrade Roles (مرئي فقط لما allowRoleUpgrade = true)
            if (allowRoleUpgrade) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.manage_accounts,
                          color: widget.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "الأدوار المسموح بالترقية إليها",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "حدد الأدوار التي يمكن للزبون أن يطلب الترقية إليها. إذا لم تحدد أي دور، ستظهر جميع أدوار الزبائن.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    _buildAllowedUpgradeRoles(),
                  ],
                ),
              ),
            ],

            const Divider(),

            // ── Restrict Price Selector switch ────────────
            SwitchListTile(
              title: const Text(
                "تقييد زر اختيار فئة السعر بأدوار محددة (Restrict Price Selector)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "عند التفعيل، سيظهر زر تبديل الأسعار (جملة/قطاعي) فقط للمستخدمين الذين يمتلكون أحد الأدوار المحددة",
                style: TextStyle(fontSize: 12),
              ),
              value: widget.orderSettings['restrictPriceSelector'] ?? false,
              onChanged: widget.isEditing
                  ? (val) {
                      final newSettings = Map<String, dynamic>.from(
                        widget.orderSettings,
                      );
                      newSettings['restrictPriceSelector'] = val;
                      if (!val) {
                        newSettings['allowedPriceSelectorRoles'] = [];
                        newSettings[B2bHomeConfig.keyWholesaleWorkflowSlug] = null;
                      }
                      widget.onSettingsChanged(newSettings);
                    }
                  : null,
              activeColor: widget.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),

            // ── Allowed Price Selector Roles (مرئي فقط لما restrictPriceSelector = true)
            if (restrictPriceSelector) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: widget.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "الأدوار المسموح لها باستخدام فئات الأسعار",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "حدد الأدوار التي يمكن لأصحابها رؤية واستخدام زر تغيير فئات الأسعار (جملة/موزع) في التطبيق.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    _buildAllowedPriceSelectorRoles(),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    // ── Wholesale Workflow Selector ────────────
                    Row(
                      children: [
                        Icon(
                          Icons.alt_route_rounded,
                          color: widget.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "سير عمل طلبات الجملة (Wholesale Workflow)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "اختر سير العمل المخصص الذي سيتم اعتماد الطلب عليه عند قيام تاجر الجملة بالتحويل لوضع الجملة.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<
                      WorkflowManagementBloc,
                      FeaturDataSourceState<WorkflowConfigModel>
                    >(
                      buildWhen: (prev, next) => prev.listState != next.listState,
                      builder: (context, state) {
                        final workflows = state.listState.maybeWhen(
                          success: (data) => data ?? [],
                          orElse: () => [],
                        );

                        final Map<String, String> workflowOptions = {
                          "": "بدون سير عمل خاص للجملة (استخدام الافتراضي)",
                        };
                        for (var wf in workflows) {
                          workflowOptions[wf.workflowSlug] = wf.workflowSlug;
                        }

                        return _buildDropdown(
                          "سير عمل طلبات الجملة",
                          widget.orderSettings[B2bHomeConfig.keyWholesaleWorkflowSlug] ?? "",
                          workflowOptions,
                          (val) {
                            final newSettings = Map<String, dynamic>.from(
                              widget.orderSettings,
                            );
                            newSettings[B2bHomeConfig.keyWholesaleWorkflowSlug] = val;
                            widget.onSettingsChanged(newSettings);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
