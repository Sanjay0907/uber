// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber/common/controller/services/toastService.dart';
import 'package:uber/constant/constants.dart';
import 'package:uuid/uuid.dart';

class ImageServices {
  static getImageFromGallery({required BuildContext context}) async {
    File selectedImage;
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    XFile? filePick = pickedFile;

    if (filePick != null) {
      selectedImage = File(filePick.path);
      log('The Image URL is \n$selectedImage');
      return File(selectedImage.path);
    } else {
      ToastService.sendScaffoldAlert(
        msg: 'No Image Selected',
        toastStatus: 'ERROR',
        context: context,
      );
      return;
    }
  }

  static uploadImageToFirebaseStorage({
    required File image,
    required BuildContext context,
  }) async {
    String userID = auth.currentUser!.phoneNumber!;
    Uuid uuid = const Uuid();

    String imageName = '$userID${uuid.v1().toString()}';
    Reference ref = storage.ref().child('Profile_Images').child(imageName);
    await ref.putFile(File(image.path));
    String imageURL = await ref.getDownloadURL();
    log('Uploaded Image to Firebase');
    return imageURL;
  }
}
