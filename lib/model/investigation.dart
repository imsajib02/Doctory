
class Investigation {

  int id;
  String topic;
  String result;

  Investigation({this.id, this.topic, this.result});

  Investigation.fromJson(Map<String, dynamic> json) {

    id =  json['id'] == null ? 0 : json['id'];
    topic =  json['name'] == null ? "" : json['name'];
    result =  json['result'] == null ? "" : json['result'];
  }
}