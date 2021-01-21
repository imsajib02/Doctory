class Medicine {

  int id;
  String brandName;
  String manufacturer;
  String generic;
  String strength;
  String dosage;
  String price;
  String user;
  String dar;

  Medicine({this.id, this.brandName, this.manufacturer, this.generic, this.strength,
    this.dosage, this.price, this.user, this.dar});

  Medicine.fromJson(Map<String, dynamic> json) {

    id =  json['id'] == null ? 0 : json['id'];
    brandName =  json['brand'] == null ? "" : json['brand'];
    manufacturer =  json['manufacturer'] == null ? "" : json['manufacturer'];
    generic =  json['generic'] == null ? "" : json['generic'];
    strength =  json['strength'] == null ? "" : json['strength'];
    dosage =  json['dosage'] == null ? "" : json['dosage'];
    price =  json['price'] == null ? "" : json['price'];
    user =  json['user'] == null ? "" : json['user'];
    dar =  json['dar'] == null ? "" : json['dar'];
  }
}


class Medicines {

  List<Medicine> list;

  Medicines({this.list});

  Medicines.fromJson(Map<String, dynamic> json) {

    list = List();

    if(json['medicine_list'] != null) {

      json['medicine_list'].forEach((medicine) {

        list.add(Medicine.fromJson(medicine));
      });
    }
  }
}