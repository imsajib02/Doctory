import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/dashboard.dart';
import 'package:doctory/model/user.dart';
import 'package:flutter/material.dart';

abstract class View {

  void showProgressIndicator();
  void setDashboardData(Dashboard dashboard, bool isFilteredData);
  void showFailedToLoadDataView(bool isFilterData);
  void onNoConnection();
  void onConnectionTimeOut();
}

abstract class Presenter {

  void getDashboardData(BuildContext context, String token);
  void getFilteredDashboardData(BuildContext context, List<String> chamberList, String selectedChamber,
      int selectedTimeIndex, List<Chamber> allChamber, String fromDate, String toDate, String token);
}