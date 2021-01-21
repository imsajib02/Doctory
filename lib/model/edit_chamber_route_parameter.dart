import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/user.dart';

class EditChamberRouteParameter {

  User currentUser;
  Chamber chamber;
  List<Chamber> chamberList;

  EditChamberRouteParameter({this.currentUser, this.chamber, this.chamberList});
}