import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint("Location services are disabled.");
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint("Location permission denied.");
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint("Location permission permanently denied.");
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  } catch (e) {
    debugPrint("Error getting current position: $e");
    return null;
  }
}

GeoPoint positionToGeoPoint(Position position) {
  return GeoPoint(position.latitude, position.longitude);
}