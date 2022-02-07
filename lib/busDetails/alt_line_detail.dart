import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'line_information.dart';
import 'line_timings.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

StreamController<int> streamControllerScroll =
    StreamController<int>.broadcast();

class AltLineDetail extends StatefulWidget {
  final String busStopName; //get from other page to see the details
  final String busCode; // get code for line_information.dart page
  const AltLineDetail(this.busStopName, this.busCode);

  @override
  _AltLineDetailState createState() =>
      _AltLineDetailState(busStopName: this.busStopName, busCode: this.busCode);
}

class _AltLineDetailState extends State<AltLineDetail> {
  // For more smooth experience

  bool nearStop = false;
  Stream<int> stream = streamControllerScroll.stream;
  mySetState(int x) {
    setState(() {
      returnNearest();
      itemScrollController.scrollTo(
          index: indexBlink,
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn);
      nearStop = true;
    });
  }

  // For coloring the current location
  Map<String, dynamic> inStop;
  List<String> stopList = [];
  Future<Map<String, dynamic>> getInStops() async {
    String directionNum;
    if (direction == "DEPARTURE")
      directionNum = "1";
    else
      directionNum = "2";

    //get data
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/VehiclesInLine?lineCode=$busCode&direction=$directionNum"),
        headers: {"Accept": "application/json"});
    this.setState(() {
      inStop = jsonDecode(response.body);
    });
    int x = inStop["vehicles"].length;
    /*  Map deneme = inStop["vehicles"][0];
    String propName = deneme["previousStop"]["name"];
    String propName1 = inStop["vehicles"][0]["previousStop"]["name"]; */

