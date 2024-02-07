import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:uber/common/controller/services/profileDataCRUDServices.dart';
import 'package:uber/common/model/profileDataModel.dart';
import 'package:uber/constant/constants.dart';

class ProfileDataProvider extends ChangeNotifier {
  ProfileDataModel? profileData;

  getProfileData() async {
    profileData =
        await ProfileDataCRUDServices.getProfileDataFromRealTimeDatabase(
            auth.currentUser!.phoneNumber!);
    log(profileData!.toMap().toString());
    notifyListeners();
  }
}
