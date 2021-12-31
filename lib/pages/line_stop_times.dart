import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kayseri_ulasim/busDetails/line_detail.dart';
import 'package:kayseri_ulasim/pages/bus_stop.dart';

class StopTimes extends StatefulWidget {
  final String busStopCode;
  final String busStopName;
  final String busLineCode;
  final String busName;
  const StopTimes(
      {Key key,
      this.busLineCode,
      this.busStopCode,
      this.busName,
      this.busStopName})
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
    print(
        "http://kaktusmobile.kayseriulasim.com.tr/api/StopTimesForLine?DurakId=${widget.busStopCode}&HatKod=${widget.busLineCode}");
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
    timeData = getData();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)
          ),
          title: Text(
            widget.busName,
            style: TextStyle(fontSize: 15),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: FutureBuilder<List>(
              future: timeData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: snapshot.data[index]["line"]
                                                ["code"] +
                                            " ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: snapshot.data[index]["line"]
                                                ["name"] +
                                            "\n",
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: Text(snapshot.data[index]["doorNo"]),
                                trailing: Container(
                                  child: Text(
                                    snapshot.data[index]["timeToStop"]
                                        .toString()
                                        .substring(0, 5),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LineDetail(
                                              widget.busStopName,
                                              widget.busLineCode)));
                                },
                              ),
                            ],
                          ),
                        );
                      });
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }
}
