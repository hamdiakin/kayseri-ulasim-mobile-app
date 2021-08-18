import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        appBar: PreferredSize(
          //change appbar size
          preferredSize:
              Size.fromHeight((MediaQuery.of(context).size.height) * 2 / 20),
          child: AppBar(
            backgroundColor: Colors.blueGrey.shade900,
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Center(child: Text("Timetable")),
            actions: [
              Padding(
                padding: const EdgeInsets.all(2.0),
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
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: Text(
                busName,
                style: TextStyle(fontSize: 20.0),
              )),
              SizedBox(
                height: 10.0,
              ),
              Text(
                getStationName(),
                style: TextStyle(fontSize: 20.0, color: Colors.blue),
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
                          height:
                              (MediaQuery.of(context).size.height) * 13 / 20,
                          child: FutureBuilder<List>(
                            future: lineTimesFuture, //future of lineTimes
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    itemCount: snapshot.data
                                        .length, //set the length to hole data length
                                    itemBuilder: (BuildContext ctx, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black12,
                                            border: Border.all(
                                                color: Colors.black)),
                                        alignment: Alignment.center,
                                        child: decidedStation == true
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
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: <Widget>[
                                                          Text(snapshot
                                                                  .data[index]
                                                              ["time"]),
                                                        ],
                                                      ),
                                                    ),
                                                  )
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
                                                            children: <Widget>[
                                                              Text(
                                                                  snapshot.data[
                                                                          index]
                                                                      ["time"]),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0.0,
                                                        width: 0.0,
                                                      )
                                                : SizedBox(
                                                    height: 0.0,
                                                    width: 0.0,
                                                  ), //if no data but SizedBox()
                                      );
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
                          height:
                              (MediaQuery.of(context).size.height) * 13 / 20,
                          child: FutureBuilder<List>(
                            future: lineTimesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (BuildContext ctx, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black12,
                                            border: Border.all(
                                                color: Colors.black)),
                                        alignment: Alignment.center,
                                        child: decidedStation == true
                                            ? snapshot.data[index]
                                                            ["direction"] ==
                                                        "DEPARTURE" &&
                                                    snapshot.data[index]
                                                            ["dayType"] ==
                                                        "SATURDAY"
                                                ? Card(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: <Widget>[
                                                          Text(snapshot
                                                                  .data[index]
                                                              ["time"]),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0.0,
                                                    width: 0.0,
                                                  )
                                            : decidedStation == false
                                                ? snapshot.data[index]
                                                                ["direction"] ==
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
                                                            children: <Widget>[
                                                              Text(
                                                                  snapshot.data[
                                                                          index]
                                                                      ["time"]),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0.0,
                                                        width: 0.0,
                                                      )
                                                : SizedBox(
                                                    height: 0.0,
                                                    width: 0.0,
                                                  ),
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
                          height:
                              (MediaQuery.of(context).size.height) * 13 / 20,
                          child: FutureBuilder<List>(
                            future: lineTimesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (BuildContext ctx, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black12,
                                            border: Border.all(
                                                color: Colors.black)),
                                        alignment: Alignment.center,
                                        child: decidedStation == true
                                            ? snapshot.data[index]
                                                            ["direction"] ==
                                                        "DEPARTURE" &&
                                                    snapshot.data[index]
                                                            ["dayType"] ==
                                                        "SUNDAY"
                                                ? Card(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: <Widget>[
                                                          Text(snapshot
                                                                  .data[index]
                                                              ["time"]),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0.0,
                                                    width: 0.0,
                                                  )
                                            : decidedStation == false
                                                ? snapshot.data[index]
                                                                ["direction"] ==
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
                                                            children: <Widget>[
                                                              Text(
                                                                  snapshot.data[
                                                                          index]
                                                                      ["time"]),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0.0,
                                                        width: 0.0,
                                                      )
                                                : SizedBox(
                                                    height: 0.0,
                                                    width: 0.0,
                                                  ),
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
      ),
    );
  }
}
