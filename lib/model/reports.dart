import 'package:doctory/model/patient.dart';

class Report {

  List<Patient> patientList;

  Report({this.patientList});

  Report.fromJson(Map<String, dynamic> json) {

    patientList = List();

    if(json['patients'] != null) {

      json['patients'].forEach((report) {

        if(report['prescriptions'].length > 0) {

          patientList.add(Patient.fromReport(report));
        }
      });
    }
  }
}