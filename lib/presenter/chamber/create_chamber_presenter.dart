import 'dart:convert';

import 'package:doctory/contract/create_chamber_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctory/utils/connection_check.dart';

class CreateChamberPresenter implements Presenter {

  View _view;
  List<Chamber> _chamberList;

  CreateChamberPresenter(View view, List<Chamber> chamberList) {
    this._view = view;
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

        _checkIfChamberExists(context, token, inputData);
      }
    }
  }


  _checkIfChamberExists(BuildContext context, String token, Chamber inputData) {

    bool _duplicate = false;

    for(int i=0; i<_chamberList.length; i++) {

      if(inputData.name == _chamberList[i].name && inputData.address == _chamberList[i].address) {

        _duplicate = true;
        break;
      }
    }

    if(_duplicate) {

      _view.onError(AppLocalization.of(context).getTranslatedValue("chamber_already_exists"));
    }
    else {

      _createChamber(context, token, inputData);
    }
  }


  Future<void> _createChamber(BuildContext context, String token, Chamber inputData) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        var client = http.Client();

        client.post(

          Uri.encodeFull(APIRoute.CREATE_CHAMBER_URL),
          body: inputData.toJson(),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Create Chamber Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              Chamber newChamber = Chamber.fromJson(jsonData['chamber']);

              CustomLogger.info(trace: CustomTrace(StackTrace.current), tag: "Chamber Created", message: "Chamber name: " +newChamber.name);

              _chamberList.add(newChamber);
              _view.onEntrySuccess(context);
            }
            else {

              _failedToCreateChamber(context);
            }
          }
          else {

            _failedToCreateChamber(context);
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


  void _failedToCreateChamber(BuildContext context) {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Create Chamber", message: "Falied to create chamber");
    _view.onEntryFailure(context);
  }
}