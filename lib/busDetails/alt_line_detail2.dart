import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/src/public_ext.dart';
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

class AltLineDetail2 extends StatefulWidget {
  final String busStopName; //get from other page to see the details
  final String busCode; // get code for line_information.dart page
  const AltLineDetail2(this.busStopName, this.busCode);

  @override
  _AltLineDetail2State createState() => _AltLineDetail2State(
      busStopName: this.busStopName, busCode: this.busCode);
}

class _AltLineDetail2State extends State<AltLineDetail2> {
  // For more smooth experience

  bool nearStop = false;
  Stream<int> stream = streamControllerScroll.stream;
  mySetState(int x) {
    setState(() {
      //returnNearest();
      itemScrollController.scrollTo(
          index: indexBlink,
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn);
      //nearStop = true;
    });
  }

  // For coloring the current location
  List inStop = [];
  Map<String, dynamic> inStop1;
  List<String> stopList = [];
  List whereBus = [];
  Future<List> getInStops() async {
    //get data
    if (widget.busCode == "T1" || widget.busCode == "T2") {
      var response = await http.get(
          Uri.parse(
              "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=$direction"),
          headers: {"Accept": "application/json"});
      this.setState(() {
        inStop = jsonDecode(response.body);
      });

      for (int i = 0; i < inStop.length; i++) {
        if (inStop[i]["buses"].length > 0) {
          whereBus.add(inStop[i]["buses"][0]["busLocation"]);
        }
      }
    } else {
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
        inStop1 = jsonDecode(response.body);
      });
      int x = inStop1["vehicles"].length;

