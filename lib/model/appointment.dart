import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/patient.dart';
import 'package:intl/intl.dart';

class Appointment {

  int id;
  String patientName;
  String patientMobile;
  int patientID;
  int chamberID;
  String dateTime;
  String originalDate;
  String date;
  String time;
  Chamber chamber;
  Patient patient;

  Appointment({this.id, this.patientName, this.patientMobile, this.patientID, this.chamberID,
    this.dateTime, this.originalDate, this.date, this.time, this.patient, this.chamber});

  Appointment.fromJson(Map<String, dynamic> json) {

    id =  json['id'] == null ? 0 : json['id'];
    patientName =  json['name'] == null ? "" : json['name'];
    patientMobile =  json['mobile'] == null ? "" : json['mobile'];
    dateTime =  json['datetime'] == null ? "" : json['datetime'];

    var splitList = dateTime.split(" ");

    originalDate = splitList[0];
    DateTime apDate = DateFormat('d/M/yyyy').parse(splitList[0].split("-").reversed.join("/"));
    date = DateFormat('MMMM d, yyyy').format(apDate);

    var timeSplit = splitList[1].split(":");

    if(int.tryParse(timeSplit[0]) == 0) {

      time = "12:" + timeSplit[1] + " am";
    }
    else if(int.tryParse(timeSplit[0]) > 0 && int.tryParse(timeSplit[0]) < 12) {

      time = timeSplit[0] + ":" + timeSplit[1] + " am";
    }
    else if(int.tryParse(timeSplit[0]) >= 12 && int.tryParse(timeSplit[0]) < 24) {

      time = (24 - int.tryParse(timeSplit[0])).toString() + ":" + timeSplit[1] + " pm";
    }

    chamber = json['chamber'] == null ? Chamber() : Chamber.fromJson(json['chamber']);
    patient = json['patient'] == null ? Patient() : Patient.fromJson(json['patient']);
    patientID =  patient.id == null ? 0 : patient.id;
    chamberID =  chamber.id == null ? 0 : chamber.id;
  }

  Appointment.fromCreate(Map<String, dynamic> json) {

    id =  json['id'] == null ? 0 : json['id'];
    patientName =  json['name'] == null ? "" : json['name'];
    patientMobile =  json['mobile'] == null ? "" : json['mobile'];
    dateTime =  json['datetime'] == null ? "" : json['datetime'];

    var splitList = dateTime.split(" ");

    originalDate = splitList[0];
    DateTime apDate = DateFormat('d/M/yyyy').parse(splitList[0].split("-").reversed.join("/"));
    date = DateFormat('MMMM d, yyyy').format(apDate);

    var timeSplit = splitList[1].split(":");

    if(int.tryParse(timeSplit[0]) == 0) {

      time = "12:" + timeSplit[1] + " am";
    }
    else if(int.tryParse(timeSplit[0]) > 0 && int.tryParse(timeSplit[0]) < 12) {

      time = timeSplit[0] + ":" + timeSplit[1] + " am";
    }
    else if(int.tryParse(timeSplit[0]) >= 12 && int.tryParse(timeSplit[0]) < 24) {

      time = (24 - int.tryParse(timeSplit[0])).toString() + ":" + timeSplit[1] + " pm";
    }

    chamber = json['chamber'] == null ? Chamber() : Chamber.fromJson(json['chamber']);
    patient = json['patient'] == null ? Patient() : Patient.fromJson(json['patient']);
    patientID =  patient.id == null ? 0 : patient.id;
    chamberID =  chamber.id == null ? 0 : chamber.id;
  }

  toJson() {

    return {
      "chamber_id" : chamberID == null ? "0" : chamberID.toString(),
      "patient_id" : patientID == null ? null : patientID.toString(),
      "name" : patientName == null ? "" : patientName,
      "mobile" : patientMobile == null ? "" : patientMobile,
      "date" : date == null ? "" : date,
      "time" : time == null ? "" : time
    };
  }
}


class Appointments {

  List<Appointment> list;

  Appointments({this.list});

  Appointments.fromJson(Map<String, dynamic> json) {

    list = List();

    if(json['appointment_list'] != null) {

      json['appointment_list'].forEach((appointment) {

        list.add(Appointment.fromJson(appointment));
      });
    }
  }
}