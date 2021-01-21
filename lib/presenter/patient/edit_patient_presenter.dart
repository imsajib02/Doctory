import 'dart:convert';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/utils/connection_check.dart';
import 'package:doctory/model/patient.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctory/contract/edit_patient_contract.dart';

class EditPatientPresenter implements Presenter {

  View _view;
  Patient _patientToBeEdited;
  List<Patient> _patientList;

  EditPatientPresenter(View view, Patient patientToBeEdited, List<Patient> patientList) {
    this._view = view;
    this._patientToBeEdited = patientToBeEdited;
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

              _checkIfSameDataIsGiven(context, token, inputData);
            }
          }
        }
      }
    }
  }


  void _checkIfSameDataIsGiven(BuildContext context, String token, Patient inputData) {

    if(inputData.name == _patientToBeEdited.name && inputData.age == _patientToBeEdited.age &&
        inputData.gender.toLowerCase() == _patientToBeEdited.gender.toLowerCase() &&
        inputData.mobile == _patientToBeEdited.mobile && inputData.address == _patientToBeEdited.address) {

      _view.onError(AppLocalization.of(context).getTranslatedValue("provide_new_information_message"));
    }
    else {

      _checkWithOtherPatients(context, token, inputData);
    }
  }


  _checkWithOtherPatients(BuildContext context, String token, Patient inputData) {

    bool _duplicate = false;

    for(int i=0; i<_patientList.length; i++) {

      if(_patientList[i].id != _patientToBeEdited.id) {

        if(inputData.name == _patientList[i].name && inputData.age == _patientList[i].age &&
            inputData.gender == _patientList[i].gender && inputData.mobile == _patientList[i].mobile &&
            inputData.address == _patientList[i].address) {

          _duplicate = true;
          break;
        }
      }
    }

    if(_duplicate) {

      _view.onError(AppLocalization.of(context).getTranslatedValue("patient_exists_with_same_information"));
    }
    else {

      _updateChamber(context, token, inputData);
    }
  }


  Future<void> _updateChamber(BuildContext context, String token, Patient inputData) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        var client = http.Client();

        client.post(

          Uri.encodeFull(APIRoute.UPDATE_PATIENT_URL  + _patientToBeEdited.id.toString()),
          body: inputData.toJson(),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Update Patient Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              Patient updatedPatient = Patient.fromJson(jsonData['patient']);

              CustomLogger.info(trace: CustomTrace(StackTrace.current), tag: "Patient Updated", message: "Updated patient id: " +updatedPatient.id.toString());

              _patientToBeEdited.name = updatedPatient.name;
              _patientToBeEdited.mobile = updatedPatient.mobile;
              _patientToBeEdited.age = updatedPatient.age;
              _patientToBeEdited.gender = updatedPatient.gender;
              _patientToBeEdited.address = updatedPatient.address;
              _patientToBeEdited.history = updatedPatient.history;

              _view.onUpdateSuccess(context);
            }
            else {

              _failedToUpdatePatient(context);
            }
          }
          else {

            _failedToUpdatePatient(context);
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


  void _failedToUpdatePatient(BuildContext context) {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Update Patient", message: "Falied to update patient");
    _view.onUpdateFailure(context);
  }
}