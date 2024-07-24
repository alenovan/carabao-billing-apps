import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:carabaobillingapps/SplashScreen.dart';
import 'package:carabaobillingapps/helper/global_helper.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:carabaobillingapps/util/BackgroundService.dart';
import 'package:carabaobillingapps/util/DatabaseHelper.dart';
import 'package:carabaobillingapps/util/PusherForegroundService.dart';
import 'package:carabaobillingapps/util/TimerService.dart';
import 'package:carabaobillingapps/util/pusher_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'constant/url_constant.dart';
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
    WakelockPlus.enable();
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
      Duration(minutes: 1),
      0,
      backgroundTask,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
    await pusher.init(
      apiKey: "1ae635fc4ca9f011e201",
      cluster: "ap1",
    );
    final myChannel = await pusher.subscribe(
        channelName: "orders",
        onEvent: (event) async {
          try {
            final eventData = json.decode(event.data);
            final message = eventData['message'];
            final link = eventData['link'];
            print(link);
            await offLamp(link);
            await _showNotification(
              "Open - Billing",
              message,
            );
          } catch (e) {}
        });
    await pusher.connect();

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
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  TimerService.instance.startTimer();
  runApp(
    MyApp(),
  );
}

void Registerbackgroun(context) async {
  var result = await OrderRepoRepositoryImpl(context).getOrderBg();
  await saveData(result.data ?? []);
  backgroundTask(true);
}

Future<void> RegisterBackground(BuildContext context) async {
  var result = await OrderRepoRepositoryImpl(context).getOrderBg();
  await saveData(result.data ?? []);
  backgroundTask(true);
}

Future<void> _showNotification(String title, String body) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
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

Future<void> cancelNotification(int notificationId) async {
  await flutterLocalNotificationsPlugin.cancel(notificationId);
}

Future<void> stopBilling(int orderId, ip, secret, code) async {
  var apiUrl = UrlConstant.order_stop_billing;
  var apiKey = '51383db2eb3e126e52695488e0650f68ea43b4c6';

  try {
    print('Attempting to stop billing. Order ID: $orderId');
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'order_id': orderId,
        'key': apiKey,
      }),
    );

    if (response.statusCode == 200) {
      // Request was successful
      print(
          'Successfully stopped billing. Status code: ${response.statusCode}');
      switchLamp(ip: ip, key: secret, code: code, status: false);
    } else {
      print('Failed to stop billing. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error during stopBilling request: $error');
  }
}

Future<void> offLamp(link) async {
  try {
    var response = await http.post(
      Uri.parse(link),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
    } else {}
  } catch (error) {
    print('Error during stopBilling request: $error');
  }
}

Future<void> saveData(List<NewestOrder> orders) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  // Reset the existing data to null
  await _prefs.remove('orders');

  // Convert the input orders to a list of JSON objects
  List<Map<String, dynamic>> _newOrders =
      orders.map((order) => order.toJson()).toList();

  // Encode the list of new orders and save to SharedPreferences
  final String newOrdersJson = json.encode(_newOrders);
  await _prefs.setString('orders', newOrdersJson);

  // Save orders to the local database
  final dbHelper = DatabaseHelper();
  await dbHelper.deleteOrders(); // Clear existing orders
  for (var order in orders) {
    await dbHelper.insertOrder(order);
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
