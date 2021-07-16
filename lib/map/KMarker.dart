import 'package:google_maps_flutter/google_maps_flutter.dart';

class KMarker extends Marker {
  final String name;

  KMarker(this.name, {MarkerId id, lat, lng, onTap})
      : super(
          markerId: id,
          position: LatLng(
            lat,
            lng,
          ),
          infoWindow: InfoWindow(title: name, snippet: 'Name of the busstop: $name.'),
          onTap: onTap,
        );
}
