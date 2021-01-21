import 'dart:async';
import 'dart:convert';

import 'package:doctory/contract/registration_page_contact.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/phone_verification_route_parameter.dart';
import 'package:doctory/model/registration_route_parameter.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:doctory/utils/regex_pattern.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../utils/api_routes.dart';
import '../utils/connection_check.dart';

class RegistrationPresenter extends Presenter {

  View _view;
  FirebaseAuth _firebaseAuth;

  RegistrationPresenter(View view) {
    this._view = view;
    _firebaseAuth = FirebaseAuth.instance;
  }

  @override
  void isPhoneVerified(RegistrationRouteParameter routeParameter) {

    try {

      if(routeParameter.isPhoneVerified || routeParameter.reEdit) {

        _view.fillInTextFields();
      }
    }
    catch(error) {

      CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Registration Re Edit", message: error);
    }
  }

  @override
  void validateInput(BuildContext context, User registrationData, String previousNumberInput, FirebaseUser firebaseUser) {

    if(registrationData.name.isEmpty) {

      _view.onEmpty(AppLocalization.of(context).getTranslatedValue("name_field_empty"));
    }
    else {

      if(registrationData.name.contains(RegexPattern.digits) ||
          registrationData.name.contains(RegexPattern.specialCharactersWithoutDot)) {

        _view.onInvalidInput(AppLocalization.of(context).getTranslatedValue("invalid_name"));
      }
      else {

        if(registrationData.email.isEmpty) {

          _view.onEmpty(AppLocalization.of(context).getTranslatedValue("email_field_empty"));
        }
        else {

          if(!registrationData.email.contains("@") && !registrationData.email.contains(".")) {

            _view.onInvalidInput(AppLocalization.of(context).getTranslatedValue("invalid_email_address"));
          }
          else {

            if(registrationData.password.isEmpty) {

              _view.onEmpty(AppLocalization.of(context).getTranslatedValue("password_field_empty"));
            }
            else if(registrationData.mobile.isEmpty) {

              _view.onEmpty(AppLocalization.of(context).getTranslatedValue("phone_field_empty"));
            }
            else {

              if(registrationData.mobile.contains(RegexPattern.letters) ||
                  registrationData.mobile.contains(RegexPattern.specialCharactersWithDot) ||
                  registrationData.mobile.startsWith("0") || registrationData.mobile.length == 11) {

                _view.onInvalidInput(AppLocalization.of(context).getTranslatedValue("invalid_phone_number"));
              }
              else {

                if(registrationData.mobile.contains(" ")) {

                  _view.onInvalidInput(AppLocalization.of(context).getTranslatedValue("phone_number_can_not_have_space"));
                }
                else {

                  _checkIfEmailOrPhoneIsRegistered(context, registrationData);
                }
              }
            }
          }
        }
      }
    }
  }

  Future<void> _checkIfEmailOrPhoneIsRegistered(BuildContext context, User registrationData) async {

    checkInternetConnection().then((isConnected) async {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        //add 0 before number to check on server
        registrationData.mobile = "0" + registrationData.mobile;

        var client = http.Client();

        client.post(

            Uri.encodeFull(APIRoute.EMAIL_PHONE_DUPLICATE_CHECK_URL),
            body: registrationData.toDuplicateCheck(),
            headers: {"Accept" : "application/json"}

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Registration Data Duplicate Check", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("phone_email_not_taken")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Registration", message: "Email and phone are available");

              _sendOTP(context, registrationData);
            }
            else if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("phone_email_already_taken")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Registration", message: "Email and phone both are unavailable");

              _view.hideProgressDialog();
              _view.onError(AppLocalization.of(context).getTranslatedValue("phone_email_already_taken_message"));
            }
            else if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("phone_already_taken")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Registration", message: "Phone is unavailable");

              _view.hideProgressDialog();
              _view.onError(AppLocalization.of(context).getTranslatedValue("phone_already_taken_message"));
            }
            else if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("email_already_taken")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Registration", message: "Email is unavailable");

              _view.hideProgressDialog();
              _view.onError(AppLocalization.of(context).getTranslatedValue("email_already_taken_message"));
            }
            else if(jsonData['message'] == AppLocalization.of(context).getTranslatedValue("email_must_be_valid")) {

              CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Registration", message: "Invalid email");

              _view.hideProgressDialog();
              _view.onError(AppLocalization.of(context).getTranslatedValue("email_invalid_message"));
            }
          }
          else {

            CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Registration", message: "Duplicate checking failed");

            _view.hideProgressDialog();
            _view.onError(AppLocalization.of(context).getTranslatedValue("general_error_message"));
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

  void _sendOTP(BuildContext context, User registrationData) {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        Timer(const Duration(milliseconds: 500), () {

          _view.updateProgressDialog(AppLocalization.of(context).getTranslatedValue("sending_code_message"));
        });

        String phoneNumber = "+88" + registrationData.mobile;

        _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(seconds: 0),
          verificationCompleted: (authCredential) {},
          verificationFailed: (authException) {

            CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Registration", message: authException.message);

            _view.hideProgressDialog();
            _view.onError(AppLocalization.of(context).getTranslatedValue("error_sending_code_message"));
          },
          codeSent: (verificationId, [token]) {

            //do nothing
          },
          codeAutoRetrievalTimeout: (verificationId) {

            PhoneVerificationRouteParameter _routeParameter = PhoneVerificationRouteParameter(false, verificationId, registrationData);
            _view.gotToPhoneVerificationPage(_routeParameter);
          },
        );
      }
      else {

        _view.onNoConnection();
      }
    });
  }
}