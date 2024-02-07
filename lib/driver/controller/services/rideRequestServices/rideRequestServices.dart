// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uber/common/controller/provider/profileDataProvider.dart';
import 'package:uber/common/controller/services/toastService.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/common/model/rideRequestModel.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/driver/controller/provider/rideRequestProvider.dart';
import 'package:uuid/uuid.dart';

class RideRequestServicesDriver {
  static checkRideAvailability(BuildContext context, String rideID) async {
    DatabaseReference? tripRef =
        FirebaseDatabase.instance.ref().child('RideRequest/$rideID');
    final snapshot = await tripRef.get();
    if (snapshot.exists) {
      Stream<DatabaseEvent> stream = tripRef.onValue;
      stream.listen((event) async {
        final checkSnapshotExists = await tripRef.get();
        if (checkSnapshotExists.exists) {
          RideRequestModel rideRequestModel = RideRequestModel.fromMap(
              jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>);
          if (rideRequestModel.driverProfile != null) {
            audioPlayer.stop();
            Navigator.pop(context);
            ToastService.sendScaffoldAlert(
              msg: 'Opps! Trip accepted by someone',
              toastStatus: 'ERROR',
              context: context,
            );
          }
        } else {
          audioPlayer.stop();
          Navigator.pop(context);
          ToastService.sendScaffoldAlert(
            msg: 'Opps! Ride Was Cancelled',
            toastStatus: 'ERROR',
            context: context,
          );
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  static getRideRequestData(String rideID) async {
    DatabaseReference? tripRef =
        FirebaseDatabase.instance.ref().child('RideRequest/$rideID');
    final snapshot = await tripRef.get();
    if (snapshot.exists) {
      RideRequestModel rideRequestModel = RideRequestModel.fromMap(
          jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>);
      return rideRequestModel;
    }
  }

  static updateRideRequestStatus(String rideRequestStatus, String rideID) {
    DatabaseReference tripRef =
        FirebaseDatabase.instance.ref().child('RideRequest/$rideID/rideStatus');
    tripRef.set(rideRequestStatus);
  }

  static getRideStatus(int rideStatusNum) {
    switch (rideStatusNum) {
      case 0:
        return 'WAITING_FOR_RIDE_REQUEST';
      case 1:
        return 'WAITING_FOR_DRIVER_TO_ARRIVE';

      case 2:
        return 'MOVING_TOWARDS_DESTINATION';

      case 3:
        return 'RIDE_COMPLETED';
    }
  }

  static updateRideRequestID(String rideID) {
    DatabaseReference tripRef = FirebaseDatabase.instance
        .ref()
        .child('User/${auth.currentUser!.phoneNumber}/activeRideRequestID');
    tripRef.set(rideID);
  }

  static acceptRideRequest(String rideID, BuildContext context) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('RideRequest/$rideID/driverProfile');
    ProfileDataModel profileData =
        context.read<ProfileDataProvider>().profileData!;
    ref.set(profileData.toMap()).then((value) {
      ToastService.sendScaffoldAlert(
        msg: 'Ride Request Registered Successfully',
        toastStatus: 'SUCCESS',
        context: context,
      );
    }).onError((error, stackTrace) {
      ToastService.sendScaffoldAlert(
        msg: 'Opps! Unable to Register Ride',
        toastStatus: 'ERROR',
        context: context,
      );
      throw Exception(error);
    });
  }

  static endRide(String rideID, BuildContext context) async {
    try {
      Uuid uuid = const Uuid();
      String uniqueID = uuid.v1().toString();
      DatabaseReference rideRef = FirebaseDatabase.instance
          .ref()
          .child('RideRequest/$rideID/rideEndTime');
      DatabaseReference rideRefFetchData =
          FirebaseDatabase.instance.ref().child('RideRequest/$rideID');
      DatabaseReference riderRef = FirebaseDatabase.instance
          .ref()
          .child('RideHistoryRider/$rideID/$uniqueID');
      DatabaseReference driverProfileRef = FirebaseDatabase.instance
          .ref()
          .child('User/${auth.currentUser!.phoneNumber}/activeRideRequestID');
      DatabaseReference driverRef = FirebaseDatabase.instance
          .ref()
          .child('RideHistoryDriver/$rideID/$uniqueID');
      context.read<RideRequestProviderDriver>().updateUpdateMarkerStatus(false);
      await rideRef.set(DateTime.now().microsecondsSinceEpoch);
      final snapshot = await rideRefFetchData.get();
      RideRequestModel rideData = RideRequestModel.fromMap(
          jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>);
      await RideRequestServicesDriver.updateRideRequestStatus(
        RideRequestServicesDriver.getRideStatus(3),
        rideID,
      );
      await riderRef.set(rideData.toMap());
      await driverRef.set(rideData.toMap());
      await rideRefFetchData.remove();
      await driverProfileRef.remove();
      ToastService.sendScaffoldAlert(
        msg: 'Trip Ended!!! You earned ${int.parse(rideData.fare) * 0.9}',
        toastStatus: 'SUCCESS',
        context: context,
      );
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
