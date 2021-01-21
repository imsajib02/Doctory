import 'package:doctory/contract/password_recovery_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/phone_verification_route_parameter.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/presenter/password_recovery_presenter.dart';
import 'package:doctory/resources/images.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:doctory/utils/bounce_animation.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:doctory/utils/my_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class PasswordRecoverPage extends StatefulWidget {

  @override
  _PasswordRecoverPageState createState() => _PasswordRecoverPageState();
}

class _PasswordRecoverPageState extends State<PasswordRecoverPage> with WidgetsBindingObserver implements View {

  TextEditingController _emailController = TextEditingController();

  User _user;
  Presenter _presenter;
  MyWidget _myWidget;

  final _bounceStateKey = GlobalKey<BounceState>();

  BuildContext _scaffoldContext;

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);

    _user = User();
    _presenter = PasswordRecoveryPresenter(this);
    _myWidget = MyWidget(context);

    super.initState();
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
      onWillPop: () {

        try {
          _bounceStateKey.currentState.animationController.dispose();
        }
        catch(error) {}

        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(RouteManager.LOGIN_ROUTE);

        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            _scaffoldContext = context;

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.only(top: 7 * SizeConfig.heightSizeMultiplier, bottom: 3.75 * SizeConfig.heightSizeMultiplier),
                    child: Text(AppLocalization.of(context).getTranslatedValue("recover_password_text"),
                      style: Theme.of(context).textTheme.display3,
                    ),
                  ),

                  Flexible(
                    child: ScrollConfiguration(
                      behavior: new ScrollBehavior()..buildViewportChrome(context, null, AxisDirection.down),
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Container(
                          margin: EdgeInsets.only(top: 3 * SizeConfig.heightSizeMultiplier, left: 12.82 * SizeConfig.widthSizeMultiplier,
                            right: 12.82 * SizeConfig.widthSizeMultiplier,),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: EdgeInsets.only(bottom: 3.75 * SizeConfig.heightSizeMultiplier),
                                child: SizedBox(
                                  width: 25 * SizeConfig.widthSizeMultiplier,
                                  height: 12 * SizeConfig.heightSizeMultiplier,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(Images.passwordLockImage,
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 2.5 * SizeConfig.heightSizeMultiplier, bottom: 3.75 * SizeConfig.heightSizeMultiplier),
                                child: Text(AppLocalization.of(context).getTranslatedValue("enter_your_registered_email_text"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.title,
                                ),
                              ),

                              TextField(
                                textAlign: TextAlign.center,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: AppLocalization.of(context).getTranslatedValue("reg_email_hint"),
                                  hintStyle: Theme.of(context).textTheme.subhead,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                  fillColor: AppThemeNotifier().isDarkModeOn == false ? Colors.black12.withOpacity(.035) : Colors.white.withOpacity(.3),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 5 * SizeConfig.heightSizeMultiplier, bottom: 3.75 * SizeConfig.heightSizeMultiplier,
                                left: 5.1 * SizeConfig.widthSizeMultiplier, right: 5.1 * SizeConfig.widthSizeMultiplier),
                                child: Text(AppLocalization.of(context).getTranslatedValue("an_otp_will_be_send_text"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),

                              SizedBox(height: 3 * SizeConfig.heightSizeMultiplier,),

                              BounceAnimation(
                                key: _bounceStateKey,
                                childWidget: RaisedButton(
                                  padding: EdgeInsets.all(0),
                                  elevation: 5,
                                  onPressed: () {

                                    _bounceStateKey.currentState.animationController.forward();
                                    FocusScope.of(context).unfocus();

                                    _user.email = _emailController.text;

                                    _presenter.validateInput(context, _user);
                                  },
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                  textColor: Colors.white,
                                  child: Container(
                                    width: 50 * SizeConfig.widthSizeMultiplier,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: <Color>[
                                            Colors.deepPurple,
                                            Color(0xFF9E1E1E),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    child: Text(
                                      AppLocalization.of(context).getTranslatedValue("verify_button"),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 2.25 * SizeConfig.textSizeMultiplier,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 6.25 * SizeConfig.heightSizeMultiplier,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void onEmpty(String message) {

    _myWidget.showToastMessage(message, 2000, ToastGravity.BOTTOM, Colors.black, 0.7, Colors.white, 1.0);
  }

  @override
  void onInvalidInput(String message) {

    _myWidget.showToastMessage(message, 3000, ToastGravity.BOTTOM, Colors.white, 1.0, Colors.red.shade400, 1.0);
  }

  @override
  void onError(String message) {

    _myWidget.showToastMessage(message, 3000, ToastGravity.BOTTOM, Colors.white, 1.0, Colors.red.shade400, 1.0);
  }

  @override
  void showProgressDialog(String message) {

    _myWidget.showProgressDialog(message);
  }

  @override
  void updateProgressDialog(String message) {

    _myWidget.updateProgressDialog(message);
  }

  @override
  void hideProgressDialog() {

    _myWidget.hideProgressDialog();
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
  void goToPhoneVerificationPage(PhoneVerificationRouteParameter routeParameter) {

    try {
      _bounceStateKey.currentState.animationController.dispose();
    }
    catch(error) {}

    hideProgressDialog();
    Navigator.of(context).pushNamed(RouteManager.PHONE_VERIFICATION_ROUTE, arguments: routeParameter);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}