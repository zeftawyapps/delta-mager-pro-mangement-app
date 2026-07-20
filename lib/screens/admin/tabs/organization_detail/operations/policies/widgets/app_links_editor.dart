import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class AppLinksEditor extends StatelessWidget {
  final List<AppLinkItem> links;
  final bool isEditing;
  final ValueChanged<List<AppLinkItem>> onLinksChanged;
  final bool isDark;

  const AppLinksEditor({
    super.key,
    required this.links,
    required this.isEditing,
    required this.onLinksChanged,
    required this.isDark,
  });

  QuillController _initQuillController(String? htmlContent) {
    Delta delta;
    try {
      if (htmlContent != null && htmlContent.isNotEmpty) {
        delta = HtmlToDelta().convert(htmlContent);
        if (delta.isEmpty) {
          delta = Delta()..insert('\n');
        }
      } else {
        delta = Delta()..insert('\n');
      }
    } catch (_) {
      delta = Delta()..insert('\n');
    }
    return QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  String _quillToHtml(QuillController controller) {
    try {
      final deltaJson = controller.document.toDelta().toJson();
      final converter = QuillDeltaToHtmlConverter(
        List<Map<String, dynamic>>.from(deltaJson),
      );
      return converter.convert();
    } catch (_) {
      return '';
    }
  }

  void _showAddLinkDialog(BuildContext context, {AppLinkItem? editingLink, int? index}) {
    final titleController = TextEditingController(text: editingLink?.title ?? '');
    final urlController = TextEditingController(text: editingLink?.url ?? '');
    final bodyController = _initQuillController(editingLink?.body);
    String linkType = editingLink?.linkType ?? 'external';
    String displayLocation = editingLink?.displayLocation ?? 'both';
    String? textColor = editingLink?.textColor ?? '#1E3A8A'; // default primary-like hex
    String fontWeight = editingLink?.fontWeight ?? 'normal';
    bool isUnderlined = editingLink?.isUnderlined ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(editingLink == null ? "إضافة رابط تطبيق جديد" : "تعديل الرابط"),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: linkType,
                    decoration: const InputDecoration(labelText: "نوع الرابط"),
                    items: const [
                      DropdownMenuItem(value: 'external', child: Text('رابط خارجي (URL)')),
                      DropdownMenuItem(value: 'page', child: Text('صفحة داخل التطبيق')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => linkType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: linkType == 'page'
                          ? "عنوان الصفحة (مثال: سياسة الاسترجاع)"
                          : "عنوان الرابط (مثال: سياسة الاسترجاع)",
                    ),
                  ),
                  if (linkType == 'external')
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(labelText: "رابط URL الموجه له"),
                    ),
                  if (linkType == 'page') ...[
                    const SizedBox(height: 16),
                    Text(
                      "محتوى الصفحة (نص مزين)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          QuillSimpleToolbar(
                            controller: bodyController,
                            config: const QuillSimpleToolbarConfig(
                              showFontFamily: false,
                              showFontSize: false,
                              showInlineCode: false,
                              showSubscript: false,
                              showSuperscript: false,
                              showSearchButton: false,
                              showListCheck: false,
                              showIndent: false,
                              multiRowsDisplay: false,
                            ),
                          ),
                          const Divider(height: 1),
                          SizedBox(
                            height: 220,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: QuillEditor.basic(
                                controller: bodyController,
                                config: const QuillEditorConfig(
                                  placeholder: "اكتب محتوى الصفحة وقم بتنسيقه هنا...",
                                  expands: true,
                                  scrollable: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: displayLocation,
                    decoration: const InputDecoration(labelText: "مكان العرض"),
                    items: const [
                      DropdownMenuItem(value: 'header', child: Text('الهيدر فقط')),
                      DropdownMenuItem(value: 'footer', child: Text('الفوتر فقط')),
                      DropdownMenuItem(value: 'both', child: Text('الهيدر والفوتر معاً')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => displayLocation = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: fontWeight,
                    decoration: const InputDecoration(labelText: "سمك الخط (Weight)"),
                    items: const [
                      DropdownMenuItem(value: 'normal', child: Text('خط عادي (Normal)')),
                      DropdownMenuItem(value: 'bold', child: Text('خط عريض (Bold)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => fontWeight = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text("وضع خط أسفل الرابط (Underline)"),
                    value: isUnderlined,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => isUnderlined = val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("لون الخط: "),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _parseHexColor(textColor),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (pickerCtx) => AlertDialog(
                              title: const Text('اختر لون الخط للرابط'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: _parseHexColor(textColor),
                                  onColorChanged: (color) {
                                    textColor = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {});
                                    Navigator.pop(pickerCtx);
                                  },
                                  child: const Text('حفظ اللون'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text("تغيير اللون"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                final bodyHtml = _quillToHtml(bodyController);
                final isValid = titleController.text.isNotEmpty &&
                    (linkType == 'page' || urlController.text.isNotEmpty);
                if (isValid) {
                  final newLinks = List<AppLinkItem>.from(links);
                  final item = AppLinkItem(
                    title: titleController.text,
                    url: urlController.text,
                    displayLocation: displayLocation,
                    textColor: textColor,
                    fontWeight: fontWeight,
                    isUnderlined: isUnderlined,
                    linkType: linkType,
                    body: linkType == 'page' ? bodyHtml : null,
                  );
                  if (index != null) {
                    newLinks[index] = item;
                  } else {
                    newLinks.add(item);
                  }
                  onLinksChanged(newLinks);
                }
                Navigator.pop(dialogContext);
              },
              child: Text(editingLink == null ? "إضافة" : "حفظ"),
            ),
          ],
        ),
      ),
    ).then((_) => bodyController.dispose());
  }

  Color _parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.black;
    try {
      final formatted = hexString.replaceAll('#', '');
      return Color(int.parse('FF$formatted', radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }

  String _getLocationName(String location) {
    switch (location) {
      case 'header':
        return 'الهيدر';
      case 'footer':
        return 'الفوتر';
      default:
        return 'الهيدر والفوتر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white70 : Colors.grey[800];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "روابط التطبيق المضافة",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: titleColor),
            ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                onPressed: () => _showAddLinkDialog(context),
                tooltip: "إضافة رابط جديد",
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (links.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "لا توجد روابط مضافة حالياً. سيتم استخدام الروابط الافتراضية.",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? Colors.grey : Colors.grey[600]),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: links.length,
            itemBuilder: (context, idx) {
              final link = links[idx];
              final isBold = link.fontWeight == 'bold';
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    link.isPage ? Icons.article_outlined : Icons.open_in_new,
                    size: 18,
                    color: link.isPage ? Colors.purple : Colors.blue,
                  ),
                  title: Text(
                    link.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: _parseHexColor(link.textColor),
                      decoration: link.isUnderlined == true ? TextDecoration.underline : null,
                    ),
                  ),
                  subtitle: Text(
                    "${link.isPage ? 'صفحة داخلية' : link.url} • مكان العرض: ${_getLocationName(link.displayLocation)}",
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: isEditing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange, size: 16),
                              onPressed: () => _showAddLinkDialog(context, editingLink: link, index: idx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                              onPressed: () {
                                final newLinks = List<AppLinkItem>.from(links)..removeAt(idx);
                                onLinksChanged(newLinks);
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }
}
