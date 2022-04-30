import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:kayseri_ulasim/controller/language_controller.dart';
import 'package:provider/src/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_kayseri.dart';
import 'about_kayseri_ulasim.dart';
import 'announcements.dart';
import 'contact_us.dart';
import 'settings.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String _url = "https://www.kart38.com";
  void _launchURL() async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          createDrawerHeader(),
          createDrawerBodyItem(
            icon: Icons.info,
            text: 'drawer_card_app'.tr(),
            onTap: () {
              _launchURL();
              /* Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url: "https://www.kayseriulasim.com/kartbasvurusu",
                            appBar: new AppBar(
                              title: Text("Card Application"),
                            ),
                          ))); */
            },
          ),
          createDrawerBodyItem(
            icon: Icons.settings,
            text: 'drawer_settings'.tr(),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
          ),
          createDrawerBodyItem(
            icon: Icons.help,
            text: 'drawer_help'.tr(),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url:
                                "https://www.kayseriulasim.com/tr/kayseri-ulasim/sss/kart38-sikca-sorulanlar",
                            appBar: new AppBar(
                              title: Text(
                                'drawer_help'.tr(),
                              ),
                            ),
                          )));
            },
          ),
          createDrawerBodyItem(
              icon: Icons.bus_alert,
              text: 'drawer_about_comp'.tr(),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AboutKayseriUlasim()));
              }),
          createDrawerBodyItem(
              icon: Icons.history_edu,
              text: 'drawer_about_city'.tr(),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutKayseri()));
              }),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("drawer_connection".tr()),
          ),
          createDrawerBodyItem(
              icon: Icons.contact_page,
              text: 'drawer_contact'.tr(),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ContactUs()));
              }),
          createDrawerBodyItem(
              icon: Icons.notifications,
              text: 'drawer_announcements'.tr(),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Announcements()));
              }),
          createDrawerBodyItem(
            icon: Icons.text_fields,
            text: 'drawer_survey'.tr(),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url:
                                "https://www.kayseriulasim.com/tr/kayseri-ulasim/iletisim/musteri-memnuniyet-anketi",
                            appBar: new AppBar(
                              title: Text('drawer_survey'.tr(),),
                            ),
                          )));
            },
          ),
          createDrawerBodyItem(
            icon: Icons.announcement,
            text: 'drawer_issue'.tr(),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url: "https://www.kayseriulasim.com/iletisim-formu",
                            appBar: new AppBar(
                              title: Text('drawer_issue'.tr()),
                            ),
                          )));
            },
          ),
        ],
      ),
    );
  }
}

Widget createDrawerHeader() {
  return DrawerHeader(
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    decoration: BoxDecoration(),
    child: Row(
      children: [
        SizedBox(
          width: 10,
        ),
        Image.asset('assets/kbb.png', fit: BoxFit.fitHeight, height: 100),
        SizedBox(
          width: 20,
        ),
        Image.asset(
          'assets/transparent.png',
          fit: BoxFit.fitHeight,
          height: 150,
        ),
      ],
    ),
  );
}

Widget createDrawerBodyItem(
    {IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
        ),
        Text(text),
      ],
    ),
    onTap: onTap,
  );
}
