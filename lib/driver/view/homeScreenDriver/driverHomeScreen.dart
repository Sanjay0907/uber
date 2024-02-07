import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:uber/common/controller/services/locationServices.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/constant/utils/textStyles.dart';
import 'package:uber/driver/controller/services/geofiberServices.dart';
import 'package:uber/driver/controller/services/mapsProviderDriver.dart';

class HomeScreenDriver extends StatefulWidget {
  const HomeScreenDriver({super.key});

  @override
  State<HomeScreenDriver> createState() => _HomeScreenDriverState();
}

class _HomeScreenDriverState extends State<HomeScreenDriver> {
  Completer<GoogleMapController> mapControllerDriver = Completer();
  GoogleMapController? mapController;
  DatabaseReference driverProfileRef = FirebaseDatabase.instance
      .ref()
      .child('User/${auth.currentUser!.phoneNumber}');
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(100.w, 10.h),
            child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.h,
                ),
                child: StreamBuilder(
                  stream: driverProfileRef.onValue,
                  builder: (context, event) {
                    if (event.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: black,
                        ),
                      );
                    }
                    log(event.data.toString());
                    if (event.data == null) {
                      return SwipeButton(
                        thumbPadding: EdgeInsets.all(1.w),
                        thumb: Icon(
                          Icons.chevron_right,
                          color: white,
                        ),
                        inactiveThumbColor: black,
                        activeThumbColor: black,
                        inactiveTrackColor: greyShade3,
                        activeTrackColor: greyShade3,
                        elevationThumb: 2,
                        elevationTrack: 2,
                        onSwipe: () {
                          log('Button is Swiped');
                          GeoFireServices.goOnline();
                          GeoFireServices.updateLocationRealTime(context);
                        },
                        child: Builder(builder: (context) {
                          return Text(
                            'Go Online',
                            style: AppTextStyles.body16Bold,
                          );
                        }),
                      );
                    }
                    if (event.data != null) {
                      ProfileDataModel profileData = ProfileDataModel.fromMap(
                          jsonDecode(jsonEncode(event.data!.snapshot.value))
                              as Map<String, dynamic>);
                      log(profileData.driverStatus.toString());
                      log(profileData.toMap().toString());
                      if (profileData.driverStatus == 'ONLINE') {
                        return SwipeButton(
                          thumbPadding: EdgeInsets.all(1.w),
                          thumb: Icon(
                            Icons.chevron_right,
                            color: white,
                          ),
                          inactiveThumbColor: black,
                          activeThumbColor: black,
                          inactiveTrackColor: greyShade3,
                          activeTrackColor: greyShade3,
                          elevationThumb: 2,
                          elevationTrack: 2,
                          onSwipe: () {
                            log('Button is Swiped');
                            GeoFireServices.goOffline(context);
                          },
                          child: Builder(builder: (context) {
                            return Text(
                              'Go Offline',
                              style: AppTextStyles.body16Bold,
                            );
                          }),
                        );
                      } else {
                        return SwipeButton(
                          thumbPadding: EdgeInsets.all(1.w),
                          thumb: Icon(
                            Icons.chevron_right,
                            color: white,
                          ),
                          inactiveThumbColor: black,
                          activeThumbColor: black,
                          inactiveTrackColor: greyShade3,
                          activeTrackColor: greyShade3,
                          elevationThumb: 2,
                          elevationTrack: 2,
                          onSwipe: () {
                            log('Button is Swiped');
                            GeoFireServices.goOnline();
                            GeoFireServices.updateLocationRealTime(context);
                          },
                          child: Builder(builder: (context) {
                            return Text(
                              'Go Online',
                              style: AppTextStyles.body16Bold,
                            );
                          }),
                        );
                      }
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: black,
                      ),
                    );
                  },
                )),
          ),
          body: Stack(
            children: [
              Consumer<MapsProviderDriver>(
                  builder: (context, mapProvider, child) {
                return GoogleMap(
                  initialCameraPosition: mapProvider.initialCameraPosition,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  onMapCreated: (GoogleMapController controller) async {
                    mapControllerDriver.complete(controller);
                    mapController = controller;
                    LatLng crrLocation =
                        await LocationServices.getCurrentLocation();
                    CameraPosition cameraPosition = CameraPosition(
                      target: crrLocation,
                      zoom: 14,
                    );
                    mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(cameraPosition));
                  },
                );
              })
            ],
          )),
    );
  }
}
