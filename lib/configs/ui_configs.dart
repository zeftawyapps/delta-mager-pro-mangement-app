import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/app_bar_config.dart';
import 'package:JoDija_tamplites/util/localization/loaclized_init.dart';
import 'package:JoDija_tamplites/util/localization/loclization/app_localizations.dart';
import 'package:flutter/material.dart';

class DefaultAppLocal extends AppLocal {
  @override
  Map<String, String> get values => {};
}

class LocalizationConfigs {
  static Map<String, AppLocalizationsInit> buildLocalizations() {
    return {'ar': DefaultAppLocal(), 'en': DefaultAppLocal()};
  }
}

class AppBarConfigs {
  static AppBarConfig buildSmallScreenAppBar(BuildContext context) {
    return AppBarConfig(title: 'Small Screen');
  }

  static AppBarConfig buildLargeScreenAppBar(BuildContext context) {
    return AppBarConfig(title: 'Large Screen');
  }
}

class ErrorsScreen extends StatelessWidget {
  const ErrorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Error Screen')));
  }
}
