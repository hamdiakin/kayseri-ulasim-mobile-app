import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class AboutKayseri extends StatelessWidget {
 static const String routeName = '/about_kayseri';

 @override
 Widget build(BuildContext context) {
   return new Scaffold(
       appBar: AppBar(
         title: Text("About Kayseri"),
       ),
       drawer: NavigationDrawer(),
              body: Center(child: Text("This is About Kayseri Page")));
 }
}