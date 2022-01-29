import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/map/KMarker.dart';
import 'package:kayseri_ulasim/map/locations.dart';
import 'dart:io' show Platform;

class LineInformation extends StatefulWidget {
  final String busCode; //get the code to see the line of the markers

  const LineInformation(this.busCode);
  @override
  _LineInformationState createState() =>
      _LineInformationState(busCode: this.busCode);
}

class _LineInformationState extends State<LineInformation> {
  String busCode;
  _LineInformationState({this.busCode});

  List lineInfo; //get data into list
  Future<String> getBusLine() async {
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=DEPARTURE"),
        headers: {"Accept": "application/json"});
    this.setState(() {
      lineInfo = jsonDecode(response.body);
    });
    return "success";
  }

  GoogleMapController mapController; //to create the Map
  Position _currentPosition; // zoom to my location
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(0.0, 0.0)); // initial position

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
              zoom: 20.0,
            ),
          ),
        );
      });
      //await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _getUserLocation();
    await getBusLine();
    // To update mapcontroller
    setState(() {
      mapController = controller;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition.latitude,
              _currentPosition.longitude,
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

  void addMarkers() {
    int index = 0;
    locations.forEach((element) {
      final KMarker marker = KMarker(
        element.name,
        "",
        pinLocationIcon,
        context,
        id: MarkerId(index.toString()),
        lat: element.lat,
        lng: element.long,
      );
      markersList.add(marker);
      index++;
    });
  }
  bool isIOS = Platform.isIOS;

  BitmapDescriptor pinLocationIcon;
  @override
  void initState() {
    super.initState();
    //creating markers
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(/* devicePixelRatio: 1.5, */ /* size: Size(32, 32) */),
            isIOS ? 'assets/marker_ios.png' : 'assets/marker.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
    _getUserLocation();
    getBusLine();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps Sample'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
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
