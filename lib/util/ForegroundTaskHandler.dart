import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/models/order/ResponseListOrdersModels.dart';

class ForegroundTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  Timer? _timer;
  int _counter = 0; // Initialize the counter

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    print('customData');
    startPeriodicUpdate();
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // This can be used if you need to handle specific events.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Cancel the timer when the task is destroyed
    _timer?.cancel();
  }

  @override
  void onButtonPressed(String id) {
    startPeriodicUpdate();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  void startPeriodicUpdate() {
    // Cancel any existing timer
    _timer?.cancel();

    // Start a new timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      _counter++;
      print('Counter: $_counter');
      await updateNotificationWithFetchedData();
    });
  }

  Future<void> updateNotificationWithFetchedData() async {
    List<NewestOrder> orders = await fetchData();
    if (orders.isNotEmpty) {
      String latestOrderName = orders[0].name.toString();

      // Print the counter and latest order data to the console


      FlutterForegroundTask.updateService(
        notificationText: 'Counter: $_counter - Latest Order: $latestOrderName',
      );
    } else {
      // Print the counter and no orders found message to the console
      print('Counter: $_counter - No orders found');

      FlutterForegroundTask.updateService(
        notificationText: 'Counter: $_counter - No orders found',
      );
    }
  }

  Future<List<NewestOrder>> fetchData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String? ordersJson = _prefs.getString('orders');

    if (ordersJson != null) {
      List<dynamic> orderList = json.decode(ordersJson);
      return orderList.map((json) => NewestOrder.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onRepeatEvent
    _sendPort?.send(timestamp);
    print(timestamp.toString());
  }
}