import 'dart:convert';

import 'package:doctory/contract/create_appointment_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/appointment.dart';
import 'package:doctory/utils/connection_check.dart';
import 'package:doctory/model/patient.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateAppointmentPresenter implements Presenter {

  View _view;
  List<Appointment> _appointmentList;
  List<Patient> _patientList;

  CreateAppointmentPresenter(View view, List<Appointment> appointmentList, List<Patient> patientList) {
    this._view = view;
    this._appointmentList = appointmentList;
    this._patientList = patientList;
  }

  @override
  void validateInput(BuildContext context, String token, Appointment inputData) {

    if(inputData.chamberID == null) {

      _view.onEmpty(AppLocalization.of(context).getTranslatedValue("choose_chamber_hint"));
    }
    else {

      if(inputData.patientName.isEmpty) {

        _view.onEmpty(AppLocalization.of(context).getTranslatedValue("select_patient_or_enter_patient_name"));
      }
      else {

        if(inputData.patientMobile.isEmpty) {

          _view.onEmpty(AppLocalization.of(context).getTranslatedValue("select_patient_or_enter_patient_phone"));
        }
        else {

          if(inputData.date.isEmpty) {

            _view.onEmpty(AppLocalization.of(context).getTranslatedValue("select_date_text"));
          }
          else {

            if(inputData.time.isEmpty) {

              _view.onEmpty(AppLocalization.of(context).getTranslatedValue("select_time_text"));
            }
            else {

              _checkIfAppointmentExists(context, token, inputData);
            }
          }
        }
      }
    }
  }


  _checkIfAppointmentExists(BuildContext context, String token, Appointment inputData) {

    bool _duplicate = false;

    for(int i=0; i<_appointmentList.length; i++) {

      if(inputData.chamberID == _appointmentList[i].chamberID && inputData.patientName == _appointmentList[i].patientName &&
          inputData.patientMobile == _appointmentList[i].patientMobile && inputData.date == _appointmentList[i].date &&
          inputData.time == _appointmentList[i].time) {

        _duplicate = true;
        break;
      }
    }

    if(_duplicate) {

      _view.onError(AppLocalization.of(context).getTranslatedValue("appointment_already_exists"));
    }
    else {

      _createAppointment(context, token, inputData);
    }
  }


  Future<void> _createAppointment(BuildContext context, String token, Appointment inputData) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        if(inputData.patientID != null) {

          for(int i=0; i<_patientList.length; i++) {

            if(inputData.patientID == _patientList[i].id) {

              if(inputData.patientName != _patientList[i].name || inputData.patientMobile != _patientList[i].mobile) {

                inputData.patientID = null;
                break;
              }
            }
          }
        }

        var client = http.Client();

        client.post(

          Uri.encodeFull(APIRoute.CREATE_APPOINTMENT_URL),
          body: inputData.toJson(),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Create Appointment Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              Appointment newAppointment = Appointment.fromCreate(jsonData['appointment']);

              CustomLogger.info(trace: CustomTrace(StackTrace.current), tag: "Appointment Created", message: "Patient name: " +newAppointment.patientName);

              _appointmentList.add(newAppointment);
              _view.onEntrySuccess(context);
            }
            else {

              _failedToCreateAppointment(context);
            }
          }
          else {

            _failedToCreateAppointment(context);
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


  void _failedToCreateAppointment(BuildContext context) {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Create Appointment", message: "Falied to create appointment");
    _view.onEntryFailure(context);
  }
}