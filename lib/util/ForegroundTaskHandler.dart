import 'dart:async';
import 'dart:isolate';

import 'package:carabaobillingapps/util/BackgroundService.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

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
      backgroundTask(true);
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onRepeatEvent
    _sendPort?.send(timestamp);
    backgroundTask(true);
  }
}
