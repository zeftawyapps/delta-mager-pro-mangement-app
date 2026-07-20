import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:matger_pro_core_logic/core/orgnization/data/organization_config.dart';

/// Palette extracted from organization themes (light + website).
class IntroThemePalette {
  final Map<String, String> colors;
  final Map<String, String> labels;

  const IntroThemePalette({
    required this.colors,
    required this.labels,
  });

  static IntroThemePalette fromOrganizationConfig(OrganizationConfig? config) {
    final light = config?.themes?.light?.toJson() ?? {};
    final website = config?.themes?.website?.toJson() ?? {};

    const lightLabels = {
      'primary': 'أساسي',
      'secondary': 'ثانوي',
      'accent': 'تمييزي',
      'background': 'خلفية',
      'surface': 'سطح',
      'surfaceVariant': 'سطح بديل',
      'textPrimary': 'نص أساسي',
      'textSecondary': 'نص فرعي',
      'textOnPrimary': 'نص فوق الأساسي',
      'buttonPrimary': 'زر أساسي',
      'buttonSecondary': 'زر ثانوي',
    };

    const websiteLabels = {
      'headerBackground': 'خلفية الهيدر',
      'footerBackground': 'خلفية الفوتر',
      'footerText': 'نص الفوتر',
      'heroOverlay': 'تراكب الهيرو',
    };

    final colors = <String, String>{};
    final labels = <String, String>{};

    for (final key in lightLabels.keys) {
      final raw = light[key]?.toString();
      if (raw != null && raw.isNotEmpty) {
        colors[key] = IntroColorUtils.normalizeToWebsiteHex(raw);
        labels[key] = lightLabels[key]!;
      }
    }

    for (final key in websiteLabels.keys) {
      final raw = website[key]?.toString();
      if (raw != null && raw.isNotEmpty) {
        final mapKey = 'web_$key';
        colors[mapKey] = IntroColorUtils.normalizeToWebsiteHex(raw);
        labels[mapKey] = websiteLabels[key]!;
      }
    }

    colors['white'] = '#FFFFFF';
    colors['black'] = '#000000';
    labels['white'] = 'أبيض';
    labels['black'] = 'أسود';

    return IntroThemePalette(colors: colors, labels: labels);
  }

  List<MapEntry<String, String>> get backgroundSwatches {
    const order = [
      'primary',
      'secondary',
      'accent',
      'background',
      'surface',
      'surfaceVariant',
      'web_headerBackground',
      'web_heroOverlay',
    ];
    return order
        .where((k) => colors.containsKey(k))
        .map((k) => MapEntry(k, colors[k]!))
        .toList();
  }

  List<MapEntry<String, String>> get textSwatches {
    const order = [
      'textPrimary',
      'textSecondary',
      'textOnPrimary',
      'white',
      'black',
      'web_footerText',
    ];
    return order
        .where((k) => colors.containsKey(k))
        .map((k) => MapEntry(k, colors[k]!))
        .toList();
  }

  List<({String label, String gradient})> get textGradientPresets {
    String? g(String a, String b) {
      final c1 = colors[a];
      final c2 = colors[b];
      if (c1 == null || c2 == null) return null;
      return IntroColorUtils.buildGradient(c1, c2);
    }

    final presets = <({String label, String gradient})>[];
    void add(String label, String? gradient) {
      if (gradient != null) presets.add((label: label, gradient: gradient));
    }

    add('أساسي → تمييزي', g('primary', 'accent'));
    add('نص أساسي → أساسي', g('textPrimary', 'primary'));
    add('أبيض → تمييزي', g('white', 'accent'));
    add('نص فوق الأساسي → ثانوي', g('textOnPrimary', 'secondary'));
    add('ثانوي → أساسي', g('secondary', 'primary'));
    return presets;
  }

  List<({String label, String gradient})> get gradientPresets {
    String? g(String a, String b) {
      final c1 = colors[a];
      final c2 = colors[b];
      if (c1 == null || c2 == null) return null;
      return IntroColorUtils.buildGradient(c1, c2);
    }

    final presets = <({String label, String gradient})>[];
    void add(String label, String? gradient) {
      if (gradient != null) presets.add((label: label, gradient: gradient));
    }

    add('أساسي → ثانوي', g('primary', 'secondary'));
    add('أساسي → تمييزي', g('primary', 'accent'));
    add('خلفية → سطح', g('background', 'surface'));
    add('ثانوي → أساسي', g('secondary', 'primary'));
    return presets;
  }
}

