import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NearByDriversModel {
  String driverID;
  double latitude;
  double longitude;
  NearByDriversModel({
    required this.driverID,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'driverID': driverID,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory NearByDriversModel.fromMap(Map<String, dynamic> map) {
    return NearByDriversModel(
      driverID: map['driverID'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory NearByDriversModel.fromJson(String source) => NearByDriversModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
