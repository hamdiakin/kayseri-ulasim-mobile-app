import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kayseri_ulasim/pages/bus_stop.dart';

class KMarker extends Marker {
  final String name;
  final String code;
  final BitmapDescriptor deneme;
  final BuildContext context;

  KMarker(this.name, this.code, this.deneme, this.context,
      {MarkerId id, lat, lng})
      : super(
          markerId: id,
          position: LatLng(
            lat,
            lng,
          ),
          icon: deneme,
          infoWindow: InfoWindow(
            title: name,
            snippet: code == "Live" ? "This is live location information!" : 'Name of the bus stop: $name.',
            onTap: () => code == "Live" ? {}: Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BusStopPage(
                          busStopCode: code,
                          busStopName: name,
                        ))),
          ),
        );
}
