import 'dart:async';
import 'dart:convert';

import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:carabaobillingapps/constant/url_constant.dart';
import 'package:carabaobillingapps/util/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _logs = [];
  bool _isSending = false;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  static const int logsPerPage = 50;
  int _currentPage = 0;
  bool _hasMoreLogs = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMoreLogs && !_isLoading) {
        _loadMoreLogs();
      }
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _logs = [];
      _currentPage = 0;
    });

    try {
      final logs = await _dbHelper.getLogs(limit: logsPerPage, offset: 0);
      setState(() {
        _logs = logs;
        _hasMoreLogs = logs.length == logsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreLogs() async {
    if (!_hasMoreLogs || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final moreLogs = await _dbHelper.getLogs(
        limit: logsPerPage,
        offset: nextPage * logsPerPage,
      );

      setState(() {
        _logs.addAll(moreLogs);
        _currentPage = nextPage;
        _hasMoreLogs = moreLogs.length == logsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading more logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendLogs() async {
    setState(() {
      _isSending = true;
    });

    try {
      // Convert logs to string format
      final logsString = _logs.map((log) => '''
Time: ${log['timestamp']}
Type: ${log['type']}
Message: ${log['message']}
-------------------------
''').join('\n');

      final response = await http.post(
        Uri.parse(UrlConstant.logs),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'logs': logsString}),
      );

      if (response.statusCode == 200) {
        // Optionally clear logs after successful upload
        await _dbHelper.clearLogs();
        await _loadLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logs sent successfully.')),
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
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _clearLogs() async {
    try {
      await _dbHelper.clearLogs();
      await _loadLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logs cleared successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing logs: $e')),
      );
    }
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.w, horizontal: 8.w),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log['type'] ?? 'UNKNOWN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.primary,
                  ),
                ),
                Text(
                  DateTime.parse(log['timestamp']).toLocal().toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    color: ColorConstant.subtext,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              log['message'] ?? '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: ColorConstant.titletext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _logs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(
                        child: Text(
                          'No logs available.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: ColorConstant.subtext,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _logs.length + (_hasMoreLogs ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _logs.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: const CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _buildLogItem(_logs[index]);
                        },
                      ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstant.primary,
                minimumSize: Size(double.infinity, 50.h),
              ),
              onPressed: _isSending ? null : _sendLogs,
              child: _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Send Logs',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
