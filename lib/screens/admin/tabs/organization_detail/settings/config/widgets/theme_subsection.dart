import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeSubsection extends StatelessWidget {
  final String title;
  final Map<String, dynamic> themeMap;
  final bool isEditing;
  final void Function(String key, String newColorHex) onColorChanged;

  static const Map<String, String> _colorLabels = {
    "primary": "اللون الأساسي",
    "secondary": "اللون الثانوي",
    "accent": "اللون التمييزي",
    "background": "لون الخلفية",
    "surface": "لون الأسطح (البطاقات)",
    "surfaceVariant": "لون الأسطح البديل (خلفيات الشبكة)",
    "textPrimary": "النص الأساسي",
    "textSecondary": "النص الفرعي",
    "textHint": "نص التلميح (Hint)",
    "textOnPrimary": "النص فوق اللون الأساسي",
    "buttonPrimary": "اللون الأساسي للأزرار",
    "buttonSecondary": "اللون الثانوي للأزرار",
    "buttonText": "لون نص الأزرار",
    "divider": "لون الفواصل",
    "icon": "لون الأيقونات",
    "inputBackground": "خلفية حقول الإدخال",
    "inputBorder": "حدود حقول الإدخال",
    "inputFocus": "لون التركيز في الحقول",
    "herbGreen": "لون سير العمل (أخضر عشبي)",
    "success": "لون النجاح",
    "error": "لون الخطأ",
    "warning": "لون التحذير",
    "info": "لون المعلومات"
  };

  const ThemeSubsection({
    super.key,
    required this.title,
    required this.themeMap,
    required this.isEditing,
    required this.onColorChanged,
  });

  Color _parseSafeColor(String value) {
    try {
      String hexColor = value.replaceAll('#', '').replaceAll('0x', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (_) {
      return Colors.transparent;
    }
  }

  void _showColorPicker(BuildContext context, String label, String initialValue) {
    Color selectedColor = _parseSafeColor(initialValue);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("اختيار لون ${(_colorLabels[label] ?? label)}"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) => selectedColor = color,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("الغاء"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text("حفظ"),
              onPressed: () {
                onColorChanged(label, "0x${selectedColor.toFormatString().toUpperCase()}");
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      children: themeMap.entries.map((entry) {
        final displayLabel = _colorLabels[entry.key] ?? entry.key;
        return ListTile(
          title: Text(displayLabel, style: const TextStyle(fontSize: 12)),
          trailing: Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(
              color: _parseSafeColor(entry.value),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: isEditing ? () => _showColorPicker(context, entry.key, entry.value) : null,
        );
      }).toList(),
    );
  }
}

extension ColorExtension on Color {
  String toFormatString() {
    return value.toRadixString(16).padLeft(8, '0');
  }
}
