import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Alarm/set_an_alarm.dart';

void main() async{
  runApp(MyApp());
  await AndroidAlarmManager.initialize();
}


List<String> emptyList=[];
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Kayseri Ulaşım',
      home:SetAnAlarm(),
    );
  }
}

