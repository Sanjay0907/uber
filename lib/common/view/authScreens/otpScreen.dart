import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:uber/common/controller/provider/authProvider.dart';
import 'package:uber/common/controller/services/mobileAuthServices.dart';
import 'package:uber/common/widgets/elevatedButtonCommon.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/constant/utils/textStyles.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  int num = 60;
  TextEditingController otpController = TextEditingController();
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();

  decreaseNum() {
    if (num > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          num = num - 1;
        });
        decreaseNum();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      decreaseNum();
    });
  }

  @override
  void dispose() {
    super.dispose();
    otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButtonCommon(
              onPressed: () {},
              backgroundColor: white,
              borderRadius: 50.sp,
              height: 6.h,
              width: 6.h,
              child: Icon(
                Icons.arrow_back,
                color: black,
              ),
            ),
            ElevatedButtonCommon(
                onPressed: () {},
                backgroundColor: white,
                borderRadius: 50.sp,
                height: 6.h,
                width: 6.h,
                child: Row(
                  children: [
                    Text(
                      'Continue',
                      style: AppTextStyles.small12,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: black,
                    )
                  ],
                ))
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        children: [
          Text(
            'Welcome',
            style: AppTextStyles.body18,
          ),
          SizedBox(height: 2.h),
          Text(
            'Enter the 6-digit code sent to you at ${context.read<MobileAuthProvider>().mobileNumber}',
            style: AppTextStyles.small10,
          ),
          SizedBox(
            height: 4.h,
          ),
          PinCodeTextField(
            appContext: context,
            length: 6,
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
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: transparent,
            enableActiveFill: true,
            errorAnimationController: errorController,
            controller: otpController,
            onCompleted: (value) {
              MobileAuthServices.verifyOTP(
                  context: context, otp: otpController.text.trim());
            },
            onChanged: (value) {},
            beforeTextPaste: (text) {
              return true;
            },
          ),
          SizedBox(
            height: 3.h,
          ),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      50.sp,
                    ),
                    color: greyShade3,
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  child: Text(
                    num > 0
                        ? 'I didn\'t receive a code (00:$num)'
                        : 'I didn\'t receive a code',
                    style: AppTextStyles.small10
                        .copyWith(color: num > 1 ? black38 : black),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
