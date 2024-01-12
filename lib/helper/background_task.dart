import 'package:flutter_background_service/flutter_background_service.dart';

void backgroundTask() {
  FlutterBackgroundService().invoke("Start time",
    {"current_time": DateTime.now().toIso8601String()},
  );
}
