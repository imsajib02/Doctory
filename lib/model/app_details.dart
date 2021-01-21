class AppDetails {

  String appNameEnglish;
  String appNameBangla;
  String generalAppVersion;
  String androidAppVersion;
  String iosAppVersion;
  bool forceUpdate;
  String androidAppLink;
  String iosAppLink;

  AppDetails({this.appNameEnglish, this.appNameBangla, this.generalAppVersion, this.androidAppLink,
    this.androidAppVersion, this.iosAppVersion, this.forceUpdate, this.iosAppLink});

  AppDetails.fromFirebase(Map<dynamic, dynamic> json) {

    appNameEnglish =  json['appNameEnglish'] == null ? "" : json['appNameEnglish'];
    appNameBangla =  json['appNameBangla'] == null ? "" : json['appNameBangla'];
    generalAppVersion =  json['generalAppVersion'] == null ? "" : json['generalAppVersion'];
    androidAppVersion =  json['androidAppVersion'] == null ? "" : json['androidAppVersion'];
    iosAppVersion =  json['iosAppVersion'] == null ? "" : json['iosAppVersion'];
    forceUpdate = json['forceUpdate'] == null ? false : json['forceUpdate'];
    androidAppLink =  json['androidAppLink'] == null ? "" : json['androidAppLink'];
    iosAppLink =  json['iosAppLink'] == null ? "" : json['iosAppLink'];
  }
}