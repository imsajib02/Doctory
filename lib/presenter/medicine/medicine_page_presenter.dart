import 'dart:convert';

import 'package:doctory/contract/medicine_page_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/medicine.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MedicinePresenter implements Presenter {

  View _view;
  Medicines _medicines;

  MedicinePresenter(this._view);

  @override
  Future<void> getMedicines(BuildContext context, String token) async {

    _view.showProgressIndicator();

    var response = await http.get(

      Uri.encodeFull(APIRoute.OPEN_MEDICINE_LIST_URL),
      headers: {"Accept" : "application/json"},
    );

    CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "MedicinePage Response", message: response.body);

    var jsonData = json.decode(response.body);

    if(response.statusCode == 200 || response.statusCode == 201) {

      if(jsonData['status'] == AppLocalization.of(context).getTranslatedValue("status_success_response")) {

        _medicines = Medicines.fromJson(jsonData);

        _view.showMedicineList(_medicines, false);
      }
      else {

        _failedToGetMedicines();
      }
    }
    else {

      _failedToGetMedicines();
    }
  }


  @override
  Future<void> loadMedicineList() async {

    _view.showProgressIndicator();

    String jsonStringValues = await rootBundle.loadString("assets/json/medicines.json");

    var jsonData = json.decode(jsonStringValues);

    _medicines = Medicines.fromJson(jsonData);

    _medicines.list.sort((a, b) => a.brandName.compareTo(b.brandName));

    _view.showMedicineList(_medicines, false);
  }


  void _failedToGetMedicines() {

    CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "MedicinePage", message: "Falied to get medicine list");
    _view.showFailedToLoadDataView();
  }

  @override
  void searchMedicine(BuildContext context, String pattern, List<Medicine> medicineList) {

    List<Medicine> result = List();

    if(pattern.isNotEmpty) {

      _view.showProgressIndicator();

      medicineList.forEach((medicine) {

        if(medicine.brandName.toLowerCase().startsWith(pattern.toLowerCase())) {

          result.add(medicine);
        }
      });

      _view.showSearchResult(result);
    }
  }

  @override
  void onTextChanged(String value, bool isSearched) {

    if(isSearched && value.length == 0) {

      _view.showAllMedicine();
    }
  }
}