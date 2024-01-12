import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:carabaobillingapps/SplashScreen.dart';
import 'package:carabaobillingapps/constant/url_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'helper/global_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Carabao Service',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
    ),
  );
}

bool stopBillingSuccess = false;

Future<void> stopBilling(int orderId) async {
  var apiUrl = UrlConstant.order_stop_table_bg;
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
      print('Successfully stopped billing. Status code: ${response.statusCode}');
      stopBillingSuccess = true;
    } else {
      // Request failed
      stopBillingSuccess = false;
      print('Failed to stop billing. Status code: ${response.statusCode}');
    }
  } catch (error) {
    // Exception occurred during the HTTP request
    stopBillingSuccess = false;
    print('Error during stopBilling request: $error');
  }
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // bring to foreground
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Fetch data from the API
        var apiUrl = UrlConstant.newest_orders_bg;
        var response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          // Parse JSON data
          var data = json.decode(response.body);
          var newestOrders = data['newestOrders'];

          // Update notifications based on the received data
          for (var order in newestOrders) {
            // Extract room details
            var roomId = order['room_id'];
            var roomName = order['name'];
            var statusOrder = order['status_order'] ?? 'No orders';
            var endTimeString = order['newest_order_end_time'];

            // Check if there is an end time specified
            if (endTimeString != null && endTimeString != 'No orders') {
              // Parse end time
              var endTime = DateTime.parse(endTimeString);

              // Calculate time difference
              var timeDifference = endTime.difference(DateTime.now());

              // Check if the end time has passed
              if (timeDifference.isNegative) {
                // Remove the notification for this room

                // Hit endpoint to stop billing
                var orderId = order['id'];
                await stopBilling(orderId);

                // Trigger switchLamp if the stopBilling request is successful
                if (stopBillingSuccess) {
                  switchLamp(order['code'], false);
                  flutterLocalNotificationsPlugin.cancel(roomId);
                }
              } else {
                // Display countdown in notification for rooms with end time
                flutterLocalNotificationsPlugin.show(
                  roomId, // Reusing the same notification id
                  'Room $roomName',
                  'Status: $statusOrder\nTime Left: ${timeDifference.inMinutes} minutes',
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      notificationChannelId,
                      'MY FOREGROUND SERVICE',
                      icon: 'ic_bg_service_small',
                      ongoing: true,
                    ),
                  ),
                );
              }
            }
          }
        } else {
          print(
              'Failed to fetch data from the API. Status code: ${response.statusCode}');
        }
      }
    }
  });
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
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.orange,
            textTheme: const TextTheme(
              bodyText2: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
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
