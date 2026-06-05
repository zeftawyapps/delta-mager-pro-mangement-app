import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/order_path_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/location_models.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';

class OrderPathEditorDialog extends StatefulWidget {
  final OrderPathModel? path;
  final String organizationId;
  final bool isDark;

  const OrderPathEditorDialog({
    super.key,
    this.path,
    required this.organizationId,
    required this.isDark,
  });

  @override
  State<OrderPathEditorDialog> createState() => _OrderPathEditorDialogState();
}

class _OrderPathEditorDialogState extends State<OrderPathEditorDialog> {
  late final TextEditingController nameController;
  late bool autoAssign;

  // Dropdown variables
  String? activeGovernorateId;
  String? activeCityId;
  final List<String> selectedRegions = [];
  final Map<String, String> selectedRegionNames = {};

  // Schedule variables
  late String scheduleType;
  final List<int> selectedDays = [];

  // Workflow variables
  String? activeWorkflowSlug;
  int? activeTriggerStepNumber;

  // Week days definitions
  static const Map<int, String> weekDays = {
    6: 'السبت',
    7: 'الأحد',
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
  };

  @override
  void initState() {
    super.initState();
    final path = widget.path;
    nameController = TextEditingController(text: path?.name);
    autoAssign = path?.autoAssign ?? true;

    if (path != null) {
      selectedRegions.addAll(path.regions);
      final locState = context.read<LocationsBloc>().state;
      for (var id in selectedRegions) {
        final cityName = locState.getCityName(id);
        final govName = locState.getGovernorateName(id);
        if (cityName.isNotEmpty) {
          selectedRegionNames[id] = cityName;
        } else if (govName.isNotEmpty) {
          selectedRegionNames[id] = govName;
        }
      }

      if (path.schedule != null) {
        scheduleType = path.schedule!.type;
        selectedDays.addAll(List<int>.from(path.schedule!.values));
      } else {
        scheduleType = 'always';
      }
      activeWorkflowSlug = path.workflowSlug;
      activeTriggerStepNumber = path.triggerStepNumber;
    } else {
      scheduleType = 'always';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? DarkColors.primary : LightColors.primary;
    final isEditMode = widget.path != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEditMode ? Icons.edit_road : Icons.add_road,
            color: isEditMode ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 10),
          Text(isEditMode ? "تعديل خط السير" : "إنشاء خط سير جديد"),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "اسم خط السير *",
                  hintText: isEditMode ? null : "مثال: خط القاهرة - الجيزة",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 16),
              
