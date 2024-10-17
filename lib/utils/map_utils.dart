import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapUtil {
  /// Retrieves a marker image from the specified [path] with the given [width].
  ///
  /// This method loads the marker image from the asset bundle at the provided [path]
  /// and resizes it to the specified [width]. The resulting image is returned
  /// as a byte array ([Uint8List]).

  static Future<Uint8List> getMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  /// Determines the user's current position using the device's location services.
  ///
  /// This method checks if location services are enabled and if the app has
  /// permission to access the device's location. If not, it requests permission.
  /// It then retrieves the user's current position using the Geolocator plugin.
  ///
  /// Returns a [Future] containing the user's current [Position].

  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
