import 'dart:convert';

import 'package:doctory/contract/chamber_page_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctory/utils/connection_check.dart';

class ChamberPresenter implements Presenter {

  View _view;
  Chambers _chambers;

  ChamberPresenter(this._view);


  @override
  Future<void> getChambers(BuildContext context, String token) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressIndicator();

        var client = http.Client();

        client.get(

          Uri.encodeFull(APIRoute.CHAMBER_LIST_URL),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "ChamberPage Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              _chambers = Chambers.fromJson(jsonData);

              _chambers.list.sort((a, b) => a.name.compareTo(b.name));

              _view.showChamberList(_chambers);
            }
            else {

              _failedToGetChambers();
            }
          }
          else {

            _failedToGetChambers();
          }

        }).timeout(Duration(seconds: 15), onTimeout: () {

          client.close();

          _view.showFailedToLoadDataView();
          _view.onConnectionTimeOut();
        });
      }
      else {

        _view.showFailedToLoadDataView();
        _view.onNoConnection();
      }
    });
  }


  void _failedToGetChambers() {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "ChamberPage", message: "Falied to get dashboard data");
    _view.showFailedToLoadDataView();
  }


  @override
  Future<void> deleteChamber(BuildContext context, int chamberID, String token) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressDialog(AppLocalization.of(context).getTranslatedValue("please_wait_message"));

        var client = http.Client();

        client.post(

          Uri.encodeFull(APIRoute.DELETE_CHAMBER_URL + chamberID.toString()),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Chamber Delete Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              CustomLogger.info(trace: CustomTrace(StackTrace.current), tag: "Chamber Delete Successful",
                  message: "Deleted chamber id: " + chamberID.toString());

              _view.onDeleteSuccess(chamberID);
            }
            else {

              _failedToDeleteChamber();
            }
          }
          else {

            _failedToDeleteChamber();
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


  void _failedToDeleteChamber() {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Chamber Delete", message: "Falied to delete chamber");
    _view.onDeleteFailed();
  }
}