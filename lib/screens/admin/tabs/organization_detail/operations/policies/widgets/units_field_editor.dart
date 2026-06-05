import 'package:flutter/material.dart';

class UnitsFieldEditor extends StatelessWidget {
  final List<String> allowedUnits;
  final bool isEditing;
  final ValueChanged<List<String>> onUnitsChanged;
  final bool isDark;

  const UnitsFieldEditor({
    super.key,
    required this.allowedUnits,
    required this.isEditing,
    required this.onUnitsChanged,
    required this.isDark,
  });

  void _showAddUnitDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("إضافة وحدة"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "اسم الوحدة"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newUnits = List<String>.from(allowedUnits)..add(controller.text.trim());
                onUnitsChanged(newUnits);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("الوحدات المسموح بها", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ...allowedUnits.map((u) => Chip(
                  label: Text(u, style: const TextStyle(fontSize: 11)),
                  onDeleted: isEditing ? () {
                    final newUnits = List<String>.from(allowedUnits)..remove(u);
                    onUnitsChanged(newUnits);
                  } : null,
                )),
            if (isEditing)
              ActionChip(
                label: const Icon(Icons.add, size: 16),
                onPressed: () => _showAddUnitDialog(context),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
