import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PickupNDropLocationModel {
  String? name;
  String? description;
  String? placeID;
  double? latitude;
  double? longitude;
  PickupNDropLocationModel({
    this.name,
    this.description,
    this.placeID,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'placeID': placeID,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PickupNDropLocationModel.fromMap(Map<String, dynamic> map) {
    return PickupNDropLocationModel(
      name: map['name'] != null ? map['name'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      placeID: map['placeID'] != null ? map['placeID'] as String : null,
      latitude: map['latitude'] != null ? map['latitude'] as double : null,
      longitude: map['longitude'] != null ? map['longitude'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PickupNDropLocationModel.fromJson(String source) =>
      PickupNDropLocationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
