import 'dart:convert';

import 'package:doctory/contract/edit_chamber_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctory/utils/connection_check.dart';

class EditChamberPresenter implements Presenter {

  View _view;
  Chamber _chamberToBeEdited;
  List<Chamber> _chamberList;

  EditChamberPresenter(View view, Chamber chamberToBeEdited, List<Chamber> chamberList) {
    this._view = view;
    this._chamberToBeEdited = chamberToBeEdited;
    this._chamberList = chamberList;
  }

  @override
  void validateInput(BuildContext context, String token, Chamber inputData) {

    if(inputData.name.isEmpty) {

      _view.onEmpty(AppLocalization.of(context).getTranslatedValue("enter_chamber_name"));
    }
    else {

      if(inputData.address.isEmpty) {

        _view.onEmpty(AppLocalization.of(context).getTranslatedValue("enter_chamber_address"));
      }
      else {

        _checkIfSameDataIsGiven(context, token, inputData);
      }
    }
  }


  void _checkIfSameDataIsGiven(BuildContext context, String token, Chamber inputData) {

    if(inputData.name == _chamberToBeEdited.name && inputData.address == _chamberToBeEdited.address) {

      _view.onError(AppLocalization.of(context).getTranslatedValue("provide_new_information_message"));
    }
    else {

      _checkWithOtherChambers(context, token, inputData);
    }
  }


  _checkWithOtherChambers(BuildContext context, String token, Chamber inputData) {

    bool _duplicate = false;

    for(int i=0; i<_chamberList.length; i++) {

      if(_chamberList[i].id != _chamberToBeEdited.id) {

        if(inputData.name == _chamberList[i].name && inputData.address == _chamberList[i].address) {

          _duplicate = true;
          break;
        }
      }
    }

    if(_duplicate) {

      _view.onError(AppLocalization.of(context).getTranslatedValue("chamber_exists_with_same_information"));
    }
    else {

      _updateChamber(context, token, inputData);
    }
  }


  Future<void> _updateChamber(BuildContext context, String token, Chamber inputData) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        var client = http.Client();

        client.post(

          Uri.encodeFull(APIRoute.UPDATE_CHAMBER_URL  + _chamberToBeEdited.id.toString()),
          body: inputData.toJson(),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Update Chamber Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              Chamber updatedChamber = Chamber.fromJson(jsonData['chamber']);

              CustomLogger.info(trace: CustomTrace(StackTrace.current), tag: "Chamber Updated", message: "Updated chamber id: " +updatedChamber.id.toString());

              _chamberToBeEdited.name = updatedChamber.name;
              _chamberToBeEdited.address = updatedChamber.address;

              _view.onUpdateSuccess(context);
            }
            else {

              _failedToUpdateChamber(context);
            }
          }
          else {

            _failedToUpdateChamber(context);
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


  void _failedToUpdateChamber(BuildContext context) {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Update Chamber", message: "Falied to update chamber");
    _view.onUpdateFailure(context);
  }
}