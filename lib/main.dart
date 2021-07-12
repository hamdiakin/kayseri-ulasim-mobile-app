import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kayseri_ulasim/Drawer/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Kayseri Ulaşım',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double ar = 0;
    String lonA="";
  String latA = "";


   GoogleMapController mapController;
   Position _currentPosition;
  String _currentAddress = '';
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  

  TextEditingController searchControl = TextEditingController();
    // Method for retrieving the current location
  _getUserLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
        latA= _currentPosition.latitude.toString();
        lonA= _currentPosition.longitude.toString();
      });
      //await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  /*// Parts that are related to functions to retrieve location data
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  String lat = "";
  String long = "";

  Future<void> _getUserLocation() async {
    Location location = new Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();

    setState(() {
      lat = _locationData.latitude.toString();
      long = _locationData.longitude.toString();
    });
  }*/

  // For retrieving data from API services
  List data;
  Future<String> getData() async {
    await _getUserLocation();
     String lat= _currentPosition.latitude.toString();
    String long= _currentPosition.longitude.toString();
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/nearest?lon=$long&lat=$lat"),
        headers: {"Accept": "application/json"});
    this.setState(() {
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
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
                      onPressed: () {},
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
            SizedBox(
              height: (MediaQuery.of(context).size.height) * (1 / 20),
            ),
            // Closest bus stops
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (a, b, c) => MyApp(),
                      transitionDuration: Duration(milliseconds: 5),
                    ),
                  );
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
                            if ((data[index]["busStop"]["type"]) == "busStop") {
                              code = data[index]["busStop"]["code"];
                            } else {
                              code = "";
                            }
                            return code;
                          }

                          return Column(
                            children: [
                              Card(
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
                                      onTap: () {},
                                      // This part of the code decides whether the tram icon or the bus icon should be used
                                      leading: Icon(
                                        getCode() == ""
                                            ? Icons.tram
                                            : Icons.bus_alert,
                                        color: getCode() == ""
                                            ? Colors.red
                                            : Colors.blue.shade700,
                                      ),
                                      title: Text(getCode() == ""
                                          ? data[index]["busStop"]["name"]
                                          : getCode() +
                                              "  " +
                                              data[index]["busStop"]["name"]),
                                      subtitle: Text(
                                          (data[index]["distance"] * 1000)
                                                  .toInt()
                                                  .toString() +
                                              "m"),
                                    ),
                                  ],
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
                        onPressed: () {},
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
