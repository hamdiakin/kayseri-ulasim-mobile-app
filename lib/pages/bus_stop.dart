import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/busDetails/alt_line_detail.dart';
import 'package:kayseri_ulasim/busDetails/alt_line_detail2.dart';
import 'package:kayseri_ulasim/busDetails/line_detail.dart';
import 'package:kayseri_ulasim/database/database_helper.dart';
import 'package:kayseri_ulasim/pages/home_page.dart';
import 'package:kayseri_ulasim/pages/line_stop_times.dart';

class BusStopPage extends StatefulWidget {
  final String busStopName;
  final String busStopCode;
  const BusStopPage({Key key, this.busStopName, this.busStopCode})
      : super(key: key);

  @override
  _BusStopPageState createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  // Jam area for update favorites function

  // For local database
  final dbHelper = DatabaseHelper.instance;

  // Lists are containing code information and the index of the code within the data source.
  List<String> _selectedCodeList = [];
  List<int> _selectedIndexList1 = [];

  // Bool selectionState is a key factor of the function of the page, it will be used to decide if the block is selected or not.
  bool selectionState = false;
  Future<List> fAprLines;

  // _changeSelection function adds or deletes the wanted data from the above list
  void _changeSelection({String code, int index}) {
    if (_selectedCodeList.contains(code) == false) {
      _selectedCodeList.add(code);
      _selectedIndexList1.add(index);
    } else if (_selectedCodeList.contains(code)) {
      _selectedCodeList.remove(code);
      _selectedIndexList1.remove(index);
    }
    if (_selectedCodeList.isNotEmpty) {
      selectionState = true;
    } else if (_selectedCodeList.isEmpty) {
      selectionState = false;
    }
  }

