// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:uber/common/controller/services/directionServices.dart';
import 'package:uber/common/controller/services/locationServices.dart';
import 'package:uber/common/model/rideRequestModel.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/constant/utils/textStyles.dart';
import 'package:uber/driver/controller/provider/rideRequestProvider.dart';
import 'package:uber/driver/controller/services/rideRequestServices/rideRequestServices.dart';

class PushNotificationDialouge {
  static rideRequestDialogue(
      RideRequestModel rideRequestModel, BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          audioPlayer.setAsset('assets/sounds/alert.mp3');
          audioPlayer.play();
          RideRequestServicesDriver.checkRideAvailability(
            context,
            rideRequestModel.riderProfile.mobileNumber!,
          );
          return AlertDialog(
            content: SizedBox(
              height: 50.h,
              width: 90.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (context) {
                    if (rideRequestModel.carType == 'Uber Go') {
                      return Image(
                        image: const AssetImage(
                          'assets/images/vehicle/uberGo.png',
                        ),
                        height: 5.h,
                      );
                    } else if (rideRequestModel.carType == 'Uber Go Sedan') {
                      return Image(
                        image: const AssetImage(
                            'assets/images/vehicle/uberGoSedan.png'),
                        height: 5.h,
                      );
                    } else if (rideRequestModel.carType == 'Uber Premier') {
                      return Image(
                        image: const AssetImage(
                            'assets/images/vehicle/uberPremier.png'),
                        height: 5.h,
                      );
                    } else {
                      return Image(
                        image: const AssetImage(
                            'assets/images/vehicle/uberXL.png'),
                        height: 5.h,
                      );
                    }
                  }),
                  SizedBox(
                    height: 3.w,
                  ),
                  Text(
                    'Ride Request',
                    style: AppTextStyles.body18Bold,
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 4.h,
                        child: const Image(
                          image:
                              AssetImage('assets/images/icons/pickupPng.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: Text(
                          rideRequestModel.pickupLocation.name!,
                          maxLines: 2,
                          style: AppTextStyles.body16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 4.h,
                        child: const Image(
                          image: AssetImage('assets/images/icons/dropPng.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: Text(
                          rideRequestModel.dropLocation.name!,
                          maxLines: 2,
                          style: AppTextStyles.body16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SwipeButton(
                    thumbPadding: EdgeInsets.all(1.w),
                    thumb: Icon(
                      Icons.chevron_right,
                      color: white,
                    ),
                    inactiveThumbColor: success,
                    activeThumbColor: success,
                    inactiveTrackColor: greyShade3,
                    activeTrackColor: greyShade3,
                    elevationThumb: 2,
                    elevationTrack: 2,
                    onSwipe: () async {
                      context
                          .read<RideRequestProviderDriver>()
                          .updateRideRequestData(rideRequestModel);
                      context
                          .read<RideRequestProviderDriver>()
                          .updateTripPickupAndDropLoction(
                              rideRequestModel.pickupLocation,
                              rideRequestModel.dropLocation,);
                      context
                          .read<RideRequestProviderDriver>()
                          .createIcons(context);
                      LatLng crrDriverLocation =
                          await LocationServices.getCurrentLocation();
                      context
                          .read<RideRequestProviderDriver>()
                          .updateRideAcceptLocation(crrDriverLocation);
                      LatLng pickupLocation = LatLng(
                        rideRequestModel.pickupLocation.latitude!,
                        rideRequestModel.pickupLocation.longitude!,
                      );
                      await DirectionServices.getDirectionDetailsDriver(
                          crrDriverLocation, pickupLocation, context);
                      context
                          .read<RideRequestProviderDriver>()
                          .decodePolylineAndUpdatePolylineField();
                      context
                          .read<RideRequestProviderDriver>()
                          .updateUpdateMarkerStatus(true);
                      context
                          .read<RideRequestProviderDriver>()
                          .updateMovingFromCurrentLocationToPickupLocationStatus(
                              true);
                      context.read<RideRequestProviderDriver>().updateMarker();
                      RideRequestServicesDriver.acceptRideRequest(
                          rideRequestModel.riderProfile.mobileNumber!, context);
                      RideRequestServicesDriver.updateRideRequestStatus(
                        RideRequestServicesDriver.getRideStatus(1),
                        rideRequestModel.riderProfile.mobileNumber!,
                      );
                      RideRequestServicesDriver.updateRideRequestID(
                        rideRequestModel.riderProfile.mobileNumber!,
                      );

                      audioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Builder(builder: (context) {
                      return Text(
                        'Accept',
                        style: AppTextStyles.body16Bold,
                      );
                    }),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SwipeButton(
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
                    onSwipe: () {
                      audioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Builder(builder: (context) {
                      return Text(
                        'Deny',
                        style: AppTextStyles.body16Bold,
                      );
                    }),
                  )
                ],
              ),
            ),
          );
        });
  }
}
