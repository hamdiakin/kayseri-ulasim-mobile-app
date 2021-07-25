import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kayseri_ulasim/mainPage.dart';
import 'package:kayseri_ulasim/map/mapGoogle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Kayseri Ulaşım',
      home: mapGoogle(),
    );
  }
}

