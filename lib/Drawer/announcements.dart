import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class Announcements extends StatelessWidget {
  static const String routeName = '/announcements';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text(
            'drawer_announcements'.tr(),
          ),
        ),
        drawer: NavigationDrawer(),
        body: Center(
            child: Text(
          'drawer_announcements_content'.tr(),
        )));
  }
}
