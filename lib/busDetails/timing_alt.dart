import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TimingAlt extends StatefulWidget {
  final String busName;
  final String busCode;
  final String firstStation;
  final String lastStation;

  const TimingAlt(
      this.busName, this.busCode, this.firstStation, this.lastStation);

  @override
  _TimingAltState createState() => _TimingAltState(
      busName: this.busName,
      busCode: this.busCode,
      firstStation: this.firstStation,
      lastStation: this.lastStation);
}

class _TimingAltState extends State<TimingAlt> {
  _TimingAltState(
      {this.busName, this.busCode, this.firstStation, this.lastStation});

  String busName;
  String busCode;
  String firstStation; //if departure, show first station
  String lastStation; // if arrival, show last station
  bool decidedStation = true; //decide if arrival or departure direction

  List lineTimes; //get data into list

  Future<List<Map<String, dynamic>>> getBusTimes() async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/timetable"));
    if (response.statusCode != 200) return null;
    lineTimes = List<Map<String, dynamic>>.from(
        json.decode(response.body)['lineSchedules']);
    return lineTimes;
  }

  Future<List> lineTimesFuture;

  // Fun stuff

  List filterOut(List data, String dayType, String direction) {
    List deneme = [];
    for (int i = 0; i < data.length; i++) {
      print("hello");
      if (data[i]["direction"] == direction && data[i]["dayType"] == dayType) {
        deneme.add(2);
        //(deneme.add(data[i]);
      }
    }
    print("hello");
    return deneme;
  }

  @override
  void initState() {
    lineTimesFuture = getBusTimes(); // set the future list to our list
    super.initState();
  }

  getStationName() {
    //method for showing first or last station
    if (decidedStation == true) {
      return firstStation;
    } else {
      return lastStation;
    }
  }

  @override
  Widget build(BuildContext context) {
    getStationName();
    filterOut(lineTimes, "WORKDAY", "DEPARTURE");
    return Text("Yello");
  }
}
