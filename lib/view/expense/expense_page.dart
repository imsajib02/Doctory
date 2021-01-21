import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/localization/localization_constrants.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/create_expense_route_model.dart';
import 'package:doctory/model/dashboard_route_parameter.dart';
import 'package:doctory/model/edit_expense_route_parameter.dart';
import 'package:doctory/model/expense.dart';
import 'package:doctory/model/expense_category.dart';
import 'package:doctory/model/expense_details_route_parameter.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/presenter/expense_page_presenter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:doctory/utils/local_memory.dart';
import 'package:doctory/utils/my_widgets.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:doctory/contract/expense_page_contract.dart';

class ExpensePage extends StatefulWidget {

  final User _currentUser;

  ExpensePage(this._currentUser);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> with WidgetsBindingObserver implements View {

  List<String> _chamberFilterList;
  List<String> _timeFilterList;
  List<String> _categoryFilterList;

  String _selectedChamber;
  String _selectedCategory;

  Presenter _presenter;
  MyWidget _myWidget;

  BuildContext _scaffoldContext;
  Widget _body;
  double _total = 0.0;

  List<Expense> _expenseList;
  List<Expense> _resultList;
  List<Chamber> _chamberList;
  List<ExpenseCategory> _categoryList;

  Locale _locale;
  LocalMemory _localMemory;

  static const int _category = 207;

  bool _visibility;
  bool _isSearched;
  FocusNode _focusNode;

  TextEditingController _searchController = TextEditingController();
  TextEditingController _dateController1 = TextEditingController();
  TextEditingController _dateController2 = TextEditingController();

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);

    _presenter = ExpensePresenter(this);
    _myWidget = MyWidget(context);
    _body = Container();

    _localMemory = LocalMemory();

    _localMemory.getLanguageCode().then((locale) {
      _locale = locale;
    });

    _visibility = false;

    _expenseList = List();
    _resultList = List();

    _focusNode = FocusNode();
    _isSearched = false;

    _dateController1.text = "- - - -";
    _dateController2.text = "- - - -";

