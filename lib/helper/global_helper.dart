import 'dart:async';

import 'package:carabaobillingapps/helper/shared_preference.dart';
import 'package:flutter/cupertino.dart';

import '../constant/data_constant.dart';

void hideKeyboard(context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void popScreen(BuildContext context, [dynamic data]) {
  Navigator.pop(context, data);
}

enum RouteTransition { slide, dualSlide, fade, material, cupertino }

Future pushScreenAndWait(BuildContext context, Widget buildScreen) async {
  await Navigator.push(
      context, CupertinoPageRoute(builder: (context) => buildScreen));
  return;
}

Future pushScreenAndWaitReplace(BuildContext context,
    Widget buildScreen) async {
  await Navigator.pushReplacement(
      context, CupertinoPageRoute(builder: (context) => buildScreen));
  return;
}

Future<Map<String, String>> tokenHeader(bool contentType) async {
  var token = await getStringValuesSF(ConstantData.token);
  var headers = {'Authorization': 'Bearer $token'};
  if (contentType) {
    headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };
  }

  return headers;
}
