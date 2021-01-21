import 'dart:convert';

import 'package:doctory/contract/home_page_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/dashboard.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctory/utils/connection_check.dart';

class HomePagePresenter implements Presenter {

  View _view;
  Dashboard _dashboard;

  HomePagePresenter(this._view);

  @override
  Future<void> getDashboardData(BuildContext context, String token) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressIndicator();

        var client = http.Client();

        client.get(

          Uri.encodeFull(APIRoute.DASHBOARD_URL),
          headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "HomePage Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              _dashboard = Dashboard.fromJson(jsonData);

              _view.setDashboardData(_dashboard, false);
            }
            else {

              _failedToGetData(false, "HomePage", "Falied to get dashboard data");
            }
          }
          else {

            _failedToGetData(false, "HomePage", "Falied to get dashboard data");
          }

        }).timeout(Duration(seconds: 15), onTimeout: () {

          client.close();

          _view.showFailedToLoadDataView(false);
          _view.onConnectionTimeOut();
        });
      }
      else {

        _view.showFailedToLoadDataView(false);
        _view.onNoConnection();
      }
    });
  }

  @override
  Future<void> getFilteredDashboardData(BuildContext context, List<String> chamberList, String selectedChamber,
      int selectedTimeIndex, List<Chamber> allChamber, String fromDate, String toDate, String token) async {

    checkInternetConnection().then((isConnected) {

      if(isConnected) {

        _view.showProgressIndicator();

        String url = APIRoute.DASHBOARD_URL;
        Map<String, String> map = Map();

        int index = chamberList.indexOf(selectedChamber);

        if(index != 0) {

          allChamber.forEach((chamber) {

            if(chamber.name == selectedChamber) {

              map["chamber_id"] = chamber.id.toString();
            }
          });
        }

        if((fromDate.isNotEmpty && fromDate != "- - - -") && (toDate.isNotEmpty && toDate != "- - - -")) {

          map["start_date"] = fromDate.split("-").reversed.join("-");
          map["end_date"] = toDate.split("-").reversed.join("-");
        }

        Uri uri = Uri.parse(url);
        Uri finalUri = uri.replace(queryParameters: map);

        var client = http.Client();

        client.get(

          finalUri, headers: {"Authorization": "Bearer $token", "Accept" : "application/json"},

        ).then((response) {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "HomePage Filtered Response", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

              _dashboard = Dashboard.fromJson(jsonData);

              _view.setDashboardData(_dashboard, true);
            }
            else {

              _failedToGetData(true, "HomePage Filtered", "Falied to get filtered data");
            }
          }
          else {

            _failedToGetData(true, "HomePage Filtered", "Falied to get filtered data");
          }

        }).timeout(Duration(seconds: 15), onTimeout: () {

          client.close();

          _view.showFailedToLoadDataView(true);
          _view.onConnectionTimeOut();
        });
      }
      else {

        _view.showFailedToLoadDataView(true);
        _view.onNoConnection();
      }
    });
  }


  void _failedToGetData(bool isFilteredData, String tag, String message) {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: tag, message: message);
    _view.showFailedToLoadDataView(isFilteredData);
  }
}