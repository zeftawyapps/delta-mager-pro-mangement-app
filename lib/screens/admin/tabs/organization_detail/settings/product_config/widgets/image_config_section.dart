import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class ImageConfigSection extends StatelessWidget {
  final String title;
  final String groupPrefix;
  final Map<String, dynamic> data;
  final bool isEditing;
  final bool isDark;
  final Color primaryColor;
  final void Function(String key, dynamic value) onFieldUpdated;

  const ImageConfigSection({
    super.key,
    required this.title,
    required this.groupPrefix,
    required this.data,
    required this.isEditing,
    required this.isDark,
    required this.primaryColor,
    required this.onFieldUpdated,
  });

  Widget _buildSwitch(
    String label,
    String key, {
    bool defaultValue = false,
    String? subtitle,
    bool enabled = true,
  }) {
    final textColor = (isDark ? Colors.white : Colors.black87)
        .withOpacity(enabled ? 1.0 : 0.4);
    final subColor = (isDark ? Colors.white60 : Colors.black54)
        .withOpacity(enabled ? 1.0 : 0.4);

    return Column(
      children: [
        SwitchListTile(
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, style: TextStyle(fontSize: 12, color: subColor))
              : null,
          value: enabled ? (data[key] ?? defaultValue) : false,
          onChanged: (isEditing && enabled)
              ? (val) => onFieldUpdated(key, val)
              : null,
          activeColor: primaryColor,
          dense: false,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildNumberInput(String label, String key, dynamic value) {
    return TextFormField(
      initialValue: value.toString(),
      key: ValueKey("${key}_$isEditing"),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        isDense: true,
        border: const OutlineInputBorder(),
        filled: !isEditing,
        fillColor: isEditing
            ? null
            : (isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05)),
      ),
      keyboardType: TextInputType.number,
      readOnly: !isEditing,
      onChanged: (val) {
        final numVal = num.tryParse(val);
        if (numVal != null) {
          onFieldUpdated(key, numVal);
        }
      },
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: primaryColor,
          ),
        ),
        _buildSwitch(
          "الصورة مطلوبة",
          "${groupPrefix}_isRequired",
          subtitle: "جعل رفع الصورة شرطاً أساسياً لحفظ المنتج",
        ),
        _buildSwitch(
          "فرض نسبة العرض للارتفاع",
          "${groupPrefix}_enforceRatio",
          defaultValue: true,
          subtitle: "إجبار المستخدم على قص الصورة لتناسب الأبعاد المذكورة",
        ),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput(
                "الارتفاع",
                "${groupPrefix}_height",
                data["${groupPrefix}_height"] ?? 200,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNumberInput(
                "العرض",
                "${groupPrefix}_width",
                data["${groupPrefix}_width"] ?? 200,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNumberInput(
                "الحد الأقصى (MB)",
                "${groupPrefix}_maxSizeMB",
                data["${groupPrefix}_maxSizeMB"] ?? 5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
