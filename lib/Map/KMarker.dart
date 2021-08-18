import 'package:google_maps_flutter/google_maps_flutter.dart';

class KMarker extends Marker {
  final String name;
  final BitmapDescriptor deneme;

  KMarker(this.name, this.deneme, {MarkerId id, lat, lng, onTap})
      : super(
          markerId: id,
          position: LatLng(
            lat,
            lng,
          ),
          icon: deneme,
          infoWindow: InfoWindow(title: name, snippet: 'Name of the bus stop: $name.'),
          onTap: onTap,
        );
}
