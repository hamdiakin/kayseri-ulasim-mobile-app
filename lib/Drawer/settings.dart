import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:kayseri_ulasim/Drawer/popup.dart';
import 'package:kayseri_ulasim/controller/language_controller.dart';
import 'package:provider/provider.dart';
import 'navigation_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  static const String routeName = '/settings';

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //Shared pref
  int _counter = 0;
  Future<void> readySharedPreferences() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    _counter = sharedPreferences.getInt("sayac") ?? 1;
    setState(() {});
  }

  Future<void> saveData() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    _counter = 0;
    sharedPreferences.setInt("sayac", _counter);
  }

  Future<void> saveData1() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    _counter = 1;
    sharedPreferences.setInt("sayac", _counter);
  }

  @override
  void initState() {
    super.initState();
    readySharedPreferences();
  }

  String dropdownValue = 'English - US';
  //String icon = "uk.png";
  @override
  Widget build(BuildContext context) {
    LanguageController controller = context.read<LanguageController>();
    return new Scaffold(
        appBar: AppBar(
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }),
          title: Text("drawer_settings".tr()),
        ),
        drawer: NavigationDrawer(),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 3 / 153,
            ),
            Card(
              child: ListTile(
                leading: Image(
                  image: AssetImage("assets/conv_logo.png"),
                ),
                title: Text('drawer_set_pick'.tr()),
                subtitle: Text('drawer_opt_lang'.tr()),
                trailing: Container(
                  height: 40,
                  padding: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.black, width: .9),
                  ),
                  child: Container(
                      padding: EdgeInsets.only(left: 4, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DropdownButton<String>(
                            icon: Container(
                              padding: EdgeInsets.only(
                                left: 10,
                              ),
                              child: Image(
                                image: AssetImage(_counter == 0
                                    ? "assets/us_logo.png"
                                    : "assets/tr_logo.png"),
                              ),
                              height: 30,
                              width: 30,
                            ),
                            iconSize: 15,
                            elevation: 16,
                            value: _counter == 0
                                ? dropdownValue = "English - US"
                                : dropdownValue = "Türkçe - TR",
                            style: TextStyle(color: Colors.black),
                            underline: Container(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              color: Colors.transparent,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                if (newValue == 'English - US') {
                                  this.setState(() {
                                    dropdownValue = 'English - US';
                                    // icon = "uk.png";
                                    context.locale = Locale('en', 'US');
                                    controller.onLanguageChanged();
                                    saveData();
                                  });
                                } else if (newValue == 'Türkçe - TR') {
                                  this.setState(() {
                                    dropdownValue = 'Türkçe - TR';
                                    // icon = "es.png";
                                    context.locale = Locale('tr', 'TR');
                                    controller.onLanguageChanged();
                                    saveData1();
                                  });
                                }
                              });
                            },
                            items: <String>['English - US', 'Türkçe - TR']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 3),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                            ),
                          )
                        ],
                      )),
                ),
              ),
            ),
          ],
        ));
  }
}

class SetListTiles extends StatefulWidget {
  String language;
  SetListTiles({Key key, this.language}) : super(key: key);

  @override
  _SetListTilesState createState() => _SetListTilesState();
}

class _SetListTilesState extends State<SetListTiles> {
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Dart'),
          leading: new Radio(
            value: "Dart",
            groupValue: widget.language,
            onChanged: (String selectedLanguage) {
              setState(() {
                widget.language = selectedLanguage;
              });
            },
          ),
        ),
        ListTile(
          title: Text('Java'),
          leading: new Radio(
            value: "Java",
            groupValue: widget.language,
            onChanged: (String selectedLanguage) {
              setState(() {
                widget.language = selectedLanguage;
              });
            },
          ),
        ),
        ListTile(
          title: Text('Python'),
          leading: new Radio(
            value: "Python",
            groupValue: widget.language,
            onChanged: (String selectedLanguage) {
              setState(() {
                widget.language = selectedLanguage;
              });
            },
          ),
        ),
      ],
    );
  }
}
