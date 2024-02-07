// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/common/controller/provider/locattionProvider.dart';
import 'package:uber/common/controller/services/APIsNKeys/apis.dart';
import 'package:http/http.dart' as http;
import 'package:uber/common/controller/services/toastService.dart';
import 'package:uber/common/model/pickupNDropLocationModel.dart';
import 'package:uber/common/model/searchedAddressModel.dart';

class LocationServices {
  static getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        getCurrentLocation();
      }
    }
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    LatLng currentLocation = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    return currentLocation;
  }

  static Future getAddressFromLatLng(
      {required LatLng position, required BuildContext context}) async {
    final api = Uri.parse(APIs.geoCoadingAPI(position));
    try {
      var response = await http
          .get(api, headers: {'Content-Type': 'application/json'}).timeout(
              const Duration(seconds: 60), onTimeout: () {
        ToastService.sendScaffoldAlert(
          msg: 'Opps! Connection Timed Out',
          toastStatus: 'ERROR',
          context: context,
        );
        throw TimeoutException('Connection Timed Out');
      });

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        PickupNDropLocationModel model = PickupNDropLocationModel(
          name: decodedResponse['results'][0]['formatted_address'],
          placeID: decodedResponse['results'][0]['place_id'],
          latitude: position.latitude,
          longitude: position.latitude,
        );
        log(model.toMap().toString());
        context.read<LocationProvider>().updatePickupLocation(model);
        return model;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future getSearchedAddress(
      {required String placeName, required BuildContext context}) async {
    List<SearchedAddressModel> address = [];
    final api = Uri.parse(APIs.placesAPI(placeName));
    try {
      var response = await http
          .get(api, headers: {'Content-Type': 'application/json'}).timeout(
              const Duration(seconds: 60), onTimeout: () {
        ToastService.sendScaffoldAlert(
          msg: 'Opps! Connection Timed Out',
          toastStatus: 'ERROR',
          context: context,
        );
        throw TimeoutException('Connection Timed Out');
      });

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        for (var data in decodedResponse['predictions']) {
          address.add(SearchedAddressModel(
            mainName: data['structured_formatting']['main_text'],
            secondaryName: data['structured_formatting']['secondary_text'],
            placeID: data['place_id'],
          ));
        }
        context.read<LocationProvider>().updateSearchedAddress(address);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static getLatLngFromPlaceID(SearchedAddressModel address,
      BuildContext context, String locationType) async {
    final api = Uri.parse(APIs.getLatLngFromPlaceIDAPI(address.placeID));

    try {
      var response = await http
          .get(api, headers: {'Content-Type': 'application/json'}).timeout(
              const Duration(seconds: 60), onTimeout: () {
        ToastService.sendScaffoldAlert(
          msg: 'Opps! Connection Timed Out',
          toastStatus: 'ERROR',
          context: context,
        );
        throw TimeoutException('Connection Timed Out');
      });
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);

        var locationLatLng = decodedResponse['result']['geometry']['location'];
        PickupNDropLocationModel model = PickupNDropLocationModel(
            name: address.mainName,
            description: address.secondaryName,
            placeID: address.placeID,
            latitude: locationLatLng['lat'],
            longitude: locationLatLng['lng']);

        if (locationType == 'DROP') {
          context.read<LocationProvider>().updateDropLocation(model);
        } else {
          context.read<LocationProvider>().updatePickupLocation(model);
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
