import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/location_models.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class SystemManagementTab extends StatefulWidget {
  final bool isDark;

  const SystemManagementTab({super.key, required this.isDark});

  @override
  State<SystemManagementTab> createState() => _SystemManagementTabState();
}

class _SystemManagementTabState extends State<SystemManagementTab> {
  String? _selectedCountryId;
  String? _selectedGovernorateId;

  @override
  void initState() {
    super.initState();
    context.read<LocationsBloc>().loadCountries();
    context.read<LocationsBloc>().loadLanguages();
  }

  void _showAddGovernorateDialog() {
    if (_selectedCountryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى اختيار دولة أولاً")));
      return;
    }
    final arController = TextEditingController();
    final enController = TextEditingController();
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة محافظة جديدة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: arController,
              decoration: const InputDecoration(labelText: "الاسم بالعربي"),
            ),
            TextField(
              controller: enController,
              decoration: const InputDecoration(labelText: "الاسم بالإنجليزي"),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "كود المحافظة (مثال: CAI)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (arController.text.isNotEmpty &&
                  enController.text.isNotEmpty) {
                context.read<LocationsBloc>().addGovernorate(
                  Governorate(
                    id: '',
                    countryId: _selectedCountryId!,
                    name: Name(ar: arController.text, en: enController.text),
                    code: codeController.text.isNotEmpty
                        ? codeController.text.toUpperCase()
                        : null,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  void _showAddCityDialog(String governorateId) {
    final arController = TextEditingController();
    final enController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة مدينة جديدة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: arController,
              decoration: const InputDecoration(labelText: "الاسم بالعربي"),
            ),
            TextField(
              controller: enController,
              decoration: const InputDecoration(labelText: "الاسم بالإنجليزي"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (arController.text.isNotEmpty &&
                  enController.text.isNotEmpty) {
                context.read<LocationsBloc>().addCity(
                  City(
                    id: '',
                    governorateId: governorateId,
                    name: Name(ar: arController.text, en: enController.text),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;
    final surfaceColor = isDark ? DarkColors.surface : Colors.white;

    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.map_rounded,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "إدارة البيانات الجغرافية",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                      ),
                      Text(
                        "إدارة الدول والمحافظات والمدن الخاصة بالتطبيق",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showAddGovernorateDialog,
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text("إضافة محافظة"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Country Selector Section ---
              state.countriesState.when(
                init: () => const SizedBox(),
                loading: () => const LinearProgressIndicator(),
                success: (countries) => Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountryId,
                    decoration: InputDecoration(
                      labelText: "الدولة النشطة",
                      prefixIcon: const Icon(Icons.public_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    items: countries
                        ?.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              "${c.name.ar} (${c.id})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCountryId = val;
                        _selectedGovernorateId = null;
                      });
                      if (val != null) {
                        context.read<LocationsBloc>().loadGovernorates(val);
                      }
                    },
                  ),
                ),
                failure: (error, reload) => TextButton.icon(
                  onPressed: reload,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text(
                    "حدث خطأ أثناء تحميل الدول. إعادة المحاولة؟",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Main Content (Governorates & Cities) ---
              Expanded(
                child: state.governoratesState.when(
                  init: () => _selectedCountryId == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.travel_explore_rounded,
                                size: 64,
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "يرجى اختيار دولة لعرض تفاصيلها الجغرافية",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  success: (governorates) => Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Governorates Column ---
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_city_rounded,
                                    size: 18,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "المحافظات",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${governorates?.length ?? 0}",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: governorates?.length ?? 0,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (context, index) {
                                  final gov = governorates![index];
                                  final isSelected =
                                      _selectedGovernorateId == gov.id;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        setState(
                                          () => _selectedGovernorateId = gov.id,
                                        );
                                        context
                                            .read<LocationsBloc>()
                                            .loadCities(gov.id);
                                      },
                                      title: Text(
                                        gov.name.ar,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? primaryColor
                                              : (isDark
                                                    ? Colors.white
                                                    : Colors.black87),
                                        ),
                                      ),
                                      subtitle: Text(
                                        gov.name.en,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black45,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? Icon(
                                              Icons.arrow_back_ios_new_rounded,
                                              size: 14,
                                              color: primaryColor,
                                            )
                                          : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // --- Cities Column ---
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12,
                            ),
                          ),
                          child: _selectedGovernorateId == null
                              ? const Center(
                                  child: Text(
                                    "اختر محافظة لعرض مدنها السكنية",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.holiday_village_rounded,
                                            size: 18,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "المدن / الأحياء",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton.icon(
                                            onPressed: () => _showAddCityDialog(
                                              _selectedGovernorateId!,
                                            ),
                                            icon: const Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 18,
                                            ),
                                            label: const Text("إضافة مدينة"),
                                            style: TextButton.styleFrom(
                                              foregroundColor: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    Expanded(
                                      child: state.citiesState.when(
                                        init: () => const SizedBox(),
                                        loading: () => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        success: (cities) =>
                                            (cities?.isEmpty ?? true)
                                            ? const Center(
                                                child: Text(
                                                  "لم يتم إضافة مدن لهذه المحافظة بعد",
                                                ),
                                              )
                                            : GridView.builder(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                gridDelegate:
                                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 250,
                                                      mainAxisExtent: 80,
                                                      crossAxisSpacing: 12,
                                                      mainAxisSpacing: 12,
                                                    ),
                                                itemCount: cities!.length,
                                                itemBuilder: (context, index) {
                                                  final city = cities[index];
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: surfaceColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color: isDark
                                                            ? Colors.white10
                                                            : Colors.black
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                      ),
                                                    ),
                                                    child: ListTile(
                                                      title: Text(
                                                        city.name.ar,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        city.name.en,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      trailing: city.isActive
                                                          ? Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    2,
                                                                  ),
                                                              decoration:
                                                                  const BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                              child: const Icon(
                                                                Icons.check,
                                                                size: 10,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                  );
                                                },
                                              ),
                                        failure: (error, reload) => Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                error.message ??
                                                    "فشل تحميل المدن",
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton(
                                                onPressed: reload,
                                                child: const Text(
                                                  "إعادة المحاولة",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  failure: (error, reload) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(error.message ?? "حدث خطأ غير متوقع"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: reload,
                          child: const Text("إعادة المحاولة"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
