import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:flutter/material.dart';

/// شاشة مخصصة للعناصر المضافة
// ignore: must_be_immutable
class OrgLoginScreen extends StatefulWidget with AppShellRouterMixin {
  OrgLoginScreen({super.key});

  @override
  State<OrgLoginScreen> createState() => _OrgLoginScreenState();
}

class _OrgLoginScreenState extends State<OrgLoginScreen> {
  final String title = "sadf";

  @override
  initState() {
    super.initState();
    // goRoute(context,  '/analyses/custem/5/new?qu=55');
    //          setState(() {

    //          });
  }

  @override
  Widget build(BuildContext context) {
    var prams = widget.getPrams();
    String id = prams!['org'];
    String qu = widget.getQuery()?["qu"] ?? "DD";

    if (prams['org'] == ":org") {
      prams['org'] = "5";
      widget.goRoute(context, '/analyses/custem/5/new');
      id = prams['org'];
    }

    return Scaffold(
      // AppBar مع إعدادات مخصصة
      appBar: AppBar(title: const Text('محتوى مخصص')),

      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  // add 2 bottons
                  ElevatedButton(
                    onPressed: () {
                      widget.goRoute(
                        context,
                        '/analyses/custem/7555/new?qu=7755',
                      );
                      setState(() {});
                    },
                    child: const Text('تعديل'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      widget.goRoute(
                        context,
                        '/analyses/custem/755/new?qu=77dd',
                      );
                      setState(() {});
                    },
                    child: const Text('حذف'),
                  ),
                ],
              ),

              Icon(
                Icons.extension,
                size: 80,
                color: const Color.fromARGB(255, 150, 122, 0),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text('محتوى مخصص تم إضافته ديناميكيًا'),
              Text(id.toString()),
              Text(qu.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
