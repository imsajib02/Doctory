import 'dart:io';
import 'package:doctory/contract/profile_page_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/dashboard_route_parameter.dart';
import 'package:doctory/model/profile_route_parameter.dart';
import 'package:doctory/model/user.dart';
import 'package:doctory/presenter/profile_page_presenter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:doctory/utils/api_routes.dart';
import 'package:doctory/utils/bounce_animation.dart';
import 'package:doctory/utils/local_memory.dart';
import 'package:doctory/utils/my_widgets.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {

  final ProfileRouteParameter _parameter;

  ProfilePage(this._parameter);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> implements View {

  Presenter _presenter;
  int _currentIndex;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _officeMobileController = TextEditingController();
  TextEditingController _designationController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  bool _skipBtnVisibility;
  bool _implyLeading;
  bool _isLoading;

  Widget _profileImage;
  FileImage _image;

  LocalMemory _localMemory;
  MyWidget _myWidget;

  final _bounceStateKey1 = GlobalKey<BounceState>();
  final _bounceStateKey2 = GlobalKey<BounceState>();

  User _user;

  BuildContext _scaffoldContext;

  @override
  void initState() {

    _currentIndex = 3;

    _implyLeading = false;
    _isLoading = false;
    _skipBtnVisibility = false;

    _presenter = ProfilePagePresenter(this, widget._parameter.currentUser, widget._parameter.isFirstOpen);

    _localMemory = LocalMemory();
    _myWidget = MyWidget(context);

    _user = User();
    _user.avatar = widget._parameter.currentUser.avatar;

    super.initState();
  }

  @override
  void didChangeDependencies() {

    _presenter.isFirstOpen(context, widget._parameter.currentUser.accessToken);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {

        _presenter.onBackPressed();
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
              color: Colors.white
          ),
          backgroundColor: Colors.deepOrangeAccent,
          brightness: Brightness.dark,
          elevation: 2,
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("update_your_profile"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1.copyWith(color: Colors.white),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            _scaffoldContext = context;

            return SafeArea(
              child: IndexedStack(
                index: _currentIndex,
                children: <Widget>[

                  ScrollConfiguration(
                    behavior: ScrollBehavior()..buildViewportChrome(context, null, AxisDirection.down),
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Container(
                        margin: EdgeInsets.only(top: 3 * SizeConfig.heightSizeMultiplier, left: 10 * SizeConfig.widthSizeMultiplier,
                          right: 10 * SizeConfig.widthSizeMultiplier,),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                            Container(
                              alignment: Alignment.center,
                              width: 20.5 * SizeConfig.widthSizeMultiplier,
                              height: 10 * SizeConfig.heightSizeMultiplier,
                              child: _user.avatar == "" ? GestureDetector(
                                onTap: () {

                                  _presenter.pickImage(context, _isLoading);
                                },
                                child: CircleAvatar(
                                  radius: 5 * SizeConfig.heightSizeMultiplier,
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.photo_camera, size: 12 * SizeConfig.imageSizeMultiplier, color: Theme.of(context).primaryColor,),
                                ),
                              ) : Stack(children: <Widget>[

                                CircleAvatar(
                                  radius: 5 * SizeConfig.heightSizeMultiplier,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: _profileImage,
                                  ),
                                  backgroundImage: _image,
                                ),

                                GestureDetector(
                                  onTap: () {

                                    _presenter.pickImage(context, _isLoading);
                                  },
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(Icons.edit, color: Colors.blueAccent,),
                                  ),
                                ),
                              ],
                              ),
                            ),

                            SizedBox(height: 1.5 * SizeConfig.heightSizeMultiplier,),

                            Text(AppLocalization.of(context).getTranslatedValue("choose_profile_image"),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 1.5 * SizeConfig.textSizeMultiplier),
                            ),

                            SizedBox(height: .5 * SizeConfig.heightSizeMultiplier,),

                            Text(AppLocalization.of(context).getTranslatedValue("max_file_size"),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 1.5 * SizeConfig.textSizeMultiplier),
                            ),

                            SizedBox(height: 5 * SizeConfig.heightSizeMultiplier,),

                            TextField(
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: AppLocalization.of(context).getTranslatedValue("reg_name_hint"),
                                labelStyle: Theme.of(context).textTheme.subhead,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              ),
                            ),

                            SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: AppLocalization.of(context).getTranslatedValue("reg_email_hint"),
                                labelStyle: Theme.of(context).textTheme.subhead,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              ),
                            ),

                            SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                            TextField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: AppLocalization.of(context).getTranslatedValue("reg_phone_hint"),
                                labelStyle: Theme.of(context).textTheme.subhead,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              ),
                            ),

                            SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                            TextField(
                              controller: _officeMobileController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: AppLocalization.of(context).getTranslatedValue("office_mobile_hint"),
                                labelStyle: Theme.of(context).textTheme.subhead,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              ),
                            ),

                            SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                            TextField(
                              controller: _designationController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: AppLocalization.of(context).getTranslatedValue("designation_hint"),
                                labelStyle: Theme.of(context).textTheme.subhead,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              ),
                            ),

                            SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),

                            TextField(
                              controller: _addressController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: AppLocalization.of(context).getTranslatedValue("address_hint"),
                                labelStyle: Theme.of(context).textTheme.subhead,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(width: 1,
                                    color: AppThemeNotifier().isDarkModeOn ? Colors.white : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              ),
                            ),

                            SizedBox(height: 7 * SizeConfig.heightSizeMultiplier,),

                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[

                                Flexible(
                                  flex: 1,
                                  child: BounceAnimation(
                                    key: _bounceStateKey1,
                                    childWidget: RaisedButton(
                                      padding: EdgeInsets.all(0),
                                      elevation: 5,
                                      onPressed: _isLoading ? null : () {

                                        _bounceStateKey1.currentState.animationController.forward();
                                        FocusScope.of(context).unfocus();

                                        _user.name = _nameController.text;
                                        _user.officeMobile = _officeMobileController.text;
                                        _user.designation = _designationController.text;
                                        _user.address = _addressController.text;

                                        _presenter.validateInput(context, widget._parameter.currentUser.accessToken, _user);
                                      },
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                      textColor: Colors.white,
                                      child: Container(
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
                                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                                        child: Text(
                                          AppLocalization.of(context).getTranslatedValue("update_button"),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 2.25 * SizeConfig.textSizeMultiplier,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Visibility(
                                  visible: _skipBtnVisibility,
                                  child: SizedBox(width: 3.84 * SizeConfig.widthSizeMultiplier,
                                  ),
                                ),

                                Visibility(
                                  visible: _skipBtnVisibility,
                                  child: Flexible(
                                    flex: 1,
                                    child: BounceAnimation(
                                      key: _bounceStateKey2,
                                      childWidget: RaisedButton(
                                        padding: EdgeInsets.all(0),
                                        elevation: 5,
                                        onPressed: _isLoading ? null : () {

                                          _bounceStateKey2.currentState.animationController.forward();
                                          FocusScope.of(context).unfocus();

                                          goToDashBoard(widget._parameter.currentUser);
                                        },
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                        textColor: Colors.white,
                                        child: Container(
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
                                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                                          child: Text(
                                            AppLocalization.of(context).getTranslatedValue("skip_button"),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 2.25 * SizeConfig.textSizeMultiplier,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5 * SizeConfig.heightSizeMultiplier,),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Column(
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

                                _presenter.getProfileInfo(context, widget._parameter.currentUser.accessToken);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                  Container(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void setImageLoadingView() {

    _isLoading = true;

    setState(() {
      _profileImage = CircularProgressIndicator();
    });
  }

  @override
  void setImage(File file) {

    _isLoading = false;

    setState(() {
      _profileImage = Container();
      _image = FileImage(file);
    });
  }

  @override
  setImageFromGallery(File file) {

    setState(() {
      _image = FileImage(file);
      //widget._parameter.currentUser.avatar = file.path;
      _user.avatar = file.path;
    });
  }

  @override
  void showProgressIndicator() {

    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  void onEmpty(String message) {

    _myWidget.showToastMessage(message, 2000, ToastGravity.BOTTOM, Colors.black, 0.7, Colors.white, 1.0);
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
  void hideProgressDialog() {

    _myWidget.hideProgressDialog();
  }

  @override
  void onUpdateFailure(BuildContext context) {

    hideProgressDialog();
    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("profile_update_failed"),
        Colors.red, 3);
  }

  @override
  void onUpdateSuccess(BuildContext context, User userInfo) {

    userInfo.accessToken = widget._parameter.currentUser.accessToken;
    userInfo.tokenType = widget._parameter.currentUser.tokenType;

    widget._parameter.currentUser = userInfo;

    _myWidget.showSnackBar(context, AppLocalization.of(context).getTranslatedValue("profile_update_success"),
        Colors.green, 3);
  }

  @override
  void failedToGetProfileData(BuildContext context) {

    setState(() {
      _currentIndex = 1;
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

  @override
  Future<void> setProfileInfoFromLoginData() async {
    
    setState(() {
      _currentIndex = 0;
      _implyLeading = false;
      _skipBtnVisibility = true;
    });

    _presenter.getImage(context, APIRoute.BASE_URL + widget._parameter.currentUser.avatar);

    _setTextFieldData(widget._parameter.currentUser);
  }

  @override
  Future<void> setProfileInfoFromProfileData(User userProfile) async {

    userProfile.accessToken = widget._parameter.currentUser.accessToken;
    userProfile.tokenType = widget._parameter.currentUser.tokenType;

    widget._parameter.currentUser = userProfile;

    setState(() {
      _currentIndex = 0;
      _implyLeading = true;
      _skipBtnVisibility = false;
    });

    _presenter.getImage(context, APIRoute.BASE_URL + widget._parameter.currentUser.avatar);

    _setTextFieldData(widget._parameter.currentUser);
  }

  void _setTextFieldData(User userInfo) {

    _nameController.text = userInfo.name;
    _emailController.text = userInfo.email;
    _mobileController.text = userInfo.mobile;
    _officeMobileController.text = userInfo.officeMobile;
    _designationController.text = userInfo.designation;
    _addressController.text = userInfo.address;
  }

  @override
  Future<void> goToDashBoard(User user) async {

    await _localMemory.setFirstOpenOrNot(false);

    try {
      _bounceStateKey1.currentState.animationController.dispose();
      _bounceStateKey2.currentState.animationController.dispose();
    }
    catch(error) {}

    DashboardRouteParameter _parameter = DashboardRouteParameter(pageNumber: widget._parameter.pageNumber, currentUser: user);

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.DASHBOARD_ROUTE, arguments: _parameter);
  }
}