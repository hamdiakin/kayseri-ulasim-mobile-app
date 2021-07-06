import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class Settings extends StatelessWidget {
 static const String routeName = '/settings';

 @override
 Widget build(BuildContext context) {
   return new Scaffold(
       appBar: AppBar(
         title: Text("Settings"),
       ),
       drawer: NavigationDrawer(),
              body: Center(child: Text("This is Settings Page")));
 }
}