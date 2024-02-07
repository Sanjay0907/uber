import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uber/common/controller/services/toastService.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/common/view/signInLogic/signInLogin.dart';
import 'package:uber/constant/constants.dart';

class ProfileDataCRUDServices {
  static getProfileDataFromRealTimeDatabase(String userID) async {
    try {
      final snapshot = await realTimeDatabaseRef.child('User/$userID').get();
      if (snapshot.exists) {
        ProfileDataModel userModel = ProfileDataModel.fromMap(
            jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>);
        return userModel;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<bool> checkForRegisteredUser(BuildContext context) async {
    try {
      final snapshot = await realTimeDatabaseRef
          .child('User/${auth.currentUser!.phoneNumber}')
          .get();
      if (snapshot.exists) {
        log('User Data found');
        return true;
      }
      log('User Data not found');
      return false;
    } catch (e) {
      throw Exception(e);
    }
  }

  static registerUserToDatabase(
      {required ProfileDataModel profileData, required BuildContext context}) {
    realTimeDatabaseRef
        .child('User/${auth.currentUser!.phoneNumber}')
        .set(profileData.toMap())
        .then((value) {
      ToastService.sendScaffoldAlert(
        msg: 'User Registered Successful',
        toastStatus: 'SUCCESS',
        context: context,
      );
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: const SignInLogic(),
            type: PageTransitionType.rightToLeft,
          ),
          (route) => false);
    }).onError((error, stackTrace) {
      ToastService.sendScaffoldAlert(
        msg: 'Opps! Error getting Registered',
        toastStatus: 'SUCCESS',
        context: context,
      );
    });
  }

  static Future<bool> userIsDriver(BuildContext context) async {
    try {
      DataSnapshot snapshot = await realTimeDatabaseRef
          .child('User/${auth.currentUser!.phoneNumber}')
          .get();

      if (snapshot.exists) {
        ProfileDataModel userModel = ProfileDataModel.fromMap(
            jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>);

        log('User Type is ${userModel.userType}');
        if (userModel.userType != 'CUSTOMER') {
          return true;
        }
      }
    } catch (e) {
      throw Exception(e);
    }
    return false;
  }
}
