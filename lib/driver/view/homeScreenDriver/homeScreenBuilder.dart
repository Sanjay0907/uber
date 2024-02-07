import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/driver/view/homeScreenDriver/driverHomeScreen.dart';
import 'package:uber/driver/view/homeScreenDriver/tripScreen.dart';

class DriverHomeScreeBuilder extends StatefulWidget {
  const DriverHomeScreeBuilder({super.key});

  @override
  State<DriverHomeScreeBuilder> createState() => _DriverHomeScreeBuilderState();
}

class _DriverHomeScreeBuilderState extends State<DriverHomeScreeBuilder> {
  DatabaseReference driverProfileRef = FirebaseDatabase.instance
      .ref()
      .child('User/${auth.currentUser!.phoneNumber}');
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: driverProfileRef.onValue,
        builder: (context, event) {
          if (event.connectionState == ConnectionState.waiting) {
            return const HomeScreenDriver();
          }
          if (event.data != null) {
            ProfileDataModel profileData = ProfileDataModel.fromMap(
                jsonDecode(jsonEncode(event.data!.snapshot.value))
                    as Map<String, dynamic>);
            if (profileData.activeRideRequestID != null) {
              return  TripScreen(rideID:  profileData.activeRideRequestID!,);
            } else {
              return const HomeScreenDriver();
            }
          } else {
            return const HomeScreenDriver();
          }
        });
  }
}
