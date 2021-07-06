import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class ContactUs extends StatelessWidget {
 static const String routeName = '/contact_us';

 @override
 Widget build(BuildContext context) {
   return new Scaffold(
       appBar: AppBar(
         title: Text("Contact Us"),
       ),
       drawer: NavigationDrawer(),
              body: Center(child: Text("This is Contact Us Page")));
 }
}