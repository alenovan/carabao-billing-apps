import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carabaobillingapps/constant/url_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String _logContent = '';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final file = File('logs.txt');
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _logContent = content;
      });
    } else {
      setState(() {
        _logContent = 'No logs available.';
      });
    }
  }

  Future<void> _sendLogs() async {
    setState(() {
      _isSending = true;
    });

    final file = File('logs.txt');
    if (await file.exists()) {
      try {
        final logs = await file.readAsString();
        final response = await http.post(
          Uri.parse(UrlConstant.logs),
          // Replace with your API endpoint
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'logs': logs}),
        );

        if (response.statusCode == 200) {
          print('Logs uploaded successfully');
          await file
              .writeAsString(''); // Clear the file after successful upload
          _loadLogs(); // Reload logs to show the cleared state
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logs sent successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to send logs: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending logs: $e')),
        );
      }
    }

    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Viewer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _logContent,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSending ? null : _sendLogs,
              child:
                  _isSending ? CircularProgressIndicator() : Text('Send Logs'),
            ),
          ],
        ),
      ),
    );
  }
}
