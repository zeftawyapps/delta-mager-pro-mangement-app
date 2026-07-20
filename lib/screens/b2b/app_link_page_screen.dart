import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

/// Displays an in-app page for an [AppLinkItem] of type 'page'.
///
/// Renders the styled (rich text / HTML) body content in a read-only Quill
/// editor so the formatting authored in the admin panel is preserved.
class AppLinkPageScreen extends StatefulWidget {
  final String title;
  final String? bodyHtml;

  const AppLinkPageScreen({
    super.key,
    required this.title,
    this.bodyHtml,
  });

  @override
  State<AppLinkPageScreen> createState() => _AppLinkPageScreenState();
}

class _AppLinkPageScreenState extends State<AppLinkPageScreen> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _initController(widget.bodyHtml);
  }

  QuillController _initController(String? htmlContent) {
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
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasContent = widget.bodyHtml != null && widget.bodyHtml!.trim().isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: isDark ? DarkColors.surface : LightColors.primary,
          foregroundColor: Colors.white,
        ),
        body: hasContent
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: QuillEditor.basic(
                  controller: _controller,
                  config: const QuillEditorConfig(
                    showCursor: false,
                    padding: EdgeInsets.zero,
                  ),
                ),
              )
            : Center(
                child: Text(
                  "لا يوجد محتوى لعرضه حالياً.",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey : Colors.grey[600],
                  ),
                ),
              ),
      ),
    );
  }
}
