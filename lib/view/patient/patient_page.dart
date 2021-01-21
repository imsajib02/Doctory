import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/dashboard_route_parameter.dart';
import 'package:doctory/model/edit_chamber_route_parameter.dart';
import 'package:doctory/model/edit_patient_route_parameter.dart';
import 'package:doctory/model/patient.dart';
import 'package:doctory/model/patient_details_route_parameter.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/presenter/patient_page_presenter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:doctory/utils/my_widgets.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:doctory/contract/patient_page_contract.dart';
import 'package:doctory/model/create_patient_route_parameter.dart';

class PatientPage extends StatefulWidget {

  final User _currentUser;

  PatientPage(this._currentUser);

  @override
  PatientPageState createState() => PatientPageState();
}

class PatientPageState extends State<PatientPage> with WidgetsBindingObserver implements View {

  Presenter _presenter;
  Widget _body;
  MyWidget _myWidget;

  List<Patient> _patientList;
  List<Patient> _resultList;

  bool _visibility;
  bool _isSearched;
  FocusNode _focusNode;

  BuildContext _scaffoldContext;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);

    _presenter = PatientPresenter(this);
    _body = Container();
    _myWidget = MyWidget(context);

    _visibility = false;

    _patientList = List();
    _resultList = List();

    _focusNode = FocusNode();
    _isSearched = false;

    super.initState();
  }

  @override
  void didChangeDependencies() {

    try {

      _presenter.getPatientList(context, widget._currentUser.accessToken);
    }
    catch(error) {}

    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state == AppLifecycleState.paused) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _backPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 2,
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("patient_appbar_title"),
            style: Theme.of(context).textTheme.headline.copyWith(color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            _scaffoldContext = context;

            return SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.only(top: 2.5 * SizeConfig.heightSizeMultiplier),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Visibility(
                      visible: _visibility,
                      child: Container(
                        width: double.infinity,
                        height: 5.5 * SizeConfig.heightSizeMultiplier,
                        margin: EdgeInsets.only(left: 5 * SizeConfig.widthSizeMultiplier, right: 5 * SizeConfig.widthSizeMultiplier),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.deepOrangeAccent,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25)),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  keyboardType: TextInputType.text,
                                  focusNode: _focusNode,
                                  onChanged: (value) {

                                    _presenter.onTextChanged(context, value);
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalization.of(context).getTranslatedValue("search_by_patient_name"),
                                    hintStyle: Theme.of(context).textTheme.caption,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {

                                  _focusNode.unfocus();

                                  String pattern = _searchController.text;
                                  _presenter.searchPatient(context, pattern, _patientList);
                                },
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.deepOrangeAccent,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25)),
                                  ),
                                  child: Text(AppLocalization.of(context).getTranslatedValue("search_btn"),
                                    style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                    _body,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  void showProgressIndicator() {

    setState(() {

      _visibility = false;

      _body = Flexible(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    });
  }

  @override
  void showProgressDialog(String message) {

    _myWidget.showProgressDialog(message);
  }

  @override
  void hideProgressDialog() {

    _myWidget.hideProgressDialog();
  }

  @override
  void storeOriginalData(Patients patients) {

    _patientList = patients.list;

    showPatientList(patients);
  }

  @override
  void showPatientList(Patients patients) {

    _focusNode.unfocus();

    setState(() {

      _visibility = true;

      _body = Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(left: 5.12 * SizeConfig.widthSizeMultiplier, right: 5.12 * SizeConfig.widthSizeMultiplier),
              child: GestureDetector(
                onTap: () {

                  CreatePatientRouteParameter _parameter = CreatePatientRouteParameter(currentUser: widget._currentUser, patientList: _patientList);

                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(RouteManager.CREATE_PATIENT_ROUTE, arguments: _parameter);
                },
                child: CircleAvatar(
                  radius: 5.89 * SizeConfig.imageSizeMultiplier,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add,
                    size: 6.41 * SizeConfig.imageSizeMultiplier,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

            Flexible(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: EdgeInsets.only(bottom: 2.5 * SizeConfig.heightSizeMultiplier),
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 1.25 * SizeConfig.heightSizeMultiplier,
                        left: 2.56 * SizeConfig.widthSizeMultiplier, right: 2.56 * SizeConfig.widthSizeMultiplier),
                    itemCount: patients.list.length,
                    itemBuilder: (BuildContext context, int index) {

                      return GestureDetector(
                        onTap: () {

//                          PatientDetailsRouteParameter parameter = PatientDetailsRouteParameter(currentUser: widget._currentUser, patient: patients.list[index]);
//
//                          Navigator.of(context).pop();
//                          Navigator.of(context).pushNamed(RouteManager.PATIENT_DETAILS_ROUTE, arguments: parameter);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(1 * SizeConfig.heightSizeMultiplier),
                          child: Container(
                            child: Material(
                              elevation: 10,
                              color: Theme.of(context).primaryColor,
                              shadowColor: AppThemeNotifier().isDarkModeOn ? Colors.black12 : Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: <Widget>[

                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.56 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                              child: Text(patients.list[index].name,
                                                style: Theme.of(context).textTheme.title.copyWith(color: Colors.blue),
                                              ),
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.56 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                              child: Row(
                                                children: <Widget>[

                                                  Text(AppLocalization.of(context).getTranslatedValue("age_text") + patients.list[index].age,
                                                    style: Theme.of(context).textTheme.body1.copyWith(fontSize: 1.44 * SizeConfig.textSizeMultiplier),
                                                  ),

                                                  SizedBox(width: 5.128 * SizeConfig.widthSizeMultiplier,),

                                                  Text(AppLocalization.of(context).getTranslatedValue("gender_text") + patients.list[index].gender,
                                                    style: Theme.of(context).textTheme.body1.copyWith(fontSize: 1.44 * SizeConfig.textSizeMultiplier),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.56 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                              child: Row(
                                                children: <Widget>[

                                                  Icon(Icons.phone, size: 4.2 * SizeConfig.imageSizeMultiplier, color: Colors.black38,),

                                                  SizedBox(width: 1.3 * SizeConfig.widthSizeMultiplier,),

                                                  Text(patients.list[index].mobile,
                                                    style: Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.05 * SizeConfig.widthSizeMultiplier),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[

                                                  Flexible(
                                                    flex: 1,
                                                    child: Icon(Icons.location_on, size: 2.25 * SizeConfig.heightSizeMultiplier,
                                                      color: AppThemeNotifier().isDarkModeOn ? Colors.white.withOpacity(.5) :
                                                      Colors.black38,
                                                    ),
                                                  ),

                                                  SizedBox(width: 1.28 * SizeConfig.widthSizeMultiplier,),

                                                  Flexible(
                                                    flex: 10,
                                                    child: Text(patients.list[index].address,
                                                      style: Theme.of(context).textTheme.body1.copyWith(fontSize: 1.44 * SizeConfig.textSizeMultiplier),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(height: 1.25 * SizeConfig.heightSizeMultiplier,),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: <Widget>[

                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {

                                                  EditPatientRouteParameter _parameter = EditPatientRouteParameter(currentUser: widget._currentUser, patient: patients.list[index], patientList: _patientList);

                                                  Navigator.pop(context);
                                                  Navigator.of(context).pushNamed(RouteManager.EDIT_PATIENT_ROUTE, arguments: _parameter);
                                                },
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: CircleAvatar(
                                                    radius: 2.5 * SizeConfig.heightSizeMultiplier,
                                                    backgroundColor: Colors.lightGreen.shade300,
                                                    child: Icon(Icons.edit),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 5.128 * SizeConfig.widthSizeMultiplier,),

                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {

                                                  _showDeleteAlert(context, patients.list[index]);
                                                },
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: CircleAvatar(
                                                    radius: 2.5 * SizeConfig.heightSizeMultiplier,
                                                    backgroundColor: Colors.redAccent.shade200,
                                                    child: Icon(Icons.delete),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      );
    });
  }


  void _showDeleteAlert(BuildContext scaffoldContext, Patient patient) {

    showDialog(
        context: scaffoldContext,
        barrierDismissible: false,
        builder: (BuildContext context) {

          return WillPopScope(
            onWillPop: () {
              return Future(() => false);
            },
            child: AlertDialog(
              elevation: 10,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text(AppLocalization.of(context).getTranslatedValue("alert_message"), textAlign: TextAlign.center,),
              titlePadding: EdgeInsets.only(top: 2.5 * SizeConfig.heightSizeMultiplier,
                  left: 2.56 * SizeConfig.widthSizeMultiplier, right: 2.56 * SizeConfig.widthSizeMultiplier),
              titleTextStyle: TextStyle(
                color: Colors.redAccent,
                fontSize: 2.5 * SizeConfig.textSizeMultiplier,
                fontWeight: FontWeight.bold,
              ),
              content: Text("\"" + patient.name + "\"" + AppLocalization.of(context).getTranslatedValue("delete_patient_text"),
                textAlign: TextAlign.center,
              ),
              contentTextStyle: TextStyle(
                color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                fontSize: 2.125 * SizeConfig.textSizeMultiplier,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: EdgeInsets.only(top: 2.5 * SizeConfig.heightSizeMultiplier, bottom: 2.5 * SizeConfig.heightSizeMultiplier,
                  left: 5 * SizeConfig.widthSizeMultiplier, right: 5 * SizeConfig.widthSizeMultiplier),
              actions: <Widget>[

                FlatButton(
                  onPressed: () {

                    Navigator.of(context).pop();
                    _presenter.deletePatient(scaffoldContext, patient.id, widget._currentUser.accessToken);
                  },
                  color: Colors.lightBlueAccent,
                  textColor: Colors.white,
                  child: Text(AppLocalization.of(context).getTranslatedValue("yes_message"), style: TextStyle(

                    fontSize: 2.25 * SizeConfig.textSizeMultiplier,
                  ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(right: 2.56 * SizeConfig.widthSizeMultiplier),
                  child: FlatButton(
                    onPressed: () {

                      Navigator.of(context).pop();
                    },
                    color: Colors.redAccent,
                    textColor: Colors.white,
                    child: Text(AppLocalization.of(context).getTranslatedValue("no_message"), style: TextStyle(

                      fontSize: 2.25 * SizeConfig.textSizeMultiplier,
                    ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


  @override
  void showFailedToLoadDataView() {

    setState(() {

      _body = Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: 2.5 * SizeConfig.heightSizeMultiplier),
                child: Text(AppLocalization.of(context).getTranslatedValue("could_not_load_data"),
                  style: TextStyle(
                    color: AppThemeNotifier().isDarkModeOn ? Colors.white.withOpacity(.5) : Colors.black54,
                    fontSize: 2.8 * SizeConfig.textSizeMultiplier,
                  ),
                ),
              ),
            ),

            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: 3.75 * SizeConfig.heightSizeMultiplier),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppThemeNotifier().isDarkModeOn ? Colors.white.withOpacity(.5) : Colors.black26),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.all(5),
                    icon: Icon(
                      Icons.refresh,
                      size: 9 * SizeConfig.imageSizeMultiplier,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: () {

                      _presenter.getPatientList(context, widget._currentUser.accessToken);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }


  @override
  void onDeleteFailed(BuildContext context) {

    hideProgressDialog();

    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("failed_to_delete_patient"),
        Colors.red, 3);
  }

  @override
  void onDeleteSuccess(BuildContext context, int patientID) {

    hideProgressDialog();

    for(int i=0; i<_patientList.length; i++) {

      if(_patientList[i].id == patientID) {

        _patientList.removeAt(i);
        break;
      }
    }

    String pattern = _searchController.text;
    _presenter.searchPatient(context, pattern, _patientList);

    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("successfully_deleted_patient"),
        Colors.green, 3);
  }

  @override
  void showSearchedList(List<Patient> resultList, bool isSearched) {

    _isSearched = isSearched;
    _resultList = resultList;

    Patients patients = Patients(list: resultList);

    showPatientList(patients);
  }

  @override
  void onSearchCleared() {

    _isSearched = false;
    _resultList.clear();

    Patients patients = Patients(list: _patientList);

    showPatientList(patients);
  }

  Future<bool> _backPressed() {

    DashboardRouteParameter _parameter = DashboardRouteParameter(pageNumber: 2, currentUser: widget._currentUser);

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.DASHBOARD_ROUTE, arguments: _parameter);

    return Future(() => false);
  }

  @override
  void onNoConnection() {

    hideProgressDialog();

    _myWidget.showSnackBar(_scaffoldContext, AppLocalization.of(context).getTranslatedValue("no_internet_available"), Colors.red, 3);
  }

  @override
  void onConnectionTimeOut() {

    hideProgressDialog();

    _myWidget.showSnackBar(_scaffoldContext, AppLocalization.of(context).getTranslatedValue("connection_time_out"), Colors.red, 3);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}