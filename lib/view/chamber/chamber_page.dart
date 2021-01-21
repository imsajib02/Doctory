import 'package:doctory/contract/chamber_page_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/create_chamber_route_parameter.dart';
import 'package:doctory/model/edit_chamber_route_parameter.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/presenter/chamber_page_presenter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:doctory/utils/my_widgets.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:flutter/material.dart';

class ChamberPage extends StatefulWidget {

  final User _currentUser;

  ChamberPage(this._currentUser);

  @override
  _ChamberPageState createState() => _ChamberPageState();
}

class _ChamberPageState extends State<ChamberPage> implements View {

  Presenter _presenter;
  Widget _body;
  MyWidget _myWidget;

  BuildContext _scaffoldContext;

  List<Chamber> _chamberList;

  @override
  void initState() {

    _presenter = ChamberPresenter(this);
    _body = Container();
    _myWidget = MyWidget(context);
    super.initState();
  }


  @override
  void didChangeDependencies() {

    try {

      _presenter.getChambers(context, widget._currentUser.accessToken);
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
              child: _body,
            );
          },
        ),
      ),
    );
  }


  @override
  void showProgressIndicator() {

    setState(() {
      _body = Container(child: Center(child: CircularProgressIndicator()));
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
  void showChamberList(Chambers chambers) {

    _chamberList = chambers.list;

    setState(() {

      _body = Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(top: 2.5 * SizeConfig.heightSizeMultiplier),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Container(
              padding: EdgeInsets.only(left: 5.12 * SizeConfig.widthSizeMultiplier, right: 5.12 * SizeConfig.widthSizeMultiplier),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {

                  CreateChamberRouteParameter _parameter = CreateChamberRouteParameter(currentUser: widget._currentUser, chamberList: _chamberList);

                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(RouteManager.CREATE_CHAMBER_ROUTE, arguments: _parameter);
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
                    itemCount: chambers.list.length,
                    itemBuilder: (BuildContext context, int index) {

                      return Padding(
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[

                                          Padding(
                                            padding: EdgeInsets.only(left: 2.56 * SizeConfig.widthSizeMultiplier, bottom: 1.25 * SizeConfig.heightSizeMultiplier),
                                            child: Text(chambers.list[index].name,
                                              style: Theme.of(context).textTheme.title.copyWith(color: Colors.green),
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
                                                  child: Text(chambers.list[index].address,
                                                    style: Theme.of(context).textTheme.body1.copyWith(fontSize: 1.44 * SizeConfig.textSizeMultiplier)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 3 * SizeConfig.widthSizeMultiplier,),

                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: <Widget>[

                                          Expanded(
                                            flex: 1,
                                            child: GestureDetector(
                                              onTap: () {

                                                EditChamberRouteParameter _parameter = EditChamberRouteParameter(currentUser: widget._currentUser, chamber: chambers.list[index], chamberList: _chamberList);

                                                Navigator.pop(context);
                                                Navigator.of(context).pushNamed(RouteManager.EDIT_CHAMBER_ROUTE, arguments: _parameter);
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

                                                _showDeleteAlert(context, chambers.list[index]);
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

                    _presenter.getChambers(context, widget._currentUser.accessToken);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }


  void _showDeleteAlert(BuildContext scaffoldContext, Chamber chamber) {

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
              content: Text("\"" + chamber.name + "\"" + AppLocalization.of(context).getTranslatedValue("delete_chamber_text"),
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
                    _presenter.deleteChamber(scaffoldContext, chamber.id, widget._currentUser.accessToken);
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
  void onDeleteFailed() {

    hideProgressDialog();

    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("failed_to_delete_chamber"),
        Colors.red, 3);
  }

  @override
  void onDeleteSuccess(int chamberID) {

    hideProgressDialog();

    for(int i=0; i<_chamberList.length; i++) {

      if(_chamberList[i].id == chamberID) {

        _chamberList.removeAt(i);
        break;
      }
    }

    Chambers chambers = Chambers();
    chambers.list = _chamberList;
    showChamberList(chambers);

    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("successfully_deleted_chamber"),
        Colors.green, 3);
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
}