import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'SecondTaskHandler.dart';

class FirstTaskHandler extends TaskHandler {
  int _count = 1; // Start counting from 1

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {}

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    if (_count <= 100) {
      FlutterForegroundTask.updateService(
        foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000),
        notificationTitle: 'FirstTaskHandler',
        notificationText: 'Count: $_count',
      );

      // Send data to the main isolate.
      sendPort?.send(_count);

      _count++;
    } else {
      // Switch to SecondTaskHandler when count reaches 100
      FlutterForegroundTask.setTaskHandler(SecondTaskHandler());
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {}
}

@pragma('vm:entry-point')
void updateCallback() {
  FlutterForegroundTask.setTaskHandler(SecondTaskHandler());
}
