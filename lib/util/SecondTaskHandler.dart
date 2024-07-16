import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class SecondTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {}

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'SecondTaskHandler',
      notificationText: timestamp.toString(),
    );

    // Send data to the main isolate.
    sendPort?.send(timestamp);
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {}
}