      for (int i = 0; i < x; i++) {
        whereBus.add(inStop1["vehicles"][i]["vehicle"]["location"]);
      }
    }

    double latTar = 0;
    double longTar = 0;
    double dist = 0;
    for (int i = 0; i < whereBus.length; i++) {
      if (lineDetail == null) {
        await getBusLine().then((value) => {
              for (int j = 0; j < value.length; j++)
                {
                  dist = calculateDistance(
                      whereBus[i]["latitude"],
                      whereBus[i]["longitude"],
                      lineDetail[j]["stop"]["latitude"],
                      lineDetail[j]["stop"]["longitude"]),
                  if (dist < 0.2) stopList.add(lineDetail[j]["stop"]["name"])
                }
            });
      } else {
        for (int j = 0; j < lineDetail.length; j++) {
          dist = calculateDistance(
              whereBus[i]["latitude"],
              whereBus[i]["longitude"],
              lineDetail[j]["stop"]["latitude"],
              lineDetail[j]["stop"]["longitude"]);
          if (dist < 0.2) {
            stopList.add(lineDetail[j]["stop"]["name"]);
          }
        }
      }
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
    double latBase = 38.722690;
    double longBase = 35.486939;

    if (_currentPosition == null) {
      await getLoc().then((value) => {
            latBase = value.latitude,
            longBase = value.longitude,
          });
    } else {
      latBase = _currentPosition.latitude;
      longBase = _currentPosition.longitude;
    }

    double latTar = 0;
    double longTar = 0;
    double min = 0;
    if (lineDetail == null) {
      await getBusLine().then((value) => {
            min = calculateDistance(
                latBase,
                longBase,
                lineDetail[0]["stop"]["latitude"],
                lineDetail[0]["stop"]["longitude"])
          });
    } else {
      min = calculateDistance(
          latBase,
          longBase,
          lineDetail[0]["stop"]["latitude"],
          lineDetail[0]["stop"]["longitude"]);
    }

    int min_index = 0;

    for (int i = 1; i < lineDetail.length; i++) {
      latTar = lineDetail[i]["stop"]["latitude"];
      longTar = lineDetail[i]["stop"]["longitude"];
      if (min > calculateDistance(latBase, longBase, latTar, longTar)) {
        min = calculateDistance(latBase, longBase, latTar, longTar);
        //min_index = i;
        setState(() {
          min_index = i;
        });
      }
    }

    /* WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          indexBlink = min_index;
          nearStop = true;
        })); */
    if (mounted) {
      setState(() {
        if (min_index != -1) {
          streamControllerScroll.add(5);
        }
        indexBlink = min_index;
        nearStop = true;
      });
    }
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
  double navLat = 38.722690;
  double navLon = 35.486939;

  Future getLoc() async {
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
    return _currentPosition;
  }

  // For two directions

  // departure
  String busStopName;
  String busCode;
  _AltLineDetail2State({this.busStopName, this.busCode});
  String yeryon = "";
  String direction =
      "DEPARTURE"; // to change the direction when pressed the icons
  List lineDetail;
  List copy;
  Future<List> lineFuture;
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

    setState(() {
      yeryon = lineDetail.last["stop"]["name"] + "line_detail_direction".tr();
    });
    copy = lineDetail;
    return lineDetail; // all the data about a line
  }

  // arrival
  List lineDetailArrival;
  Future<List> lineFutureArrival;
  Future<List<dynamic>> getBusLineArr() async {
    //get data
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=ARRIVAL"),
        headers: {"Accept": "application/json"});
    if (mounted) {
      this.setState(() {
        lineDetailArrival = jsonDecode(response.body);
      });
    }

    return lineDetailArrival; // all the data about a line
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
    getBusLineArr();
    returnNearest();
    getInStops();
    lineFuture = getBusLine();
    lineFutureArrival = getBusLineArr();
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
      /*  Row(children: [
          Expanded(
              child: Text("$busStopName", maxLines: 2, )) */ // these lines makes only two lined titles

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
                    color: Colors
                        .white30, //determine which color will be given on clicked
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
                            Text("line_detail_detail".tr()),
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
                    color: Colors.white30,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {});
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LineInformation(
                                      busStopName,
                                      busCode,
                                      direction,
                                      navLat,
                                      navLon)));
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
                            Text("line_detail_information".tr()),
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
                    color: Colors.white30,
                    border: Border.all(color: Colors.black38),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            /* 
                            _colorContainer = Colors.white; */
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
                            Text("line_detail_timings".tr()),
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
                                yeryon == "" ? widget.busStopName : yeryon,
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
                              whereBus.clear();
                              stopList.clear();
                            });
                            if (initialIndex == 0) {
                              setState(() {
                                lineDetail = copy;
                                direction = "DEPARTURE";
                                /* getBusLine().then((value) {
                                  yeryon =
                                      value.last["stop"]["name"] + " Direction";

                                  returnNearest();
                                }); */
                                yeryon = lineDetail.last["stop"]["name"] +
                                    "line_detail_direction".tr();
                                returnNearest();
                                getInStops();
                              });
                            } else {
                              setState(() {
                                lineDetail = lineDetailArrival;
                                direction = "ARRIVAL";
                                /* getBusLine().then((value) {
                                  yeryon =
                                      value.last["stop"]["name"] + " Direction";

                                  returnNearest();
                                }); */
                                yeryon = lineDetail.last["stop"]["name"] +
                                   "line_detail_direction".tr();
                                returnNearest();
                                getInStops();
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
            child: FutureBuilder(
                future: lineFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RefreshIndicator(
                      onRefresh: () {
                        setState(() {
                          returnNearest();
                          itemScrollController.scrollTo(
                              index: indexBlink,
                              duration: Duration(seconds: 2),
                              curve: Curves.fastOutSlowIn);
                        });
                        CircularProgressIndicator(color: Colors.green);
                        return Future.value(true);
                      },
                      child: /* _currentPosition == null
                          ? Center(child: CircularProgressIndicator())
                          :  */
                          new ScrollablePositionedList.builder(
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
                                                              "line_detail_close_msg".tr())
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
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      "error",
                      style: TextStyle(color: Colors.grey[200]),
                    );
                  }
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                      ]);
                }),
          ),
        ],
      ),
    );
  }
}
