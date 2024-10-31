import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carabaobillingapps/constant/url_constant.dart';
import 'package:carabaobillingapps/helper/shared_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constant/data_constant.dart';
import '../service/repository/RoomsRepository.dart';

const String logFilePath = 'logs.txt';

void hideKeyboard(context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void popScreen(BuildContext context, [dynamic data]) {
  Navigator.pop(context, data);
}

enum RouteTransition { slide, dualSlide, fade, material, cupertino }

Future pushScreenAndWait(BuildContext context, Widget buildScreen) async {
  await Navigator.push(
      context, CupertinoPageRoute(builder: (context) => buildScreen));
  return;
}

Future pushScreenAndWaitReplace(
    BuildContext context, Widget buildScreen) async {
  await Navigator.pushReplacement(
      context, CupertinoPageRoute(builder: (context) => buildScreen));
  return;
}

Future<Map<String, String>> tokenHeader(bool contentType) async {
  var token = await getStringValuesSF(ConstantData.token);
  var headers = {'Authorization': 'Bearer $token'};
  if (contentType) {
    headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };
  }

  return headers;
}

void switchLamp({
  required String ip,
  required String key,
  required String code,
  required String id_order,
  required bool status,
}) async {
  final startTime = DateTime.now(); // Record the start time

  try {
    // Dapatkan respons dari openRooms
    var url = ip + code + (status ? "on" : "off") + "?key=" + key;
    final response = await RoomsRepoRepositoryImpl().openRooms(url);

    final endTime = DateTime.now(); // Record the end time
    final duration =
        endTime.difference(startTime).inMilliseconds; // Calculate the duration

    // Cek apakah respons null (misalnya jika timeout)
    if (response == null) {
      print('No response received from openRooms.');
      final errorMessage = '''
Lamp Switch Error:
-------------------------
IP: $ip
Code: $code
Trigger_lamp: ${status ? 'On' : 'Off'}
Error: No response received from openRooms.
id_order: $id_order
Execution Time: ${duration}ms
-------------------------
''';
      logToFile(errorMessage);
      return;
    }

    // Ambil status code dari respons
    final statusCode = response.statusCode;

    // Ambil body dari respons sebagai string (optional)
    final statusMessage = response.body;

    final logMessage = '''
Lamp Switch Log:
-------------------------
IP: $ip
Code: $code
Trigger_lamp: ${status ? 'On' : 'Off'}
Response: $statusMessage
Status Code: $statusCode
id_order: $id_order
Execution Time: ${duration}ms
-------------------------
''';
    logToFile(logMessage);
  } catch (e) {
    final endTime = DateTime.now(); // Record the end time in case of error
    final duration =
        endTime.difference(startTime).inMilliseconds; // Calculate the duration

    final errorMessage = '''
Lamp Switch Error:
-------------------------
IP: $ip
Code: $code
Trigger_lamp: ${status ? 'On' : 'Off'}
Error: $e
id_order: $id_order
Execution Time: ${duration}ms
-------------------------
''';
    logToFile(errorMessage);
  }
}

Future<void> logToFile(String message) async {
  print(message);
  uploadLogs(message);
}

// Step 3: Function to send logs via HTTP to an API
Future<void> uploadLogs(String data) async {
  try {
    final response = await http.post(
      Uri.parse(UrlConstant.logs), // Replace with your API endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'logs': data}),
    );

    if (response.statusCode == 200) {
      print('Logs uploaded successfully');
    } else {
      print('Failed to upload logs: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading logs: $e');
  }
}

String formatDuration(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  String hoursString = hours > 0 ? '$hours Jam' : '';
  String minutesString = minutes > 0 ? ' $minutes Menit' : '';
  String secondsString = seconds > 0 ? ' $seconds Detik' : '';

  return hoursString + minutesString + secondsString;
}

String _cleanAndCapitalize(String input) {
  String cleanedType =
      input.replaceAll(RegExp(r'[^\w\s]'), ' '); // Replace symbols with spaces
  cleanedType =
      cleanedType.toLowerCase().capitalize(); // Capitalize the first letter
  return cleanedType;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String formatDateTimeWeb(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Invalid date';
  }

  // Define a custom date format
  final DateFormat formatter = DateFormat('d MMMM yyyy - HH:mm', 'id_ID');

  // Format the DateTime object
  return formatter.format(dateTime);
}

int calculateTimeDifference(String endTime) {
  DateTime now = DateTime.now();
  DateTime end = DateFormat("yyyy-MM-dd HH:mm:ss")
      .parse(endTime); // Adjust format if needed
  return now.difference(end).inMinutes.abs();
}