  // This function and list hold the information of the bus lines that passes through the bus stop
  List busLinesData;
  Future<List> getBusLines() async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/code/${widget.busStopCode}/buslines?cityId=6"));
    if (response.statusCode == 200) {
      this.busLinesData = jsonDecode(response.body);
      return busLinesData;
    }
  }

  Future<List> busLineData;

  // This function and list hold the information of the approaching lines to the bus stop - generally under 60 minutes
  List aprLinesData;
  Future<List> aprBusLines() async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/code/${widget.busStopCode}/buses"));
    if (response.statusCode == 200) {
      this.aprLinesData = jsonDecode(response.body);
      return aprLinesData;
    }
  }

  Future<List> aprLineData;

  // This function compares the name of the bus line to the approcahing lines and returns, if there is, the time for a bus to come to the bus stop
  String getTimetoStop(String name) {
    String dummy = "";
    for (var i = 0; i < aprLinesData.length; i++) {
      if (aprLinesData[i]["line"]["name"] == name) {
        dummy = formatter(aprLinesData[i]["doorNo"]);
        return dummy;
      }
    }
    return "bus_stop_busInfo_msg".tr();
  }

  String formatter(String s) {
    String leading = "[";
    String rest = "";
    int length = s.length;

    int i = 0;
    while (i < s.length && s[i] != "-") {
      leading += s[i];
      i++;
    }

    leading += "] ";

    for (int j = i + 1; j < length; j++) {
      rest += s[j];
    }

    return leading + rest;
  }

  String formatter_new(String s) {
    String kuplet = "";
    String open = "[";
    String close = "]";

    s += "*";
    kuplet += open;

    if (s == "PLAN") return "[PLAN]";

    for (int i = 0; i < s.length - 1; i++) {
      if (int.tryParse(s[i]) != null) {
        kuplet += s[i];
      } else if (s[i] == " " && int.tryParse(s[i + 1]) == null) {
        kuplet += close;
      } else if (s[i] == " ") {
        kuplet += " ";
        kuplet += open;
      }

      if (s[i + 1] == "*") {
        kuplet += close;
      }
    }
    return kuplet;

    /* bool flag = false;
    returnVal += open;

    int counter = 1;
    if (s.length < 10) {
      for (int i = 0; i < s.length; i++) {
        if (int.tryParse(s[i]) != null && s[i] != " ") {
          if (counter == 0) {
            returnVal += open;
            counter++;
          }
          returnVal += s[i];
        } else if (counter == 1) {
          returnVal += close;
          returnVal += "";
          counter--;

          if(s[i+1] == null && counter == 0){
            returnVal += "]";
          }
        }
      }
    } else {
      for (int i = 0; i < s.length; i++) {
        if (int.tryParse(s[i]) != null && s[i] != " " && flag == false) {
          if (counter == 0) {
            returnVal += open;
            counter++;
          }
          returnVal += s[i];
        } else if (counter == 1 && flag == false) {
          returnVal += close;
          returnVal += " ";
          flag = true;
        }
        if (flag) {
          for (int j = i; j < s.length; j++) {
            if (s[j] != "-") returnVal += s[j];
          }
          break;
        } */

    //returnVal += s[i];

    /* if(flag){
        if(s[i] != "-"){
          if(int.tryParse(s[i]) != null){
            returnVal += s[i];
          }else if(isSpace == false){
            returnVal += " ";
            returnVal += s[i];
            isSpace = true;
          }
          else if(isSpace){
            returnVal +=s[i];
          }
        }
      } */
    /*   }
    } */
  }

  String getTimetoStop1(String name) {
    for (var i = 0; i < aprLinesData.length; i++) {
      if (aprLinesData[i]["line"]["name"] == name) {
        return aprLinesData[i]["timeToStop"].toString() +
            "bus_stop_remaining_time".tr();
      }
    }
    return " ";
  }

  // To check if exist in the db
  bool check = false;
  inCheck() async {
    bool propCheck = await dbHelper.ifContains(widget.busStopName);
    print("Is exist: $propCheck");
    setState(() {
      check = propCheck;
    });
  }

  // Timer is used to refresh the page state to aquaire present time left to the bus stop
  Timer timer;
  @override
  void initState() {
    super.initState();
    busLineData = getBusLines();
    aprLineData = aprBusLines();
    if (mounted) {
      timer = Timer.periodic(
          Duration(seconds: 13),
          (Timer t) => setState(() {
                aprLineData = aprBusLines();
              }));
    }
    inCheck();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios_outlined),
            onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(widget.busStopName)))
        ]),
        actions: <Widget>[
          IconButton(
            icon: check == true
                ? Icon(
                    Icons.star,
                    color: Colors.yellowAccent,
                  )
                : Icon(
                    Icons.star_border,
                    color: Colors.yellowAccent,
                  ),
            onPressed: () {
              inCheck();
              if (check) {
                dbHelper.delete1(widget.busStopName);
                streamController.add(5);
              } else {
                _insert(widget.busStopName, widget.busStopCode);
                streamController.add(5);
              }

              _query();
              inCheck();
            },
          )
        ],
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "bus_stop_passing".tr(),
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // This part of the screen shows the lines passing through the bus stop
            Expanded(
              flex: 1,
              child: SizedBox(
                child: FutureBuilder<List>(
                  future: busLineData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length == 0) {
                        return Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 20,
                            ),
                            Center(
                              child: Text("bus_stop_no_line".tr()),
                            )
                          ],
                        );
                      }
                      return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 6 / 2,
                                  crossAxisSpacing: 7,
                                  mainAxisSpacing: 17),
                          itemCount: busLinesData.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _changeSelection(
                                      index: index,
                                      code: snapshot.data[index]["code"]);
                                });
                                // To show which lines are included to "selectedIndexes"
                                /* for (var i = 0;
                                      i < _selectedCodeList.length;
                                      i++) {
                                    print(_selectedCodeList[i]);
                                  } */
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(snapshot.data[index]["code"]),
                                decoration: BoxDecoration(
                                    color: _selectedCodeList.contains(
                                            snapshot.data[index]["code"])
                                        ? Colors.grey[500]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            );
                          });
                    }
                    return Text(
                      "bus_stop_no_line".tr(), // can be written as error
                      style: TextStyle(color: Colors.black),
                    );
                  },
                ),
              ),
            ),
            Container(
              color: Colors.blue,
              child: ListTile(
                leading: Icon(
                  Icons.bus_alert,
                  color: Colors.white,
                ),
                title: Text("bus_stop_approaching".tr()),
              ),
            ),
            // This part of the screen shows the bus lines that are approaching to the bus stop - approximetly, under, 60 minutes away
            Expanded(
              flex: 2,
              child: SizedBox(
                child: RefreshIndicator(
                  onRefresh: () {
                    setState(() {
                      aprLineData = aprBusLines();
                    });
                    CircularProgressIndicator();
                    return Future.value(true);
                  },
                  child: FutureBuilder<List>(
                    // When the selectionState changes the items that will be shown are also going to change
                    future: selectionState == true ? fAprLines : aprLineData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length == 0 &&
                            selectionState == false) {
                          return Column(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 1 / 20,
                              ),
                              Center(child: Text("bus_stop_no_vehicle".tr()))
                            ],
                          );
                        }
                        return ListView.builder(
                          // Changes with selectionState information
                          itemCount: selectionState == true
                              ? _selectedIndexList1.length
                              : aprLinesData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        onTap: () {
                                          selectionState == true
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          StopTimes(
                                                            busName: busLinesData[
                                                                _selectedIndexList1[
                                                                    index]]["name"],
                                                            busLineCode: busLinesData[
                                                                _selectedIndexList1[
                                                                    index]]["code"],
                                                            busStopCode: widget
                                                                .busStopCode,
                                                            busStopName: widget
                                                                .busStopName,
                                                          )))
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AltLineDetail2(
                                                              "${aprLinesData[index]["line"]["name"]}",
                                                              "${aprLinesData[index]["line"]["code"]}")));
                                        },
                                        leading: widget.busStopCode.length > 5
                                            ? Icon(
                                                Icons.tram,
                                                color: Colors.red,
                                              )
                                            : Icon(
                                                Icons.directions_bus,
                                                color: Colors.blue.shade700,
                                              ),
                                        title: selectionState == true
                                            ? (RichText(
                                                text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: busLinesData[
                                                                  _selectedIndexList1[
                                                                      index]]
                                                              ["code"],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      TextSpan(text: " "),
                                                      TextSpan(
                                                          text: busLinesData[
                                                              _selectedIndexList1[
                                                                  index]]["name"])
                                                    ]),
                                              ))
                                            : RichText(
                                                text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: aprLinesData[
                                                                  index]["line"]
                                                              ["code"],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      TextSpan(text: " "),
                                                      TextSpan(
                                                          text: aprLinesData[
                                                                  index]["line"]
                                                              ["name"])
                                                    ]),
                                              ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(selectionState == true
                                                  ? getTimetoStop(busLinesData[
                                                      _selectedIndexList1[
                                                          index]]["name"])
                                                  : (widget.busStopCode.length >
                                                          5
                                                      ? formatter_new(
                                                              aprLinesData[index]
                                                                  ["doorNo"]) +
                                                          " "
                                                      : formatter(
                                                              aprLinesData[index]
                                                                  ["doorNo"]) +
                                                          " ")),
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          children: [
                                            SizedBox(
                                              height: 30.0,
                                              width: 60.0,
                                              child: IconButton(
                                                  padding:
                                                      new EdgeInsets.all(0.0),
                                                  onPressed: () {
                                                    //
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    StopTimes(
                                                                      busName: selectionState ==
                                                                              true
                                                                          ? busLinesData[_selectedIndexList1[index]]
                                                                              [
                                                                              "name"]
                                                                          : aprLinesData[index]["line"]
                                                                              [
                                                                              "name"],
                                                                      busLineCode: selectionState ==
                                                                              true
                                                                          ? busLinesData[_selectedIndexList1[index]]
                                                                              [
                                                                              "code"]
                                                                          : aprLinesData[index]["line"]
                                                                              [
                                                                              "code"],
                                                                      busStopCode:
                                                                          widget
                                                                              .busStopCode,
                                                                      busStopName:
                                                                          widget
                                                                              .busStopName,
                                                                    )));
                                                  },
                                                  icon: Icon(
                                                    Icons.access_alarm_outlined,
                                                    color: Colors.blue.shade700,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(selectionState == true
                                                ? getTimetoStop1(busLinesData[
                                                    _selectedIndexList1[
                                                        index]]["name"])
                                                : aprLinesData[index]
                                                            ["timeToStop"]
                                                        .toString() +
                                                    "bus_stop_remaining_time"
                                                        .tr()),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      //return Text("error");
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insert(String name1, String code2) async {
    // row to insert

    Map<String, dynamic> row = {
      DatabaseHelper.columnName: '$name1',
      DatabaseHelper.columnCode: '$code2',
      DatabaseHelper.columnType: 'bus_stop'
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach(print);
  }
}
