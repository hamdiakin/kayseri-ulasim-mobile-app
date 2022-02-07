import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';
import 'line_information.dart';
import 'line_timings.dart';
import 'package:location/location.dart';

class LineDetail extends StatefulWidget {
  final String busStopName; //get from other page to see the details
  final String busCode; // get code for line_information.dart page
  const LineDetail(this.busStopName, this.busCode);

  @override
  _LineDetailState createState() =>
      _LineDetailState(busStopName: this.busStopName, busCode: this.busCode);
}

class _LineDetailState extends State<LineDetail> {

  // coloring the current stop

  // for scrolling to nearest item
  final ScrollController _controller = ScrollController();
  final double _height = 500;

   void _animateToIndex() {
    if (_controller.hasClients) {
      _controller.animateTo(
        indexBlink * _height *65,
        duration: Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    }
  } 
    /* void _animateToIndex() {
    _controller.animateTo(
      8 * _height,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  } */

  // for location part
  bool blink = false;
  String isB = "";
  int indexBlink = 0;
  LocationData _currentPosition;
  Location location = Location();

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
      });
    });
  }

  List data;
  Future<String> getData() async {
    await getLoc();
    String lat = _currentPosition.latitude.toString();
    String long = _currentPosition.longitude.toString();
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/nearest?lon=$long&lat=$lat"),
        headers: {"Accept": "application/json"});
    setState(() {
      data = jsonDecode(response.body);
    });
    return "success";
  }

  isBlink() async {
    await getBusLine();
    await getLoc();
    await getData();

    for (int i = 0; i < lineDetail.length; i++) {
      // Modify the function to the nearest location settings
      for (int j = 0; j < data.length; j++) {
        if (lineDetail[i]["stop"]["name"] == data[j]["busStop"]["name"]) {
          setState(() {
            blink = true;
            isB = lineDetail[i]["stop"]["name"];
            indexBlink = i;
          });
        }
      }
    }
  }
  //

  String busStopName;
  String busCode;
  _LineDetailState({this.busStopName, this.busCode});

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
    this.setState(() {
      lineDetail = jsonDecode(response.body);
    });
    yeryon = lineDetail.last["stop"]["name"] + " Direction";
    return lineDetail; // all the data about a line
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBusLine(); //make sure the data is taken before launching
    getLoc();
    getData();
    isBlink();
  }

  //For toggle switch
  int initialIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_downward),
          onPressed: () {
            setState(() {
              indexBlink = indexBlink;
            });
            _animateToIndex();
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
                                  builder: (context) =>
                                      LineInformation(busCode, direction, _height, _height)));
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
                            _colorContainer = Colors.black12;
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
                            });
                            if (initialIndex == 0) {
                              setState(() {
                                isBlink();
                                direction = "DEPARTURE";
                                yeryon = lineDetail.last["stop"]["name"] +
                                    " Direction";
                                    getBusLine();
                              });
                            } else {
                              setState(() {
                                isBlink();
                                direction = "ARRIVAL";
                                yeryon = lineDetail.first["stop"]["name"] +
                                    " Direction";
                                getBusLine();
                              });
                            }
                            //getBusLine();
                            print(index);
                          },
                        ),
                      ),
                    ),

                    /*      Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: (MediaQuery.of(context).size.height) * 4 / 20,
                        width: (MediaQuery.of(context).size.width) * 5.3 / 20,
                        color: Colors.black38,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              // Toggle here
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 28.0,
                                  color: direction == "DEPARTURE"
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    direction =
                                        "DEPARTURE"; //set the direction when presssed
                                  });
                                  getBusLine();
                                },
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 28.0,
                                  color: direction == "DEPARTURE"
                                      ? Colors.white
                                      : Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    direction =
                                        "ARRIVAL"; //change the listView vice versa when clicked
                                  });
                                  getBusLine();
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
            ],
          ),
          Expanded(
            flex: 3,
            child: lineDetail == null // check if data available
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : new ListView.builder(
                    controller: _controller,
                    itemCount: lineDetail == null ? 0 : lineDetail.length,
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
                            color: lineDetail[index]["stop"]["name"] == isB
                                ? Colors.blueGrey.shade200
                                : Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                lineDetail[index]["stop"]["name"] == isB
                                    ? ListTile(
                                        //   onTap: () {},
                                        // This part of the code decides whether the tram icon or the bus icon should be used
                                        leading: Icon(Icons.directions_bus),
                                        title: Text(
                                          lineDetail[index]["stop"][
                                              "name"], //show the stops that a bus passes from
                                          maxLines: 1,
                                        ),
                                        subtitle: lineDetail[index]["stop"]
                                                    ["name"] ==
                                                isB
                                            ? Text(
                                                "You are close to this stop!")
                                            : Text(""),
                                      )
                                    : ListTile(
                                        //   onTap: () {},
                                        // This part of the code decides whether the tram icon or the bus icon should be used
                                        leading: Icon(Icons.directions_bus),
                                        title: Text(
                                          lineDetail[index]["stop"][
                                              "name"], //show the stops that a bus passes from
                                          maxLines: 1,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 4.23,
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