    super.initState();
  }

  @override
  void didChangeDependencies() {

    try {

      _categoryFilterList = [AppLocalization.of(context).getTranslatedValue("all_category_filter")];

      _chamberFilterList = [AppLocalization.of(context).getTranslatedValue("all_chamber_filter")];

      _timeFilterList = [AppLocalization.of(context).getTranslatedValue("today_filter"),
        AppLocalization.of(context).getTranslatedValue("from_yesterday_filter"),
        AppLocalization.of(context).getTranslatedValue("from_last_week_filter"),
        AppLocalization.of(context).getTranslatedValue("from_last_month_filter"),
        AppLocalization.of(context).getTranslatedValue("from_last_year_filter")];

      _selectedChamber = _chamberFilterList[0];
      _selectedCategory = _categoryFilterList[0];

      _presenter.getExpenses(context, widget._currentUser.accessToken);
    }
    catch(error) {
      print(error);
    }

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
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("expense_appbar_title"),
            style: Theme.of(context).textTheme.headline.copyWith(color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 2,
          automaticallyImplyLeading: true,
          actions: <Widget>[

            PopupMenuButton<int>(

              icon: Icon(Icons.more_vert),
              elevation: 10,
              offset: Offset(0, 100),
              itemBuilder: (BuildContext context) => [

                PopupMenuItem(height: 30, child: Text(AppLocalization.of(context).getTranslatedValue("category_item")),
                  textStyle: Theme.of(context).textTheme.subtitle, value: _category,),
              ],
              onSelected: (value) {

                switch(value) {

                  case _category: {

                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(RouteManager.EXPENSE_CATEGORY_ROUTE, arguments: widget._currentUser);
                  } break;

                  default: break;
                }
              },
            ),
          ],
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
                      child: Column(
                        children: <Widget>[

                          Container(
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

                                        _presenter.onTextChanged(context, value, _selectedChamber, _selectedCategory, _expenseList, _dateController1.text, _dateController2.text);
                                      },
                                      decoration: InputDecoration(
                                        hintText: AppLocalization.of(context).getTranslatedValue("search_by_recipient_name"),
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
                                      _presenter.searchExpense(context, pattern, _selectedChamber, _selectedCategory, _expenseList, _dateController1.text, _dateController2.text);
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

                          SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Container(
                                padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
                                height: 5 * SizeConfig.heightSizeMultiplier,
                                width: 38.46 * SizeConfig.widthSizeMultiplier,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppThemeNotifier().isDarkModeOn ? Colors.white.withOpacity(.5) : Colors.black26,
                                    width: .3846 * SizeConfig.widthSizeMultiplier,),
                                ),
                                child: DropdownButton(
                                  value: _selectedChamber,
                                  isExpanded: true,
                                  isDense: true,
                                  underline: SizedBox(),
                                  items: _chamberFilterList.map((value) {

                                    return DropdownMenuItem(child: Text(value), value: value);
                                  }).toList(),
                                  onChanged: (value) {

                                    setState(() {

                                      if(value != _selectedChamber) {

                                        _selectedChamber = value;
                                        String pattern = _searchController.text;

                                        _presenter.filterDataChamberAndCategoryWise(context, pattern, _selectedChamber, _selectedCategory, _expenseList, _isSearched, _dateController1.text, _dateController2.text);
                                      }
                                    });
                                  },
                                ),
                              ),

                              SizedBox(width: 5.128 * SizeConfig.widthSizeMultiplier,),

                              Container(
                                margin: EdgeInsets.only(right: 8 * SizeConfig.widthSizeMultiplier,),
                                padding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
                                height: 5 * SizeConfig.heightSizeMultiplier,
                                width: 38.46 * SizeConfig.widthSizeMultiplier,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppThemeNotifier().isDarkModeOn ? Colors.white.withOpacity(.5) : Colors.black26,
                                    width: .3846 * SizeConfig.widthSizeMultiplier,),
                                ),
                                child: DropdownButton(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  isDense: true,
                                  underline: SizedBox(),
                                  items: _categoryFilterList.map((value) {

                                    return DropdownMenuItem(child: Text(value), value: value);
                                  }).toList(),
                                  onChanged: (value) {

                                    setState(() {

                                      if(value != _selectedCategory) {

                                        _selectedCategory = value;
                                        String pattern = _searchController.text;

                                        _presenter.filterDataChamberAndCategoryWise(context, pattern, _selectedChamber, _selectedCategory, _expenseList, _isSearched, _dateController1.text, _dateController2.text);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                          Container(
                            padding: EdgeInsets.only(left: 10 * SizeConfig.widthSizeMultiplier, right: 5.5 * SizeConfig.widthSizeMultiplier),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[

                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    child: Text(AppLocalization.of(context).getTranslatedValue("total") + _total.toString(),
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context).textTheme.display1.copyWith(fontWeight: FontWeight.w500, color: Colors.red),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 5.12 * SizeConfig.widthSizeMultiplier,),

                                Expanded(
                                  flex: 1,
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

                                SizedBox(width: 5.12 * SizeConfig.widthSizeMultiplier,),

                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {

                                      CreateExpenseRouteParameter _parameter = CreateExpenseRouteParameter(currentUser: widget._currentUser,
                                          expenseList: _expenseList, chamberList: _chamberList, categoryList: _categoryList);

                                      Navigator.pop(context);
                                      Navigator.of(context).pushNamed(RouteManager.CREATE_EXPENSE_ROUTE, arguments: _parameter);
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.75 * SizeConfig.heightSizeMultiplier,),

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

                                String pattern = _searchController.text;
                                _presenter.filterDataChamberAndCategoryWise(context, pattern, _selectedChamber, _selectedCategory, _expenseList, _isSearched, _dateController1.text, _dateController2.text);
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
  void showProgressDialog(String message) {

    _myWidget.showProgressDialog(message);
  }

  @override
  void hideProgressDialog() {

    _myWidget.hideProgressDialog();
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
  void storeOriginalData(Expenses expenses) {

    _expenseList = expenses.list;
    _chamberList = expenses.chamberList;
    _categoryList = expenses.categoryList;

    expenses.chamberList.forEach((chamber) {

      _chamberFilterList.add(chamber.name);
    });

    expenses.categoryList.forEach((category) {

      _categoryFilterList.add(category.name);
    });

    showExpenseList(expenses);
  }

  @override
  void showExpenseList(Expenses expenses) {

    _focusNode.unfocus();

    setState(() {

      _total = 0.0;

      expenses.list.forEach((expense) {
        _total = _total + double.tryParse(expense.amount);
      });

      _visibility = true;

      _body = Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Flexible(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: EdgeInsets.only(bottom: 2.5 * SizeConfig.heightSizeMultiplier),
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 1.25 * SizeConfig.heightSizeMultiplier, bottom: 2 * SizeConfig.heightSizeMultiplier,
                        left: 2.56 * SizeConfig.widthSizeMultiplier, right: 2.56 * SizeConfig.widthSizeMultiplier),
                    itemCount: expenses.list.length,
                    itemBuilder: (BuildContext context, int index) {

                      return GestureDetector(
                        onTap: () {

                          ExpenseDetailsRouteParameter parameter = ExpenseDetailsRouteParameter(currentUser: widget._currentUser, expense: expenses.list[index]);

                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(RouteManager.EXPENSE_DETAILS_ROUTE, arguments: parameter);
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
                                        flex: 4,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.05 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                              child: Text(expenses.list[index].recipientName,
                                                style: Theme.of(context).textTheme.title.copyWith(color: Colors.blue),
                                              ),
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.05 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                              child: Text(AppLocalization.of(context).getTranslatedValue("chamber_text") + ": " + expenses.list[index].chamber.name,
                                                style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.green),
                                              ),
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.05 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
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
                                                    child: Text(expenses.list[index].chamber.address,
                                                        style: Theme.of(context).textTheme.body1.copyWith(fontSize: 1.44 * SizeConfig.textSizeMultiplier)
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.05 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                              child: Text(AppLocalization.of(context).getTranslatedValue("category_text") +
                                                  expenses.list[index].category.name == null ? "" : expenses.list[index].category.name,
                                                style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.grey[700]),
                                              ),
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(left: 2.05 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                              child: Text(AppLocalization.of(context).getTranslatedValue("date_text") + expenses.list[index].createdAt,
                                                style: Theme.of(context).textTheme.subhead,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[

                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 2.05 * SizeConfig.widthSizeMultiplier,),
                                                child: Center(
                                                  child: Text(AppLocalization.of(context).getTranslatedValue("bdt_sign") + expenses.list[index].amount,
                                                    style: Theme.of(context).textTheme.headline.copyWith(color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 1.25 * SizeConfig.heightSizeMultiplier,),

                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                children: <Widget>[

                                                  Expanded(
                                                    flex: 1,
                                                    child: GestureDetector(
                                                      onTap: () {

                                                        EditExpenseRouteParameter parameter = EditExpenseRouteParameter(currentUser: widget._currentUser,
                                                        expense: expenses.list[index], chamberList: _chamberList, categoryList: _categoryList);

                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).pushNamed(RouteManager.EDIT_EXPENSE_ROUTE, arguments: parameter);
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

                                                        _showDeleteAlert(context, expenses.list[index]);
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


  @override
  void showFailedToLoadDataView() {

    setState(() {

      _body = Flexible(
        child: Column(
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

                      _presenter.getExpenses(context, widget._currentUser.accessToken);
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

  void _showDeleteAlert(BuildContext scaffoldContext, Expense expense) {

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
              content: Text(_locale.languageCode == ENGLISH ? AppLocalization.of(context).getTranslatedValue("delete_expense_text") + "\"" + expense.recipientName + "\"?" :
                    "\"" + expense.recipientName + "\"" + AppLocalization.of(context).getTranslatedValue("delete_appointment_text"),
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
                    _presenter.deleteExpense(scaffoldContext, expense.id, widget._currentUser.accessToken);
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
  void onDeleteFailed(BuildContext context) {

    hideProgressDialog();

    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("failed_to_delete_expense"),
        Colors.red, 3);
  }

  @override
  void onDeleteSuccess(BuildContext context, int expenseID) {

    hideProgressDialog();

    for(int i=0; i<_expenseList.length; i++) {

      if(_expenseList[i].id == expenseID) {

        _expenseList.removeAt(i);
        break;
      }
    }

    String pattern = _searchController.text;
    _presenter.filterDataChamberAndCategoryWise(context, pattern, _selectedChamber, _selectedCategory, _expenseList, _isSearched, _dateController1.text, _dateController2.text);

    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("successfully_deleted_expense"),
        Colors.green, 3);
  }

  @override
  void showSearchedAndFilteredList(List<Expense> resultList, bool isSearched) {

    _isSearched = isSearched;
    _resultList = resultList;

    Expenses expenses = Expenses(list: resultList);

    showExpenseList(expenses);
  }

  @override
  void onSearchCleared(List<Expense> expenseList) {

    _isSearched = false;
    _resultList.clear();

    Expenses expenses = Expenses(list: expenseList);

    showExpenseList(expenses);
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

  Future<bool> _backPressed() {

    DashboardRouteParameter _parameter = DashboardRouteParameter(pageNumber: 2, currentUser: widget._currentUser);

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.DASHBOARD_ROUTE, arguments: _parameter);

    return Future(() => false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}