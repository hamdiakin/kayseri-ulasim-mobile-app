import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:kayseri_ulasim/alarm/set_an_alarm.dart';
import '../database/db_helper_alarm.dart';
import 'notification_manager.dart';

//Schedule program class
class ScheduleProgram {
  bool enabled;
  ScheduleProgram({
    this.enabled,
  });
}

class GetNotf extends StatefulWidget {
  const GetNotf({Key key}) : super(key: key);

  @override
  _GetNotfState createState() => _GetNotfState();
}

NotificationManager n = new NotificationManager();

class _GetNotfState extends State<GetNotf> {
  // This function gets data from local database
  List<Map<String, dynamic>> alarms;
  var alarmDB;
  Future getAlarms() async {
    this.alarms = await DatabaseHelperAlarm.instance.queryAllRows();
    setState(() {
      alarmDB = alarms.toList();
    });
  }

  // Since the data loads asynchronically from db length of the data was causing problems
  // To overcome those problems I got the length directly from database itself
  int alarmLength = 0;
  Future<int> getLength() async {
    var x = await DatabaseHelperAlarm.instance.queryRowCount();
    print(x);
    alarmLength = x;
    return alarmLength;
  }

  //make a list of bool values and set all of them to false so that we can have all values false in the begggining
  List<ScheduleProgram> scheduleList = [];
  Future<List<ScheduleProgram>> generateListOfBools() async {
    await getLength();
    setState(() {
      scheduleList = List<ScheduleProgram>.generate(
        alarmLength,
        (index) => ScheduleProgram(
          enabled: false,
        ),
        growable: false,
      );
    });
    return scheduleList;
  }

  // to format the data in terms of hour and mins
  List hour = []; //hour array
  List min = []; // min array

  //The function of formatting strings
  formatStrings() async {
    getAlarms(); //First get alarms
    for (int i = 0; i < alarmLength; i++) {
      if (alarmDB[i]["timePeriod1"].length == 7) {
        //get the hour according to length of time string
        hour.add(alarmDB[i]["timePeriod1"].substring(0, 1));
      } else {
        hour.add(alarmDB[i]["timePeriod1"].substring(0, 2));
      }

      if (alarmDB[i]["timePeriod1"].length == 7) {
        //get the min according to length of time string
        min.add(alarmDB[i]["timePeriod1"].substring(2, 4));
      } else {
        min.add(alarmDB[i]["timePeriod1"].substring(3, 5)); // divide the string
      }
    }
  }

  //to invoke the alarm
  startAlarm() async {
    formatStrings();
    getLength();
    for (int i = 0; i < alarmLength; i++) {
      AndroidAlarmManager.periodic(
        const Duration(hours: 12),
        i,
        notificate,
        startAt: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, int.parse(hour[i]), int.parse(min[i])),
      );
      print(DateTime.now());
    }
  }

  @override
  void initState() {
    getAlarms();
    generateListOfBools();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: Center(child: Text("Alarms")),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SetAnAlarm()));
              },
              icon: Icon(Icons.add)),
        ],
      ),
      body: alarmLength == 0 //if no data return a sized box
          ? SizedBox()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: new ListView.builder(
                    itemCount: alarmLength,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    onTap: () {},
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              alarmDB[index]["busLine"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              alarmDB[index]["busStop"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Before ${alarmDB[index]["minBefore"]} minutes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w200,
                                                  fontSize: 13.0),
                                            ),
                                            Text(
                                              "${alarmDB[index]["timePeriod1"]}-${alarmDB[index]["timePeriod2"]}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w200,
                                                  fontSize: 13.0),
                                            ),
                                            Text(
                                              alarmDB[index]["monday"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w200,
                                                  fontSize: 13.0),
                                            ),
                                          ],
                                        ),
                                        Transform.scale(
                                          scale: 1,
                                          //to enable the switch button
                                          child: Switch(
                                            onChanged: (v) {
                                              setState(() {
                                                scheduleList[index].enabled = v;
                                              });
                                              //if enabled start the alarm
                                              if (v == true) {
                                                startAlarm(); //the function to start the alarm
                                                print('Alarm Timer Started!');
                                              }
                                              //if disabled cancel the alarm
                                              else {
                                                AndroidAlarmManager.cancel(
                                                    index);
                                                print('Alarm Timer Canceled');
                                              }
                                            },
                                            value: scheduleList[index]
                                                .enabled, //set the value to the selected one
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

//start the alarm funciton
Future<void> notificate() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  n.initNotificationManager();
  n.showNotificationWithDefaultSound("Kayseri Ulaşım", "First Notification");
  return;
}
