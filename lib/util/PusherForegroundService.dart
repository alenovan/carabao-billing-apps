import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PusherService {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  PusherService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize local notifications
    _initializeLocalNotifications();

    // Initialize Pusher
    await _initializePusher();

    // Start foreground service
    startForegroundService();
  }

  void _initializeLocalNotifications() {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _initializePusher() async {
    try {
      await _pusher.init(
        apiKey: "1ae635fc4ca9f011e201",
        cluster: "ap1",
      );
      await _pusher.connect();
      await _subscribeToPusherChannels();
      print("Pusher initialized and connected successfully.");
    } catch (e) {
      print("Error initializing Pusher: $e");
    }
  }

  Future<void> _subscribeToPusherChannels() async {
    try {
      await _pusher.subscribe(
        channelName: "orders",
        onEvent: (event) async {
          print("Event received: ${event.data}"); // Log raw event data
          try {
            final eventData = json.decode(event.data);
            final message = eventData['message'];
            final link = eventData['link'];
            print("Message: $message");
            print("Link: $link");
            await _offLamp(link);
            await _showNotification("Open - Billing", message);
          } catch (e) {
            print("Error processing Pusher event: $e");
          }
        },
      );
      print("Subscribed to Pusher channel successfully.");
    } catch (e) {
      print("Error subscribing to Pusher channels: $e");
    }
  }

  Future<void> _offLamp(String link) async {
    try {
      // Implement your logic to turn off the lamp using the link
      print("Turning off lamp with link: $link");
    } catch (e) {
      print("Error turning off lamp: $e");
    }
  }

  Future<void> _showNotification(String title, String message) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformChannelSpecifics,
      payload: 'item_x',
    );
  }

  void startForegroundService() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Pusher Service',
      notificationText: 'Listening for events...',
      callback: _startForegroundTask,
    );
  }

  @pragma('vm:entry-point')
  static void _startForegroundTask() {
    FlutterForegroundTask().startService(
      notificationTitle: 'Pusher Service',
      notificationText: 'Listening for events...',
    );
  }
}
