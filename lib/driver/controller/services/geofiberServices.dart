import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/common/controller/services/locationServices.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/driver/controller/provider/locationProviderDriver.dart';

class GeoFireServices {
  static DatabaseReference databaseRef = FirebaseDatabase.instance
      .ref()
      .child('User/${auth.currentUser!.phoneNumber}/driverStatus');

  static goOnline() async {
    LatLng currentPosition = await LocationServices.getCurrentLocation();
    Geofire.initialize('OnlineDrivers');
    Geofire.setLocation(
      auth.currentUser!.phoneNumber!,
      currentPosition.latitude,
      currentPosition.longitude,
    );
    databaseRef.set('ONLINE');
    databaseRef.onValue.listen((event) {});
  }

  static goOffline(BuildContext context) {
    Geofire.removeLocation(auth.currentUser!.phoneNumber!);
    databaseRef.set('OFFLINE');
    databaseRef.onDisconnect();
  }

  static updateLocationRealTime(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );
    StreamSubscription<Position> driverPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((event) {
      context.read<LocationProviderDriver>().updateDriverPosition(event);
      Geofire.setLocation(
        auth.currentUser!.phoneNumber!,
        event.latitude,
        event.longitude,
      );
    });
  }
}
