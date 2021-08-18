import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'line_information.dart';
import 'line_timings.dart';


class LineDetail extends StatefulWidget {
  final String busStopName; //get from other page to see the details
  final String busCode; // get code for line_information.dart page
  const LineDetail(this.busStopName,this.busCode);

  @override
  _LineDetailState createState() =>
      _LineDetailState(busStopName: this.busStopName, busCode:this.busCode);
}

class _LineDetailState extends State<LineDetail> {
  String busStopName;
  String busCode;
  _LineDetailState({this.busStopName, this.busCode});

  Color _colorContainer = Colors.white;


  String direction = "DEPARTURE"; // to change the direction when pressed the icons

  List lineDetail;
  Future<List<dynamic>> getBusLine() async {  //get data
    var response = await http.get(
        Uri.parse(
            "http://kaktusmobile.kayseriulasim.com.tr/api/rest/buslines/code/$busCode/buses/direction=$direction"),
        headers: {"Accept": "application/json"});
    this.setState(() {
      lineDetail = jsonDecode(response.body);
    });
    return lineDetail; // all the data about a line
  }

  @override
  void initState() {
 getBusLine(); //make sure the data is taken before launching
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar
        (
        backgroundColor: Colors.blueGrey.shade900,
        title: Text("$busStopName"),// the name of bus got from busStop page
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(

                height: (MediaQuery.of(context).size.height) * 3.52 / 20,
                width: (MediaQuery.of(context).size.height) * 3.52 / 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  color: _colorContainer, //determine which color will be given on clicked
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {

                        setState(() {
                          _colorContainer =Colors.black12; //when clicked change the color
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LineDetail(busStopName,busCode)));// push the paramaters
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
              Container(
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
                          _colorContainer=Colors.black12;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LineInformation(busCode)));
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
              ), Container(
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
                          _colorContainer= Colors.black12;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LineTimings(busStopName, busCode, lineDetail[0]["stop"]["name"],  lineDetail[lineDetail.length-1]["stop"]["name"])));//send the required parameters to linetimings page
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

            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // set it to min
            children: <Widget>[
              Container(
                color: Colors.blueGrey.shade200,
                height: (MediaQuery.of(context).size.height) * 3.3 / 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: (MediaQuery.of(context).size.width) * 12 / 20,
                        child: Text(
                        "$busStopName Direction",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Padding(

                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: (MediaQuery.of(context).size.height) * 4 / 20,
                        width: (MediaQuery.of(context).size.width) * 5.3 / 20,
                        color: Colors.black38,
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_rounded,
                                size: 28.0,
                                color: direction=="DEPARTURE"?
                                Colors.blue
                                : Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  direction = "DEPARTURE"; //set the direction when presssed
                                });
                                getBusLine();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                size: 28.0,
                                color: direction=="DEPARTURE"?
                                Colors.white
                                : Colors.blue,
                              ),
                              onPressed: () {
                                setState(() {
                                  direction = "ARRIVAL"; //change the listView vice versa when clicked
                                });
                                getBusLine();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Text("SOME HASH KEY HERE"),
            ],
          ),
          Expanded(
            flex: 3,
            child: lineDetail == null// check if data available
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : new ListView.builder(
                    itemCount: lineDetail == null ? 0 : lineDetail.length,
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
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  //   onTap: () {},
                                  // This part of the code decides whether the tram icon or the bus icon should be used
                                  leading: Icon(Icons.directions_bus),
                                  title: Text(
                                    lineDetail[index]["stop"]["name"], //show the stops that a bus passes from
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
          ),
        ],
      ),
    );
  }
}
