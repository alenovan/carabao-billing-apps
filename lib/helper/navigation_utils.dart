import 'package:flutter/material.dart';

class NavigationUtils {

  static void navigateTo(BuildContext context, StatefulWidget page, bool isAddToBackstack) {
    if (isAddToBackstack) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(fullscreenDialog: true, builder: (context) => page),
            (route) => false,
      );
    }
  }

  static void resetRouteTo(BuildContext context, StatefulWidget page) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => page,
        ),
        ModalRoute.withName('/'));
  }

}