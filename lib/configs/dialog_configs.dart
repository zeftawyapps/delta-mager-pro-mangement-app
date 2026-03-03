import 'package:flutter/material.dart';
import 'package:JoDija_tamplites/util/main-screen/screen-type.dart';
import 'package:JoDija_tamplites/util/functions/show_dialog.dart';

/// دالة مخصصة لإظهار النوافذ المنبثقة مع معالجة لوحة المفاتيح في الموبايل
void showCustomInputDialog({
  required BuildContext context,
  required Widget content,
  double height = 600,
  double width = 500,
  void Function(dynamic)? onResult,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;

  if (isMobile) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Input',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Material(color: Colors.transparent, child: content),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  } else {
    ShowInputFieldsDialogs(
      height: height,
      width: width,
      content: content,
      screenType: ScreenType.web,
    ).showDialogs(context, onResult: onResult);
  }
}
