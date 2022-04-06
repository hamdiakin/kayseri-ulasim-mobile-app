import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/map/KMarker.dart';
import 'package:kayseri_ulasim/map/locations.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';
import 'dart:io' show Platform;

class LineInformation extends StatefulWidget {
  final String busName;
  final String busCode; //get the code to see the line of the markers
  final String direction;
  final double navLat;
  final double navLon;
  const LineInformation(
      this.busName, this.busCode, this.direction, this.navLat, this.navLon);
  @override
  _LineInformationState createState() =>
      _LineInformationState(busCode: this.busCode);
}

class _LineInformationState extends State<LineInformation> {
  // Live location for Trams, complicated bits yuck
/*   Map<String, dynamic> inStop;
  List liveLoc = [];
  Future<Map<String, dynamic>> getLiveLoc() async {
    //get data
    var response = await http.get(
        Uri.parse(
            "https://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=${widget.direction}"),
        headers: {"Accept": "application/json"});
    this.setState(() {
      inStop = jsonDecode(response.body);
    });

    for (int i = 0; i < inStop.length; i++) {
      if (inStop[i]["buses"] != null) {
        for (int j = 0; j < inStop[i]["buses"].length; j++) {
          liveLoc.add(inStop[i]["buses"][j]["busLocation"]);
        }
      }
    }
    return inStop; // all the data about a line
  }
 */
  // For live positions of the busses
  Map<String, dynamic> inStop;
  List inStop1 = [];
  List liveLoc = [];
  Future<Map<String, dynamic>> getLiveLoc() async {
    if (widget.busCode == "T1" || widget.busCode == "T2") {
      var response = await http.get(
          Uri.parse(
              "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=${widget.direction}"),
          headers: {"Accept": "application/json"});
      this.setState(() {
        inStop1 = jsonDecode(response.body);
      });

      for (int i = 0; i < inStop1.length; i++) {
        if (inStop1[i]["buses"] != null) {
          for (int j = 0; j < inStop1[i]["buses"].length; j++) {
            liveLoc.add(inStop1[i]["buses"][j]["busLocation"]);
          }
        }
      }
      setState(() {
        inStop1 = inStop1;
      });
    } else {
      String directionNum;
      if (widget.direction == "DEPARTURE")
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
        liveLoc.add(inStop["vehicles"][i]["vehicle"]["location"]);
      }
      return inStop;
    }

    // all the data about a line
  }

  String busCode;
  _LineInformationState({this.busCode});

  List lineInfo; //get data into list
  Future<String> getBusLine() async {
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=DEPARTURE"),
        headers: {"Accept": "application/json"});

    if (mounted) {
      this.setState(() {
        lineInfo = jsonDecode(response.body);
      });
    }

    return "success";
  }

  GoogleMapController mapController; //to create the Map
  Position _currentPosition; // zoom to my location
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(0.0, 0.0)); // initial position

  // Method for retrieving the current location
/*   _getUserLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17.0,
            ),
          ),
        );
      });
      //await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  locationGetter() async {
    await _getUserLocation();
  } */

  void _onMapCreated(GoogleMapController controller) async {
    //locationGetter();
    await getBusLine();
    // To update mapcontroller
    setState(() {
      mapController = controller;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.navLat,
              widget.navLon,
            ),
            zoom: 15.0,
          ),
        ),
      );
      getBusLine();
      addToList();
      addMarkers();
    });
    // Adding markers to marker list and eventually to the Map
    // addMarkers();
    /* setState(() {
      addMarkers();
    }); */
  }

  List<Location> locations = [];
  // Adding location information of the bus stops into the list
  addToList() async {
    for (var i = 0; i < lineInfo.length; i++) {
      locations.add(Location(
          lineInfo[i]["stop"]["latitude"],
          lineInfo[i]["stop"]["longitude"],
          lineInfo[i]["stop"]["name"],
          lineInfo[i]["stop"]["code"]));
    }
  }

  // Adding Markers
  //final LatLng _center = const LatLng(lat, long);

  Set<KMarker> markersList = new Set();
  List<Marker> customMarkers = [];
  Set<Polyline> _polyline = {};
  List<LatLng> latlng = List();

  void addMarkers() {
    int index = 0;
    locations.forEach((element) {
      final KMarker marker = KMarker(
        element.name,
        element.code,
        pinLocationIcon,
        context,
        id: MarkerId(index.toString()),
        lat: element.lat,
        lng: element.long,
      );
      markersList.add(marker);
      index++;
      latlng.add(LatLng(element.lat, element.long));
    });
    setState(() {
      liveIndex = index;
      for (int i = 0; i < latlng.length; i++) {
        _polyline.add(Polyline(
          polylineId: PolylineId(index.toString()),
          visible: true,
          //latlng is List<LatLng>
          points: latlng,
          color: Colors.blue,
        ));
      }

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          getBounds(markersList),
          10.0,
        ),
      );
    });
    addMarkersLive(index);
  }

  int liveIndex = 0;

  Future<void> addMarkersLive(int index) async {
    liveLoc.clear();
    await getLiveLoc();
    markersList.removeWhere((element) => element.code == "Live");
    liveLoc.forEach((element) {
      final KMarker marker = KMarker(
        "Live Location",
        "Live",
        pinLocationIconLive,
        context,
        id: MarkerId((index).toString()),
        lat: element["latitude"],
        lng: element["longitude"],
      );
      markersList.add(marker);
      index++;
      /*  if (liveIndex == markersList.length) {
        if (markersList.isEmpty == false) {
          markersList.remove(markersList.last);
        }
        markersList.add(marker);
      } else {
        markersList.add(marker);
        setState(() {
          liveIndex++;
        });
      } */
    });
  }

  // to fit in
  LatLngBounds getBounds(Set<Marker> markersList) {
    var lngs = markersList.map<double>((m) => m.position.longitude).toList();
    var lats = markersList.map<double>((m) => m.position.latitude).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );

    return bounds;
  }

  bool isIOS = Platform.isIOS;

  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinLocationIconLive;
  
  Timer _clockTimer;
  @override
  void initState() {
    super.initState();
    //creating markers
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                /* devicePixelRatio: 1.5, */ /* size: Size(32, 32) */),
            isIOS ? 'assets/marker_ios.png' : 'assets/marker.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                /* devicePixelRatio: 1.5, */ /* size: Size(32, 32) */),
            isIOS ? 'assets/livebus_ios.png' : 'assets/livebus.png')
        .then((onValue) {
      pinLocationIconLive = onValue;
    });
      _clockTimer = Timer.periodic(
          Duration(seconds: 5),
          (Timer t) => setState(() {
                //markersList.removeWhere((element) => element.code == "Live");
                addMarkersLive(liveIndex);
              }));
    

    //locationGetter();
    getBusLine();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.busName),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
          polylines: _polyline,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: _onMapCreated,
          markers: markersList,
          initialCameraPosition: _initialLocation,
        ),
      ]),
    );
  }
}
