import 'package:shared_preferences/shared_preferences.dart';

addStringSf(param, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(param, value);
}

getStringValuesSF(param) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString(param);
  return stringValue;
}

addModelsSF(param, List<String> value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(param, value);
}

getModelsSF(param) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? stringValue = prefs.getStringList(param);
  return stringValue;
}

addBoolSf(param, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(param, value);
}

getBoolSF(param) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? value = prefs.getBool(param);
  return value;
}

getSF(param) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  dynamic value = prefs.get(param);
  return await value;
}
