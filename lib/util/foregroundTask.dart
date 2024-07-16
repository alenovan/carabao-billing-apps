import 'package:carabaobillingapps/util/FirstTaskHandler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; // Ensure you import this for Colors

import '../main.dart';
import '../service/models/order/ResponseListOrdersModels.dart';
import 'DatabaseHelper.dart';

class ForegroundTaskService {
  static const String TASK_NAME = "Foreground Task";
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        isOnceEvent: true,
      ),
    );
  }

  Future<void> startForegroundTask() async {
    await FlutterForegroundTask.startService(
      notificationTitle: 'Foreground Service is running',
      notificationText: 'Tap to return to the app',
      notificationIcon: null,
      callback: startCallback,
    );
  }

  // The callback function should always be a top-level function.
  @pragma('vm:entry-point')
  void startCallback() {
    // The setTaskHandler function must be called to handle the task in the background.
    FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
  }

  void stopForegroundTask() {
    FlutterForegroundTask.stopService();
  }

  Future<void> _foregroundTask() async {
    print("Background task executed!");

    // Check for new data
    await checkForNewData();
  }

  Future<void> checkForNewData() async {
    final dbHelper = DatabaseHelper();
    List<NewestOrder> orders = await dbHelper.getOrders();
    if (orders.isNotEmpty) {
      String ordersMessage = "";
      for (var order in orders) {
        DateTime endTime = DateTime.parse(order.newestOrderEndTime!);
        Duration timeLeft = endTime.difference(DateTime.now());

        ordersMessage += "${order.name} - ON\n";
        if (DateTime.now().isAfter(endTime)) {
          stopBilling(order.id!, order.ip, order.secret, order.code);
        }
      }

      // Show all orders in a notification
      await _showNotification(
        "Open - Billing",
        ordersMessage,
      );
    }
  }

  Future<void> _showNotification(String title, String body) async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'countdown_channel',
      'Countdown Channel',
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
      enableLights: false,
      ongoing: true, // Set to true to create a persistent notification
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID (should be unique for each notification)
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
