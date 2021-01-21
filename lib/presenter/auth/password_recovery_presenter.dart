import 'dart:convert';

import 'package:doctory/contract/password_recovery_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/phone_verification_route_parameter.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/resources/strings.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/api_routes.dart';
import '../utils/connection_check.dart';

class PasswordRecoveryPresenter extends Presenter {

  View _view;
  FirebaseAuth _firebaseAuth;
  User _user;

  PasswordRecoveryPresenter(View view) {

    this._view = view;
    _firebaseAuth = FirebaseAuth.instance;
  }

  @override
  void validateInput(BuildContext context, User recoveryData) {

    if(recoveryData.email.isEmpty) {

      _view.onEmpty(AppLocalization.of(context).getTranslatedValue("email_field_empty"));
    }
    else {

      if(!recoveryData.email.contains("@") && !recoveryData.email.contains(".")) {

        _view.onInvalidInput(AppLocalization.of(context).getTranslatedValue("invalid_email_address"));
      }
      else {

        _getUser(context, recoveryData);
      }
    }
  }


  Future<void> _getUser(BuildContext context, User recoveryData) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        var client = http.Client();

        client.post(

            Uri.encodeFull(APIRoute.EMAIL_VERIFY_URL),
            body: recoveryData.toEmailVerify(),
            headers: {"Accept" : "application/json"}

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Password Recovery Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("user_found_response")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Password Recovery", message: "Email match found");

              _view.hideProgressDialog();

              _user = User.fromLogin(jsonData);

              if(_user.mobile.isEmpty) {

                _view.onError(AppLocalization.of(context).getTranslatedValue("no_number_found"));
              }
              else {

                recoveryData.mobile = _user.mobile;
                _sendOTP(context, recoveryData);
              }
            }
            else if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("invalid_email_response")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Password Recovery", message: "Email does not match");

              _view.hideProgressDialog();
              _view.onError(AppLocalization.of(context).getTranslatedValue("no_user_found_with_this_email"));
            }
            else if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("email_must_be_valid")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Password Recovery", message: "Invalid email");

              _view.hideProgressDialog();
              _view.onError(AppLocalization.of(context).getTranslatedValue("email_invalid_message"));
            }
          }
          else {

            CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Password Recovery", message: "Email verification failed");

            _view.hideProgressDialog();
            _view.onError(AppLocalization.of(context).getTranslatedValue("failed_to_verify_email_message"));
          }

        }).timeout(Duration(seconds: 15), onTimeout: () {

          client.close();

          _view.onConnectionTimeOut();
        });
      }
      else {

        _view.onNoConnection();
      }
    });
  }


  void _sendOTP(BuildContext context, User recoveryData) {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        //We don't want to change the value of mobile in recoveryData
        //Because the mobile number we got from response will be used to reset password
        String phoneNumber = recoveryData.mobile;

        if(!phoneNumber.startsWith("+88")) {

          phoneNumber = "+88" + phoneNumber;
        }

        _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(seconds: 0),
          verificationCompleted: (authCredential) {},
          verificationFailed: (authException) {

            CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Password Recovery", message: authException.message);

            _view.hideProgressDialog();
            _view.onError(AppLocalization.of(context).getTranslatedValue("error_sending_code_message"));
          },
          codeSent: (verificationId, [token]) {

            //do nothing
          },
          codeAutoRetrievalTimeout: (verificationId) {

            PhoneVerificationRouteParameter _routeParameter = PhoneVerificationRouteParameter(true, verificationId, recoveryData);
            _view.goToPhoneVerificationPage(_routeParameter);
          },
        );
      }
      else {

        _view.onNoConnection();
      }
    });
  }
}