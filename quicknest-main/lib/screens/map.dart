import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final Function(double, double) onLocationSelected;

  const MapScreen({required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(31.4449387, -9.73999),
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId('marker_1'),
            position: LatLng(31.4449387, -9.73999),
            infoWindow: InfoWindow(title: 'Marker Title'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          // Add additional functionality here if needed
        },
        onTap: (LatLng position) {
          // Return the coordinates of the selected position
          onLocationSelected(position.latitude, position.longitude);
          Navigator.pop(context, {'latitude': position.latitude, 'longitude': position.longitude}); // Close the map
        },
      ),
    );
  }
}