class IntroColorUtils {
  static String normalizeToWebsiteHex(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('#')) {
      return trimmed.length == 7 ? trimmed.toUpperCase() : trimmed;
    }
    if (trimmed.startsWith('0x') || trimmed.startsWith('0X')) {
      var hex = trimmed.substring(2);
      if (hex.length == 8) hex = hex.substring(2);
      return '#${hex.toUpperCase()}';
    }
    return trimmed;
  }

  static Color parseColor(String? value, {Color fallback = Colors.grey}) {
    if (value == null || value.isEmpty || value.contains('gradient')) {
      return fallback;
    }
    try {
      var hex = value.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  static String colorToWebsiteHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static bool isGradient(String? value) =>
      value != null && value.contains('linear-gradient');

  static ({String start, String end}) parseGradientColors(String? value) {
    if (value == null || !isGradient(value)) {
      return (start: '#100C1C', end: '#1A2332');
    }
    final regex = RegExp(r'#[0-9A-Fa-f]{6}|0x[0-9A-Fa-f]{8}');
    final matches = regex.allMatches(value).map((m) => m.group(0)!).toList();
    if (matches.length >= 2) {
      return (
        start: normalizeToWebsiteHex(matches[0]),
        end: normalizeToWebsiteHex(matches[1]),
      );
    }
    return (start: '#100C1C', end: '#1A2332');
  }

  static String buildGradient(String start, String end) {
    return 'linear-gradient(135deg, ${normalizeToWebsiteHex(start)}, ${normalizeToWebsiteHex(end)})';
  }

  static Future<Color?> showPickerDialog(
    BuildContext context, {
    required String title,
    required Color initial,
  }) async {
    Color selected = initial;
    return showDialog<Color>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initial,
            onColorChanged: (c) => selected = c,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, selected),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class IntroBackgroundColorPicker extends StatelessWidget {
  final String backgroundType;
  final String customBg;
  final bool isEditing;
  final IntroThemePalette palette;
  final ValueChanged<String> onChanged;

  const IntroBackgroundColorPicker({
    super.key,
    required this.backgroundType,
    required this.customBg,
    required this.isEditing,
    required this.palette,
    required this.onChanged,
  });

  bool get _isGradient => backgroundType == 'gradient';

  @override
  Widget build(BuildContext context) {
    if (_isGradient) {
      final colors = IntroColorUtils.parseGradientColors(customBg);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تدرج الخلفية',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _GradientPreview(value: customBg),
          const SizedBox(height: 10),
          if (palette.gradientPresets.isNotEmpty) ...[
            const Text('تدرجات جاهزة من الثيم', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: palette.gradientPresets.map((preset) {
                return ActionChip(
                  label: Text(preset.label, style: const TextStyle(fontSize: 11)),
                  onPressed: isEditing ? () => onChanged(preset.gradient) : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          _ColorPickRow(
            label: 'لون البداية',
            hex: colors.start,
            isEditing: isEditing,
            onPick: (hex) => onChanged(
              IntroColorUtils.buildGradient(hex, colors.end),
            ),
          ),
          const SizedBox(height: 8),
          _ColorPickRow(
            label: 'لون النهاية',
            hex: colors.end,
            isEditing: isEditing,
            onPick: (hex) => onChanged(
              IntroColorUtils.buildGradient(colors.start, hex),
            ),
          ),
        ],
      );
    }

    final solid = IntroColorUtils.isGradient(customBg)
        ? IntroColorUtils.parseGradientColors(customBg).start
        : (customBg.isEmpty
            ? (palette.colors['primary'] ?? '#1A2332')
            : IntroColorUtils.normalizeToWebsiteHex(customBg));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'لون الخلفية',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _ThemeSwatches(
          entries: palette.backgroundSwatches,
          labels: palette.labels,
          isEditing: isEditing,
          onSelected: onChanged,
        ),
        const SizedBox(height: 8),
        _ColorPickRow(
          label: 'لون مخصص',
          hex: solid,
          isEditing: isEditing,
          onPick: onChanged,
        ),
      ],
    );
  }
}

class IntroTextColorPicker extends StatelessWidget {
  final String textColor;
  final bool isEditing;
  final IntroThemePalette palette;
  final ValueChanged<String> onChanged;

  const IntroTextColorPicker({
    super.key,
    required this.textColor,
    required this.isEditing,
    required this.palette,
    required this.onChanged,
  });

  bool get _isGradient => IntroColorUtils.isGradient(textColor);

  void _onTypeChanged(String type) {
    if (type == 'gradient') {
      if (_isGradient) return;
      final start = textColor.isEmpty
          ? (palette.colors['textPrimary'] ?? palette.colors['white'] ?? '#FFFFFF')
          : IntroColorUtils.normalizeToWebsiteHex(textColor);
      final end = palette.colors['accent'] ??
          palette.colors['primary'] ??
          palette.colors['secondary'] ??
          '#F8FAFC';
      onChanged(IntroColorUtils.buildGradient(start, end));
      return;
    }

    if (_isGradient) {
      onChanged(IntroColorUtils.parseGradientColors(textColor).start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = _isGradient ? 'gradient' : 'solid';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'لون النص',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'solid', label: Text('لون صريح')),
            ButtonSegment(value: 'gradient', label: Text('تدرج')),
          ],
          selected: {selectedType},
          onSelectionChanged:
              isEditing ? (v) => _onTypeChanged(v.first) : null,
        ),
        const SizedBox(height: 10),
        if (_isGradient) ...[
          _GradientPreview(value: textColor),
          const SizedBox(height: 10),
          if (palette.textGradientPresets.isNotEmpty) ...[
            const Text(
              'تدرجات جاهزة للنص',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: palette.textGradientPresets.map((preset) {
                return ActionChip(
                  label: Text(preset.label, style: const TextStyle(fontSize: 11)),
                  onPressed: isEditing ? () => onChanged(preset.gradient) : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          Builder(
            builder: (context) {
              final colors = IntroColorUtils.parseGradientColors(textColor);
              return Column(
                children: [
                  _ColorPickRow(
                    label: 'لون البداية',
                    hex: colors.start,
                    isEditing: isEditing,
                    onPick: (hex) => onChanged(
                      IntroColorUtils.buildGradient(hex, colors.end),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ColorPickRow(
                    label: 'لون النهاية',
                    hex: colors.end,
                    isEditing: isEditing,
                    onPick: (hex) => onChanged(
                      IntroColorUtils.buildGradient(colors.start, hex),
                    ),
                  ),
                ],
              );
            },
          ),
        ] else ...[
          _ThemeSwatches(
            entries: palette.textSwatches,
            labels: palette.labels,
            isEditing: isEditing,
            onSelected: onChanged,
          ),
          const SizedBox(height: 8),
          _ColorPickRow(
            label: 'لون مخصص',
            hex: textColor.isEmpty
                ? (palette.colors['textPrimary'] ?? '#FFFFFF')
                : IntroColorUtils.normalizeToWebsiteHex(textColor),
            isEditing: isEditing,
            onPick: onChanged,
          ),
        ],
      ],
    );
  }
}

class _ThemeSwatches extends StatelessWidget {
  final List<MapEntry<String, String>> entries;
  final Map<String, String> labels;
  final bool isEditing;
  final ValueChanged<String> onSelected;

  const _ThemeSwatches({
    required this.entries,
    required this.labels,
    required this.isEditing,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((entry) {
        final label = labels[entry.key] ?? entry.key;
        return Tooltip(
          message: '$label (${entry.value})',
          child: InkWell(
            onTap: isEditing ? () => onSelected(entry.value) : null,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: IntroColorUtils.parseColor(entry.value),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 48,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorPickRow extends StatelessWidget {
  final String label;
  final String hex;
  final bool isEditing;
  final ValueChanged<String> onPick;

  const _ColorPickRow({
    required this.label,
    required this.hex,
    required this.isEditing,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: IntroColorUtils.parseColor(hex),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 8),
        Text(hex, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(width: 8),
        TextButton(
          onPressed: !isEditing
              ? null
              : () async {
                  final picked = await IntroColorUtils.showPickerDialog(
                    context,
                    title: label,
                    initial: IntroColorUtils.parseColor(hex),
                  );
                  if (picked != null) {
                    onPick(IntroColorUtils.colorToWebsiteHex(picked));
                  }
                },
          child: const Text('اختيار'),
        ),
      ],
    );
  }
}

class _GradientPreview extends StatelessWidget {
  final String value;

  const _GradientPreview({required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = IntroColorUtils.parseGradientColors(value);
    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IntroColorUtils.parseColor(colors.start),
            IntroColorUtils.parseColor(colors.end),
          ],
        ),
      ),
    );
  }
}
