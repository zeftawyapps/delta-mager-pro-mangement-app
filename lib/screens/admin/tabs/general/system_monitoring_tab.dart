import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/admin_organizations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/system_monitoring_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/matger_pro_core_logic.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class SystemMonitoringTab extends StatefulWidget {
  final bool isDark;

  const SystemMonitoringTab({Key? key, required this.isDark}) : super(key: key);

  @override
  _SystemMonitoringTabState createState() => _SystemMonitoringTabState();
}

class _SystemMonitoringTabState extends State<SystemMonitoringTab> {
  String? _selectedOrgId;
  int? _selectedFilterType; // null = All, 4 = 4xx, 5 = 5xx

  @override
  void initState() {
    super.initState();
    // Load organizations if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orgState = context.read<AdminOrganizationsBloc>().state;
      orgState.listState.maybeWhen(
        success: (organizations) {
          if (organizations!.isNotEmpty) {
            _selectOrganization(organizations.first.id);
          }
        },
        orElse: () {
          context.read<AdminOrganizationsBloc>().loadActiveOrganizations();
        },
      );
    });
  }

  void _selectOrganization(String orgId) {
    setState(() {
      _selectedOrgId = orgId;
    });
    _refreshData();
  }

  void _refreshData() {
    if (_selectedOrgId != null) {
      context.read<SystemMonitoringBloc>().loadApiUsage(
        organizationId: _selectedOrgId!,
      );
      _loadLogs();
    }
  }

  void _loadLogs() {
    if (_selectedOrgId != null) {
      int? statusCode;
      if (_selectedFilterType == 5) {
        statusCode = 500; // Let the backend filter or filter locally if needed.
        // Note: The backend getBlackboxLogs accepts a specific statusCode query param.
      }
      context.read<SystemMonitoringBloc>().loadBlackboxLogs(
        organizationId: _selectedOrgId,
        statusCode: statusCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark
        ? DarkColors.primary
        : LightColors.primary;
    final surfaceColor = widget.isDark
        ? DarkColors.surface
        : LightColors.surface;

    return MultiBlocListener(
      listeners: [
        BlocListener<
          AdminOrganizationsBloc,
          FeaturDataSourceState<OrganizationModel>
        >(
          listener: (context, state) {
            state.listState.maybeWhen(
              success: (organizations) {
                if (organizations!.isNotEmpty && _selectedOrgId == null) {
                  _selectOrganization(organizations.first.id);
                }
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Selector Bar
              _buildSelectorBar(primaryColor, surfaceColor),
              const SizedBox(height: 16),

              // 2. Main content area
              Expanded(
                child:
                    BlocBuilder<
                      AdminOrganizationsBloc,
                      FeaturDataSourceState<OrganizationModel>
                    >(
                      builder: (context, orgState) {
                        return orgState.listState.when(
                          init: () =>
                              const Center(child: CircularProgressIndicator()),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          failure: (err, onRetry) => _buildErrorWidget(
                            err.message ?? "Error loading organizations",
                            onRetry,
                          ),
                          success: (organizations) {
                            if (organizations!.isEmpty) {
                              return const Center(
                                child: Text(
                                  "لا توجد منظمات أو متاجر مسجلة في النظام حالياً.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            if (_selectedOrgId == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 1100;
                                if (isWide) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // API usage statistics
                                      Expanded(
                                        flex: 5,
                                        child: _buildApiUsageSection(
                                          primaryColor,
                                          surfaceColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Blackbox Error logs
                                      Expanded(
                                        flex: 6,
                                        child: _buildBlackboxSection(
                                          primaryColor,
                                          surfaceColor,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        _buildApiUsageSection(
                                          primaryColor,
                                          surfaceColor,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildBlackboxSection(
                                          primaryColor,
                                          surfaceColor,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorBar(Color primaryColor, Color surfaceColor) {
    return Card(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child:
            BlocBuilder<
              AdminOrganizationsBloc,
              FeaturDataSourceState<OrganizationModel>
            >(
              builder: (context, orgState) {
                final organizations = orgState.listState.maybeWhen(
                  success: (list) => list,
                  orElse: () => <OrganizationModel>[],
                );

                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Organization Dropdown
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.store, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          "المتجر المستهدف:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (organizations!.isEmpty)
                          const SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedOrgId,
                                items: organizations.map((org) {
                                  return DropdownMenuItem<String>(
                                    value: org.id,
                                    child: Text("${org.name} (${org.orgName})"),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _selectOrganization(val);
                                  }
                                },
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Error Code Filter dropdown
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bug_report_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "تصفية السجلات:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: _selectedFilterType,
                              items: const [
                                DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("كل السجلات والأخطاء"),
                                ),
                                DropdownMenuItem<int?>(
                                  value: 5,
                                  child: Text("أخطاء النظام فقط (5xx)"),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedFilterType = val;
                                });
                                _loadLogs();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Refresh button
                    IconButton(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      tooltip: "تحديث البيانات حالياً",
                      color: primaryColor,
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildApiUsageSection(Color primaryColor, Color surfaceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: primaryColor),
            const SizedBox(width: 8),
            const Text(
              "حجم الاستهلاك والطلبات (API Usage)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<SystemMonitoringBloc, SystemMonitoringState>(
              builder: (context, state) {
                return state.apiUsageState.when(
                  init: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  failure: (err, onRetry) =>
                      _buildErrorWidget(err.message ?? "Error", onRetry),
                  success: (stats) {
                    if (stats!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            "لا توجد بيانات استخدام مسجلة لهذا المتجر.",
                          ),
                        ),
                      );
                    }

                    // Compute summary values
                    int totalRequests = 0;
                    double totalBandwidth = 0;
                    for (var s in stats!) {
                      totalRequests += s.requestCount.toInt();
                      totalBandwidth += s.totalMegabytes;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats summary cards
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _buildMiniMetricCard(
                              "إجمالي الطلبات",
                              "$totalRequests طلب",
                              Icons.sync_alt,
                              Colors.blue,
                            ),
                            _buildMiniMetricCard(
                              "حجم البيانات الكلي",
                              "${totalBandwidth.toStringAsFixed(2)} MB",
                              Icons.cloud_queue,
                              Colors.teal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "تفاصيل الاستهلاك اليومي:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Usage Table List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stats!.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final s = stats[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.date,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${s.requestCount} طلب API",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${s.totalMegabytes.toStringAsFixed(2)} MB",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "وارد: ${s.megabytesIn.toStringAsFixed(2)} MB | صادر: ${s.megabytesOut.toStringAsFixed(2)} MB",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlackboxSection(Color primaryColor, Color surfaceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bug_report_outlined, color: primaryColor),
            const SizedBox(width: 8),
            const Text(
              "سجل أخطاء النظام (Blackbox Logs)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<SystemMonitoringBloc, SystemMonitoringState>(
          builder: (context, state) {
            return state.blackboxLogsState.when(
              init: () => Card(
                elevation: 0,
                color: surfaceColor,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              loading: () => Card(
                elevation: 0,
                color: surfaceColor,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              failure: (err, onRetry) => Card(
                elevation: 0,
                color: surfaceColor,
                child: _buildErrorWidget(err.message ?? "Error", onRetry),
              ),
              success: (logs) {
                // Apply local filters if they selected 500 but we fetched general logs.
                // Or if we just rely on backend filter.
                // Let's filter locally just in case to guarantee status code checks
                var filteredLogs = logs;
                if (_selectedFilterType == 5) {
                  filteredLogs = logs!
                      .where((l) => l.statusCode >= 500)
                      .toList();
                }

                if (filteredLogs!.isEmpty) {
                  return Card(
                    elevation: 0,
                    color: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "لا توجد أخطاء مسجلة حالياً لهذ المتجر.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs![index];
                    return BlackboxLogCard(log: log);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMiniMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("❌ $message", style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("إعادة المحاولة"),
          ),
        ],
      ),
    );
  }
}

class BlackboxLogCard extends StatefulWidget {
  final BlackboxLog log;

  const BlackboxLogCard({Key? key, required this.log}) : super(key: key);

  @override
  _BlackboxLogCardState createState() => _BlackboxLogCardState();
}

class _BlackboxLogCardState extends State<BlackboxLogCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isServerCrash = widget.log.statusCode >= 500;
    final cardColor = isServerCrash
        ? Colors.red.shade50.withOpacity(0.4)
        : Colors.orange.shade50.withOpacity(0.4);
    final borderColor = isServerCrash
        ? Colors.red.withOpacity(0.3)
        : Colors.orange.withOpacity(0.3);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            leading: Icon(
              isServerCrash ? Icons.error : Icons.warning_amber_rounded,
              color: isServerCrash ? Colors.red : Colors.orange,
              size: 28,
            ),
            title: Text(
              '${widget.log.method} ${widget.log.path}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
                fontSize: 14,
              ),
              textDirection: TextDirection.ltr,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isServerCrash ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.log.statusCode}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الوقت: ${widget.log.timestamp.toLocal().toString().substring(0, 19)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
              left: 16.0,
              bottom: 12.0,
            ),
            child: Text(
              'الرسالة: ${widget.log.message}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade900,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.log.ip.isNotEmpty ||
                      widget.log.userAgent.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text(
                          "IP: ",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          widget.log.ip,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "User: ",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          widget.log.userId.isEmpty
                              ? "مجهول"
                              : widget.log.userId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "User Agent: ${widget.log.userAgent}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Courier',
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 4),
                  ],
                  const Text(
                    "ملخص تتبع الخطأ (Stack Trace):",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    widget.log.stack.isNotEmpty
                        ? widget.log.stack
                        : "لا يوجد Stack trace متوفر لهذا الخطأ.",
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      color: Colors.lightGreenAccent,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
