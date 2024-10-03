import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:carabaobillingapps/SplashScreen.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/util/DatabaseHelper.dart';
import 'package:carabaobillingapps/util/TimerService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool enableFetch = true;
Timer? fetchTimer;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications',
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setSize(const Size(360, 690));
  }
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();

    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/launcher_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 1),
      0, // unique task ID
      backgroundTask, // callback function
      wakeup: true,
      rescheduleOnReboot: true, // Ensures task continues after device reboot
    );
    WakelockPlus.enable();
  }

  TimerService.instance.startTimer();
  runApp(
    MyApp(),
  );
}

Future<void> startForegroundService() async {
  const platform = MethodChannel(
      'com.crb.gzb.biling.carabaobillingapps.foregroundService/channel');
  try {
    await platform.invokeMethod('startForegroundService');
  } catch (e) {
    print("Failed to start foreground service: $e");
  }
}

void backgroundTask() async {
  // Initialize the database helper
  DatabaseHelper dbHelper = DatabaseHelper();

  // Fetch orders from the local database
  List<NewestOrder> orders = await dbHelper.getOrders();
  startForegroundService();

  for (var order in orders) {
    if (order.type == 'OPEN-BILLING' && order.statusOrder == 'START') {
      // Parse the start and end time of the order
      DateTime startTime = DateTime.parse(order.newestOrderStartTime!);
      DateTime endTime = DateTime.parse(order.newestOrderEndTime!);

      // Start a periodic timer that updates the notification every second
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        Duration remaining = endTime.difference(DateTime.now());

        // If time has run out, stop the timer and notify the user
        if (remaining.inSeconds <= 0) {
          timer.cancel();
          await showNotification(
            'Order ${order.name}',
            'The order has timed out. Please take action.',
          );

          // Launch the app when time runs out
          if (Platform.isAndroid) {
            await launchApp();
          }
        }
      });
    }
  }
}

Future<void> cancelNotification(int notificationId) async {
  await flutterLocalNotificationsPlugin.cancel(notificationId);
}

Future<void> launchApp() async {
  if (Platform.isAndroid) {
    // Android-specific code to launch the app
    const channel =
        MethodChannel('com.crb.gzb.biling.carabaobillingapps/channel');
    try {
      await channel.invokeMethod('launchApp');
    } catch (e) {
      print("Failed to launch app: $e");
    }
  }
}

Future<void> showNotification(String title, String body) async {
  const int notificationId = 0; // Use a constant ID for the notification
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'channel_id', // Channel ID
    'channel_name', // Channel name
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    ongoing: true,
    // This makes the notification non-dismissible
    autoCancel: false, // Prevents the notification from being removed on click
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Update the notification using the same ID
  await flutterLocalNotificationsPlugin.show(
      notificationId, title, body, platformChannelSpecifics);
}


Future<void> offLamp(String link) async {
  try {
    var response = await http.post(
      Uri.parse(link),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 5)); // Set the timeout duration

    if (response.statusCode == 200) {
      print('Lamp turned off successfully');
      // You can add your logic here for success
    } else {
      print('Failed to turn off lamp. Status code: ${response.statusCode}');
      // Handle other status codes here
    }
  } on TimeoutException catch (e) {
    print('The request timed out: $e');
    // Handle timeout-specific logic here
  } catch (error) {
    print('Error during offLamp request: $error');
    // Handle other types of errors (network issues, etc.)
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Carabao Lamp',
          home: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}