              // Regions Selection
              const Text(
                "تحديد المناطق المغطاة (Regions) *",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              BlocBuilder<LocationsBloc, LocationsState>(
                builder: (context, locState) {
                  final governorates = locState.governoratesState.maybeWhen(
                    success: (list) => list ?? [],
                    orElse: () => <GovernorateModel>[],
                  );

                  final cities = locState.citiesState.maybeWhen(
                    success: (list) => list ?? [],
                    orElse: () => <CityModel>[],
                  );

                  final isCitiesLoading = locState.citiesState.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: activeGovernorateId,
                              decoration: InputDecoration(
                                labelText: "المحافظة",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.map_outlined),
                              ),
                              items: governorates.map((gov) {
                                return DropdownMenuItem<String>(
                                  value: gov.id,
                                  child: Text(gov.name.ar),
                                );
                              }).toList(),
                              onChanged: (govId) {
                                setState(() {
                                  activeGovernorateId = govId;
                                  activeCityId = null;
                                  if (govId != null) {
                                    context.read<LocationsBloc>().loadCities(govId);
                                  }
                                });
                              },
                            ),
                          ),
                          if (activeGovernorateId != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (activeGovernorateId != null &&
                                    !selectedRegions.contains(activeGovernorateId)) {
                                  setState(() {
                                    selectedRegions.add(activeGovernorateId!);
                                    final gov = governorates.firstWhere(
                                      (g) => g.id == activeGovernorateId,
                                      orElse: () => governorates.first,
                                    );
                                    selectedRegionNames[activeGovernorateId!] = gov.name.ar;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                backgroundColor: primaryColor.withOpacity(0.1),
                                foregroundColor: primaryColor,
                              ),
                              child: const Text("إضافة الكل"),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: activeCityId,
                        disabledHint: const Text("اختر محافظة أولاً"),
                        decoration: InputDecoration(
                          labelText: isCitiesLoading ? "جاري تحميل المدن..." : "المدينة",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.location_city_outlined),
                        ),
                        items: activeGovernorateId == null
                            ? null
                            : cities.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city.id,
                                  child: Text(city.name.ar),
                                );
                              }).toList(),
                        onChanged: activeGovernorateId == null
                            ? null
                            : (cityId) {
                                setState(() {
                                  activeCityId = cityId;
                                  if (cityId != null && !selectedRegions.contains(cityId)) {
                                    selectedRegions.add(cityId);
                                    final city = cities.firstWhere((c) => c.id == cityId);
                                    selectedRegionNames[cityId] = city.name.ar;
                                  }
                                  activeCityId = null;
                                });
                              },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              if (selectedRegions.isNotEmpty) ...[
                const Text(
                  "المناطق المختارة:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedRegions.map((id) {
                      final name = selectedRegionNames[id] ?? id;
                      return Chip(
                        label: Text(
                          name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            selectedRegions.remove(id);
                          });
                        },
                        backgroundColor: primaryColor.withOpacity(0.05),
                        side: BorderSide(color: primaryColor.withOpacity(0.2)),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              
              // Schedule Section
              const Text(
                "جدول العمل (Schedule)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: scheduleType,
                decoration: InputDecoration(
                  labelText: "نوع التكرار",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                items: const [
                  DropdownMenuItem(value: 'always', child: Text("نشط دائماً (بدون جدول)")),
                  DropdownMenuItem(value: 'daily', child: Text("يومي")),
                  DropdownMenuItem(value: 'weekly', child: Text("أسبوعي (أيام محددة)")),
                ],
                onChanged: (val) {
                  setState(() {
                    scheduleType = val ?? 'always';
                    if (scheduleType != 'weekly') {
                      selectedDays.clear();
                    }
                  });
                },
              ),
              if (scheduleType == 'weekly') ...[
                const SizedBox(height: 12),
                const Text(
                  "أيام العمل في الأسبوع:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: weekDays.entries.map((entry) {
                    final isSelected = selectedDays.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDays.add(entry.key);
                          } else {
                            selectedDays.remove(entry.key);
                          }
                        });
                      },
                      selectedColor: primaryColor.withOpacity(0.2),
                      checkmarkColor: primaryColor,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              
              // Workflow Section
              const Text(
                "مسار العمل المرتبط (Workflow Config)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              BlocBuilder<WorkflowManagementBloc, FeaturDataSourceState<WorkflowConfigModel>>(
                builder: (context, wfState) {
                  final configs = wfState.listState.maybeWhen(
                    success: (list) => list ?? [],
                    orElse: () => <WorkflowConfigModel>[],
                  );

                  return DropdownButtonFormField<String>(
                    value: activeWorkflowSlug,
                    decoration: InputDecoration(
                      labelText: "كود مسار العمل (Slug)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.account_tree_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("لا يوجد مسار مرتبط"),
                      ),
                      ...configs.map((config) {
                        return DropdownMenuItem<String>(
                          value: config.workflowSlug,
                          child: Text(config.workflow.workflowName.ar),
                        );
                      }),
                    ],
                    onChanged: (slug) {
                      setState(() {
                        activeWorkflowSlug = slug;
                        activeTriggerStepNumber = null;
                      });
                    },
                  );
                },
              ),
              if (activeWorkflowSlug != null) ...[
                const SizedBox(height: 16),
                BlocBuilder<WorkflowManagementBloc, FeaturDataSourceState<WorkflowConfigModel>>(
                  builder: (context, wfState) {
                    final configs = wfState.listState.maybeWhen(
                      success: (list) => list ?? [],
                      orElse: () => <WorkflowConfigModel>[],
                    );
                    
                    WorkflowConfigModel? selectedConfig;
                    try {
                      selectedConfig = configs.firstWhere((c) => c.workflowSlug == activeWorkflowSlug);
                    } catch (_) {
                      selectedConfig = null;
                    }
                    
                    final steps = selectedConfig?.workflow.steps ?? [];

                    return DropdownButtonFormField<int>(
                      value: activeTriggerStepNumber,
                      decoration: InputDecoration(
                        labelText: "رقم خطوة الربط (Trigger Step)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text("لا يوجد خطوة ربط محددة"),
                        ),
                        ...steps.map((step) {
                          return DropdownMenuItem<int>(
                            value: step.stepNumber,
                            child: Text("${step.stepNumber} - ${step.stepName.ar}"),
                          );
                        }),
                      ],
                      onChanged: (stepNum) {
                        setState(() {
                          activeTriggerStepNumber = stepNum;
                        });
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("الربط التلقائي"),
                subtitle: const Text(
                  "ربط الطلبات بالخط آلياً عند التطابق الجغرافي",
                  style: TextStyle(fontSize: 12),
                ),
                value: autoAssign,
                onChanged: (val) {
                  setState(() => autoAssign = val);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("يرجى إدخال اسم خط السير"),
                ),
              );
              return;
            }
            if (selectedRegions.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("يرجى اختيار منطقة واحدة على الأقل"),
                ),
              );
              return;
            }

            Map<String, dynamic>? scheduleData;
            if (scheduleType == 'weekly') {
              scheduleData = {
                'type': 'weekly',
                'values': selectedDays,
              };
            } else if (scheduleType == 'daily') {
              scheduleData = {
                'type': 'daily',
              };
            }

            if (isEditMode) {
              context.read<OrderPathBloc>().updateOrderPath(
                    pathId: widget.path!.id,
                    organizationId: widget.organizationId,
                    name: nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : null,
                    regions: selectedRegions.isNotEmpty ? selectedRegions : null,
                    workflowSlug: activeWorkflowSlug,
                    triggerStepNumber: activeTriggerStepNumber,
                    autoAssign: autoAssign,
                    schedule: scheduleData,
                  );
            } else {
              context.read<OrderPathBloc>().createOrderPath(
                    organizationId: widget.organizationId,
                    name: nameController.text.trim(),
                    regions: selectedRegions,
                    workflowSlug: activeWorkflowSlug,
                    triggerStepNumber: activeTriggerStepNumber,
                    autoAssign: autoAssign,
                    schedule: scheduleData,
                  );
            }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isEditMode ? Colors.orange : LightColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditMode ? "حفظ التعديلات" : "إنشاء"),
        ),
      ],
    );
  }
}
