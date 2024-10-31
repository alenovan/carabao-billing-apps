import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:carabaobillingapps/SplashScreen.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/util/DatabaseHelper.dart';
import 'package:carabaobillingapps/util/TimerService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

// Keep original notification channel setup
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
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
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Schedule background task with optimized interval
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 5),
      0,
      backgroundTask,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    // Keep screen on
    WakelockPlus.enable();
  }

  // Start the optimized timer service
  TimerService.instance.startTimer();

  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> backgroundTask() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();

  try {
    await startForegroundService();
    TimerService.instance.startTimer();

    // health check: verify that all active orders have corresponding timers
    List<NewestOrder> orders = await dbHelper.getOrders();
    for (var order in orders) {
      if (order.type == 'OPEN-BILLING' &&
          order.statusOrder == 'START' &&
          !TimerService.instance.hasActiveTimer(order.id.toString())) {
        TimerService.instance.scheduleOrderTimer(order);
      }
    }
  } catch (e) {
    print("Background task error: $e");
  }
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

Future<void> showNotification(String title, String body) async {
  const int notificationId = 0;
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    ongoing: true,
    autoCancel: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      notificationId, title, body, platformChannelSpecifics);
}

Future<void> cancelNotification(int notificationId) async {
  await flutterLocalNotificationsPlugin.cancel(notificationId);
}

Future<void> launchApp() async {
  if (Platform.isAndroid) {
    const channel =
        MethodChannel('com.crb.gzb.biling.carabaobillingapps/channel');
    try {
      await channel.invokeMethod('launchApp');
    } catch (e) {
      print("Failed to launch app: $e");
    }
  }
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Carabao Lamp',
          home: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}
