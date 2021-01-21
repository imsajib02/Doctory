import 'package:doctory/contract/home_page_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/dashboard.dart';
import 'package:doctory/model/profile_route_parameter.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/presenter/home_page_presenter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/utils/bounce_animation.dart';
import 'package:doctory/utils/local_memory.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:intl/intl.dart';
import '../utils/my_widgets.dart';

class HomePage extends StatefulWidget {

  final User _currentUser;

  HomePage(this._currentUser);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements View {

  List<String> _chamberFilterList;
  List<String> _timeFilterList;
  String _selectedChamber;
  String _selectedTime;
  int _selectedTimeIndex;

  Presenter _presenter;
  LocalMemory _localMemory;

  final _bounceStateKey1 = new GlobalKey<BounceState>();
  final _bounceStateKey2 = new GlobalKey<BounceState>();

  BuildContext _scaffoldContext;

  Widget _body;
  bool _initialDataLoaded;
  List<Chamber> _allChamber;

  TextEditingController _dateController1 = TextEditingController();
  TextEditingController _dateController2 = TextEditingController();

  MyWidget _myWidget;

  @override
  void initState() {

    _localMemory = LocalMemory();
    _localMemory.saveUser(widget._currentUser);

    _myWidget = MyWidget(context);

    _presenter = HomePagePresenter(this);

    _body = Container();
    _initialDataLoaded = false;

    _dateController1.text = "- - - -";
    _dateController2.text = "- - - -";

    super.initState();
  }


  @override
  void didChangeDependencies() {

    try {

      _chamberFilterList = [AppLocalization.of(context).getTranslatedValue("all_chamber_filter")];

      _timeFilterList = [AppLocalization.of(context).getTranslatedValue("today_filter"),
        AppLocalization.of(context).getTranslatedValue("from_yesterday_filter"),
        AppLocalization.of(context).getTranslatedValue("from_last_week_filter"),
        AppLocalization.of(context).getTranslatedValue("from_last_month_filter"),
        AppLocalization.of(context).getTranslatedValue("from_last_year_filter")];

      _selectedChamber = _chamberFilterList[0];
      _selectedTime = _timeFilterList[0];
      _selectedTimeIndex = 0;

      _presenter.getDashboardData(context, widget._currentUser.accessToken);
    }
    catch(error) {

      print(error);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {

        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            _scaffoldContext = context;

            return SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.only(left: 5.12 * SizeConfig.widthSizeMultiplier, right: 5.12 * SizeConfig.widthSizeMultiplier,
                    bottom: 2.5 * SizeConfig.heightSizeMultiplier),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: EdgeInsets.only(right: 5 * SizeConfig.widthSizeMultiplier),
                              child: Container(
                                padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
                                height: 5 * SizeConfig.heightSizeMultiplier,
                                width: 38.46 * SizeConfig.widthSizeMultiplier,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppThemeNotifier().isDarkModeOn ? Colors.white.withOpacity(.5) : Colors.black26,
                                    width: .3846 * SizeConfig.widthSizeMultiplier,
                                  ),
                                ),
                                child: DropdownButton(
                                  value: _selectedChamber,
                                  isExpanded: true,
                                  isDense: true,
                                  underline: SizedBox(),
                                  items: _chamberFilterList.map((value) {

                                    return DropdownMenuItem(child: Text(value), value: value);
                                  }).toList(),
                                  onChanged: _initialDataLoaded ? (value) {

                                    setState(() {

                                      if(value != _selectedChamber) {

                                        _selectedChamber = value;

                                        _presenter.getFilteredDashboardData(context, _chamberFilterList, _selectedChamber,
                                            _selectedTimeIndex, _allChamber, _dateController1.text, _dateController2.text, widget._currentUser.accessToken);
                                      }
                                    });
                                  } : null,
                                ),
                              ),
                            ),
                          ),
                          
