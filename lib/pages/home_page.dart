import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kayseri_ulasim/Drawer/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/alarm/get_notf.dart';
import 'package:kayseri_ulasim/database/database_helper.dart';
import 'package:kayseri_ulasim/database/db_helper_alarm.dart';
import 'package:kayseri_ulasim/pages/map_google.dart';
import 'package:kayseri_ulasim/pages/bus_stop.dart';
import 'package:kayseri_ulasim/pages/search_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchControl = TextEditingController();
    // This function gets alarm data from local database
  List<Map<String, dynamic>> alarms;
  var alarmDB;
  Future getAlarms() async {
    this.alarms = await DatabaseHelperAlarm.instance.queryAllRows();
    setState(() {
      alarmDB = alarms.toList();
    });
  }

  //get length of alarms
  int alarmLength = 0;
  getNumberOfAlarms() async {
    var x = await DatabaseHelperAlarm.instance.queryRowCount();
    print(x);
    alarmLength = x;
  }

  // Favorites
  // This function gets fav data from local database
  List<Map<String, dynamic>> favorites;
  var favDB = [];
  Future getFavorites() async {
    this.favorites = await DatabaseHelper.instance.queryAllRows();
    setState(() {
      favDB = favorites.toList();
    });
  }

  // Since the data loads asynchronically from db length of the data was causing problems
  // To overcome those problems I got the length directly from database itself
  int favLength = 0;
  getNumber() async {
    var x = await DatabaseHelper.instance.queryRowCount();
    print(x);
    setState(() {
      favLength = x;
    });
  }

  // Method for retrieving the current location
  Position _currentPosition = new Position(longitude: 0, latitude: 0, timestamp: DateTime.now() , accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);

  _getUserLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  // For retrieving data from API services
  List data;
  Future<String> getData() async {
    await _getUserLocation();
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

  String code = "";
  @override
  void initState() {
    super.initState();
    _getUserLocation();
    getData();
    getNumber();
    getFavorites();
    getNumberOfAlarms();
    getAlarms();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: NavigationDrawer(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(75.0),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Colors.blueGrey.shade900,
            elevation: 10,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Spacer(),
                Image.asset(
                  'assets/transparent.png',
                  fit: BoxFit.fitHeight,
                  height: 150,
                ),
                new Spacer(),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_alert_sharp,
                          color: Colors.white,
                        ),
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>GetNotf()));
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                color: Colors.blueGrey.shade900,
                height: 70,
                // Search Button
                child: TextFormField(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SearchPage()));
                  },
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  cursorColor: Colors.blueGrey,
                  controller: searchControl,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search),
                      color: Colors.white,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 17,
                      color: Colors.white,
                    ),
                    hintText: "Hat / Durak Arama",
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              Text("Favorites"),
              Expanded(
                flex: 1,
                child: RefreshIndicator(
                  onRefresh: () {
                    getFavorites();
                    CircularProgressIndicator();
                    return Future.value(true);
                  },
                  child: new ListView.builder(
                    itemCount: favDB.length == 0 ? 0 : favLength,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Container(
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              color: getColor(index),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => BusStopPage(
                                                    busStopCode: favDB[index]
                                                        ["code"],
                                                    busStopName: favDB[index]
                                                        ["name"],
                                                  )));
                                    },
                                    leading: favDB[index]["code"].length > 5
                                        ? Icon(Icons.tram, color: Colors.red)
                                        : Icon(Icons.directions_bus,
                                            color: Colors.blue),
                                    title: Text(favDB[index]["name"]),
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
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height) * (1 / 45),
              ),
              // Closest bus stops
              Text("Closest"),
              Expanded(
                flex: favLength == 0 ? 4 : 2,
                child: RefreshIndicator(
                  onRefresh: () {
                    getData();
                    CircularProgressIndicator();
                    return Future.value(true);
                  },
                  child: data == null
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : new ListView.builder(
                          itemCount: data == null ? 0 : data.length,
                          itemBuilder: (BuildContext context, int index) {
                            getCode() {
                              if ((data[index]["busStop"]["type"]) ==
                                  "busStop") {
                                code = data[index]["busStop"]["code"];
                              } else {
                                code = "";
                              }
                              return code;
                            }

                            return Column(
                              children: [
                                Container(
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                    ),
                                    color: getColor(index),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BusStopPage(
                                                          busStopName: getCode() +
                                                              " " +
                                                              data[index][
                                                                      "busStop"]
                                                                  ["name"],
                                                          busStopCode: data[
                                                                      index]
                                                                  ["busStop"]
                                                              ["code"],
                                                        )));
                                          },
                                          // This part of the code decides whether the tram icon or the bus icon should be used
                                          leading: Icon(
                                            getCode() == ""
                                                ? Icons.tram
                                                : Icons.directions_bus,
                                            color: getCode() == ""
                                                ? Colors.red
                                                : Colors.blue.shade700,
                                          ),
                                          title: Text(getCode() == ""
                                              ? data[index]["busStop"]["name"]
                                              : getCode() +
                                                  "  " +
                                                  data[index]["busStop"]
                                                      ["name"]),
                                          subtitle: Text(
                                              (data[index]["distance"] * 1000)
                                                      .toInt()
                                                      .toString() +
                                                  "m"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 7.23,
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),

              // Bottom of the page
              Container(
                height: (MediaQuery.of(context).size.height) * (1 / 10),
                width: MediaQuery.of(context).size.width,
                color: Colors.blueGrey.shade900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.map,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => mapGoogle(),
                                ));
                          },
                        ),
                        Text(
                          "Harita",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // To decide which texts and colors should be used in the app
  getColor(int index) {
    if (index % 2 == 0) {
      return Colors.lightBlueAccent.shade100;
    } else {
      return Colors.white;
    }
  }
}
