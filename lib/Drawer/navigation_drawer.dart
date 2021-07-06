import 'package:flutter/material.dart';
import 'package:kayseri_ulasim/Drawer/contact_us.dart';
import 'package:kayseri_ulasim/Drawer/routes.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          createDrawerHeader(),
          createDrawerBodyItem(
            icon: Icons.info,
            text: 'Card Application',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url: "https://www.kayseriulasim.com/kartbasvurusu",
                            appBar: new AppBar(
                              title: Text("Card Application"),
                            ),
                          )));
            },
          ),
          createDrawerBodyItem(
            icon: Icons.settings,
            text: 'Settings',
            onTap: () {},
          ),
          createDrawerBodyItem(
            icon: Icons.help,
            text: 'Help',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url:
                                "https://www.kayseriulasim.com/tr/kayseri-ulasim/sss/kart38-sikca-sorulanlar",
                            appBar: new AppBar(
                              title: Text("Help"),
                            ),
                          )));
            },
          ),
          createDrawerBodyItem(
            icon: Icons.bus_alert,
            text: 'About Kayseri Ulaşım',
            onTap: () => Navigator.pushReplacementNamed(
                context, PageRoutes.about_kayseri_ulasim),
          ),
          createDrawerBodyItem(
            icon: Icons.history_edu,
            text: 'About Kayseri',
            onTap: () => Navigator.pushReplacementNamed(
                context, PageRoutes.about_kayseri),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("İletişim"),
          ),
          createDrawerBodyItem(
              icon: Icons.contact_page,
              text: 'Contact Us',
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new ContactUs(),
                  ),
                );
              }),
          createDrawerBodyItem(
            icon: Icons.notifications,
            text: 'Announcements',
            onTap: () => Navigator.pushReplacementNamed(
                context, PageRoutes.announcements),
          ),
          createDrawerBodyItem(
            icon: Icons.text_fields,
            text: 'Survey',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url:
                                "https://www.kayseriulasim.com/tr/kayseri-ulasim/iletisim/musteri-memnuniyet-anketi",
                            appBar: new AppBar(
                              title: Text("Survey"),
                            ),
                          )));
            },
          ),
          createDrawerBodyItem(
            icon: Icons.announcement,
            text: 'Report an Issue',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new WebviewScaffold(
                            url: "https://www.kayseriulasim.com/iletisim-formu",
                            appBar: new AppBar(
                              title: Text("Report an Issue"),
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
