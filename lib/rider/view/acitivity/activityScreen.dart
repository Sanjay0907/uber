import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:uber/common/model/rideRequestModel.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/constant/utils/textStyles.dart';

class ActivityScreenRider extends StatefulWidget {
  const ActivityScreenRider({super.key});

  @override
  State<ActivityScreenRider> createState() => _ActivityScreenRiderState();
}

class _ActivityScreenRiderState extends State<ActivityScreenRider> {
  getCarImage(String carType) {
    switch (carType) {
      case 'Uber Go':
        return 'assets/images/vehicle/uberGo.png';
      case 'Uber Go Sedan':
        return 'assets/images/vehicle/uberGoSedan.png';
      case 'Uber Premier':
        return 'assets/images/vehicle/uberPremier.png';
      case 'Uber XL':
        return 'assets/images/vehicle/uberXL.png';
      default:
        return 'assets/images/vehicle/uberXL.png';
    }
  }

  DatabaseReference tripHistoryRef = FirebaseDatabase.instance
      .ref()
      .child('RideHistoryRider/${auth.currentUser!.phoneNumber}');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Uber',
            style: AppTextStyles.heading20Bold,
          ),
        ),
        body: StreamBuilder(
            stream: tripHistoryRef.onValue,
            builder: (context, event) {
              if (event.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: black,
                  ),
                );
              }

              if (event.data != null) {
                return FirebaseAnimatedList(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                    ),
                    query: tripHistoryRef,
                    itemBuilder: (context, snapshot, animation, index) {
                      RideRequestModel currentRideData =
                          RideRequestModel.fromMap(
                              jsonDecode(jsonEncode(snapshot.value))
                                  as Map<String, dynamic>);
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 1.7.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: index == 9 ? transparent : greyShade3,
                            ),
                          ),
                        ),
                        height: 11.4.h,
                        width: 94.w,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0.5.h, horizontal: 1.w),
                              height: 8.h,
                              width: 8.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  8.sp,
                                ),
                                color: white,
                                image: DecorationImage(
                                  image: AssetImage(
                                    getCarImage(
                                      currentRideData.carType,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    currentRideData.pickupLocation.name!,
                                    style: AppTextStyles.small12Bold,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    currentRideData.dropLocation.name!,
                                    style: AppTextStyles.small12Bold,
                                    maxLines: 2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM, kk:mm a').format(
                                            currentRideData.rideEndTime!),
                                        style: AppTextStyles.small10
                                            .copyWith(color: black87),
                                      ),
                                      Text(
                                        '₹ ${currentRideData.fare}',
                                        style: AppTextStyles.small10Bold,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    });
              }
              return Center(
                child: Text(
                  'No Trips Made',
                  style: AppTextStyles.body14Bold.copyWith(color: grey),
                ),
              );
            }));
  }
}
