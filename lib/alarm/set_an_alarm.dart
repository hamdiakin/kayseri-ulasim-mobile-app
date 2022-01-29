/* import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kayseri_ulasim/alarm/get_notf.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:http/http.dart' as http;
import '../database/db_helper_alarm.dart';

class SetAnAlarm extends StatefulWidget {
  const SetAnAlarm({Key key}) : super(key: key);

  @override
  _SetAnAlarmState createState() => _SetAnAlarmState();
}

//create a database instance
final dbHelper = DatabaseHelperAlarm.instance;

enum SingingCharacter { destination, arrival } //radio buttons
SingingCharacter _character = SingingCharacter.destination; //radio buttons

class _SetAnAlarmState extends State<SetAnAlarm> {
  final formKey = new GlobalKey<FormState>();

  TimeOfDay _time1 =
      TimeOfDay.now(); //for interval in which the notification will be sent
  TimeOfDay _time2 =
      TimeOfDay.now(); //for interval in which the notification will be sent

  //To see the first clock on the screen
  void _selectTime1() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _time1,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _time1 = newTime;
      });
    }
  }

  //To see the second clock on the screen
  void _selectTime2() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _time2,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _time2 = newTime;
      });
    }
  }

  //line list in dropdown button
  List<DropdownMenuItem<ListItem>> _lines;
  ListItem _selectedLine;
  List<ListItem> _lineList = [
    ListItem(1, "220"),
    ListItem(2, "248"),
    ListItem(3, "550")
  ];

  //stop list in dropdown button
  List<DropdownMenuItem<ListItem>> _stops;
  ListItem _selectedStop;
  List<ListItem> _stopList = [
    ListItem(1, "134"),
    ListItem(2, "3"),
    ListItem(3, "88")
  ];

  //time intervals list in dropdown button
  List<DropdownMenuItem<ListItem>> _times;
  ListItem _selectedTime;
  List<ListItem> _timeList = [
    ListItem(1, "0-5"),
    ListItem(2, "5-10"),
    ListItem(3, "10-15"),
    ListItem(4, "15-20"),
    ListItem(5, "20-25"),
    ListItem(6, "25-30"),
    ListItem(7, "35-40")
  ];

  //The function to build the dropdown menu
  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = [];
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  // To check if exist in the db
  bool check = false;
  inCheck() async {
    bool propCheck = await dbHelper.ifContains(_selectedLine.name, destination);

    setState(() {
      check = propCheck;
    });
    print("does it exist? $check");
  }

  @override
  void initState() {
    super.initState();
    _stops = buildDropDownMenuItems(_stopList); //build stops dropdown
    _lines = buildDropDownMenuItems(_lineList); //build lines dropdown
    _times = buildDropDownMenuItems(_timeList); //build times dropdown
    _selectedTime = _times[0]
        .value; //set the value to the first item if no selected item found
  }

  // all data
  List allData;
  Future<List<dynamic>> getBusTimes() async {
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/StopTimesForLine?DurakId=${_selectedStop.name}&HatKod=${_selectedLine.name}"),
        headers: {"Accept": "application/json"});
    this.setState(() {
      allData = jsonDecode(response.body);
    });
    return allData; // all the data about a line
  }

  //get times to stop
  List<String> timesToStop = [];
  getTimes() async {
    await getBusTimes();
    for (int i = 0; i < allData.length; i++) {
      timesToStop.add(allData[i]["timeToStop"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: Center(child: Text('Set an alarm')),
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(5),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.directions_bus,
                            color: Colors.blueGrey.shade700,
                          )),
                      Expanded(
                        flex: 4,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ListItem>(
                              value: _selectedLine,
                              items: _lines,
                              hint: Text("Select a line"),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLine = value;
                                });
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
                getDestination(),
                Container(
                  margin: EdgeInsets.all(5),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.subway,
                            color: Colors.blueGrey.shade700,
                          )),
                      Expanded(
                        flex: 4,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ListItem>(
                              value: _selectedStop,
                              items: _stops,
                              hint: Text("Select a stop"),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStop = value;
                                });
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.calendar_today_sharp,
                            color: Colors.blueGrey.shade700,
                          )),
                      Expanded(
                        flex: 4,
                        child: MultiSelectFormField(
                          autovalidate: false,
                          checkBoxActiveColor: Colors.blue,
                          checkBoxCheckColor: Colors.white,
                          title: Text(
                            "Select a Day",
                            style: TextStyle(fontSize: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.length == 0) {
                              return 'Select a Day';
                            }
                            return null;
                          },
                          dataSource: [
                            {
                              "display": "Monday",
                              "value": "Monday",
                            },
                            {
                              "display": "Tuesday",
                              "value": "Tuesday",
                            },
                            {
                              "display": "Wednesday",
                              "value": "Wednesday",
                            },
                            {
                              "display": "Thursday",
                              "value": "Thursday",
                            },
                            {
                              "display": "Friday",
                              "value": "Friday",
                            },
                            {
                              "display": "Saturday",
                              "value": "Saturday",
                            },
                            {
                              "display": "Sunday",
                              "value": "Sunday",
                            },
                          ],
                          border:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          textField: 'display',
                          valueField: 'value',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          hintWidget: Text('Please choose one or more'),
                          onSaved: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.timer_outlined,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ListItem>(
                                value: _selectedTime,
                                items: _times,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTime = value;
                                  });
                                }),
                          ),
                        ),
                        Expanded(
                            flex: 1, child: Text("min before bus arrives")),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text("Select Time Period")),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueGrey,
                            ),
                            onPressed: _selectTime1,
                            child: Text('${_time1.format(context)}'),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueGrey,
                            ),
                            onPressed: _selectTime2,
                            child: Text('${_time2.format(context)}'),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 10.0),
                Container(
                  child: TextButton(
                    onPressed: () async {
                      getBusTimes();
                      getTimes();
                      await inCheck();
                      if (check)
                        print("already exist");
                      else
                        _insert(
                            _selectedLine.name,
                            destination,
                            _selectedStop.name,
                            "Monday",
                            _selectedTime.name,
                            _time1.format(context),
                            _time2.format(context));
                      _query();
                      inCheck();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => GetNotf()));
                    },
                    child: Container(
                      height:40.0,
                      width: 60.0,
                      color: Colors.blueGrey.shade900,
                        child: Center(child: Text("Save",style: TextStyle(color: Colors.white),))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Get the selected destination
  String destination = "DEPARTURE";
  Widget getDestination() {
    return _selectedLine ==
            null // if no selected line found than don2t take selected destination
        ? SizedBox()
        : Container(
            margin: const EdgeInsets.all(5.0),
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.directions,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Select Direction",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Destination'),
                            Radio<SingingCharacter>(
                              value: SingingCharacter.destination,
                              groupValue: _character,
                              onChanged: (SingingCharacter value) {
                                setState(() {
                                  _character = value;
                                  destination = "DEPARTURE";
                                });
                              },
                            ),
                            Text('Arrival'),
                            Radio<SingingCharacter>(
                              value: SingingCharacter.arrival,
                              groupValue: _character,
                              onChanged: (SingingCharacter value) {
                                setState(() {
                                  _character = value;
                                  destination = "ARRIVAL";
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

//database insert function
void _insert(
    String busLine1,
    String destination1,
    String busStop1,
    String monday1,
    String minBefore1,
    String timePeriod11,
    String timePeriod22) async {
  // row to insert
  Map<String, dynamic> row = {
    DatabaseHelperAlarm.busLine: '$busLine1',
    DatabaseHelperAlarm.destination: '$destination1',
    DatabaseHelperAlarm.busStop: '$busStop1',
    DatabaseHelperAlarm.monday: '$monday1',
    DatabaseHelperAlarm.minBefore: '$minBefore1',
    DatabaseHelperAlarm.timePeriod1: '$timePeriod11',
    DatabaseHelperAlarm.timePeriod2: '$timePeriod22'
  };
  final id = await dbHelper.insert(row);
  print('inserted row id: $id');
}

//quert the row inserted
void _query() async {
  final allRows = await dbHelper.queryAllRows();
  print('query all rows:');
  allRows.forEach(print);
}

//the value and name of the dropdowns
class ListItem {
  int value;
  String name;
  ListItem(this.value, this.name);
}
 */