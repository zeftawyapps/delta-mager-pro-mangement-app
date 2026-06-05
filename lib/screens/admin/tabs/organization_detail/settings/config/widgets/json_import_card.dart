import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class JsonImportCard extends StatefulWidget {
  final bool isDark;
  final void Function(
    Map<String, dynamic> light,
    Map<String, dynamic> dark,
    Map<String, dynamic> website,
    Map<String, dynamic>? fixed,
  ) onImportSuccess;

  const JsonImportCard({
    super.key,
    required this.isDark,
    required this.onImportSuccess,
  });

  @override
  State<JsonImportCard> createState() => _JsonImportCardState();
}

class _JsonImportCardState extends State<JsonImportCard> {
  late final TextEditingController _jsonImportController;

  @override
  void initState() {
    super.initState();
    _jsonImportController = TextEditingController();
  }

  @override
  void dispose() {
    _jsonImportController.dispose();
    super.dispose();
  }

  void _importJsonData() {
    final text = _jsonImportController.text.trim();
    if (text.isEmpty) return;

    try {
      final decoded = jsonDecode(text) as Map<String, dynamic>;

      Map<String, dynamic>? light;
      Map<String, dynamic>? dark;
      Map<String, dynamic>? website;
      Map<String, dynamic>? fixed;

      if (decoded.containsKey('themes')) {
        final themes = decoded['themes'] as Map<String, dynamic>;
        if (themes['light'] != null) {
          light = Map<String, dynamic>.from(themes['light']);
        }
        if (themes['dark'] != null) {
          dark = Map<String, dynamic>.from(themes['dark']);
        }
        if (themes['website'] != null) {
          website = Map<String, dynamic>.from(themes['website']);
        }
        if (themes['fixed'] != null) {
          fixed = Map<String, dynamic>.from(themes['fixed']);
        }
      } else {
        if (decoded['light'] != null) {
          light = Map<String, dynamic>.from(decoded['light']);
        }
        if (decoded['dark'] != null) {
          dark = Map<String, dynamic>.from(decoded['dark']);
        }
        if (decoded['website'] != null) {
          website = Map<String, dynamic>.from(decoded['website']);
        }
        if (decoded['fixed'] != null) {
          fixed = Map<String, dynamic>.from(decoded['fixed']);
        }
      }

      // Default empty maps to prevent null exceptions
      light ??= {};
      dark ??= {};
      website ??= {};

      widget.onImportSuccess(light, dark, website, fixed);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم استيراد الـ JSON وتغذية المربعات بنجاح!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ خطأ في ترميز الـ JSON: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: widget.isDark ? DarkColors.surface : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.code_rounded, color: Colors.blue),
        title: const Text(
          "استيراد الإعدادات من JSON (Quick Import)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ضع كود الـ JSON هنا لتحديث الألوان بشكل فوري:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _jsonImportController,
                  maxLines: 8,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText:
                        '{\n  "light": { "primary": "0xFF..." },\n  "dark": { ... }\n}',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _importJsonData,
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: const Text(
                      "تطبيق كود الـ JSON فوراَ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
