import 'dart:io';

import 'package:doctory/model/appointment.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/expense.dart';
import 'package:doctory/model/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class View {

  void onEmpty(String message);
  void onError(String message);
  void showProgressIndicator();
  void hideProgressDialog();
  void showProgressDialog(String message);
  void onUpdateSuccess(BuildContext context, User userInfo);
  void onUpdateFailure(BuildContext context);
  void failedToGetProfileData(BuildContext context);
  void setProfileInfoFromLoginData();
  void setProfileInfoFromProfileData(User userProfile);
  void goToDashBoard(User user);
  void setImageLoadingView();
  void setImage(File file);
  void setImageFromGallery(File file);
  void onNoConnection();
  void onConnectionTimeOut();
}

abstract class Presenter {

  void validateInput(BuildContext context, String token, User inputData);
  void isFirstOpen(BuildContext context, String token);
  void getImage(BuildContext context, String imageUrl);
  void pickImage(BuildContext context, bool isLoading);
  void getProfileInfo(BuildContext context, String token);
  void onBackPressed();
}