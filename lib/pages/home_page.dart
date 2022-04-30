import 'dart:async';
import 'dart:convert';
//import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kayseri_ulasim/Drawer/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/controller/language_controller.dart';
import 'package:kayseri_ulasim/database/database_helper.dart';
import 'package:kayseri_ulasim/database/db_helper_alarm.dart';
import 'package:kayseri_ulasim/pages/map_google.dart';
import 'package:kayseri_ulasim/pages/bus_stop.dart';
import 'package:kayseri_ulasim/pages/search_page1.dart';
import 'package:provider/src/provider.dart';

StreamController<int> streamController = StreamController<int>();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // to control the other page
  Stream<int> stream = streamController.stream;

  void mySetState(int x) {
    getFavorites();
    getNumber();
  }

  String barcode = "";
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
  Position _currentPosition = new Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
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
    stream.listen((index) {
      mySetState(index);
    });
    _getUserLocation();
    getData();
    getNumber();
    getFavorites();
    getNumberOfAlarms();
    getAlarms();
  }

  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
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
                          /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GetNotf())); */
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
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchBar()));
                  //await showSearch(context: context, delegate: DataSearch());
                },
                child: Container(
                  color: Colors.blueGrey.shade900,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2.0, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.search),
                          color: Colors.white,
                        ),
                        Text(
                          'search_bar_txt'.tr(),
                          style: TextStyle(
                            fontFamily: "Ubuntu",
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        new Spacer(),
                        IconButton(
                          onPressed: () {
                            scanNgo().whenComplete(() {
                              if (qrStopCode != "") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BusStopPage(
                                            busStopName:
                                                "Stop Number: " + qrStopCode,
                                            busStopCode: qrStopCode)));
                                setState(() {
                                  //qrStopCode = "";
                                });
                              }
                            });
                          },
                          icon: Icon(Icons.qr_code),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 15,
                color: Colors.blueGrey.shade900,
              ),
              favLength == 0
                  ? Container(
                      height: 25,
                      color: Colors.blueGrey.shade900,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'home_isFav_added'.tr(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ]))
                  : Text('home_fav'.tr()),

              favLength == 0
                  ? SizedBox(height: 0)
                  : Expanded(
                      flex:
                          favLength <= 3 ? (favLength > 0 ? favLength : 1) : 3,
                      child: RefreshIndicator(
                        onRefresh: () {
                          mySetState(5);
                          getNumber();
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
                                                    builder: (context) =>
                                                        BusStopPage(
                                                          busStopCode:
                                                              favDB[index]
                                                                  ["code"],
                                                          busStopName:
                                                              favDB[index]
                                                                  ["name"],
                                                        )));
                                          },
                                          leading:
                                              favDB[index]["code"].length > 5
                                                  ? Icon(Icons.tram,
                                                      color: Colors.red)
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
              Text('home_closest'.tr()),
              Expanded(
                flex: favLength == 0 ? 11 : 4,
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

                            if (data.length == 1) {
                              return Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        1/20,
                                  ),
                                  Center(
                                    child: Text("home_no_stop".tr()),
                                  )
                                ],
                              );
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
                                  height: 5.23,
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),

              // Bottom of the page
              Container(
                height: (MediaQuery.of(context).size.height) * (1 / 12),
                width: MediaQuery.of(context).size.width,
                color: Colors.blueGrey.shade900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Center(
                            child: Row(
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
                                  "home_map".tr(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
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

  String qrUrl = "";
  String qrStopCode = "";
  getStopNo() {
    String stopNo = "";
    if (qrUrl.contains("Durak.aspx?p=")) {
      for (int i = 40; i < qrUrl.length; i++) {
        stopNo += qrUrl[i];
      }
    }
    setState(() {
      qrStopCode = stopNo;
    });
  }

  Future scanNgo() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        this.barcode = barcode;
        print(this.barcode);
        qrUrl = this.barcode;
        getStopNo();
        //_launchURL(barcode);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  /* void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url'; */
}
