import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kayseri_ulasim/Drawer/navigation_drawer.dart';
import 'package:kayseri_ulasim/busDetails/line_detail.dart';
import 'package:kayseri_ulasim/pages/bus_stop.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To enable the "onTap" function. The class of this is on the bottom of this page
      appBar: CustomAppBar(
        onTap: () {
          showSearch(context: context, delegate: DataSearch());
        },
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
          title: Text("Hat / Durak Arama"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              },
            )
          ],
        ),
      ),
      drawer: NavigationDrawer(),
    );
  }
}

// Search Function
class DataSearch extends SearchDelegate<String> {
  // Getting the data
  List data;
  Future<List> getData(String query) async {
    var response = await http.get(Uri.parse(
        "http://kaktusmobile.kayseriulasim.com.tr/api/rest/search/$query"));
    if (response.statusCode == 200) {
      this.data = jsonDecode(response.body);
      return data;
    }
  }

  dataToObject(String query) async {
    await getData(query);
    if (data.length != null) {
      searchQuery.clear();
      for (int i = 0; i < data.length; i++) {
        searchQuery.add(new BusNStop(
            data[i]["node"]["name"], data[i]["node"]["code"], data[i]["type"]));
      }
    }
  }

  // Your search query list will be in these lists:
  List<BusNStop> searchQuery = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for app bar
    return [
      IconButton(
        onPressed: () {
          query = "";
          searchQuery.clear();
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of the app bar
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ));
  }

  int dumLength = 0;

  @override
  Widget buildSuggestions(BuildContext context) {
    // show suggestions
    print(query);
    getData(query);
    if (query.length > 0 && query.length != dumLength) {
      getData(query);
      dataToObject(query);
    }
    dumLength = query.length;

    return query.length <= 1
        ? (Column(
            // In case you want to use any kind of image
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text("Wow, such empty!")),
            ],
          ))
        //List goes here
        : ListView.builder(
            itemCount: searchQuery.length + 1,
            itemBuilder: (context, index) {
              return GestureDetector(
                child: ListTile(
                  onTap: () {
                    if (searchQuery[index].type == "BusStop") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BusStopPage(
                                    busStopCode: searchQuery[index].code,
                                    busStopName: searchQuery[index].name,
                                  )));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LineDetail(
                                    searchQuery[index].name,
                                    searchQuery[index].code,
                                  )));
                    }
                  },
                  leading: Icon(
                    searchQuery[index].type == "BusStop"
                        ? (searchQuery[index].code.length > 5
                            ? Icons.tram
                            : Icons.directions_bus)
                        : searchQuery[index].code.length > 5
                            ? Icons.tram
                            : Icons.directions_bus,
                  ),
                  title: Text(searchQuery[index].name),
                ),
              );
            });
  }

  @override
  Widget buildResults(BuildContext context) {
    // After clicking the search button in your keyboard, iaw when you meant to search
    getData(query);
    return ListView.builder(
        itemCount: searchQuery.length + 1,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              if (searchQuery[index].type == "BusStop") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BusStopPage(
                              busStopCode: searchQuery[index].code,
                              busStopName: searchQuery[index].name,
                            )));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LineDetail(
                              searchQuery[index].name,
                              searchQuery[index].code,
                            )));
              }
            },
            leading: Icon(
              searchQuery[index].type == "BusStop"
                  ? (searchQuery[index].code.length > 5
                      ? Icons.tram
                      : Icons.directions_bus)
                  : searchQuery[index].code.length > 5
                      ? Icons.tram
                      : Icons.directions_bus,
            ),
            title: Text(searchQuery[index].name),
          );
        });
  }
}

class BusNStop {
  String name;
  String code;
  String type;
  BusNStop(this.name, this.code, this.type);
}

// For "Custom App Bar"
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTap;
  final AppBar appBar;

  const CustomAppBar({Key key, this.onTap, this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: appBar);
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
