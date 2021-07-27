import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusStopPage extends StatefulWidget {
  const BusStopPage({Key key}) : super(key: key);

  @override
  _BusStopPageState createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  Timer timer;
  List aData;
  Future<List> getBusLines() async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/code/12/buslines?cityId=6"));
    this.aData = jsonDecode(response.body);
    return aData;
  }

  List bData;
  Future<List> aprBusLines() async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/busstops/code/5/buses"));
    this.bData = jsonDecode(response.body);
    return bData;
  }

  Future<List> busLineData;
  Future<List> aprLineData;
  @override
  void initState() {
    super.initState();
    busLineData = getBusLines();
    aprLineData = aprBusLines();
    timer = Timer.periodic(
        Duration(seconds: 13),
        (Timer t) => setState(() {
              aprLineData = aprBusLines();
            }));
  }

  @override
  Widget build(BuildContext context) {
    getBusLines();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bus Stop Page '),
          backgroundColor: Colors.blueGrey.shade900,
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Lines Passing by the Stop",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  child: FutureBuilder<List>(
                    future: busLineData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 6 / 2,
                                    crossAxisSpacing: 7,
                                    mainAxisSpacing: 17),
                            itemCount: aData.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text(snapshot.data[index]["code"]),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6)),
                              );
                            });
                      }
                      return Text(
                        "error",
                        style: TextStyle(color: Colors.grey[200]),
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.blue,
                child: ListTile(
                  leading: Icon(
                    Icons.bus_alert,
                    color: Colors.white,
                  ),
                  title: Text("Lines Approaching to the Stop"),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  child: RefreshIndicator(
                    onRefresh: () {
                      setState(() {
                        aprLineData = aprBusLines();
                      });
                      CircularProgressIndicator();
                      return Future.value(true);
                    },
                    child: bData == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : FutureBuilder<List>(
                            future: aprLineData,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  // Dont forget to add proper values
                                  itemCount: bData.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                onTap: () {},
                                                leading: Icon(
                                                  Icons.bus_alert,
                                                  color: Colors.blue.shade700,
                                                ),
                                                title: Text(bData[index]["line"]
                                                    ["name"]),
                                                subtitle: Text(bData[index]
                                                        ["timeToStop"]
                                                    .toString()),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              return Text("error");
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