                          Expanded(
                            flex: 1,
                            child: Visibility(
                              visible: _initialDataLoaded,
                              child: GestureDetector(
                                onTap: () {

                                  _showDateSelectionDialog(context);
                                },
                                child: CircleAvatar(
                                  radius: 5.89 * SizeConfig.imageSizeMultiplier,
                                  child: Icon(Icons.date_range,
                                    size: 6.41 * SizeConfig.imageSizeMultiplier,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Visibility(
                            visible: false,
                            child: Container(
                              padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
                              height: 5 * SizeConfig.heightSizeMultiplier,
                              width: 38.46 * SizeConfig.widthSizeMultiplier,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: AppThemeNotifier().isDarkModeOn ? Colors.white.withOpacity(.5) : Colors.black26,
                                  width: .3846 * SizeConfig.widthSizeMultiplier,
                                ),
                              ),
                              child: DropdownButton(
                                value: _selectedTime,
                                isExpanded: true,
                                isDense: true,
                                underline: SizedBox(),
                                items: _timeFilterList.map((value) {

                                  return DropdownMenuItem(child: Text(value), value: value);
                                }).toList(),
                                onChanged: _initialDataLoaded ? (value) {

                                  setState(() {

                                    if(value != _selectedTime) {

                                      _selectedTime = value;
                                      _selectedTimeIndex = _timeFilterList.indexOf(_selectedTime);

                                      _presenter.getFilteredDashboardData(context, _chamberFilterList, _selectedChamber,
                                          _selectedTimeIndex, _allChamber, _dateController1.text, _dateController2.text, widget._currentUser.accessToken);
                                    }
                                  });
                                } : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 6,
                      child: _body,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  void _showDateSelectionDialog(BuildContext scaffoldContext) async {

    return showDialog(
        context: context,
        builder: (BuildContext context) {

          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,

            child: Container(
              height: 25 * SizeConfig.heightSizeMultiplier,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Expanded(
                                flex: 1,
                                child: Text(AppLocalization.of(context).getTranslatedValue("from"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.subtitle.copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),

                              Expanded(
                                flex: 1,
                                child: Text(AppLocalization.of(context).getTranslatedValue("to"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.subtitle.copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _showDatePicker(context, _dateController1);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextField(
                                      enabled: false,
                                      controller: _dateController1,
                                      style: Theme.of(context).textTheme.subhead,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(width: 1, style: BorderStyle.solid,),
                                        ),
                                        filled: true,
                                        contentPadding: EdgeInsets.all(1.5 * SizeConfig.heightSizeMultiplier),
                                        fillColor: AppThemeNotifier().isDarkModeOn == false ? Colors.black12.withOpacity(.035) : Colors.white.withOpacity(.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 5.12 * SizeConfig.widthSizeMultiplier,),

                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _showDatePicker(context, _dateController2);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextField(
                                      enabled: false,
                                      controller: _dateController2,
                                      style: Theme.of(context).textTheme.subhead,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(width: 1, style: BorderStyle.none,),
                                        ),
                                        filled: true,
                                        contentPadding: EdgeInsets.all(1.5 * SizeConfig.heightSizeMultiplier),
                                        fillColor: AppThemeNotifier().isDarkModeOn == false ? Colors.black12.withOpacity(.035) : Colors.white.withOpacity(.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                color: Colors.red,
                                child: Text(AppLocalization.of(context).getTranslatedValue("cancel_text"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();

                                _presenter.getFilteredDashboardData(scaffoldContext, _chamberFilterList, _selectedChamber,
                                    _selectedTimeIndex, _allChamber, _dateController1.text, _dateController2.text, widget._currentUser.accessToken);
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                color: Colors.blue,
                                child: Text(AppLocalization.of(context).getTranslatedValue("ok_message"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }


  _showDatePicker(BuildContext scaffoldContext, TextEditingController controller) {

    var pickerFormat = DateFormat('yyyy-MM-dd');

    DateTime currentDateTime = DateTime.now();
    String currentDate = pickerFormat.format(currentDateTime);

    String minDate = "2001-01-01";

    var dateSplitList = currentDate.split("-");
    dateSplitList[0] = (int.tryParse(dateSplitList[0]) + 10).toString();

    String maxDate = "${dateSplitList[0]}-12-12";

    String dateFormat = 'MMM-d-yyyy';

    try {

      showDialog(
          context: scaffoldContext,
          builder: (BuildContext context) {

            return Dialog(
              elevation: 0.0,
              backgroundColor: Colors.transparent,

              child: Container(
                height: 50 * SizeConfig.heightSizeMultiplier,
                child: DatePickerWidget(
                  onMonthChangeStartWithFirstDate: false,
                  minDateTime: DateTime.tryParse(minDate),
                  maxDateTime: DateTime.tryParse(maxDate),
                  initialDateTime: DateTime.tryParse(currentDate),
                  dateFormat: dateFormat,
                  locale: DateTimePickerLocale.en_us,
                  pickerTheme: DateTimePickerTheme(
                    backgroundColor: Theme.of(context).primaryColor,
                    itemTextStyle: TextStyle(color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black),
                    cancel: Text(AppLocalization.of(context).getTranslatedValue("cancel_text"),
                      style: TextStyle(
                        fontSize: 1.75 * SizeConfig.textSizeMultiplier,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                    confirm: Text(AppLocalization.of(context).getTranslatedValue("done_text"),
                      style: TextStyle(
                        fontSize: 1.75 * SizeConfig.textSizeMultiplier,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    pickerHeight: 40 * SizeConfig.heightSizeMultiplier,
                    itemHeight: 3.75 * SizeConfig.heightSizeMultiplier,
                  ),
                  onConfirm: (selectedDateTime, selectedIndexList) {

                    setState(() {
                      controller.text = DateFormat('dd-MM-yyyy').format(selectedDateTime);
                    });
                  },
                ),
              ),
            );
          }
      );
    }
    catch(error) {

      print(error);
    }
  }


  @override
  void showProgressIndicator() {

    setState(() {
      _body = Container(child: Center(child: CircularProgressIndicator()));
    });
  }


  @override
  void setDashboardData(Dashboard dashboard, bool isFilteredData) {

    if(!isFilteredData) {

      _allChamber = dashboard.allChamber;

      if(dashboard.allChamber.length > 0) {

        for(int i=0; i<dashboard.allChamber.length; i++) {

          _chamberFilterList.add(dashboard.allChamber[i].name);
        }
      }
    }

    setState(() {

      _initialDataLoaded = true;

      _body = ScrollConfiguration(
        behavior: new ScrollBehavior()..buildViewportChrome(context, null, AxisDirection.down),
        child: CustomScrollView(
          slivers: <Widget>[

            SliverStaggeredGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 3.07 *SizeConfig.widthSizeMultiplier,
              mainAxisSpacing: 1.5 * SizeConfig.heightSizeMultiplier,
              children: <Widget>[

                SizedBox(),

                GestureDetector(
                  onTap: () {

                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(RouteManager.TOTAL_INCOME_ROUTE, arguments: widget._currentUser);
                  },
                  child: _amountItem(AppLocalization.of(context).getTranslatedValue("income_text"), Colors.green,
                      AppLocalization.of(context).getTranslatedValue("bdt_sign"), dashboard.income),
                ),

                GestureDetector(
                  onTap: () {

                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(RouteManager.TOTAL_EXPENSE_ROUTE, arguments: widget._currentUser);
                  },
                  child: _amountItem(AppLocalization.of(context).getTranslatedValue("expense_text"), Colors.red,
                      AppLocalization.of(context).getTranslatedValue("bdt_sign"), dashboard.expense),
                ),

                _amountItem(AppLocalization.of(context).getTranslatedValue("net_income_text"), Colors.blue,
                    AppLocalization.of(context).getTranslatedValue("bdt_sign"), dashboard.netIncome),

                _settingItem(AppLocalization.of(context).getTranslatedValue("settings_text"), Colors.purple),

                GestureDetector(
                  onTap: () {

                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(RouteManager.TOTAL_PATIENT_ROUTE, arguments: widget._currentUser);
                  },
                  child: _amountItem(AppLocalization.of(context).getTranslatedValue("total_patient_text"),
                      Colors.deepOrangeAccent, "", dashboard.patients.toString()),
                ),

                GestureDetector(
                  onTap: () {

                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(RouteManager.MEDICINE_PAGE_ROUTE, arguments: widget._currentUser);
                  },
                  child: _reportItem(AppLocalization.of(context).getTranslatedValue("medicine_text"), Colors.indigo),
                ),
              ],
              staggeredTiles: [

                StaggeredTile.extent(2, 10),
                StaggeredTile.extent(1, 120),
                StaggeredTile.extent(1, 120),
                StaggeredTile.extent(1, 120),
                StaggeredTile.extent(1, 252),
                StaggeredTile.extent(1, 120),
                StaggeredTile.extent(2, 120),
              ],
            ),
          ],
        ),
      );
    });
  }



  Material _amountItem(String title, Color color, String prefix, String amount) {

    return Material(
      elevation: 10,
      color: Theme.of(context).primaryColor,
      shadowColor: AppThemeNotifier().isDarkModeOn ? Colors.black12 : Colors.black45,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                CircleAvatar(
                  radius: 1.25 * SizeConfig.heightSizeMultiplier,
                  backgroundColor: color,
                  child: Text(title[0],
                    style: TextStyle(fontSize: 1.5 * SizeConfig.textSizeMultiplier, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(width: 2.56 * SizeConfig.widthSizeMultiplier,),

                Text(title, style: Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w400),),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(top: 1.5 * SizeConfig.heightSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
              child: Text(prefix + amount, overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.subtitle,),
            ),

            Text(AppLocalization.of(context).getTranslatedValue("click_to_see_details"),
              style: Theme.of(context).textTheme.body1,
            ),
          ],
        ),
      ),
    );
  }



  Material _settingItem(String title, Color color) {

    return Material(
      elevation: 10,
      color: Theme.of(context).primaryColor,
      shadowColor: AppThemeNotifier().isDarkModeOn ? Colors.black12 : Colors.black45,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                CircleAvatar(
                  radius: 1.25 * SizeConfig.heightSizeMultiplier,
                  backgroundColor: color,
                  child: Text(title[0],
                    style: TextStyle(fontSize: 1.5 * SizeConfig.textSizeMultiplier, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(width: 2.56 * SizeConfig.widthSizeMultiplier,),

                Text(title, style: Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w400),),
              ],
            ),

            SizedBox(height: 5 * SizeConfig.heightSizeMultiplier,),

            Align(
              alignment: Alignment.center,
              child: BounceAnimation(
                key: _bounceStateKey1,
                childWidget: RaisedButton(
                  padding: EdgeInsets.all(0),
                  elevation: 0,
                  onPressed: () {

                    _bounceStateKey1.currentState.animationController.forward();

                    _goToProfilePage();
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  textColor: Colors.white,
                  child: Container(
                    width: 35 * SizeConfig.widthSizeMultiplier,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(
                      AppLocalization.of(context).getTranslatedValue("general_settings_text"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 2 * SizeConfig.textSizeMultiplier,
                      ),
                    ),
                  ),
                ),
              ),
            ),


            Align(
              alignment: Alignment.center,
              child: BounceAnimation(
                key: _bounceStateKey2,
                childWidget: RaisedButton(
                  padding: EdgeInsets.all(0),
                  elevation: 0,
                  onPressed: () {

                    _bounceStateKey2.currentState.animationController.forward();

                    //TODO: prescription settings
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  textColor: Colors.white,
                  child: Container(
                    width: 35 * SizeConfig.widthSizeMultiplier,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(
                      AppLocalization.of(context).getTranslatedValue("prescription_settings_text"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 2 * SizeConfig.textSizeMultiplier,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 5 * SizeConfig.heightSizeMultiplier, bottom: 2 * SizeConfig.heightSizeMultiplier),
                child: Text(AppLocalization.of(context).getTranslatedValue("click_to_edit_settings"),
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Material _reportItem(String title, Color color) {

    return Material(
      elevation: 10,
      color: Theme.of(context).primaryColor,
      shadowColor: AppThemeNotifier().isDarkModeOn ? Colors.black12 : Colors.black45,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                CircleAvatar(
                  radius: 1.25 * SizeConfig.heightSizeMultiplier,
                  backgroundColor: color,
                  child: Text(title[0],
                    style: TextStyle(fontSize: 1.5 * SizeConfig.textSizeMultiplier, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(width: 2.56 * SizeConfig.widthSizeMultiplier,),

                Text(title, style: Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w400),),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(top: 2 * SizeConfig.heightSizeMultiplier, bottom: 1 * SizeConfig.heightSizeMultiplier),
              child: Text(AppLocalization.of(context).getTranslatedValue("medicine_list_text"),
                style: Theme.of(context).textTheme.subtitle,
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 1 * SizeConfig.heightSizeMultiplier),
              child: Text(AppLocalization.of(context).getTranslatedValue("click_to_see_details"),
                style: Theme.of(context).textTheme.body1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void showFailedToLoadDataView(bool isFilterData) {

    setState(() {

      _body = Column(
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

                    isFilterData ? _presenter.getFilteredDashboardData(context, _chamberFilterList, _selectedChamber,
                        _selectedTimeIndex, _allChamber, _dateController1.text, _dateController2.text, widget._currentUser.accessToken) :
                    _presenter.getDashboardData(context, widget._currentUser.accessToken);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  void onNoConnection() {

    _myWidget.showSnackBar(_scaffoldContext, AppLocalization.of(context).getTranslatedValue("no_internet_available"), Colors.red, 3);
  }

  @override
  void onConnectionTimeOut() {

    _myWidget.showSnackBar(_scaffoldContext, AppLocalization.of(context).getTranslatedValue("connection_time_out"), Colors.red, 3);
  }

  void _goToProfilePage() {

    try {
      _bounceStateKey1.currentState.animationController.dispose();
      _bounceStateKey2.currentState.animationController.dispose();
    }
    catch(error) {}

    ProfileRouteParameter _parameter = ProfileRouteParameter(currentUser: widget._currentUser, isFirstOpen: false, pageNumber: 2);

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.PROFILE_PAGE_ROUTE, arguments: _parameter);
  }
}