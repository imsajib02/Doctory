import 'package:doctory/contract/dash_board_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/change_password_route_parameter.dart';
import 'package:doctory/model/dashboard_route_parameter.dart';
import 'package:doctory/model/language_page_route_parameter.dart';
import 'package:doctory/model/profile_route_parameter.dart';
import 'package:doctory/presenter/dash_board_presenter.dart';
import 'package:doctory/resources/images.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/app_settings.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:doctory/utils/local_memory.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:doctory/utils/my_widgets.dart';
import 'package:doctory/view/dashboard/home_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class DashBoard extends StatefulWidget {

  final DashboardRouteParameter _routeParameter;

  DashBoard(this._routeParameter);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> implements View {

  Presenter _presenter;
  MyWidget _getWidget;
  LocalMemory _localMemory;

  int _currentTabIndex;
  Widget _currentTab;
  Widget _appBarTitle;

  PackageInfo packageInfo;

  @override
  initState() {

    _presenter = DashBoardPresenter(this);
    _getWidget = MyWidget(context);

    _localMemory = LocalMemory();
    _localMemory.saveUser(widget._routeParameter.currentUser);

    _currentTabIndex = widget._routeParameter.pageNumber;

    super.initState();
  }

  @override
  void didChangeDependencies() {

    _currentTab = Container();

    _presenter.onTabSelected(context, widget._routeParameter.pageNumber, widget._routeParameter.currentUser);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(DashBoard oldWidget) {

    _presenter.onTabSelected(context, _currentTabIndex, widget._routeParameter.currentUser);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {

        return _presenter.onBackPress(_currentTabIndex, widget._routeParameter.currentUser);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 2,
          centerTitle: true,
          title: _appBarTitle,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        drawer: _drawer(),
        body: Builder(
          builder: (BuildContext context) {

            return _currentTab;
          },
        ),
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.deepOrange,
          backgroundColor: Theme.of(context).primaryColor,
          buttonBackgroundColor: Theme.of(context).primaryColor,
          index: _currentTabIndex,
          onTap: (index) {

            _presenter.onTabSelected(context, index, widget._routeParameter.currentUser);
          },
          animationDuration: Duration(milliseconds: 300),
          height: 6.875 * SizeConfig.heightSizeMultiplier,
          items: <Widget>[

            Container(
              height: 3.125 * SizeConfig.heightSizeMultiplier,
              width: 6.41 * SizeConfig.widthSizeMultiplier,
              child: Image.asset(Images.chamberIcon),
            ),

            Container(
              height: 3.125 * SizeConfig.heightSizeMultiplier,
              width: 6.41 * SizeConfig.widthSizeMultiplier,
              child: Image.asset(Images.appointmentIcon),
            ),

            Container(
              height: 3.125 * SizeConfig.heightSizeMultiplier,
              width: 6.41 * SizeConfig.widthSizeMultiplier,
              child: Image.asset(Images.homeIcon),
            ),

            Container(
              height: 3.125 * SizeConfig.heightSizeMultiplier,
              width: 6.41 * SizeConfig.widthSizeMultiplier,
              child: Image.asset(Images.prescriptionIcon),
            ),

            Container(
              height: 3.125 * SizeConfig.heightSizeMultiplier,
              width: 6.41 * SizeConfig.widthSizeMultiplier,
              child: Image.asset(Images.reportsIcon),
            ),
          ],
        ),
      ),
    );
  }


  Drawer _drawer() {

    imageCache.clear();

    return Drawer(
      child: ListView(
        children: <Widget>[

          DrawerHeader(
            padding: EdgeInsets.all(2.5 * SizeConfig.heightSizeMultiplier),
            decoration: BoxDecoration(
              color: Colors.black12.withOpacity(.05),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                widget._routeParameter.currentUser.avatar == "" ? CircleAvatar(
                  radius: 3.75 * SizeConfig.heightSizeMultiplier,
                  backgroundColor: Colors.deepOrangeAccent.shade100,
                  child: Icon(Icons.person, size: 10 * SizeConfig.imageSizeMultiplier, color: Theme.of(context).primaryColor,),
                ) : CircleAvatar(
                  radius: 3.75 * SizeConfig.heightSizeMultiplier,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.75 * SizeConfig.heightSizeMultiplier),
                  ),
                  backgroundImage: NetworkImage(APIRoute.BASE_URL + widget._routeParameter.currentUser.avatar),
                ),

                SizedBox(height: 1.5 * SizeConfig.heightSizeMultiplier,),

                Text(widget._routeParameter.currentUser.name, style: Theme.of(context).textTheme.display1,),

                SizedBox(height: .5 * SizeConfig.heightSizeMultiplier,),

                Text(widget._routeParameter.currentUser.email, style: Theme.of(context).textTheme.caption,)
              ],
            ),
          ),

          ListTile(
            onTap: () {

              Navigator.of(context).pop();

              ProfileRouteParameter _parameter = ProfileRouteParameter(currentUser: widget._routeParameter.currentUser, isFirstOpen: false, pageNumber: _currentTabIndex);

              Navigator.pop(context);
              Navigator.of(context).pushNamed(RouteManager.PROFILE_PAGE_ROUTE, arguments: _parameter);
            },
            leading: Icon(
              Icons.person,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("profile_text"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),

          ListTile(
            onTap: () {

              Navigator.of(context).pop();

              showSelectedTab(2, HomePage(widget._routeParameter.currentUser));
            },
            leading: Icon(
              Icons.home,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("home_text"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),

          ListTile(
            onTap: () {

              Navigator.of(context).pop();

              ChangePasswordRouteParameter parameter = ChangePasswordRouteParameter(currentUser: widget._routeParameter.currentUser, pageNumber: _currentTabIndex);

              Navigator.pop(context);
              Navigator.of(context).pushNamed(RouteManager.CHANGE_PASSWORD_PAGE_ROUTE, arguments: parameter);
            },
            leading: Icon(
              Icons.lock,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("change_password"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),

          ListTile(
            onTap: () {

              Navigator.of(context).pop();

              LanguagePageRouteParameter parameter = LanguagePageRouteParameter(currentUser: widget._routeParameter.currentUser, pageNumber: _currentTabIndex);

              Navigator.pop(context);
              Navigator.of(context).pushNamed(RouteManager.LANGUAGE_PAGE_ROUTE, arguments: parameter);
            },
            leading: Icon(
              Icons.translate,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("language_text"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),

          ListTile(
            onTap: () {

              Navigator.of(context).pop();
              _launchURL(AppSettings.PRIVACY_POLICY_URL);
            },
            leading: Icon(
              Icons.security,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("privacy_policy_text"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),

          ListTile(
            onTap: () {

              Navigator.of(context).pop();
              _launchURL(AppSettings.TERMS_AND_CONDITIONS_URL);
            },
            leading: Icon(
              Icons.receipt,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("terms_condition_text"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),

          ListTile(
            onTap: () async {

              Navigator.of(context).pop();

              //packageInfo = await PackageInfo.fromPlatform();

              showAboutDialog(
                context: context,
                applicationIcon: Container(
                  height: 5 * SizeConfig.heightSizeMultiplier,
                  width: 10.25 * SizeConfig.widthSizeMultiplier,
                  child: Image.asset(Images.appIcon),
                ),
                applicationName: AppLocalization.of(context).getTranslatedValue("app_name1") + AppLocalization.of(context).getTranslatedValue("app_name2"),
                applicationVersion: AppLocalization.of(context).getTranslatedValue("version"),
                applicationLegalese: AppLocalization.of(context).getTranslatedValue("about_app"),
              );
            },
            leading: Icon(
              Icons.info_outline,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("about_text"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),

          ListTile(
            onTap: () {

              _signOut();
            },
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.deepOrangeAccent.shade200,
            ),
            title: Text(AppLocalization.of(context).getTranslatedValue("sign_out_text"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _launchURL(String url) async {

    if(await canLaunch(url)) {

      CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Launching URL", message: url);
      await launch(url);
    }
    else {

      CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Failed To Launch URL", message: url);
      throw 'Could not launch $url';
    }
  }


  @override
  void showSelectedTab(int index, Widget tab, {Widget appbarTitle}) {

    appbarTitle == null ? appbarTitle = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        Text(AppLocalization.of(context).getTranslatedValue("app_name1"),
          style: Theme.of(context).textTheme.headline.copyWith(color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,),
        ),

        Text(AppLocalization.of(context).getTranslatedValue("app_name2"),
          style: Theme.of(context).textTheme.headline.copyWith(color: Colors.green),
        ),
      ],
    ) : appbarTitle = appbarTitle;

    setState(() {
      _appBarTitle = appbarTitle;
      _currentTabIndex = index;
      _currentTab = tab;
    });
  }

  @override
  void showAlertOnExit() {

    _getWidget.showToastMessage(AppLocalization.of(context).getTranslatedValue("tap_again_to_exit"),
        2000, ToastGravity.BOTTOM, Colors.black, 0.7, Colors.white, 1.0);
  }

  Future<void> _signOut() async {

    await _localMemory.remove(LocalMemory.LOGGED_USER);

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.LOGIN_ROUTE);
  }
}