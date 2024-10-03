import 'dart:async';

import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:carabaobillingapps/screen/BottomNavigationScreen.dart';
import 'package:carabaobillingapps/screen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart'; // Import for permission handling

import 'constant/image_constant.dart';
import 'helper/shared_preference.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  // Check if notifications are enabled or request permission
  void _checkNotificationPermission() async {
    if (await _areNotificationsEnabled()) {
      // Notifications are already enabled, navigate to the next screen
      navigateToNextScreen();
    } else {
      // Request permission for notifications
      if (await _requestNotificationPermission()) {
        // If permission granted, proceed
        navigateToNextScreen();
      } else {
        // If permission denied, show a dialog or handle accordingly
        _showPermissionDeniedDialog();
      }
    }
  }

  // Check if notifications are enabled (for Android 13+)
  Future<bool> _areNotificationsEnabled() async {
    if (await Permission.notification.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  // Request notification permission
  Future<bool> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    return status.isGranted;
  }

  // Show a dialog if the permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable Notifications'),
          content: Text(
              'This app requires notifications to be enabled in order to proceed. Please enable notifications in your settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // This will open app settings
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Navigate to the next screen based on whether the token exists
  void navigateToNextScreen() async {
    var token = await getStringValuesSF(ConstantData.token);
    if (token.toString().length > 4) {
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen()),
        );
      });
    } else {
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageConstant.logo,
              width: 250.w,
            ),
          ],
        ),
      ),
    );
  }
}
