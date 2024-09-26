import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() => _instance;

  BackgroundService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'open_billing_channel', // Channel ID
      'Open Billing Service', // Channel Name
      description: 'This channel handles the Open Billing service',
      importance: Importance.low, // Importance level
    );

    // Setup notification plugin
    if (Platform.isIOS || Platform.isAndroid) {
      await _notificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Configure the background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'open_billing_channel',
        initialNotificationTitle: 'Open Billing Service',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 999,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final log = prefs.getStringList('log') ?? <String>[];
    log.add('Background task executed at ${DateTime.now()}');
    await prefs.setStringList('log', log);

    return true;
  }

  @pragma('vm:entry-point')
  void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('startBillingTimer').listen((event) {
      String endTimeString = event!['endTime'];
      String orderId = event['orderId'];

      DateTime endTime = DateTime.parse(endTimeString);
      Duration remaining = endTime.difference(DateTime.now());

      Timer.periodic(const Duration(seconds: 1), (timer) async {
        remaining = remaining - const Duration(seconds: 1);

        if (remaining.inSeconds <= 0) {
          timer.cancel();
          _showNotification(
            title: 'Billing Ended',
            body: 'Your billing for Order #$orderId has ended.',
            id: int.parse(orderId),
          );
        }
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            service.setForegroundNotificationInfo(
              title: 'Billing for Order #$orderId',
              content: 'Remaining Time: ${remaining.inMinutes} mins',
            );
          }
        }
      });
    });

    service.on('stopBillingTimer').listen((event) {
      service.stopSelf();
    });
  }

  Future<void> _showNotification(
      {required String title, required String body, required int id}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'open_billing_channel',
      'Open Billing Service',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id, // Use order ID as notification ID to make it unique
      title,
      body,
      platformDetails,
    );
  }
}
