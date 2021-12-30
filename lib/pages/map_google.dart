import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kayseri_ulasim/map/locations.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/map/KMarker.dart';

class mapGoogle extends StatefulWidget {
  const mapGoogle({Key key}) : super(key: key);

  @override
  _mapGoogleState createState() => _mapGoogleState();
}

class _mapGoogleState extends State<mapGoogle> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;
  Position _currentPosition;

  var Get;

  // Method for retrieving the current location
  _getUserLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      //await _getAddress();
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
    this.setState(() {
      data = jsonDecode(response.body);
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _getUserLocation();
    await addToList();
    // To update mapcontroller
    setState(() {
      mapController = controller;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(38.722690, 35.486939
                /* _currentPosition.latitude,
              _currentPosition.longitude, */
                ),
            zoom: 18.0,
          ),
        ),
      );
    });
    // Adding markers to marker list and eventually to the map
    /* Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        addMarkers();
      });
    }); */

    //addMarkers();
  }

  List data1;

  Future<String> getData1(double lat, double long) async {
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/borders=${lat + 0.009},${long - 0.009},${lat + 0.009},${long + 0.009},${lat - 0.009},${long - 0.009},${lat - 0.009},${long + 0.009}"),
        headers: {"Accept": "application/json"});
    this.data1 = jsonDecode(response.body);

    return "success";
  }

  List<Location> locations = [];
  // Adding location information of the bus stops into the list
  addToList() async {
    await getData();
    for (var i = 0; i < data.length; i++) {
      locations.add(Location(data[i]["latitude"], data[i]["longitude"],
          data[i]["name"], data[i]["code"]));
    }
  }

  List<Location> locations1 = [];
  // Adding location information of the bus stops into the list
  addToList1() async {
    for (var i = 0; i < data1.length; i++) {
      locations1.add(Location(data1[i]["latitude"], data1[i]["longitude"],
          data1[i]["name"], data1[i]["code"]));
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
        element.code,
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

  void addMarkers1() {
    int index = 0;
    locations1.forEach((element) {
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
    });
  }

  int counter = 3;
  void updateFunction(CameraPosition position) {
    if (counter > 0) {
      locations1.clear();
      markersList.clear();
      getData1(position.target.latitude, position.target.longitude);
      addToList1();
      setState(() {
        addMarkers1();
      });
      counter = counter - 24;
    } else {
      counter++;
      print("counter has been restted");
    }
  }

  BitmapDescriptor pinLocationIcon;
  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
    _getUserLocation();
    getData();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample'),
          backgroundColor: Colors.blueGrey.shade900,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              minMaxZoomPreference: MinMaxZoomPreference(2, 16),
              onCameraMove: (CameraPosition position) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  updateFunction(position);
                });
              },
              onMapCreated: _onMapCreated,
              markers: markersList,
              initialCameraPosition: _initialLocation,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 17.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
