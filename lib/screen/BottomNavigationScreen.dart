import 'dart:async';

import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:carabaobillingapps/constant/image_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'menu/HistoryScreen.dart';
import 'menu/HomeScreen.dart';
import 'menu/SettingScreen.dart';

class BottomNavigationScreen extends StatefulWidget {
  final int? defaultMenuIndex; // Added parameter

  const BottomNavigationScreen({super.key, this.defaultMenuIndex = 0}); // Default to 0 if null

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;
  CountdownTimer? countdownTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.defaultMenuIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);

    // Example usage of CountdownTimer
    // _setupCountdownTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    countdownTimer?.cancel(); // Cancel the timer if it's running
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorConstant.bg,
        bottomNavigationBar: _buildBottomNavigationBar(),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            HomeScreen(),
            HistoryScreen(),
            SettingScreen(),
          ],
        ),
      ),
    );
  }

  // Bottom navigation bar builder
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            spreadRadius: 2.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 56.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                _navigateToPage(0);
              },
              child: Image.asset(
                _currentIndex == 0
                    ? ImageConstant.home_selected
                    : ImageConstant.home,
                width: 45.w,
                height: 45.w,
              ),
            ),
            VerticalDivider(
              color: ColorConstant.dividermenu,
              thickness: 1.0,
              width: 20.0,
            ),
            InkWell(
              onTap: () {
                _navigateToPage(1);
              },
              child: Image.asset(
                _currentIndex == 1
                    ? ImageConstant.history_selected
                    : ImageConstant.history,
                width: 45.w,
                height: 45.w,
              ),
            ),
            VerticalDivider(
              color: ColorConstant.dividermenu,
              thickness: 1.0,
              width: 20.0,
            ),
            InkWell(
              onTap: () {
                _navigateToPage(2);
              },
              child: Image.asset(
                _currentIndex == 2
                    ? ImageConstant.setting_selected
                    : ImageConstant.setting,
                width: 45.w,
                height: 45.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation function to handle page change
  void _navigateToPage(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  // Countdown timer setup and handling
  void _setupCountdownTimer() {
    // Define the end time for the countdown (for example, 5 minutes from now)
    DateTime endTime = DateTime.now().add(Duration(minutes: 5));

    countdownTimer = CountdownTimer(
      key: "timer1",
      endTime: endTime,
      onTick: (remainingTime) {
        print('Remaining time: ${remainingTime.inMinutes}:${remainingTime.inSeconds % 60}');
        // You can update the UI or show notification here for each tick
      },
      onCountdownFinish: () {
        print("Countdown finished!");
        _showCountdownFinishedDialog();
      },
      onStart: () {
        print("Countdown started!");
      },
    );

    countdownTimer?.start();
  }

  // Show a dialog when the countdown finishes
  void _showCountdownFinishedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Countdown Finished'),
          content: Text('The countdown timer has finished.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CountdownTimer {
  final String key;
  final DateTime endTime;
  final Function(Duration) onTick;
  final Function() onCountdownFinish;
  final Function() onStart;
  late Timer _timer;

  CountdownTimer({
    required this.key,
    required this.endTime,
    required this.onTick,
    required this.onCountdownFinish,
    required this.onStart,
  });

  void start() {
    final Duration countdownDuration = endTime.difference(DateTime.now());
    onStart();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final Duration remainingTime = endTime.difference(DateTime.now());
      if (remainingTime.inSeconds <= 0) {
        _timer.cancel();
        onCountdownFinish();
      } else {
        onTick(remainingTime);
      }
    });
  }

  void cancel() {
    _timer.cancel();
  }
}
