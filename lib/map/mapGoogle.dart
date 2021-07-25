import 'dart:convert';
import 'package:flutter/material.dart';
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
  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) async {
    await addToList();
    // To update mapcontroller
    setState(() {
      mapController = controller;
    });
    // Adding markers to marker list and eventually to the map
    addMarkers();
  }

  // Serbest Vuruş

  // To reach API information
  List data;

  Future<String> getData() async {
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/borders=38.732972,35.508576,38.735353,35.526429,38.722087,35.510464,38.726996,35.530301"),
        headers: {"Accept": "application/json"});
    this.data = jsonDecode(response.body);

    return "success";
  }

  List data1;

   Future<String> getData1(double lat, double long) async {
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/borders=${lat+0.002},${long-0.002},${lat+0.002},${long+0.002},${lat-0.002},${long -0.002},${lat-0.002},${long+0.002}"),
        headers: {"Accept": "application/json"});
    this.data1 = jsonDecode(response.body);

    return "success";
  }

  List<Location> locations1 = [
    Location(38.7296, 35.515276, "nane"),
  ];
  // Adding locatiopn information of the bus stops into the list
  addToList1() async {
    for (var i = 0; i < data1.length; i++) {
      locations1.add(Location(
        data1[i]["latitude"],
        data1[i]["longitude"],
        data1[i]["name"],
        
      ));
    }
  }

  List<Location> locations = [
    Location(38.7296, 35.515276, "nane"),
  ];
  // Adding locatiopn information of the bus stops into the list
  addToList() async {
    await getData();
    for (var i = 0; i < data.length; i++) {
      locations.add(Location(
        data[i]["latitude"],
        data[i]["longitude"],
        data[i]["name"],
      ));
    }
  }

  // Adding Markers
  final LatLng _center = const LatLng(38.7287631, 35.5127753);

  Set<KMarker> markersList = new Set();

  void addMarkers() {
    int index = 0;
    locations.forEach((element) {
      final KMarker marker = KMarker(element.name,
          id: MarkerId(index.toString()),
          lat: element.lat,
          lng: element.long,
          onTap: null);
      markersList.add(marker);
      index++;
    });
  }
   void addMarkers1() {
    int index = 0;
    locations1.forEach((element) {
      final KMarker marker = KMarker(element.name,
          id: MarkerId(index.toString()),
          lat: element.lat,
          lng: element.long,
          onTap: null);
      markersList.add(marker);
      index++;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget build(BuildContext context) {
    print("eni vici vokke");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample '),
          backgroundColor: Colors.blueGrey.shade900,
        ),
        body: GoogleMap(
          onCameraMove: (CameraPosition position) {
            locations1.clear();
            markersList.clear();
            print("${position.target.latitude}  ${position.target.longitude}");
            getData1(position.target.latitude, position.target.longitude);
            addToList1();
            addMarkers1(); 
            print("http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/borders=${position.target.latitude+0.002},${position.target.longitude-0.002},${position.target.latitude+0.002},${position.target.longitude+0.002},${position.target.latitude-0.002},${position.target.longitude -0.002},${position.target.latitude-0.002},${position.target.longitude+0.002}");
          },
          onMapCreated: _onMapCreated,
          markers: markersList,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 10.5,
          ),
        ),
      ),
    );
  }
}
