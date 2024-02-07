// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/common/controller/services/APIsNKeys/apis.dart';
import 'package:http/http.dart' as http;
import 'package:uber/common/model/directionModel.dart';
import 'package:uber/driver/controller/provider/rideRequestProvider.dart';
import 'package:uber/rider/controller/provider/tripProvider/rideRequestProvider.dart';

class DirectionServices {
  static Future getDirectionDetailsRider(
      LatLng pickupLocation, LatLng dropLocation, BuildContext context) async {
    final api = Uri.parse(APIs.directionAPI(pickupLocation, dropLocation));
    try {
      var response = await http
          .get(api, headers: {'Content-Type': 'application/json'}).timeout(
              const Duration(seconds: 60), onTimeout: () {
        throw TimeoutException('Connection Timed Out');
      }).onError((error, stackTrace) {
        throw Exception(error);
      });

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        log(decodedResponse.toString());
        // log(decodedResponse.toString());
        DirectionModel directionModel = DirectionModel(
          distanceInKM: decodedResponse['routes'][0]['legs'][0]['distance']
              ['text'],
          distanceInMeter: decodedResponse['routes'][0]['legs'][0]['distance']
              ['value'],
          durationInHour: decodedResponse['routes'][0]['legs'][0]['duration']
              ['text'],
          duration: decodedResponse['routes'][0]['legs'][0]['duration']
              ['value'],
          polylinePoints: decodedResponse['routes'][0]['overview_polyline']
              ['points'],
        );
        log(directionModel.toMap().toString());
        context.read<RideRequestProvider>().updateDirection(directionModel);
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
  static Future getDirectionDetailsDriver(
      LatLng pickupLocation, LatLng dropLocation, BuildContext context) async {
    final api = Uri.parse(APIs.directionAPI(pickupLocation, dropLocation));
    try {
      var response = await http
          .get(api, headers: {'Content-Type': 'application/json'}).timeout(
              const Duration(seconds: 60), onTimeout: () {
        throw TimeoutException('Connection Timed Out');
      }).onError((error, stackTrace) {
        throw Exception(error);
      });

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        log(decodedResponse.toString());
        // log(decodedResponse.toString());
        DirectionModel directionModel = DirectionModel(
          distanceInKM: decodedResponse['routes'][0]['legs'][0]['distance']
              ['text'],
          distanceInMeter: decodedResponse['routes'][0]['legs'][0]['distance']
              ['value'],
          durationInHour: decodedResponse['routes'][0]['legs'][0]['duration']
              ['text'],
          duration: decodedResponse['routes'][0]['legs'][0]['duration']
              ['value'],
          polylinePoints: decodedResponse['routes'][0]['overview_polyline']
              ['points'],
        );
        log(directionModel.toMap().toString());
        context.read<RideRequestProviderDriver>().updateDirection(directionModel);
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
