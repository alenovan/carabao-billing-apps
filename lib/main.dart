import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:carabaobillingapps/SplashScreen.dart';
import 'package:carabaobillingapps/helper/global_helper.dart';
import 'package:carabaobillingapps/screen/BottomNavigationScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constant/url_constant.dart';

late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool enableFetch = true;
Timer? fetchTimer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

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

Future<void> stopBilling(int orderId, ip, secret, code) async {
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
      print(
          'Successfully stopped billing. Status code: ${response.statusCode}');
      switchLamp(ip: ip, key: secret, code: code, status: false);
    } else {
      print('Failed to stop billing. Status code: ${response.statusCode}');
    }
    await removeOrderFromPrefs(orderId.toString());
  } catch (error) {
    print('Error during stopBilling request: $error');
  }
}

Future<void> initPrefs() async {
  List<Map<String, dynamic>> _orders = [];
  SharedPreferences? _prefs = await SharedPreferences.getInstance();
// Load orders from SharedPreferences
  final String? ordersJson = _prefs!.getString('orders');
  if (ordersJson != null) {
    _orders = List<Map<String, dynamic>>.from(json.decode(ordersJson));
  }
  final List<Map<String, dynamic>> startOrders =
      _orders.where((order) => order['status_order'] == 'START').toList();
  // print(startOrders);
  startOrders.forEach((order) => startCountdown(order));
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // Set initial value to true to allow fetching data

  // Start a periodic timer to execute the fetch logic
  fetchTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
    // Only execute the fetch logic if enableFetch is true
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        try {
          await initPrefs();
        } catch (e) {}
      }
    }
  });
}

void startCountdown(Map<String, dynamic> order) {
  late CountdownTimer _countdownTimer;
  final DateTime endTime = DateTime.parse(order['newest_order_end_time']);
  final String orderId = order['id'].toString();

  _countdownTimer = CountdownTimer(
    key: orderId,
    endTime: endTime,
    onTick: (Duration duration) {
      final String formattedTime =
          '${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}';
      showNotification(orderId, formattedTime, order['name'].toString());
    },
    onCountdownFinish: () async{
      stopBilling(order['id'], order['ip'].toString(),
          order['secret'].toString(), order['code'].toString());
      removeNotification(orderId);
    },
  );
  _countdownTimer.start();
}

Future<void> removeNotification(String orderId) async {
  await _flutterLocalNotificationsPlugin.cancel(int.parse(orderId));

}

Future<void> removeOrderFromPrefs(String orderId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Map<String, dynamic>> orders = [];

  // Load orders from SharedPreferences
  final String? ordersJson = prefs.getString('orders');
  if (ordersJson != null) {
    orders = List<Map<String, dynamic>>.from(json.decode(ordersJson));
  }

  // Remove the order from the list
  orders.removeWhere((order) => order['id'] == orderId);
  // Save updated orders back to SharedPreferences
  print(orders);
  await prefs.setString('orders', jsonEncode(orders));
}

Future<void> showNotification(
  String orderId,
  String timeRemaining,
  String name,
) async {


  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'countdown_channel',
    'Countdown Channel',
    importance: Importance.high,
    playSound: false, // Disable sound
    enableVibration: false,
    enableLights: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await _flutterLocalNotificationsPlugin.show(
    int.parse(orderId),
    'Countdown ${name}',
    'Time remaining: $timeRemaining',
    platformChannelSpecifics,
  );
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
