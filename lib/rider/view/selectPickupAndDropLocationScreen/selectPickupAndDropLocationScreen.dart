// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:uber/common/controller/provider/locattionProvider.dart';
import 'package:uber/common/controller/services/directionServices.dart';
import 'package:uber/common/controller/services/locationServices.dart';
import 'package:uber/common/model/pickupNDropLocationModel.dart';
import 'package:uber/common/model/rideRequestModel.dart';
import 'package:uber/common/model/searchedAddressModel.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/constant/utils/textStyles.dart';
import 'package:uber/rider/controller/provider/tripProvider/rideRequestProvider.dart';
import 'package:uber/rider/view/bookARideScreen/bookARideScreen.dart';

class PickupAndDropLocationScreen extends StatefulWidget {
  const PickupAndDropLocationScreen({super.key});

  @override
  State<PickupAndDropLocationScreen> createState() =>
      _PickupAndDropLocationScreenState();
}

class _PickupAndDropLocationScreenState
    extends State<PickupAndDropLocationScreen> {
  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController dropLocationController = TextEditingController();
  FocusNode dropLocationFocus = FocusNode();
  FocusNode pickupLocationFocus = FocusNode();
  String locationType = 'DROP';

  getCurrentAddress() async {
    LatLng crrLocation = await LocationServices.getCurrentLocation();
    PickupNDropLocationModel currentLocationAddress =
        await LocationServices.getAddressFromLatLng(
            position: crrLocation, context: context);
    pickupLocationController.text = currentLocationAddress.name!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentAddress();
      context.read<RideRequestProvider>().createIcons(context);
      FocusScope.of(context).requestFocus(dropLocationFocus);
    });
  }

  navigateToBookRideScreen() async {
    if (context.read<LocationProvider>().pickupLocation != null &&
        context.read<LocationProvider>().dropLocation != null) {
      PickupNDropLocationModel pickup =
          context.read<LocationProvider>().pickupLocation!;
      PickupNDropLocationModel drop =
          context.read<LocationProvider>().dropLocation!;
      context.read<RideRequestProvider>().updateRidePickupAndDropLocation(
            pickup,
            drop,
          );
      PickupNDropLocationModel pickupModel =
          context.read<LocationProvider>().pickupLocation!;
      PickupNDropLocationModel dropModel =
          context.read<LocationProvider>().dropLocation!;
      LatLng pickupLocation =
          LatLng(pickupModel.latitude!, pickupModel.longitude!);
      LatLng dropLocation = LatLng(dropModel.latitude!, dropModel.longitude!);
      await DirectionServices.getDirectionDetailsRider(
          pickupLocation, dropLocation, context);
      context.read<RideRequestProvider>().makeFareZero();
      context.read<RideRequestProvider>().createIcons(context);
      context.read<RideRequestProvider>().updateMarker();
      context.read<RideRequestProvider>().getFare();
      context
          .read<RideRequestProvider>()
          .decodePolylineAndUpdatePolylineField();
      Navigator.push(
          context,
          PageTransition(
              child: const BookARideScreen(),
              type: PageTransitionType.rightToLeft));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(
                100.w,
                22.h,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 4.h,
                        color: black,
                      ),
                    ),
                    Expanded(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 2.h,
                                color: black,
                              ),
                              Expanded(
                                child: Container(
                                  width: 1.w,
                                  color: black,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 0.5.h),
                                ),
                              ),
                              Icon(
                                Icons.square,
                                size: 2.h,
                                color: black,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextFormField(
                              controller: pickupLocationController,
                              focusNode: pickupLocationFocus,
                              cursorColor: black,
                              style: AppTextStyles.textFieldTextStyle,
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                setState(() {
                                  locationType = 'PICKUP';
                                });
                                LocationServices.getSearchedAddress(
                                  placeName: value,
                                  context: context,
                                );
                              },
                              decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: () {
                                    context
                                        .read<LocationProvider>()
                                        .nullifyPickupLocation();
                                    FocusScope.of(context)
                                        .requestFocus(pickupLocationFocus);
                                    pickupLocationController.clear();
                                  },
                                  child: Icon(
                                    CupertinoIcons.xmark,
                                    color: black38,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 2.w,
                                ),
                                hintText: 'Pickup Address',
                                hintStyle: AppTextStyles.textFieldHintTextStyle,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: dropLocationController,
                              focusNode: dropLocationFocus,
                              cursorColor: black,
                              style: AppTextStyles.textFieldTextStyle,
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                setState(() {
                                  locationType = 'DROP';
                                });
                                LocationServices.getSearchedAddress(
                                  placeName: value,
                                  context: context,
                                );
                              },
                              decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: () {
                                    context
                                        .read<LocationProvider>()
                                        .nullifyDropLocation();
                                    FocusScope.of(context)
                                        .requestFocus(dropLocationFocus);
                                    dropLocationController.clear();
                                  },
                                  child: Icon(
                                    CupertinoIcons.xmark,
                                    color: black38,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 2.w,
                                ),
                                hintText: 'Drop Address',
                                hintStyle: AppTextStyles.textFieldHintTextStyle,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  borderSide: BorderSide(
                                    color: grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                      ],
                    ))
                  ],
                ),
              ),
            ),
            body: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
              if (locationProvider.searchedAddress.isEmpty) {
                return Center(
                  child: Text(
                    'Search Address',
                    style: AppTextStyles.small12,
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: locationProvider.searchedAddress.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      SearchedAddressModel currentAddress =
                          locationProvider.searchedAddress[index];
                      return ListTile(
                        onTap: () async {
                          log(currentAddress.toMap().toString());
                          if (locationType == 'DROP') {
                            dropLocationController.text =
                                currentAddress.mainName;
                          } else {
                            pickupLocationController.text =
                                currentAddress.mainName;
                          }
                          await LocationServices.getLatLngFromPlaceID(
                              currentAddress, context, locationType);
                          navigateToBookRideScreen();
                        },
                        leading: CircleAvatar(
                          backgroundColor: greyShade3,
                          radius: 3.h,
                          child: Icon(
                            Icons.location_on,
                            color: black,
                          ),
                        ),
                        title: Text(
                          currentAddress.mainName,
                          style: AppTextStyles.small12Bold,
                        ),
                        subtitle: Text(
                          currentAddress.mainName,
                          style: AppTextStyles.small10.copyWith(color: grey),
                        ),
                      );
                    });
              }
            })));
  }
}
