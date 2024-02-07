import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/rider/controller/provider/tripProvider/rideRequestProvider.dart';
import 'package:uber/rider/model/nearbyDriversModel.dart';

class NearbyDriverServices {
  static getNearbyDrivers(LatLng pickupLocation, BuildContext context) {
    Geofire.initialize('OnlineDrivers');
    Geofire.queryAtLocation(
      pickupLocation.latitude,
      pickupLocation.longitude,
      20,
    )!
        .listen((event) {
      if (event != null) {
        log('Event is Not Null');
        var callback = event['callBack'];
        switch (callback) {
          case Geofire.onKeyEntered:
            NearByDriversModel model = NearByDriversModel(
              driverID: event['key'],
              latitude: event['latitude'],
              longitude: event['longitude'],
            );
            context.read<RideRequestProvider>().addDriver(model);
            if (context.read<RideRequestProvider>().fetchNearbyDrivers ==
                true) {
              context.read<RideRequestProvider>().updateMarker();
            }
            break;
          case Geofire.onKeyExited:
            context
                .read<RideRequestProvider>()
                .removeDriver(event['key'].toString());
            context.read<RideRequestProvider>().updateMarker();
            log('Driver Removed ${event['key']}');
            break;
          case Geofire.onKeyMoved:
            NearByDriversModel model = NearByDriversModel(
              driverID: event['key'],
              latitude: event['latitude'],
              longitude: event['longitude'],
            );
            context.read<RideRequestProvider>().updateNearbyLocation(model);
            context.read<RideRequestProvider>().updateMarker();
            break;
          case Geofire.onGeoQueryReady:
            log(context
                .read<RideRequestProvider>()
                .nearbyDrivers
                .length
                .toString());
            context.read<RideRequestProvider>().updateMarker();
            break;
        }
      } else {
        log('Event is Null');
      }
    });
  }
}
