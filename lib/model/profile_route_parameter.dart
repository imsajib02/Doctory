import 'package:doctory/model/user.dart';

class ProfileRouteParameter {

  User currentUser;
  bool isFirstOpen;
  int pageNumber;

  ProfileRouteParameter({this.currentUser, this.isFirstOpen, this.pageNumber});
}