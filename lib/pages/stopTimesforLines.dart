import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class StopTimes extends StatefulWidget {
  final String busStopCode;
  final String busLineCode;
  final String busName;
  const StopTimes({Key key, this.busLineCode, this.busStopCode, this.busName})
      : super(key: key);

  @override
  _StopTimesState createState() => _StopTimesState();
}

class _StopTimesState extends State<StopTimes> {

  // Get the data 
  List data;
  Future<List> getData() async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/StopTimesForLine?DurakId=${widget.busStopCode}&HatKod=${widget.busLineCode}"));
    if (response.statusCode == 200) {
      this.data = jsonDecode(response.body);
      return data;
    }
  }

  Future<List> timeData;

  @override
  void initState() {
    super.initState();
    timeData = getData();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.busName, style: TextStyle(fontSize: 15 ),),
          centerTitle: true,
        ),
        body: Column(
          children: [
            ListView.builder(
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            color: Colors.red,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  //   onTap: () {},
                                  // This part of the code decides whether the tram icon or the bus icon should be used
                                  leading: Icon(Icons.directions_bus),
                                  title: Text( "1", //show the stops that a bus passes from
                                    maxLines: 1,
                                  ),
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
          ],
        ),
      ),
    );
  }
}
