import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProviderDriver extends ChangeNotifier {
  Position? positon;

  updateDriverPosition(Position newPosition) {
    positon = newPosition;
    notifyListeners();
  }
}
