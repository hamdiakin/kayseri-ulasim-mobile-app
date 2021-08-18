import 'dart:async';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:kayseri_ulasim/Alarm/set_an_alarm.dart';
import '../Services/notification_manager.dart';

class GetNotification extends StatefulWidget {
  final List<String> times;
  const GetNotification(this.times);

  @override
  _GetNotificationState createState() =>
      _GetNotificationState(times: this.times);
}

NotificationManager n = new NotificationManager();

class _GetNotificationState extends State<GetNotification> {
  //the data that is coming from set_notification.dart
  List<String> times;
  _GetNotificationState({this.times});

  //the switch
  bool isOn = false;

  //the alarm id
  int alarmId = 1;

  List hour = []; //hour array
  List min = []; // min array
  formatStrings() {
    for (int i = 0; i < times.length; i++) {
      hour.add(times[i].substring(0, 2)); // divide the string

      min.add(times[i].substring(3, 5)); // divide the string
    }
    print(hour);
    print(min);
  }

  //to invoke the alarm
  startAlarm() {
    formatStrings();
    for (int i = 0; i < times.length; i++) {
      AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        alarmId,
        notificate,
        startAt: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, int.parse(hour[i]), int.parse(min[i])),
      );
      print(DateTime.now());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: Center(child: Text("Alarm")),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SetAnAlarm()));
              },
              icon: Icon(Icons.add)),
        ],
      ),
      body: times.length == 0
          ? SizedBox()
          : Column(
              children: [
                InkWell(
                  child: Container(
                    color: Colors.yellow,
                    height: 100,
                    width: 100,
                    child: Center(
                      child: Transform.scale(
                        scale: 2,
                        child: Switch(
                          value: isOn,
                          onChanged: (value) {
                            setState(() {
                              isOn = value;
                            });
                            if (isOn == true) {
                              startAlarm();
                            } else {
                              AndroidAlarmManager.cancel(alarmId);
                              print('Alarm Timer Canceled');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    print(times);
                  },
                ),
              ],
            ),
    );
  }
}

//start the alarm
Future<void> notificate() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  n.initNotificationManager();
  n.showNotificationWithDefaultSound("Kayseri Ulaşım", "First Notification");
  return;
}
