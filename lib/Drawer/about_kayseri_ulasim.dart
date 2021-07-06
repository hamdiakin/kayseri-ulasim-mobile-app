import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class AboutKayseriUlasim extends StatelessWidget {
 static const String routeName = '/about_kayseri_ulasim';

 @override
 Widget build(BuildContext context) {
   return new Scaffold(
       appBar: AppBar(
         title: Text("About Kayseri Ulasim"),
       ),
       drawer: NavigationDrawer(),
              body: Center(child: Text("This is About Kayseri Ulasim Page")));
 }
}