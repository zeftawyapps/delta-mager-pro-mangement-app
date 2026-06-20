import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';

class GovernorateFeesEditor extends StatelessWidget {
  final Map<String, num> feesByGovernorate;
  final String currency;
  final bool isEditing;
  final ValueChanged<Map<String, num>> onFeesChanged;
  final bool isDark;

  const GovernorateFeesEditor({
    super.key,
    required this.feesByGovernorate,
    required this.currency,
    required this.isEditing,
    required this.onFeesChanged,
    required this.isDark,
  });

  void _showAddFeeDialog(BuildContext context) {
    String? selectedGovCode;
    final feeController = TextEditingController();
    final locationsBloc = context.read<LocationsBloc>();

    // Ensure governorates are loaded systematically
    locationsBloc.loadGovernorates('EG');

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: locationsBloc,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text("إضافة سعر شحن لمحافظة"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<LocationsBloc, LocationsState>(
                  builder: (context, state) {
                    return state.governoratesState.when(
                      init: () => const Text("جاري التهيئة..."),
                      loading: () => const CircularProgressIndicator(),
                      success: (governorates) {
                        final validGovernorates = (governorates ?? [])
                            .where((g) => (g.code ?? g.id.toString()).isNotEmpty)
                            .toList();
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "اختر المحافظة"),
                          items: validGovernorates.map((g) {
                            final val = g.code ?? g.id.toString();
                            return DropdownMenuItem(
                              value: val, 
                              child: Text(g.code != null && g.code!.isNotEmpty 
                                  ? "${g.name.ar} (${g.code})" 
                                  : g.name.ar),
                            );
                          }).toList(),
                          onChanged: (val) => setDialogState(() => selectedGovCode = val),
                        );
                      },
                      failure: (error, reload) => TextButton(
                        onPressed: reload,
                        child: const Text("خطأ في التحميل، اضغط للإعادة"),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(labelText: "قيمة الشحن"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                if (selectedGovCode != null && feeController.text.isNotEmpty) {
                  final newFees = Map<String, num>.from(feesByGovernorate);
                  newFees[selectedGovCode!] = num.tryParse(feeController.text) ?? 0;
                  onFeesChanged(newFees);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, locationsState) {
        final governorates = locationsState.governoratesState.maybeWhen(
          success: (data) => data ?? [],
          orElse: () => [],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("أسعار الشحن للمحافظات", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ...feesByGovernorate.entries.map((e) {
              final g = governorates
                  .where((item) =>
                      item.code == e.key ||
                      item.name.ar == e.key ||
                      item.id.toString() == e.key)
                  .firstOrNull;
              final displayName = g?.name.ar ?? e.key;

              return ListTile(
                dense: true,
                title: Text(displayName, style: const TextStyle(fontSize: 13)),
                subtitle: Text("${e.value} $currency",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: isEditing
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () {
                          final newFees = Map<String, num>.from(feesByGovernorate)..remove(e.key);
                          onFeesChanged(newFees);
                        },
                      )
                    : null,
              );
            }),
            if (isEditing)
              TextButton.icon(
                onPressed: () => _showAddFeeDialog(context),
                icon: const Icon(Icons.add),
                label: const Text("إضافة سعر لمحافظة"),
              ),
          ],
        );
      },
    );
  }
}
