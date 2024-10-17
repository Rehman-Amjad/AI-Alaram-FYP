import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:move_to_background/move_to_background.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../utils/map_utils.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LocationData? _currentPosition;
  Location location = Location();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? mosqueIcon;
  BitmapDescriptor? currentLocationIcon;
  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setCustomMarkers();
  }

  Future<void> _setCustomMarkers() async {
    final Uint8List mosqueMarkerIcon =
        await GoogleMapUtil.getMarker('assets/mosque.png', 100);
    mosqueIcon = BitmapDescriptor.bytes(mosqueMarkerIcon);

    final Uint8List currentLocationMarkerIcon =
        await GoogleMapUtil.getMarker('assets/currentLocation.png', 100);
    currentLocationIcon = BitmapDescriptor.bytes(currentLocationMarkerIcon);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
      });

      if (_currentPosition != null) {
        _moveCameraToPosition();
        _updateCurrentLocationMarker();
        _checkProximityToMosques();
      }
    });
  }

  void _moveCameraToPosition() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
          zoom: 14.0,
        ),
      ),
    );
  }

  void _updateCurrentLocationMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position:
              LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
          icon: currentLocationIcon!,
        ),
      );
    });
  }

  Future<void> _checkProximityToMosques() async {
    String googleApiKey = 'YOUR_GOOGLE_API_KEY';
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=2000&type=mosque&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mosques = data['results'];

      setState(() {
        _markers.clear();
        _polylines.clear();
        for (var mosque in mosques) {
          final mosqueLat = mosque['geometry']['location']['lat'];
          final mosqueLng = mosque['geometry']['location']['lng'];

          final marker = Marker(
            icon: mosqueIcon!,
            markerId: MarkerId(mosque['place_id']),
            position: LatLng(mosqueLat, mosqueLng),
            infoWindow: InfoWindow(
              title: mosque['name'],
              snippet: mosque['vicinity'],
            ),
          );
          _markers.add(marker);

          _addPolylineToMosque(LatLng(mosqueLat, mosqueLng));

          // Check the distance between the user's current location and the mosque
          final double distance = Geolocator.distanceBetween(
            _currentPosition!.latitude!,
            _currentPosition!.longitude!,
            mosqueLat,
            mosqueLng,
          );

          if (distance <= 100) {
            _triggerActionForNearbyMosque(mosque['name']);
          }
        }
      });
    } else {
      throw Exception('Failed to load nearby mosques');
    }
  }

  void _addPolylineToMosque(LatLng mosqueLocation) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result =
        await await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyCog7RsE7QqPGoGhJePgBaaXqNbuO8fDAE",
      request: PolylineRequest(
        origin: PointLatLng(
            _currentPosition!.latitude!, _currentPosition!.longitude!),
        destination:
            PointLatLng(mosqueLocation.latitude, mosqueLocation.latitude),
        mode: TravelMode.walking,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId(mosqueLocation.toString()),
            width: 5,
            color: Colors.blue,
            points: polylineCoordinates,
          ),
        );
      });
    }
  }

  void _triggerActionForNearbyMosque(String mosqueName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nearby Mosque'),
          content: Text('You are near $mosqueName.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mosques Near Me'),
        backgroundColor: Colors.purple,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _currentPosition!.latitude!, _currentPosition!.longitude!),
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
    );
  }
}
