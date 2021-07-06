import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kayseri_ulasim/Drawer/about_kayseri.dart';
import 'package:kayseri_ulasim/Drawer/navigation_drawer.dart';
import 'package:flutter/services.dart';

class MyColors {
  static const MaterialColor navy = MaterialColor(
    0XFF263238,
    <int, Color>{
      50: Color(0XFF263238),
      100: Color(0XFF263238),
      200: Color(0XFF263238),
      300: Color(0XFF263238),
      400: Color(0XFF263238),
      500: Color(0XFF263238),
      600: Color(0XFF263238),
      700: Color(0XFF263238),
      800: Color(0XFF263238),
      900: Color(0XFF263238),
    },
  );
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kayseri Ulaşım',
      theme: ThemeData(
        primarySwatch: MyColors.navy,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  String wantedPosition;
  String location;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchControl = TextEditingController();
  get onPressed => null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blueGrey.shade900,
          elevation: 10,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Spacer(),
              Image.asset(
                'assets/transparent.png',
                fit: BoxFit.fitHeight,
                height: 150,
              ),
              new Spacer(),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add_alert_sharp,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              color: Colors.blueGrey.shade900,
              height: 70,
              // Arama Butonu
              child: TextFormField(
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                cursorColor: Colors.blueGrey,
                controller: searchControl,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                    color: Colors.white,
                  ),
                  hintStyle: TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: 17,
                    color: Colors.white,
                  ),
                  hintText: "Hat / Durak Arama",
                  contentPadding: new EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: (MediaQuery.of(context).size.height) * (1 / 20),
            ),
            Expanded(
              child: Column(),
            ),
            Container(
              height: (MediaQuery.of(context).size.height) * (1 / 10),
              width: MediaQuery.of(context).size.width,
              color: Colors.blueGrey.shade900,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.map,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        "Harita",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
