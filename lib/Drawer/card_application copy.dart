import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class Survey extends StatelessWidget {
 static const String routeName = '/survey';

 @override
 Widget build(BuildContext context) {
   return new Scaffold(
       appBar: AppBar(
         title: Text("Survey"),
       ),
       drawer: NavigationDrawer(),
              body: Center(child: Text("This is Survey Page")));
 }
}