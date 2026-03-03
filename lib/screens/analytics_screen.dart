import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AnalyticsScreen extends StatefulWidget with AppShellRouterMixin {
  AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحليلات')),
      body: const Center(
        child: Text('التحليلات (قريباً)', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
