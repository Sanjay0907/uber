import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsProviderDriver extends ChangeNotifier {
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37.4, -122),
    zoom: 14.4746,
  );
  LatLng? currentLocation;

  updateCurrentLocation(LatLng newLocation) {
    currentLocation = newLocation;
    notifyListeners();
  }


}
