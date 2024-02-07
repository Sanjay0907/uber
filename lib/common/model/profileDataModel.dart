import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProfileDataModel {
  String? name;
  String? profilePicUrl;
  String? mobileNumber;
  String? email;
  String? vehicleBrandName;
  String? vehicleModel;
  String? vehicleType;
  String? vehicleRegistrationNumber;
  String? drivingLicenseNumber;
  String? userType;
  DateTime? registeredDateTime;
  String? activeRideRequestID;
  String? driverStatus;
  String? cloudMessagingToken;
  ProfileDataModel({
    this.name,
    this.profilePicUrl,
    this.mobileNumber,
    this.email,
    this.vehicleBrandName,
    this.vehicleModel,
    this.vehicleType,
    this.vehicleRegistrationNumber,
    this.drivingLicenseNumber,
    this.userType,
    this.registeredDateTime,
    this.activeRideRequestID,
    this.driverStatus,
    this.cloudMessagingToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePicUrl': profilePicUrl,
      'mobileNumber': mobileNumber,
      'email': email,
      'vehicleBrandName': vehicleBrandName,
      'vehicleModel': vehicleModel,
      'vehicleType': vehicleType,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'userType': userType,
      'registeredDateTime': registeredDateTime?.millisecondsSinceEpoch,
      'activeRideRequestID': activeRideRequestID,
      'driverStatus': driverStatus,
      'cloudMessagingToken': cloudMessagingToken,
    };
  }

  factory ProfileDataModel.fromMap(Map<String, dynamic> map) {
    return ProfileDataModel(
      name: map['name'] != null ? map['name'] as String : null,
      profilePicUrl:
          map['profilePicUrl'] != null ? map['profilePicUrl'] as String : null,
      mobileNumber:
          map['mobileNumber'] != null ? map['mobileNumber'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      vehicleBrandName: map['vehicleBrandName'] != null
          ? map['vehicleBrandName'] as String
          : null,
      vehicleModel:
          map['vehicleModel'] != null ? map['vehicleModel'] as String : null,
      vehicleType:
          map['vehicleType'] != null ? map['vehicleType'] as String : null,
      vehicleRegistrationNumber: map['vehicleRegistrationNumber'] != null
          ? map['vehicleRegistrationNumber'] as String
          : null,
      drivingLicenseNumber: map['drivingLicenseNumber'] != null
          ? map['drivingLicenseNumber'] as String
          : null,
      userType: map['userType'] != null ? map['userType'] as String : null,
      registeredDateTime: map['registeredDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['registeredDateTime'] as int)
          : null,
      activeRideRequestID: map['activeRideRequestID'] != null
          ? map['activeRideRequestID'] as String
          : null,
      driverStatus:
          map['driverStatus'] != null ? map['driverStatus'] as String : null,
      cloudMessagingToken: map['cloudMessagingToken'] != null
          ? map['cloudMessagingToken'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileDataModel.fromJson(String source) =>
      ProfileDataModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
