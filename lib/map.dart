import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: unused_import
import 'package:google_maps_webservice/directions.dart' as directions;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapGuide extends StatefulWidget {
  final double lotlatitude;
  final double lotlongitude;

  MapGuide({
    required this.lotlatitude,
    required this.lotlongitude,
  });

  @override
  State<MapGuide> createState() => _MapGuideState();
}

class _MapGuideState extends State<MapGuide> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  bool mapError = false;

  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'LOCATION',
          style: GoogleFonts.raleway(
            fontSize: 30,
            color: Color(0xFFE4F4FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(hexColor('#003459')),
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                onMapCreated: (controller) {
                  try {
                    mapController = controller;

                    // Add a marker for the specified location
                    Marker newMarker = Marker(
                      markerId: MarkerId("parking_location"),
                      position: LatLng(widget.lotlatitude, widget.lotlongitude),
                      infoWindow: InfoWindow(
                        title: "Parking Location",
                        snippet:
                            "Latitude: ${widget.lotlatitude}, Longitude: ${widget.lotlongitude}",
                      ),
                    );

                    setState(() {
                      markers.add(newMarker);
                    });

                    // Fetch and display route
                    fetchRoute();
                  } catch (e) {
                    setState(() {
                      mapError = true;
                    });
                    print("MapError: $e");
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.lotlatitude, widget.lotlongitude),
                  zoom: 15.0,
                ),
                markers: markers,
                polylines: polylines,
                myLocationEnabled: true, // Enable GPS tracking
                myLocationButtonEnabled:
                    true, // Display a button to move the camera to the user's location
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to fetch and display the route
  void fetchRoute() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition();

      final apiKey = 'AIzaSyBT7H60imBZ02pLZtN_Df1BrGNAPP5xYoE';
      final apiUrl = 'https://maps.googleapis.com/maps/api/directions/json';

      final response = await http.get(
        Uri.parse(
            '$apiUrl?origin=${currentPosition.latitude},${currentPosition.longitude}'
            '&destination=${widget.lotlatitude},${widget.lotlongitude}&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        List<LatLng> routeCoordinates = [];

        for (var route in decodedResponse['routes']) {
          for (var leg in route['legs']) {
            for (var step in leg['steps']) {
              final List<LatLng> decodedPolyline =
                  _decodePolyline(step['polyline']['points']);
              routeCoordinates.addAll(decodedPolyline);
            }
          }
        }

        Polyline polyline = Polyline(
          polylineId: PolylineId("route"),
          points: routeCoordinates,
          color: Colors.blue,
          width: 5,
        );

        setState(() {
          polylines.add(polyline);
        });
      } else {
        print('Failed to load route. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latDouble = lat / 1e5;
      double lngDouble = lng / 1e5;
      poly.add(LatLng(latDouble, lngDouble));
    }
    return poly;
  }
}
