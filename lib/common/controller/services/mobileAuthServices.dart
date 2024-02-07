// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:uber/common/controller/provider/authProvider.dart';
import 'package:uber/common/controller/provider/profileDataProvider.dart';
import 'package:uber/common/controller/services/profileDataCRUDServices.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/common/view/authScreens/loginScreen.dart';
import 'package:uber/common/view/authScreens/otpScreen.dart';
import 'package:uber/common/view/registrationScreen/registrationScreen.dart';
import 'package:uber/common/view/signInLogic/signInLogin.dart';
import 'package:uber/constant/constants.dart';
import 'package:uber/driver/view/bottomNavBarDriver/bottomNaVBarDriver.dart';
import 'package:uber/rider/view/bottomNavBar/bottomNaVBarRider.dart';

class MobileAuthServices {
  static receiveOTP(
      {required BuildContext context, required String mobileNumber}) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          log(credential.toString());
        },
        verificationFailed: (FirebaseAuthException exception) {
          log(exception.toString());
        },
        codeSent: (String verificationCode, int? resendToken) {
          context
              .read<MobileAuthProvider>()
              .updateVerificationCode(verificationCode);
          Navigator.push(
            context,
            PageTransition(
              child: const OTPScreen(),
              type: PageTransitionType.rightToLeft,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {},
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  static verifyOTP({required BuildContext context, required String otp}) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: context.read<MobileAuthProvider>().verificationCode!,
          smsCode: otp);
      await auth.signInWithCredential(credential);
      Navigator.push(
        context,
        PageTransition(
          child: const SignInLogic(),
          type: PageTransitionType.rightToLeft,
        ),
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  static bool checkAuthentication() {
    User? user = auth.currentUser;
    if (user != null) {
      return true;
    }
    return false;
  }

  static checkAuthenticationAndNavigate({required BuildContext context}) {
    bool userIsAuthenticated = checkAuthentication();
    userIsAuthenticated
        ? checkUser(context)
        : Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: const LoginScreen(),
              type: PageTransitionType.rightToLeft,
            ),
            (route) => false,
          );
  }

  static checkUser(BuildContext context) async {
    bool userIsRegistered =
        await ProfileDataCRUDServices.checkForRegisteredUser(context);

    if (userIsRegistered == true) {
      ProfileDataModel profileData =
          await ProfileDataCRUDServices.getProfileDataFromRealTimeDatabase(
              auth.currentUser!.phoneNumber!);
      // PushNotificationServices.initializeFirebaseMessagingForUsers(
      //     profileData, context);
      bool userIsDriver = await ProfileDataCRUDServices.userIsDriver(context);
      if (userIsDriver == true) {
        // Navigate to Driver Application
        context.read<ProfileDataProvider>().getProfileData();
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
                child: const BottomNavBarDriver(),
                type: PageTransitionType.rightToLeft),
            (route) => false);
      } else {
        // Navigate to Rider Application
        context.read<ProfileDataProvider>().getProfileData();
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
                child: const BottomNavBarRider(),
                type: PageTransitionType.rightToLeft),
            (route) => false);
      }
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
              child: const RegistrationScreen(),
              type: PageTransitionType.rightToLeft),
          (route) => false);
    }
  }

  static signOut(BuildContext context) {
    auth.signOut();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const SignInLogic();
        },
      ),
      (_) => false,
    );
  }
}
