import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:uber/common/controller/services/APIsNKeys/apis.dart';
import 'package:uber/common/controller/services/APIsNKeys/keys.dart';
import 'package:uber/common/controller/services/firebasePushNotificatinServices/pushNotificationDialogue.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/common/model/rideRequestModel.dart';
import 'package:uber/constant/constants.dart';
import 'package:http/http.dart' as http;

class PushNotificationServices {
  //  Initializing Firebase Messaging Instance
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static Future initializeFirebaseMessaging(
      ProfileDataModel profileData, BuildContext context) async {
    await firebaseMessaging.requestPermission();
    if (profileData.userType == 'PARTNER') {
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackfroundHandlerDriver);
      FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        if (message.notification != null) {
          firebaseMessagingForeGroundHandlerDriver(message, context);
        }
      });
    } else {
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackfroundHandlerRider);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          firebaseMessagingForeGroundHandlerRider(message);
        }
      });
    }
  }

  static getRideRequestID(RemoteMessage message) {
    log(message.toMap().toString());
    String rideID = message.data['rideRequestID'];
    log(rideID);
    return rideID;
  }
// ! Rider Cloud Messaging Functions

  static Future<void> firebaseMessagingBackfroundHandlerRider(
      RemoteMessage message) async {}
  static firebaseMessagingForeGroundHandlerRider(RemoteMessage message) async {}

// ! Driver Cloud Messaging Functions
  static Future<void> firebaseMessagingBackfroundHandlerDriver(
      RemoteMessage message) async {
    String riderID = getRideRequestID(message);
  }

  static firebaseMessagingForeGroundHandlerDriver(
      RemoteMessage message, BuildContext context) async {
    String rideID = getRideRequestID(message);
    fetchRideRequestInfo(rideID, context);
  }

// ! *****************************************

  static Future getToken(ProfileDataModel model) async {
    String? token = await firebaseMessaging.getToken();
    log('Cloud Messaging Token is : $token');
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .ref()
        .child('User/${auth.currentUser!.phoneNumber}/cloudMessagingToken');
    tokenRef.set(token);
  }

  static fetchRideRequestInfo(String rideID, BuildContext context) {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('RideRequest/$rideID');
    ref.once().then((databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        RideRequestModel rideRequestModel = RideRequestModel.fromMap(jsonDecode(
          jsonEncode(databaseEvent.snapshot.value),
        ) as Map<String, dynamic>);
        log(rideRequestModel.toMap().toString());
//  Show a dialogue to accept ride request
        log('Showing Dialogue');
        PushNotificationDialouge.rideRequestDialogue(rideRequestModel, context);
      }
    }).onError((error, stackTrace) {
      log(error.toString());
      throw Exception(error);
    });
  }

  static subscribeToNotification(ProfileDataModel model) {
    if (model.userType == 'PARTNER') {
      firebaseMessaging.subscribeToTopic('PARTNER');
      firebaseMessaging.subscribeToTopic('USER');
    } else {
      firebaseMessaging.subscribeToTopic('RIDER');
      firebaseMessaging.subscribeToTopic('USER');
    }
  }

  static initializeFirebaseMessagingForUsers(
      ProfileDataModel profileData, BuildContext context) {
    initializeFirebaseMessaging(profileData, context);
    getToken(profileData);
    subscribeToNotification(profileData);
  }

  static sendRideRequestToNearbyDrivers(String driverFCMToken) async {
    try {
      final api = Uri.parse(APIs.pushNotificationAPI());
      var body = jsonEncode({
        "to": driverFCMToken,
        "notification": {
          "body": "New Ride Request In your Location.",
          "title": "Ride Request"
        },
        "data": {"rideRequestID": auth.currentUser!.phoneNumber!}
      });
      var response = await http
          .post(api,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'key=$fcmServerKey'
              },
              body: body)
          .then((value) {
        log('Successfully send Ride Request');
      }).timeout(const Duration(seconds: 60), onTimeout: () {
        throw TimeoutException('Connection Timed Out');
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } catch (e) {
      log(e.toString());
      log('Error sending push Notification');
      throw Exception(e);
    }
  }
}
