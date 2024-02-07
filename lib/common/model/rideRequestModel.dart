// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uber/common/model/pickupNDropLocationModel.dart';
import 'package:uber/common/model/profileDataModel.dart';

class RideRequestModel {
  DateTime rideCreatTime;
  DateTime? rideEndTime;
  double? riderRating;
  double? driverRating;
  ProfileDataModel riderProfile;
  ProfileDataModel? driverProfile;
  PickupNDropLocationModel pickupLocation;
  PickupNDropLocationModel dropLocation;
  String fare;
  String carType;
  String rideStatus;
  String otp;
  RideRequestModel({
    required this.rideCreatTime,
    this.rideEndTime,
    this.riderRating,
    this.driverRating,
    required this.riderProfile,
    this.driverProfile,
    required this.pickupLocation,
    required this.dropLocation,
    required this.fare,
    required this.carType,
    required this.rideStatus,
    required this.otp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rideCreatTime': rideCreatTime.millisecondsSinceEpoch,
      'rideEndTime': rideEndTime?.millisecondsSinceEpoch,
      'riderRating': riderRating,
      'driverRating': driverRating,
      'riderProfile': riderProfile.toMap(),
      'driverProfile': driverProfile?.toMap(),
      'pickupLocation': pickupLocation.toMap(),
      'dropLocation': dropLocation.toMap(),
      'fare': fare,
      'carType': carType,
      'rideStatus': rideStatus,
      'otp': otp,
    };
  }

  factory RideRequestModel.fromMap(Map<String, dynamic> map) {
    return RideRequestModel(
      rideCreatTime: DateTime.fromMillisecondsSinceEpoch(map['rideCreatTime'] as int),
      rideEndTime: map['rideEndTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['rideEndTime'] as int) : null,
      riderRating: map['riderRating'] != null ? map['riderRating'] as double : null,
      driverRating: map['driverRating'] != null ? map['driverRating'] as double : null,
      riderProfile: ProfileDataModel.fromMap(map['riderProfile'] as Map<String,dynamic>),
      driverProfile: map['driverProfile'] != null ? ProfileDataModel.fromMap(map['driverProfile'] as Map<String,dynamic>) : null,
      pickupLocation: PickupNDropLocationModel.fromMap(map['pickupLocation'] as Map<String,dynamic>),
      dropLocation: PickupNDropLocationModel.fromMap(map['dropLocation'] as Map<String,dynamic>),
      fare: map['fare'] as String,
      carType: map['carType'] as String,
      rideStatus: map['rideStatus'] as String,
      otp: map['otp'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RideRequestModel.fromJson(String source) =>
      RideRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
