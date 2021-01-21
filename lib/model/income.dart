import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/patient.dart';
import 'package:intl/intl.dart';

class Income {

  int id;
  int visitingFee;
  int patientID;
  int chamberID;
  Chamber chamber;
  Patient patient;
  String createdAt;
  String originalDate;
  String updateTime;

  Income({this.id, this.visitingFee, this.patientID, this.chamberID, this.patient, this.chamber, this.createdAt, this.updateTime});

  Income.fromJson(Map<String, dynamic> json) {

    id =  json['id'] == null ? 0 : json['id'];
    visitingFee =  json['visiting_fee'] == null ? 0 : json['visiting_fee'];
    chamber =  json['chamber'] == null ? Chamber() : Chamber.fromJson(json['chamber']);
    patient =  json['patient'] == null ? Patient() : Patient.fromJson(json['patient']);
    patientID =  patient.id == null ? 0 : patient.id;
    chamberID =  chamber.id == null ? 0 : chamber.id;
    createdAt =  json['created_at'] == null ? "" : json['created_at'];
    originalDate =  json['created_at'] == null ? "" : json['created_at'];

    DateTime expDate = DateFormat('d/M/yyyy').parse(createdAt.split("-").reversed.join("/"));
    createdAt = DateFormat('MMMM d, yyyy').format(expDate);

    updateTime =  json['updated_at'] == null ? "" : json['updated_at'];
  }
}

class Incomes {

  List<Income> list;
  List<Chamber> chamberList;

  Incomes({this.list, this.chamberList});

  Incomes.fromJson(Map<String, dynamic> json) {

    list = List();
    chamberList = List();

    if(json['income_list'] != null) {

      json['income_list'].forEach((income) {

        list.add(Income.fromJson(income));
      });
    }

    if(json['chamber_list'] != null) {

      json['chamber_list'].forEach((chamber) {

        chamberList.add(Chamber.fromJson(chamber));
      });
    }
  }
}