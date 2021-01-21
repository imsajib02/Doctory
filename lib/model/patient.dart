import 'package:doctory/model/prescription.dart';

class Patient {

  int id;
  String name;
  String mobile;
  String age;
  String gender;
  String address;
  String history;
  List<Prescription> prescriptionList;

  Patient({this.id, this.name, this.mobile, this.age, this.gender, this.address, this.history, this.prescriptionList});

  Patient.fromJson(Map<String, dynamic> json) {

    id =  json['id'] == null ? 0 : json['id'];
    name =  json['name'] == null ? "" : json['name'];
    mobile =  json['mobile'] == null ? "" : json['mobile'];
    age =  json['age'] == null ? "" : json['age'];
    gender =  json['gender'] == null ? "" : json['gender'];
    address =  json['address'] == null ? "" : json['address'];
    history =  json['history'] == null ? "" : json['history'];
  }

  Patient.fromReport(Map<String, dynamic> json) {

    id =  json['id'] == null ? 0 : json['id'];
    name =  json['name'] == null ? "" : json['name'];
    mobile =  json['mobile'] == null ? "" : json['mobile'];
    age =  json['age'] == null ? "" : json['age'];
    gender =  json['gender'] == null ? "" : json['gender'];
    address =  json['address'] == null ? "" : json['address'];

    prescriptionList = List();

    if(json['prescriptions'] != null) {

      json['prescriptions'].forEach((prescription) {

        prescriptionList.add(Prescription.fromReport(prescription));
      });
    }
  }

  toJson() {

    return {
      "name" : name == null ? "" : name,
      "age" : age == null ? "" : age,
      "gender" : gender == null ? "" : gender,
      "mobile" : mobile == null ? "" : mobile,
      "address" : address == null ? "" : address
    };
  }
}


class Patients {

  List<Patient> list;

  Patients({this.list});

  Patients.fromJson(Map<String, dynamic> json) {

    list = List();

    if(json['patient_list'] != null) {

      json['patient_list'].forEach((patient) {

        list.add(Patient.fromJson(patient));
      });
    }
  }
}