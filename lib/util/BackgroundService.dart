import 'package:carabaobillingapps/helper/global_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import '../service/models/order/ResponseListOrdersModels.dart';
import 'DatabaseHelper.dart';

void backgroundTask() async {
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
      ordersMessage += "${order.name} - ON\n";

      if (DateTime.now().isAfter(endTime)) {
        stopBilling(order!.id!, order!.ip, order!.secret, order!.code);
      }else{
        switchLamp(ip: order!.ip!, key: order!.secret!, code: order!.code!, status: true);
      }
    }

    // Show all orders in a notification
    await _showNotification(
      "Open - Billing",
      "Start",
    );
  }
}

Future<void> _showNotification(String title, String body) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
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
