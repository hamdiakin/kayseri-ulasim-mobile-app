import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class Announcements extends StatelessWidget {
 static const String routeName = '/announcements';

 @override
 Widget build(BuildContext context) {
   return new Scaffold(
       appBar: AppBar(
         title: Text("Announcements"),
       ),
       drawer: NavigationDrawer(),
              body: Center(child: Text("This is Announcements Page")));
 }
}