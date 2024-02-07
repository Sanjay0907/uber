// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:uber/common/controller/services/directionServices.dart';
import 'package:uber/common/controller/services/locationServices.dart';
import 'package:uber/common/model/rideRequestModel.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/constant/utils/textStyles.dart';
import 'package:uber/driver/controller/provider/rideRequestProvider.dart';
import 'package:uber/driver/controller/services/rideRequestServices/rideRequestServices.dart';
import 'package:flutter/services.dart' show rootBundle;

class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.rideID});
  final String rideID;

  @override
  State<TripScreen> createState() => _BookARideScreenState();
}

class _BookARideScreenState extends State<TripScreen> {
  Completer<GoogleMapController> mapControllerDriver = Completer();
  GoogleMapController? mapController;
  // String? rideID;

  TextEditingController otpController = TextEditingController();
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // rideID = context
      //     .read<RideRequestProviderDriver>()
      //     .rideRequestData!
      //     .riderProfile
      //     .mobileNumber!;
      // log('The Ride ID is');
      // log(rideID.toString());

      // LatLng crrLocation = await LocationServices.getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(100.w, 14.h),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
              child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('RideRequest/${widget.rideID}')
                      .onValue,
                  builder: (context, event) {
                    if (event.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: black,
                        ),
                      );
                    }
                    if (event.data != null) {
                      RideRequestModel rideRequestData =
                          RideRequestModel.fromMap(
                              jsonDecode(jsonEncode(event.data!.snapshot.value))
                                  as Map<String, dynamic>);
                      if (rideRequestData.rideStatus ==
                          RideRequestServicesDriver.getRideStatus(1)) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Enter OTP to Start Trip',
                              style: AppTextStyles.body16Bold,
                            ),
                            PinCodeTextField(
                              appContext: context,
                              length: 4,
                              obscureText: false,
                              animationType: AnimationType.fade,
                              textStyle: AppTextStyles.body14,
                              pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(5.sp),
                                  fieldHeight: 50,
                                  fieldWidth: 50,
                                  activeFillColor: white,
                                  inactiveColor: greyShade3,
                                  inactiveFillColor: greyShade3,
                                  selectedFillColor: white,
                                  selectedColor: black,
                                  activeColor: black),
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              backgroundColor: transparent,
                              enableActiveFill: true,
                              errorAnimationController: errorController,
                              controller: otpController,
                              onCompleted: (value) async {
                                if (otpController.text.trim() ==
                                    context
                                        .read<RideRequestProviderDriver>()
                                        .rideRequestData!
                                        .otp) {
                                  LatLng pickupLocation = await LocationServices
                                      .getCurrentLocation();
                                  LatLng dropLocation = LatLng(
                                      context
                                          .read<RideRequestProviderDriver>()
                                          .dropLocation!
                                          .latitude!,
                                      context
                                          .read<RideRequestProviderDriver>()
                                          .dropLocation!
                                          .longitude!);
                                  await DirectionServices
                                      .getDirectionDetailsDriver(pickupLocation,
                                          dropLocation, context);
                                  context
                                      .read<RideRequestProviderDriver>()
                                      .decodePolylineAndUpdatePolylineField();
                                  context
                                      .read<RideRequestProviderDriver>()
                                      .updateUpdateMarkerStatus(true);
                                  context
                                      .read<RideRequestProviderDriver>()
                                      .updateMovingFromCurrentLocationToPickupLocationStatus(
                                          false);
                                  context
                                      .read<RideRequestProviderDriver>()
                                      .updateMarker();

                                  RideRequestServicesDriver
                                      .updateRideRequestStatus(
                                    RideRequestServicesDriver.getRideStatus(2),
                                    context
                                        .read<RideRequestProviderDriver>()
                                        .rideRequestData!
                                        .riderProfile
                                        .mobileNumber!,
                                  );
                                }
                              },
                              onChanged: (value) {},
                              beforeTextPaste: (text) {
                                return true;
                              },
                            ),
                          ],
                        );
                      } else {
                        return SwipeButton(
                          thumbPadding: EdgeInsets.all(1.w),
                          thumb: Icon(
                            Icons.chevron_right,
                            color: white,
                          ),
                          inactiveThumbColor: red,
                          activeThumbColor: red,
                          inactiveTrackColor: greyShade3,
                          activeTrackColor: greyShade3,
                          elevationThumb: 2,
                          elevationTrack: 2,
                          onSwipe: () async {
                         await   RideRequestServicesDriver.endRide(
                                widget.rideID, context);
                          },
                          child: Builder(builder: (context) {
                            return Text(
                              'End Trip',
                              style: AppTextStyles.body16Bold,
                            );
                          }),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          color: black,
                        ),
                      );
                    }
                  }),
            )),
        body: Consumer<RideRequestProviderDriver>(
            builder: (context, rideRequestProvider, child) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    rideRequestProvider.initialCameraPosition,
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                polylines: rideRequestProvider.polylineSet,
                markers: rideRequestProvider.driverMarker,
                onMapCreated: (GoogleMapController controller) async {
                  rootBundle
                      .loadString('assets/json/customizedMap.json')
                      .then((String mapStyle) {
                    controller.setMapStyle(mapStyle);
                  });
                  mapControllerDriver.complete(controller);
                  mapController = controller;

                  LatLng pickupLocation = LatLng(
                    rideRequestProvider.rideAcceptLocation!.latitude,
                    rideRequestProvider.rideAcceptLocation!.longitude,
                  );
                  CameraPosition cameraPosition = CameraPosition(
                    target: pickupLocation,
                    zoom: 14,
                  );
                  mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition));
                },
              ),
              Positioned(
                top: 4.h,
                left: 5.w,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 5.h,
                    width: 5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: white,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: black,
                      size: 4.h,
                    ),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
