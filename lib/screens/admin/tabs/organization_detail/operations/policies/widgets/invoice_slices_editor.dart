import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';

class InvoiceSlicesEditor extends StatelessWidget {
  final List<InvoiceSlice> invoiceSlices;
  final bool isEditing;
  final ValueChanged<List<InvoiceSlice>> onSlicesChanged;
  final bool isDark;

  const InvoiceSlicesEditor({
    super.key,
    required this.invoiceSlices,
    required this.isEditing,
    required this.onSlicesChanged,
    required this.isDark,
  });

  void _showAddSliceDialog(BuildContext context) {
    final minController = TextEditingController();
    final discController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("إضافة شريحة فواتير"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              decoration: const InputDecoration(hintText: "أكثر من مبلغ..."),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: discController,
              decoration: const InputDecoration(hintText: "قيمة الخصم"),
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
              if (minController.text.isNotEmpty && discController.text.isNotEmpty) {
                final newSlices = List<InvoiceSlice>.from(invoiceSlices);
                newSlices.add(InvoiceSlice(
                  minAmount: num.tryParse(minController.text),
                  discountAmount: num.tryParse(discController.text),
                ));
                onSlicesChanged(newSlices);
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
        const Text("شرائح الفواتير والخصومات", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        ...invoiceSlices.map((s) => ListTile(
              dense: true,
              title: Text("أكثر من ${s.minAmount}", style: const TextStyle(fontSize: 13)),
              subtitle: Text("خصم ${s.discountAmount}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              trailing: isEditing
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () {
                        final newSlices = List<InvoiceSlice>.from(invoiceSlices)..remove(s);
                        onSlicesChanged(newSlices);
                      },
                    )
                  : null,
            )),
        if (isEditing)
          TextButton.icon(
            onPressed: () => _showAddSliceDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("إضافة شريحة خصم"),
          ),
      ],
    );
  }
}
