import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kayseri_ulasim/pages/home_page.dart';

void main() async {
  runApp(MyApp());
  //await AndroidAlarmManager.initialize(); //initialize alarm_managera
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kayseri Ulaşım',
      home: MyHomePage(),
    );
  }
}
