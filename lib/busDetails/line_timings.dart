import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rolling_switch/rolling_switch.dart';

class LineTimings extends StatefulWidget {
  final String busName;
  final String busCode;
  final String firstStation;
  final String lastStation;

  const LineTimings(
      this.busName, this.busCode, this.firstStation, this.lastStation);

  @override
  _LineTimingsState createState() => _LineTimingsState(
      busName: this.busName,
      busCode: this.busCode,
      firstStation: this.firstStation,
      lastStation: this.lastStation);
}

class _LineTimingsState extends State<LineTimings> {
  _LineTimingsState(
      {this.busName, this.busCode, this.firstStation, this.lastStation});

  String busName;
  String busCode;
  String firstStation; //if departure, show first station
  String lastStation; // if arrival, show last station
  bool decidedStation = true; //decide if arrival or departure direction

  List<dynamic> lineTimes; //get data into list

  Future<List<Map<String, dynamic>>> getBusTimes() async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/timetable"));
    if (response.statusCode != 200) return null;
    lineTimes = List<Map<String, dynamic>>.from(
        json.decode(response.body)['lineSchedules']);
    return lineTimes;
  }

  Future<List> lineTimesFuture;
  @override
  void initState() {
    lineTimesFuture = getBusTimes(); // set the future list to our list
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getStationName() {
      //method for showing first or last station
      if (decidedStation == true) {
        return firstStation;
      } else {
        return lastStation;
      }
    }

    return WillPopScope(
      //put customized back arrow
      onWillPop: () async => false, //don't let the system pop automatically
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: PreferredSize(
          //change appbar size
          preferredSize:
              Size.fromHeight((MediaQuery.of(context).size.height) * 2 / 30),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Colors.blueGrey.shade900,
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text("Timetable"),
            actions: [
              /* Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: decidedStation ? Colors.blue : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            decidedStation =
                                true; //change the direction to DEPARTURE when clicked
                          });
                          //getBusLine();
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: decidedStation ? Colors.white : Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            decidedStation =
                                false; //change the direction to ARRIVAL when clicked
                          });
                          //getBusLine();
                        },
                      ),
                    ),
                  ],
                ),
              ), */
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                    busName,
                    style: TextStyle(fontSize: 15.0),
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: Text(
                      getStationName(),
                      style: TextStyle(fontSize: 15.0, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width) * 6 / 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Working Days",
                              style: TextStyle(fontSize: 15.0),
                            ),
                            Container(
                              height: (MediaQuery.of(context).size.height) *
                                  13 /
                                  20,
                              child: FutureBuilder<List>(
                                future: lineTimesFuture, //future of lineTimes
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        itemCount: snapshot.data
                                            .length, //set the length to hole data length
                                        itemBuilder: (BuildContext ctx, index) {
                                          return decidedStation == true
                                              ? //if the direction decided by USER is DEPARTURE
                                              snapshot.data[index][
                                                              "direction"] == //if the direction is DEPARTURE
                                                          "DEPARTURE" &&
                                                      snapshot.data[index]
                                                              ["dayType"] ==
                                                          "WORKDAY" //if it is workday
                                                  ? Card(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text(snapshot
                                                                    .data[index]
                                                                ["time"]),
                                                          ],
                                                        ),
                                                      ),
                                                      shadowColor: Colors.grey)
                                                  : SizedBox(
                                                      height: 0.0,
                                                      width: 0.0,
                                                    )
                                              : decidedStation == false
                                                  ? //if the direction decided by USER is ARRIVAL
                                                  snapshot.data[index][
                                                                  "direction"] == //if the direction is ARRIVAL
                                                              "ARRIVAL" &&
                                                          snapshot.data[index]
                                                                  ["dayType"] ==
                                                              "WORKDAY"
                                                      ? Card(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Text(snapshot
                                                                            .data[
                                                                        index]
                                                                    ["time"]),
                                                              ],
                                                            ),
                                                          ),
                                                          shadowColor:
                                                              Colors.grey)
                                                      : SizedBox(
                                                          height: 0.0,
                                                          width: 0.0,
                                                        )
                                                  : SizedBox(
                                                      height: 0.0,
                                                      width: 0.0,
                                                    ); //if no data but SizedBox()
                                        });
                                  }
                                  return LinearProgressIndicator(); //until data comes show linear progress indicator
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Container(
                        width: (MediaQuery.of(context).size.width) * 6 / 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Saturday", //for SATURDAY column
                              style: TextStyle(fontSize: 15.0),
                            ),
                            Container(
                              height: (MediaQuery.of(context).size.height) *
                                  13 /
                                  20,
                              child: FutureBuilder<List>(
                                future: lineTimesFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (BuildContext ctx, index) {
                                          return decidedStation == true
                                              ? (snapshot.data[index]
                                                              ["direction"] ==
                                                          "DEPARTURE" &&
                                                      snapshot.data[index]
                                                              ["dayType"] ==
                                                          "SATURDAY"
                                                  ? Card(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text(snapshot
                                                                    .data[index]
                                                                ["time"]),
                                                          ],
                                                        ),
                                                      ),
                                                      shadowColor: Colors.grey)
                                                  : SizedBox(
                                                      height: 0.0,
                                                      width: 0.0,
                                                    ))
                                              : decidedStation == false
                                                  ? snapshot.data[index][
                                                                  "direction"] ==
                                                              "ARRIVAL" &&
                                                          snapshot.data[index]
                                                                  ["dayType"] ==
                                                              "SATURDAY"
                                                      ? Card(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Text(snapshot
                                                                            .data[
                                                                        index]
                                                                    ["time"]),
                                                              ],
                                                            ),
                                                          ),
                                                          shadowColor:
                                                              Colors.grey)
                                                      : SizedBox(
                                                          height: 0.0,
                                                          width: 0.0,
                                                        )
                                                  : SizedBox(
                                                      height: 0.0,
                                                      width: 0.0,
                                                    );
                                        });
                                  }
                                  return LinearProgressIndicator();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Container(
                        width: (MediaQuery.of(context).size.width) * 6 / 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Sunday/Holiday", //For SUNDAY column
                              style: TextStyle(fontSize: 15.0),
                            ),
                            Container(
                              height: (MediaQuery.of(context).size.height) *
                                  13 /
                                  20,
                              child: FutureBuilder<List>(
                                future: lineTimesFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (BuildContext ctx, index) {
                                          return decidedStation == true
                                              ? snapshot.data[index]
                                                              ["direction"] ==
                                                          "DEPARTURE" &&
                                                      snapshot.data[index]
                                                              ["dayType"] ==
                                                          "SUNDAY"
                                                  ? Card(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text(snapshot
                                                                    .data[index]
                                                                ["time"]),
                                                          ],
                                                        ),
                                                      ),
                                                      shadowColor: Colors.grey)
                                                  : SizedBox(
                                                      height: 0.0,
                                                      width: 0.0,
                                                    )
                                              : decidedStation == false
                                                  ? snapshot.data[index][
                                                                  "direction"] ==
                                                              "ARRIVAL" &&
                                                          snapshot.data[index]
                                                                  ["dayType"] ==
                                                              "SUNDAY"
                                                      ? Card(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Text(snapshot
                                                                            .data[
                                                                        index]
                                                                    ["time"]),
                                                              ],
                                                            ),
                                                          ),
                                                          shadowColor:
                                                              Colors.grey)
                                                      : SizedBox(
                                                          height: 0.0,
                                                          width: 0.0,
                                                        )
                                                  : SizedBox(
                                                      height: 0.0,
                                                      width: 0.0,
                                                    );
                                        });
                                  }
                                  return LinearProgressIndicator();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),

            Flexible(
              child: RollingSwitch.icon(
                onChanged: (bool state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (state) {
                        setState(() {
                          decidedStation = false;
                        });
                      } else {
                        setState(() {
                          decidedStation = true;
                        });
                      }
                    });
                },
                rollingInfoRight: const RollingIconInfo(
                  icon: Icons.arrow_forward_rounded,
                  text: Text('Departure'),
                ),
                rollingInfoLeft: const RollingIconInfo(
                  icon: Icons.arrow_back_rounded,
                  backgroundColor: Colors.grey,
                  text: Text('Arrival'),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 1/40
            ),
            /* Center(
              child: LiteRollingSwitch(
                //initial value
                value: true,
                textOn: 'Departure',
                textOff: 'Arrival',
                colorOn: Colors.blueGrey,
                colorOff: Colors.blue,
                iconOn: Icons.arrow_forward_rounded,
                iconOff: Icons.arrow_back_rounded,
                textSize: 14.0,
                onChanged: (bool state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (state) {
                      setState(() {
                        decidedStation = false;
                      });
                    } else {
                      setState(() {
                        decidedStation = true;
                      });
                    }
                  });
                  //Use it to manage the different states

                  print('Current State of SWITCH IS: $state');
                },
              ),
            ), */

            /* Container(
                /* width: MediaQuery.of(context).size.width * 5 /20,
                height: MediaQuery.of(context).size.height * 3 / 20, */
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: LiteRollingSwitch(
                          //initial value
                          value: true,
                          textOn: 'Arrival',
                          textOff: 'Departure',
                          colorOn: Colors.greenAccent[700],
                          colorOff: Colors.redAccent[700],
                          iconOn: Icons.arrow_forward_rounded,
                          iconOff: Icons.arrow_back_rounded,
                          textSize: 14.0,
                          onChanged: (bool state) {
                            //Use it to manage the different states
                            print('Current State of SWITCH IS: $state');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ), */
          ],
        ),
      ),
    );
  }
}
