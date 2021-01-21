import 'dart:convert';

import 'package:doctory/contract/create_patient_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/utils/connection_check.dart';
import 'package:doctory/model/patient.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreatePatientPresenter implements Presenter {

  View _view;
  List<Patient> _patientList;

  CreatePatientPresenter(View view, List<Patient> patientList) {
    this._view = view;
    this._patientList = patientList;
  }

  @override
  void validateInput(BuildContext context, String token, Patient inputData) {

    if(inputData.name.isEmpty) {

      _view.onEmpty(AppLocalization.of(context).getTranslatedValue("enter_patient_name"));
    }
    else {

      if(inputData.age.isEmpty) {

        _view.onEmpty(AppLocalization.of(context).getTranslatedValue("enter_patient_age"));
      }
      else {

        if(inputData.gender.isEmpty) {

          _view.onEmpty(AppLocalization.of(context).getTranslatedValue("enter_patient_gender"));
        }
        else {

          if(inputData.mobile.isEmpty) {

            _view.onEmpty(AppLocalization.of(context).getTranslatedValue("enter_patient_mobile"));
          }
          else {

            if(inputData.address.isEmpty) {

              _view.onEmpty(AppLocalization.of(context).getTranslatedValue("enter_patient_address"));
            }
            else {

              _checkIfPatientExists(context, token, inputData);
            }
          }
        }
      }
    }
  }


  _checkIfPatientExists(BuildContext context, String token, Patient inputData) {

    bool _duplicate = false;

    for(int i=0; i<_patientList.length; i++) {

      if(inputData.name == _patientList[i].name && inputData.age == _patientList[i].age &&
          inputData.gender.toLowerCase() == _patientList[i].gender.toLowerCase() &&
          inputData.mobile == _patientList[i].mobile && inputData.address == _patientList[i].address) {

        _duplicate = true;
        break;
      }
    }

    if(_duplicate) {

      _view.onError(AppLocalization.of(context).getTranslatedValue("patient_already_exists"));
    }
    else {

      _createPatient(context, token, inputData);
    }
  }


  Future<void> _createPatient(BuildContext context, String token, Patient inputData) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        var client = http.Client();

        client.post(

          Uri.encodeFull(APIRoute.CREATE_PATIENT_URL),
          body: inputData.toJson(),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Create Patient Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              Patient newPatient = Patient.fromJson(jsonData['patient']);

              CustomLogger.info(trace: CustomTrace(StackTrace.current), tag: "Patient Created", message: "Patient name: " +newPatient.name);

              _patientList.add(newPatient);
              _view.onEntrySuccess(context);
            }
            else {

              _failedToCreatePatient(context);
            }
          }
          else {

            _failedToCreatePatient(context);
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


  void _failedToCreatePatient(BuildContext context) {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Create Patient", message: "Falied to create patient");
    _view.onEntryFailure(context);
  }
}