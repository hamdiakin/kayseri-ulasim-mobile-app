import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  static const String routeName = '/contact_us';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: Text("Contact Us"),
      ),
      body: Center(
        child: Expanded(
          child: Column(
            children: [
              Image.asset('assets/contactUs.png', fit: BoxFit.cover, height: MediaQuery.of(context).size.height*(6/21)),
              Container(
                child: Text("Kayseri Ulaşım A.Ş. Genel Müdürlüğü", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/36),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/11),
                child: ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text("Kayseri Ulaşım A.Ş. \nOrganize Sanayi Bölgesi 9. Cad. No:2 \nMelikgazi/Kayseri, Türkiye"),
                ),
              ),
              Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/23),
                child: ListTile(
                  leading: Icon(Icons.phone_outlined),
                  title: Text("Müşteri Destek Hattı 153"),
                ),
              ),
              Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/23),
                child: ListTile(
                  leading: Icon(Icons.face_outlined),
                  title: Text("UlasimKayseri"),
                ),
              ),
              Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/23),
                child: ListTile(
                  leading: Icon(Icons.transfer_within_a_station),
                  title: Text("UlasimKayseri"),
                ),
              ),
              Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/23),
                child: ListTile(
                  leading: Icon(Icons.face_outlined),
                  title: Text("UlasimKayseri"),
                ),
              ),
              Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/23),
                child: ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text("bilgi@kayseriulasim.com"),
                ),
              ),
              Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height*(1/23),
                child: ListTile(
                  leading: Icon(Icons.center_focus_strong_rounded),
                  title: Text("UlasimKayseri"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
