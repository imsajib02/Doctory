import 'package:doctory/contract/registration_page_contact.dart';
import 'package:doctory/model/phone_verification_route_parameter.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/model/registration_route_parameter.dart';
import 'package:doctory/presenter/registration_page_presenter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:doctory/utils/app_settings.dart';
import 'package:doctory/utils/bounce_animation.dart';
import 'package:doctory/utils/custom_log.dart';
import 'package:doctory/utils/custom_trace.dart';
import 'package:doctory/utils/my_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationPage extends StatefulWidget {

  final RegistrationRouteParameter _routeParameter;

  RegistrationPage(this._routeParameter);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> with WidgetsBindingObserver implements View {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  User _user;
  Presenter _presenter;
  MyWidget _myWidget;

  FocusNode _phoneFocusNode;
  String _phonePrefixText;
  String _phoneHintText;

  BuildContext _scaffoldContext;

  bool passwordVisibility = true;
  IconData passwordToggle = Icons.visibility;

  String _previousPhoneNumberInput = "";
  FirebaseUser _firebaseUser;

  final _bounceStateKey = GlobalKey<BounceState>();

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);

    _user = User();
    _phonePrefixText = "";
    _phoneFocusNode = FocusNode();

    _phoneFocusNode.addListener(_onFocusChanged);

    _presenter = RegistrationPresenter(this);
    _presenter.isPhoneVerified(widget._routeParameter);
    _myWidget = MyWidget(context);

    super.initState();
  }

  @override
  void didChangeDependencies() {

    _phoneHintText = AppLocalization.of(context).getTranslatedValue("reg_phone_hint");
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
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            _scaffoldContext = context;

            return SafeArea(
              child: Stack(
                children: <Widget>[

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Container(
                        margin: EdgeInsets.only(top: 7.5 * SizeConfig.heightSizeMultiplier, left: 12.82 * SizeConfig.widthSizeMultiplier,
                            right: 12.82 * SizeConfig.widthSizeMultiplier, bottom: 4.5 * SizeConfig.heightSizeMultiplier),
                        child: Text(AppLocalization.of(context).getTranslatedValue("create_account_text"),
                          style: Theme.of(context).textTheme.display3,
                        ),
                      ),

                      Flexible(
                        child: ScrollConfiguration(
                          behavior: new ScrollBehavior()..buildViewportChrome(context, null, AxisDirection.down),
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            child: Container(
                              margin: EdgeInsets.only(top: 2 * SizeConfig.heightSizeMultiplier, left: 12.82 * SizeConfig.widthSizeMultiplier,
                                right: 12.82 * SizeConfig.widthSizeMultiplier,),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  TextField(
                                    controller: _nameController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hintText: AppLocalization.of(context).getTranslatedValue("reg_name_hint"),
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

                                  SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
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

                                  SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                                  TextField(
                                    controller: _passwordController,
                                    obscureText: passwordVisibility,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    maxLength: 20,
                                    decoration: InputDecoration(
                                      counter: SizedBox.shrink(),
                                      suffixIcon: IconButton(icon: Icon(passwordToggle),
                                          color: Colors.lightBlueAccent,
                                          onPressed: () {

                                            setState(() {
                                              passwordVisibility = !passwordVisibility;
                                              passwordVisibility ? passwordToggle = Icons.visibility : passwordToggle = Icons.visibility_off;
                                            });
                                          }),
                                      hintText: AppLocalization.of(context).getTranslatedValue("reg_password_hint"),
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

                                  SizedBox(height: 2 * SizeConfig.heightSizeMultiplier,),

                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    focusNode: _phoneFocusNode,
                                    decoration: InputDecoration(
                                      prefix: Text(_phonePrefixText, style: Theme.of(context).textTheme.subhead,),
                                      helperText: AppLocalization.of(context).getTranslatedValue("reg_phone_help_text"),
                                      helperMaxLines: 2,
                                      helperStyle: AppThemeNotifier().isDarkModeOn == false ? TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.5,
                                      ) : TextStyle(
                                        color: Colors.white.withOpacity(.4),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.5,
                                      ),
                                      hintText: _phoneHintText,
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

                                  SizedBox(height: 8 * SizeConfig.heightSizeMultiplier,),

                                  Align(
                                    alignment: Alignment.center,
                                    child: BounceAnimation(
                                      key: _bounceStateKey,
                                      childWidget: RaisedButton(
                                        padding: EdgeInsets.all(0),
                                        elevation: 5,
                                        onPressed: () {

                                          _bounceStateKey.currentState.animationController.forward();
                                          FocusScope.of(context).unfocus();

                                          _user.name = _nameController.text;
                                          _user.email = _emailController.text;
                                          _user.password = _passwordController.text;
                                          _user.mobile = _phoneController.text;

                                          _presenter.validateInput(context, _user, _previousPhoneNumberInput, _firebaseUser);
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
                                            AppLocalization.of(context).getTranslatedValue("reg_signup_button"),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 2.25 * SizeConfig.textSizeMultiplier,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 1 * SizeConfig.heightSizeMultiplier,),

                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(AppLocalization.of(context).getTranslatedValue("or_text"),
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),

                                  SizedBox(height: 1 * SizeConfig.heightSizeMultiplier,),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(AppLocalization.of(context).getTranslatedValue("go_back_to_login"),
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.lightBlueAccent,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 1.8 * SizeConfig.textSizeMultiplier,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 12 * SizeConfig.heightSizeMultiplier,),

                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(AppLocalization.of(context).getTranslatedValue("by_signing_up_text"),
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(top: .375 * SizeConfig.heightSizeMultiplier, bottom: 2.5 * SizeConfig.heightSizeMultiplier),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[

                                        GestureDetector(
                                          onTap: () {

                                            _launchURL(AppSettings.TERMS_AND_CONDITIONS_URL);
                                          },
                                          child: Text(AppLocalization.of(context).getTranslatedValue("terms_condition_text"),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue,
                                              fontSize: 1.8 * SizeConfig.textSizeMultiplier,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 1.28 * SizeConfig.widthSizeMultiplier,),

                                        Text(AppLocalization.of(context).getTranslatedValue("and_text"),
                                          style: Theme.of(context).textTheme.caption,
                                        ),

                                        SizedBox(width: 1.28 * SizeConfig.widthSizeMultiplier,),

                                        GestureDetector(
                                          onTap: () {

                                            _launchURL(AppSettings.PRIVACY_POLICY_URL);
                                          },
                                          child: Text(AppLocalization.of(context).getTranslatedValue("privacy_policy_text"),
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 1.8 * SizeConfig.textSizeMultiplier,
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
                    ],
                  ),
                ],
              ),
            );
          },
        ),
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

  _onFocusChanged() {

    setState(() {

      if(_phoneFocusNode.hasFocus) {

        _phonePrefixText = "+880";
        _phoneHintText = "";
      }
      else {

        if(_phoneController.text.length == 0) {

          _phonePrefixText = "";
          _phoneHintText = AppLocalization.of(context).getTranslatedValue("reg_phone_hint");
        }
      }
    });
  }

  @override
  void fillInTextFields() {

    setState(() {

      _nameController.text = widget._routeParameter.user.name;
      _emailController.text = widget._routeParameter.user.email;
      _passwordController.text = widget._routeParameter.user.password;
      _phoneController.text = widget._routeParameter.user.mobile;
    });
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

  Future<bool> _onBackPressed() {

    try {
      _bounceStateKey.currentState.animationController.dispose();
    }
    catch(error) {}

    return Future(() => true);
  }

  @override
  void gotToPhoneVerificationPage(PhoneVerificationRouteParameter routeParameter) {

    hideProgressDialog();

    try {
      _bounceStateKey.currentState.animationController.dispose();
    }
    catch(error) {}

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.PHONE_VERIFICATION_ROUTE, arguments: routeParameter);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}