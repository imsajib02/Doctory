import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/patient.dart';
import 'package:doctory/model/user.dart';

class EditPatientRouteParameter {

  User currentUser;
  Patient patient;
  List<Patient> patientList;

  EditPatientRouteParameter({this.currentUser, this.patient, this.patientList});
}