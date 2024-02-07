import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber/common/controller/services/firebasePushNotificatinServices/pushNotificationServices.dart';
import 'package:uber/common/controller/services/locationServices.dart';
import 'package:uber/common/controller/services/profileDataCRUDServices.dart';
import 'package:uber/common/model/directionModel.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:uber/common/model/pickupNDropLocationModel.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/rider/model/nearbyDriversModel.dart';

class RideRequestProvider extends ChangeNotifier {
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37.4, -122),
    zoom: 14,
  );
  Set<Marker> riderMarker = Set<Marker>();
  Set<Polyline> polylineSet = {};
  Polyline? polyline;
  List<LatLng> polylineCoordinatesList = [];
  DirectionModel? directionDetails;
  BitmapDescriptor? carIconForMap;
  BitmapDescriptor? destinationIconForMap;
  BitmapDescriptor? pickupIconForMap;
  bool updateMarkerBool = false;
  PickupNDropLocationModel? dropLocation;
  PickupNDropLocationModel? pickupLocation;
  int uberGoFare = 0;
  int uberGoSedanFare = 0;
  int uberPremierFare = 0;
  int uberXLFare = 0;
  bool fetchNearbyDrivers = false;
  List<NearByDriversModel> nearbyDrivers = [];
  bool placedRideRequest = false;
  updatePlacedRideRequestStatus(bool newStatus) {
    placedRideRequest = newStatus;
    notifyListeners();
  }

  makeFareZero() {
    uberGoFare = 0;
    uberGoSedanFare = 0;
    uberPremierFare = 0;
    uberXLFare = 0;
    notifyListeners();
  }

  getFare() {
    int baseFare = 50;
    int uberGoDistancePerKM = 12;
    int uberGoSedanDistancePerKM = 15;
    int uberPremierDistancePerKM = 17;
    int uberXLDistancePerKM = 20;
    int uberGoDurationPerMinute = 1;
    int uberGoSedanDurationPerMinute = 2;
    double uberPremierDurationPerMinute = 2.5;
    int uberXLDurationPerMinute = 3;

    uberGoFare = (baseFare +
            uberGoDistancePerKM *
                double.parse(
                    (directionDetails!.distanceInMeter / 1000).toString()) +
            (uberGoDurationPerMinute * (directionDetails!.duration / 60)))
        .round();
    uberGoSedanFare = (baseFare +
            uberGoSedanDistancePerKM *
                double.parse(
                    (directionDetails!.distanceInMeter / 1000).toString()) +
            (uberGoSedanDurationPerMinute * (directionDetails!.duration / 60)))
        .round();
    uberPremierFare = (baseFare +
            uberPremierDistancePerKM *
                double.parse(
                    (directionDetails!.distanceInMeter / 1000).toString()) +
            (uberPremierDurationPerMinute * (directionDetails!.duration / 60)))
        .round();
    uberXLFare = (baseFare +
            uberXLDistancePerKM *
                double.parse(
                    (directionDetails!.distanceInMeter / 1000).toString()) +
            (uberXLDurationPerMinute * (directionDetails!.duration / 60)))
        .round();
    notifyListeners();
  }

  updateRidePickupAndDropLocation(
    PickupNDropLocationModel pickup,
    PickupNDropLocationModel drop,
  ) {
    pickupLocation = pickup;
    dropLocation = drop;
    notifyListeners();
    log('PICKUP and DROP LOCATION IS');
    log(pickupLocation!.toMap().toString());
    log(dropLocation!.toMap().toString());
  }

  updateUpdateMarkerBool(bool newStatus) {
    updateMarkerBool = newStatus;
    notifyListeners();
  }

  updateDirection(DirectionModel newDirection) {
    directionDetails = newDirection;
    notifyListeners();
  }

  decodePolylineAndUpdatePolylineField() {
    PolylinePoints polylinePoints = PolylinePoints();
    polylineCoordinatesList.clear();
    polylineSet.clear();
    List<PointLatLng> data =
        polylinePoints.decodePolyline(directionDetails!.polylinePoints);

    if (data.isNotEmpty) {
      for (var latLngPoints in data) {
        polylineCoordinatesList.add(LatLng(
          latLngPoints.latitude,
          latLngPoints.longitude,
        ));
      }
    }
    polyline = Polyline(
      polylineId: const PolylineId('TripPolyline'),
      color: black,
      points: polylineCoordinatesList,
      jointType: JointType.round,
      width: 3,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    polylineSet.add(polyline!);

    notifyListeners();
  }

  createIcons(BuildContext context) {
    if (pickupIconForMap == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/images/icons/pickupPngSmall.png')
          .then((icon) {
        pickupIconForMap = icon;
        notifyListeners();
      });
    }
    if (destinationIconForMap == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/images/icons/dropPngSmall.png')
          .then((icon) {
        destinationIconForMap = icon;
        notifyListeners();
      });
    }
    if (carIconForMap == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/images/vehicle/mapCar.png')
          .then((icon) {
        carIconForMap = icon;
        notifyListeners();
      });
    }
  }

  updateMarker() async {
    riderMarker = Set<Marker>();
    Marker pickupMarker = Marker(
      markerId: const MarkerId('PickupMarker'),
      position: LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
      icon: pickupIconForMap!,
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId('PickupMarker'),
      position: LatLng(dropLocation!.latitude!, dropLocation!.longitude!),
      icon: destinationIconForMap!,
    );

    if (fetchNearbyDrivers == true) {
      math.Random random = math.Random();
      for (var driver in nearbyDrivers) {
        double rotaion = random.nextInt(360).toDouble();
        Marker carMarker = Marker(
          markerId: MarkerId(driver.driverID),
          rotation: rotaion,
          position: LatLng(driver.latitude, driver.longitude),
          icon: carIconForMap!,
        );
        riderMarker.add(carMarker);
      }
    }
   if (updateMarkerBool == true) {
      LatLng crrLocation = await LocationServices.getCurrentLocation();
      Marker carMarker = Marker(
        markerId: MarkerId(auth.currentUser!.phoneNumber!),
        position: LatLng(crrLocation.latitude, crrLocation.longitude),
        icon: carIconForMap!,
      );
      riderMarker.add(carMarker);
    }
    riderMarker.add(pickupMarker);
    riderMarker.add(destinationMarker);
    notifyListeners();
    if (updateMarkerBool == true) {
      await Future.delayed(
          const Duration(
            seconds: 5,
          ), () async {
        await updateMarker();
      });
    }
  }

// ! Nearby Drivers Functions
sendPushNotificationToNearbyDrivers()async{
  for(var driver in nearbyDrivers){
     ProfileDataModel driverProfileData =
            await ProfileDataCRUDServices.getProfileDataFromRealTimeDatabase(
                driver.driverID);
        await PushNotificationServices.sendRideRequestToNearbyDrivers(
            driverProfileData.cloudMessagingToken!);
  }
}

  updateFetchNearbyDrivers(bool newStatus) {
    fetchNearbyDrivers = newStatus;
    notifyListeners();
  }

  addDriver(NearByDriversModel driver) {
    nearbyDrivers.add(driver);
    notifyListeners();
  }

  removeDriver(String driverID) {
    int index =
        nearbyDrivers.indexWhere((element) => element.driverID == driverID);
    nearbyDrivers.removeAt(index);
    notifyListeners();
  }

  updateNearbyLocation(NearByDriversModel driver) {
    int index = nearbyDrivers
        .indexWhere((element) => element.driverID == driver.driverID);
    nearbyDrivers[index].longitude = driver.longitude;
    nearbyDrivers[index].latitude = driver.latitude;
    notifyListeners();
  }
}
