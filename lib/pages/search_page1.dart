import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/busDetails/alt_line_detail.dart';
import 'package:kayseri_ulasim/busDetails/alt_line_detail2.dart';
import 'package:kayseri_ulasim/busDetails/line_detail.dart';

import 'bus_stop.dart';
//import http package manually

class SearchBar extends StatefulWidget {
  @override
  State createState() {
    return _SearchBar();
  }
}

class _SearchBar extends State {
  final _debouncer = Debouncer(milliseconds: 200);
  bool cross;
  bool error;
  var data;
  String query;

  final myController = TextEditingController();

  @override
  void initState() {
    cross = false;
    error = false;
    query = "";
    super.initState();
  }

  void getSuggestion() async {
    //get suggestion function
    var res = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/search/" +
            Uri.encodeComponent(query)));
    //in query there might be unwant character so, we encode the query to url
    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        //update data value and UI
      });
    } else {
      //there is error
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: searchField(),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  query = "";
                  data.clear();
                  myController.clear();
                  cross = true;
                });
              },
              icon: Icon(Icons.clear),
            ),

            //add more icons here
          ],
          backgroundColor: Colors.blueGrey.shade900,
          //if searching set background to orange, else set to deep orange
        ),
        body: SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                child: data == null
                    ? Container(
                        padding: EdgeInsets.all(20), child: Text("Type in")
                        //if is searching then show "Please wait"
                        //else show search text
                        )
                    : Container(
                        child: showSearchSuggestions(),
                      )
                // if data is null or not retrived then
                // show message, else show suggestion
                )));
  }

  Widget showSearchSuggestions() {
    List suggestionlist = List.from(data.map((i) {
      return BusNStop.fromJSON(i);
    }));
    //serilizing json data inside model list.
    return Column(
      children: suggestionlist.map((suggestion) {
        return InkResponse(
            onTap: () {
              //when tapped on suggestion
              print(suggestion.id); //pint student id
            },
            child: SizedBox(
              width: double.infinity, //make 100% width
              child: ListTile(
                onTap: () {
                  if (suggestion.type == "BusStop") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BusStopPage(
                                  busStopCode: suggestion.code,
                                  busStopName: suggestion.name,
                                )));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AltLineDetail2(
                                  suggestion.name,
                                  suggestion.code,
                                )));
                  }
                },
                leading: Icon(
                  suggestion.type == "BusStop"
                      ? (suggestion.code.length > 5
                          ? Icons.tram
                          : Icons.directions_bus)
                      : suggestion.code.length > 5
                          ? Icons.tram
                          : Icons.directions_bus,
                ),
                //title: Text(suggestion.name + suggestion.code),
                title: RichText(
                    text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  
                  children: <TextSpan>[
                    TextSpan(
                        text: suggestion.code.length >5 ? "" : suggestion.code,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' '),
                    TextSpan(text: suggestion.name),
                  ],
                )),
              ),
            ));
      }).toList(),
    );
  }

  Widget searchField() {
    //search input field
    return Container(
        child: TextField(
      autofocus: false,
      controller: myController,
      style: TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.white, fontSize: 18),
        hintText: "Line / Stop Search",
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ), //under line border, set OutlineInputBorder() for all side border
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ), // focused border color
      ), //decoration for search input field
      onChanged: (value) {
        query = value; //update the value of query
        _debouncer.run(() => getSuggestion()); //start to get suggestion
      },
    ));
  }
}

//serarch suggestion data model to serialize JSON data
class BusNStop {
  String name;
  String code;
  String type;
  BusNStop({this.code, this.name, this.type});

  factory BusNStop.fromJSON(Map<String, dynamic> json) {
    return BusNStop(
      name: json["node"]["name"],
      code: json["node"]["code"],
      type: json["type"],
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