    for (int i = 0; i < x; i++) {
      stopList.add(inStop["vehicles"][i]["previousStop"]["name"]);
    }
    return inStop; // all the data about a line
  }

  // Calculating distance between two points
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  returnNearest() async {
    await getLoc();
    await getBusLine();
    double latBase = _currentPosition.latitude;
    double longBase = _currentPosition.longitude;

    double latTar = 0;
    double longTar = 0;
    double min = calculateDistance(latBase, longBase,
        lineDetail[0]["stop"]["latitude"], lineDetail[0]["stop"]["longitude"]);

    int min_index = -1;

    for (int i = 1; i < lineDetail.length; i++) {
      latTar = lineDetail[i]["stop"]["latitude"];
      longTar = lineDetail[i]["stop"]["longitude"];
      if (min > calculateDistance(latBase, longBase, latTar, longTar)) {
        min = calculateDistance(latBase, longBase, latTar, longTar);
        min_index = i;
      }
    }

    if (min_index != -1) {
      streamControllerScroll.add(5);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          indexBlink = min_index;
        }));
    /* setState(() {
      indexBlink = min_index;
    }); */
  }

  // Scrolling down/up to the nearest stop
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // for location part
  int indexBlink = 0;
  LocationData _currentPosition;
  Location location = Location();
  double navLat = 0;
  double navLon = 0;

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        navLat = currentLocation.latitude;
        navLon = currentLocation.longitude;
      });
    });
  }

  //

  String busStopName;
  String busCode;
  _AltLineDetailState({this.busStopName, this.busCode});

  String yeryon = "";

  Color _colorContainer = Colors.white;

  String direction =
      "DEPARTURE"; // to change the direction when pressed the icons

  List lineDetail;
  Future<List<dynamic>> getBusLine() async {
    //get data
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=$direction"),
        headers: {"Accept": "application/json"});
    if (mounted) {
      this.setState(() {
        lineDetail = jsonDecode(response.body);
      });
    }

    yeryon = lineDetail.last["stop"]["name"] + " Direction";
    return lineDetail; // all the data about a line
  }

  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    stream.listen((index) {
      mySetState(index);
    });
    getLoc();
    getBusLine();
    returnNearest();
    getInStops();
  }

  //For toggle switch
  int initialIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.share_location),
          onPressed: () {
            setState(() {
              itemScrollController.scrollTo(
                  index: indexBlink,
                  duration: Duration(seconds: 2),
                  curve: Curves.easeIn);
            });
          }),
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        title: Row(children: [
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text("$busStopName")))
        ]), // the name of bus got from busStop page
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.height) * 3.52 / 20,
                  width: (MediaQuery.of(context).size.height) * 3.52 / 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    color:
                        _colorContainer, //determine which color will be given on clicked
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          /* setState(() {
                            _colorContainer =
                                Colors.black12; //when clicked change the color
                          }); */
                        },
                        child: Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text("Line Detail"),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.height) * 3.52 / 20,
                  width: (MediaQuery.of(context).size.height) * 3.52 / 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    color: _colorContainer,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _colorContainer = Colors.black12;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LineInformation(
                                      busCode, direction, navLat, navLon)));
                        },
                        child: Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black12,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text("Line Information"),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.height) * 3.52 / 20,
                  width: (MediaQuery.of(context).size.height) * 3.52 / 20,
                  decoration: BoxDecoration(
                    color: _colorContainer,
                    border: Border.all(color: Colors.black38),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _colorContainer = Colors.white;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LineTimings(
                                      busStopName,
                                      busCode,
                                      lineDetail[0]["stop"]["name"],
                                      lineDetail[lineDetail.length - 1]["stop"][
                                          "name"]))); //send the required parameters to linetimings page
                        },
                        child: Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.black12,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text("Line Timings"),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // set it to min
            children: <Widget>[
              Container(
                color: Colors.blueGrey.shade200,
                height: (MediaQuery.of(context).size.height) * 2.3 / 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: (MediaQuery.of(context).size.width) * 12 / 20,
                          child: Row(children: [
                            Expanded(
                              child: Text(
                                yeryon,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: ToggleSwitch(
                          minWidth: 60.0,
                          minHeight: 60.0,
                          cornerRadius: 20.0,
                          initialLabelIndex: initialIndex,
                          totalSwitches: 2,
                          labels: ['', ''],
                          icons: [
                            Icons.arrow_back_rounded,
                            Icons.arrow_forward_rounded,
                          ],
                          onToggle: (index) {
                            setState(() {
                              initialIndex = index;
                              nearStop = false;
                            });
                            if (initialIndex == 0) {
                              setState(() {
                                direction = "DEPARTURE";
                                getBusLine();
                                yeryon = lineDetail.last["stop"]["name"] +
                                    " Direction";
                                returnNearest();
                              });
                            } else {
                              setState(() {
                                returnNearest();
                                direction = "ARRIVAL";
                                getBusLine();
                                yeryon = lineDetail.last["stop"]["name"] +
                                    " Direction";

                                returnNearest();
                              });
                            }
                            //getBusLine();
                            print(index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
              flex: 3,
              child: lineDetail == null // check if data available
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: () {
                        setState(() {
                          returnNearest();
                          itemScrollController.scrollTo(
                              index: indexBlink,
                              duration: Duration(seconds: 2),
                              curve: Curves.fastOutSlowIn);
                        });
                        CircularProgressIndicator();
                        return Future.value(true);
                      },
                      child: _currentPosition == null
                          ? Center(child: CircularProgressIndicator())
                          : new ScrollablePositionedList.builder(
                              itemScrollController: itemScrollController,
                              itemPositionsListener: itemPositionsListener,
                              itemCount:
                                  lineDetail == null ? 0 : lineDetail.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                      ),
                                      color: index == indexBlink
                                          ? (nearStop == true
                                              ? Colors.blueGrey.shade200
                                              : Colors.white)
                                          : Colors.white,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          index == indexBlink
                                              ? (nearStop == false
                                                  ? ListTile(
                                                      leading: stopList.contains(
                                                              lineDetail[index]
                                                                      ["stop"]
                                                                  ["name"])
                                                          ? Icon(
                                                              Icons
                                                                  .directions_bus,
                                                              color:
                                                                  Colors.blue)
                                                          : Icon(
                                                              Icons
                                                                  .directions_bus,
                                                              color:
                                                                  Colors.grey),
                                                      title: Text(
                                                        lineDetail[index]
                                                            ["stop"]["name"],
                                                        maxLines: 1,
                                                      ),
                                                    )
                                                  : ListTile(
                                                      leading: stopList.contains(
                                                              lineDetail[index]
                                                                      ["stop"]
                                                                  ["name"])
                                                          ? Icon(
                                                              Icons
                                                                  .directions_bus,
                                                              color:
                                                                  Colors.blue)
                                                          : Icon(
                                                              Icons
                                                                  .directions_bus,
                                                              color:
                                                                  Colors.grey),
                                                      title: Text(
                                                        lineDetail[index]
                                                            ["stop"]["name"],
                                                        maxLines: 1,
                                                      ),
                                                      subtitle: index ==
                                                              indexBlink
                                                          ? Text(
                                                              "You are close to this stop!")
                                                          : Text(""),
                                                    ))
                                              : ListTile(
                                                  leading: stopList.contains(
                                                          lineDetail[index]
                                                              ["stop"]["name"])
                                                      ? Icon(
                                                          Icons.directions_bus,
                                                          color: Colors.blue)
                                                      : Icon(
                                                          Icons.directions_bus,
                                                          color: Colors.grey),
                                                  title: Text(
                                                    lineDetail[index]["stop"]
                                                        ["name"],
                                                    maxLines: 1,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                    )),
        ],
      ),
    );
  }
}
